--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local nametrim = tbsrequire 'helpers/string_trimnames'
local maniacircles = tbsrequire 'helpers/draw_maniacircles'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local fillstretch = tbsrequire 'helpers/draw_stretchmiddley'
local cuttriangle = tbsrequire 'helpers/draw_cuttrianglebg'
local tiltedlines = tbsrequire 'helpers/draw_tiltedlines'
local clamping = tbsrequire 'helpers/anim_clamp'
local circles = tbsrequire 'helpers/draw_circle'
local drawf = drawlib.draw
local drawanim = drawlib.drawanim
local textlen = drawlib.text_lenght

local pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}

local title_lenght = FU/6
local title_delay1 = 2 * title_lenght
local title_delay2 = title_delay1*2
local title_delay3 = title_delay1*3
local title_delay4 = title_delay1*4

local titlebgpullaway = 2*TICRATE-TICRATE/2
local titlebgpullstep = FU/10

local tiltappear = TICRATE/9+16
local tiltdelay1 = 2
local tiltdelay2 = 4
local tiltdelay3 = 6

local tiltdissappear = 2*TICRATE+TICRATE/6

local initblocks = 0
local tiltdelay1 = 2
local tiltdelay2 = 4
local tiltdelay3 = 6

local tryx, tryy = 0, 0

local moveoffset = 4+8

local function G_EncoreModeColors()
	---@diagnostic disable-next-line
	if constants["GT_ENCORE"] then -- Would use GT_ENCORE, thing just doesn't responds.
		return {true, 124, 135, 137, 51, 213}
	end

	return {false, 65, 34, 53, 136, 123}
end

local function drawTextBG(v, x, y, width, flags)
	local nwidth = max(0, width)
	local corner1 = v.cachePatch("INTMASKEW1")
	local corner2 = v.cachePatch("INTMASKEW2")

	v.draw(x - corner1.width, y, corner1, flags)
	v.drawFill(x, y, nwidth, 17, 31|flags)
	v.draw(x + nwidth, y, corner2, flags)
end

local function drawTextBG_A(v, x, y, width, flags)
	drawTextBG(v, x, y + 17, width, flags)
end


local function exprs(t, s, e, p)
	return ease.linear(t, s, e) + ease.outsine(clamping(0, t-FU/2, FU/4), 0, p) - ease.outsine(clamping(0, t-3*FU/4, FU/4), 0, p)
end

local function drawManiaTitleTextSymbol1(v, x, y, scale, patch, flags, color, i, progress)
	local jump = exprs(progress, y+patch.height*scale, y, -patch.height*scale)
	local cuts = patch.height*scale-min(max(jump-y, 0), patch.height*scale)

	v.drawCropped(x, jump, scale, scale, patch, flags, color, 0, 0, 128*FU, cuts or 1)
end

local function drawManiaTitleTextSymbol2(v, x, y, scale, patch, flags, color, i, progress)
	local jump = exprs(progress, y-15*scale, y, patch.height*scale)
	local cuts = abs(min(jump-y, 0))

	v.drawCropped(x, jump, scale, scale, patch, flags, color, 0, cuts, 128*FU, 128*FU)
end

local function drawManiaTitleTextSymbol3(v, x, y, scale, patch, flags, color, i, progress)
	v.drawStretched(x, y, FixedMul(scale, progress), scale, patch, flags, color)
end


local function lifeicon(v, lives_x, lives_y, lives_scale, lives_f, p)
	local skin_name = string.upper(skins[p.mo.skin].name)
	local patch_name = "STYLES_MALIFE_"..skin_name
	local patch_s_name = "STYLES_SMALIFE_"..skin_name

	if v.patchExists(patch_s_name) and p.powers[pw_super] then
		v.draw(lives_x+9, lives_y+11, v.cachePatch(patch_s_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
	elseif v.patchExists(patch_name) then
		v.draw(lives_x+9, lives_y+11, v.cachePatch(patch_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
	else
		v.draw((lives_x+9), (lives_y+13), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
		for i = 1, 4 do
			v.draw((lives_x+9+pos[i][1]), (lives_y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_ALLWHITE))
		end

		v.draw(lives_x+9, lives_y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_DEFAULT, p.mo.color))
	end
end

return {

	titlecard = function(v, p, t, e, bfade)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local colors = G_EncoreModeColors()

		local lvlt = string.upper(nametrim(""..mapheaderinfo[gamemap].lvlttl))
		local act = tostring(mapheaderinfo[gamemap].actnum)
		--local scale = FU
		local offset = (#lvlt)*FU
		if t < 2 then
			tryx = (200*FU)
			tryy = -(200*FU)
		end

		local isSpecialStage = G_IsSpecialStage(gamemap)
		local fade = isSpecialStage and 0xFB00 or (bfade and 0xFA00 or 0xFF00)
		local translation = isSpecialStage and "SPECIALSTAGE_SONIC3_TITLE" or nil
		local special_gp = isSpecialStage and 'S3KTTCARDSS' or 'S3KTTCARD'

		if t and t <= 3*TICRATE then
			local scale = v.dupx()
			local intwidth = v.width() / scale

			if p.styles_entercut_timer == nil then

				if t <= TICRATE/8 then
					v.fadeScreen(fade, 31)
				end

				local progress = title_lenght * (t - TICRATE/9)

				if t <= titlebgpullaway then
					local check = progress - title_delay4

					if check < FU then
						fillstretch(v, 100, progress, colors[5])
						fillstretch(v, 100, progress - title_delay1, colors[4])
						fillstretch(v, 100, progress - title_delay2, 51)
						fillstretch(v, 100, progress - title_delay3, colors[6])
					end

					fillstretch(v, 100, progress - title_delay4, colors[2])

					---@diagnostic disable-next-line
					local line_1_x = ease.linear(clamping(0, t-9, 9), -intwidth/2, intwidth+intwidth/2)

					if line_1_x ~= intwidth+intwidth/2 then
						v.drawFill(line_1_x, 169, 130, 9, 1|V_SNAPTOLEFT)
						v.drawFill(intwidth-line_1_x, 137, 112, 17, 31|V_SNAPTOLEFT)
					end
				else
					cuttriangle(v, 160, (t - titlebgpullaway) * titlebgpullstep, colors[2])
				end
			end

			if t > tiltappear then
				local progress1 = clamping(tiltappear, t, tiltappear+10)
				local progress2 = clamping(tiltappear, t-tiltdelay1, tiltappear+10)
				local progress3 = clamping(tiltappear, t-tiltdelay2, tiltappear+10)
				local progress4 = clamping(tiltappear, t-tiltdelay3, tiltappear+10)

				local progress5 = clamping(tiltdissappear, t, tiltdissappear+10)
				local progress6 = clamping(tiltdissappear, t-tiltdelay1, tiltdissappear+10)
				local progress7 = clamping(tiltdissappear, t-tiltdelay2, tiltdissappear+10)
				local progress8 = clamping(tiltdissappear, t-tiltdelay3, tiltdissappear+10)

				local scale = v.dupx()
				local intheight = v.height() / scale

				---@diagnostic disable-next-line
				local offy1 = ease.outsine(progress1, intheight, 0) + ease.outsine(progress5, 0, 	-intheight*2) - 100

				---@diagnostic disable-next-line
				local offy2 = ease.outsine(progress2, intheight, 0) + ease.outsine(progress6, 0, 	-intheight*2) + 74

				---@diagnostic disable-next-line
				local offy3 = ease.outsine(progress3, intheight, 0) + ease.outsine(progress7, 0, 	-intheight*2) + 121

				---@diagnostic disable-next-line
				local offy4 = ease.outsine(progress4, intheight, 0) + ease.outsine(progress8, 0, 	-intheight*2) + 112

				tiltedlines(v, 160-64,  	offy2, 	offy2+150, 82,  colors[4])
				tiltedlines(v, 160-106, 	offy3, 	offy3+171, 128, colors[3])
				tiltedlines(v, 160+46,      offy4, 	offy4+142, 28,  colors[6])

				tiltedlines(v, 160,     	offy1, 	offy1+350, 64,  colors[5])

				local progress9 = clamping(tiltappear+4, t-tiltdelay3, tiltappear+8)
				--local progress10 = clamping(tiltappear+20, t-tiltdelay3, tiltappear+50)
				local progress11 = clamping(tiltdissappear+10, t-tiltdelay3, tiltdissappear+20)
				--local progress12 = clamping(tiltdissappear+10, t-tiltdelay3, tiltdissappear+20)

				local nw_x = ease.outsine(progress9, -400, 0) + ease.outsine(progress11, 0, 400)

				local zonepatch = v.cachePatch("INTMABGZONE")

				local text_width = textlen(v, 'MATTFNT', lvlt, 0)

				local progresstext = clamping(tiltappear+11, t-tiltdelay3, tiltappear+61)-1

				local encore = colors[1] and "E" or ""

				---@diagnostic disable-next-line
				if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
					v.draw(229-nw_x-zonepatch.width, 169, v.cachePatch("INTMABGZONE"))

					if progresstext > 0 then
						drawanim(v, 'MAZNFNT', (242-nw_x-zonepatch.width)*FU, 159*FU, FU, "ZONE", 0, v.getColormap(TC_DEFAULT, 1), "left", 0, 0, 0, progresstext, drawManiaTitleTextSymbol2, 7*FU/10)
					end
				end

				drawTextBG(v, 210+nw_x-text_width, 137, text_width)
				drawanim(v, 'MATTFNT', (210+nw_x-text_width)*FU, 120*FU, FU, lvlt, 0, v.getColormap(TC_DEFAULT, 1), "left", 0, 0, 0, progresstext, drawManiaTitleTextSymbol1, 7*FU/10)

				if act ~= "0" then
					local actcircleimg = v.cachePatch("INTMACIRC"..encore)
					local actcircle = clamping(FU/8, progresstext + 1, 2*FU/8) - 1
					local centering = FixedMul(actcircleimg.width/2*FU, FU-actcircle)

					local act_x = (238+nw_x/4)*FU+centering
					local act_y = (119+nw_x/4)*FU

					if actcircle > 0 then
						v.drawStretched(act_x, act_y, actcircle, FU, actcircleimg, 0, nil)

						if tonumber(act) > 9 then
							drawanim(v, 'MAN2FNT', act_x+31*FU-centering, act_y+8*FU, FU, act, 0, v.getColormap(TC_DEFAULT, 1), "center", 0, 0, 0, actcircle, drawManiaTitleTextSymbol3, FU)
						else
							drawanim(v, 'MAN1FNT', act_x+31*FU-centering, act_y+8*FU, FU, act, 0, v.getColormap(TC_DEFAULT, 1), "center", 0, 0, 0, actcircle, drawManiaTitleTextSymbol3, FU)
						end
					end
				end

				v.drawString(175, 192, mapheaderinfo[gamemap].subttl, 0|V_ALLOWLOWERCASE, "center")
			end

			return true
		end
	end,

	playericon = lifeicon,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x, colorprofile, overwrite, lifepos, colorprofile2)
		if p and p.mo then
			local lives_f = hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x
			local lives_y = hudinfo[HUD_LIVES].y

			if lifepos > 1 then
				lives_f = ($|V_SNAPTORIGHT|V_SNAPTOTOP) &~ (V_SNAPTOLEFT|V_SNAPTOBOTTOM)
				lives_x = 281-hudinfo[HUD_LIVES].x-hide_offset_x
				lives_y = 184-hudinfo[HUD_LIVES].y
			end

			lifeicon(v, lives_x, lives_y, FU, lives_f, p)

			if G_GametypeUsesLives() then
				local lives = p.lives

				if lives == INFLIVES then
					lives = "I"
				end

				drawf(v, prefix..'TNUM', (lives_x+21)*FU, (lives_y+2)*FU, FU, 'X'..lives, lives_f, colorprofile2, "left")
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(lives_x+22, lives_y, v.cachePatch('CLASSICIT'), lives_f)
			end
		end
	end,

	tallytitle = function(v, p, offsetx, color, overwrite)
		local mo = p.mo

		local lvlt = string.upper(nametrim(""..mapheaderinfo[gamemap].lvlttl))
		local act = tostring(mapheaderinfo[gamemap].actnum)

		--TODO: Actual intermission from Mania
		--local colors = G_EncoreModeColors()
		--local encore = colors[1] and "E" or ""

		local gotthrough = "THROUGH"

		if act ~= "0" then
			local act_x = (210+offsetx)*FU
			local act_y = 43*FU

			local text_width = textlen(v, 'MATAFNT', "GOT", 1)
			local text_width2 = textlen(v, 'MATAFNT', gotthrough, 1)

			drawTextBG_A(v, 197-offsetx-text_width2, 41, text_width2 + 20, V_PERPLAYER)
			drawTextBG_A(v, 217-offsetx-text_width2, 64, text_width2 + 31, V_PERPLAYER)

			local colors = G_EncoreModeColors()

			if colors[1] then
				if tonumber(act) > 9 then
					drawf(v, 'MAI4FNT', act_x+31*FU, act_y+8*FU, FU, act, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "center", 1)
				else
					drawf(v, 'MAI3FNT', act_x+31*FU, act_y+8*FU, FU, act, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "center")
				end
			else
				if tonumber(act) > 9 then
					drawf(v, 'MAI2FNT', act_x+31*FU, act_y+8*FU, FU, act, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "center", 1)
				else
					drawf(v, 'MAI1FNT', act_x+31*FU, act_y+8*FU, FU, act, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "center")
				end
			end

			drawf(v, "MATAFNT", (166-offsetx)*FU, 54*FU, FU, "GOT", V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "INTERMISSION_FONT_MANIA"), "left", 1)
			drawf(v, "MATAFNT", (166+text_width-offsetx)*FU, 77*FU, FU, gotthrough, V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "INTERMISSION_FONT_MANIA"), "right", 1)
		else
			---@diagnostic disable-next-line
			if (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				gotthrough = $..' ZONE'
			else
				gotthrough = $..' ACT'
			end

			local text_width = textlen(v, 'MATAFNT', "GOT", 1)
			local text_width2 = textlen(v, 'MATAFNT', gotthrough, 1)

			drawTextBG_A(v, 197-offsetx-text_width2, 41, text_width2 + 20, V_PERPLAYER)
			drawTextBG_A(v, 217-offsetx-text_width2, 64, text_width2 + 31, V_PERPLAYER)

			drawf(v, "MATAFNT", (166-offsetx)*FU, 54*FU, FU, "GOT", V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "INTERMISSION_FONT_MANIA"), "left")
			drawf(v, "MATAFNT", (200+text_width-offsetx)*FU, 77*FU, FU, gotthrough, V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "INTERMISSION_FONT_MANIA"), "right", 1)
		end

		if mo and mo.valid then
			local skin = skins[p.mo.skin or p.skin]

			local skin_name = nametrim(string.upper(overwrite and overwrite or skin.realname))
			local color_2 = v.getColormap(TC_DEFAULT, skin.prefcolor)

			drawf(v, "MATAFNT", (158-offsetx)*FU, 54*FU, FU, skin_name, V_PERPLAYER, color_2, "right", 1)
		else
			local skin_name = "YOU"
			local color_1 = v.getColormap(TC_DEFAULT, SKINCOLOR_BLACK)

			drawf(v, "MATAFNT", (158-offsetx)*FU, 54*FU, FU, skin_name, V_PERPLAYER, color_1, "right", 1)
		end
	end,

	tallyspecial = function(v, p, offsetx, color, color2)
		local mo = p.mo
		local str = "CHAOS EMERALDS"

		if emeralds == All7Emeralds(emeralds) then
			str = " GOT THEM ALL"

			if mo then
				str = string.upper(nametrim(mo.skin))..str
			else
				str = "YOU"..str
			end
		end

		local len = textlen(v, 'MATAFNT', str, 1)

		drawTextBG_A(v, 160-offsetx-len/2, 40, len, V_PERPLAYER)
		drawf(v, "MATAFNT", (160-offsetx)*FU, 48*FU, FU, str, V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "INTERMISSION_FONT_MANIA"), "center", 1)
	end,

	tallyspecialbg = function(v, p, offsetx, color, color2, fading)
		local colors = G_EncoreModeColors()

		v.fadeScreen(colors[2], max(min(fading*10/15, 10), 0))
		local angle = leveltime*ANG1

		---@cast angle angle_t
		maniacircles(v, 160, 100, (sin(angle)*60)/FU+100, angle+ANGLE_180, colors[4], colors[4])
		maniacircles(v, 160, 100, (cos(angle)*60)/FU+100, angle, colors[5], colors[2])
	end,
}

