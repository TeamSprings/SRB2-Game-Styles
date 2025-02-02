--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local fillstretch = tbsrequire 'helpers/draw_stretchmiddley'
local cuttriangle = tbsrequire 'helpers/draw_cuttrianglebg'
local tiltedlines = tbsrequire 'helpers/draw_tiltedlines'
local clamping = tbsrequire 'helpers/anim_clamp'
local drawf = drawlib.draw
local drawanim = drawlib.drawanim
local textlen = drawlib.text_lenght
local fontlen = drawlib.lenght

local pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}

local title_lenght = FRACUNIT/6
local title_delay1 = 2 * title_lenght
local title_delay2 = title_delay1*2
local title_delay3 = title_delay1*3
local title_delay4 = title_delay1*4

local titlebgpullaway = 2*TICRATE-TICRATE/2
local titlebgpullstep = FRACUNIT/10

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

local function drawTextBG(v, x, y, width)
	local nwidth = max(0, width)
	local corner1 = v.cachePatch("INTMASKEW1")
	local corner2 = v.cachePatch("INTMASKEW2")

	v.draw(x - corner1.width, y, corner1, 0)
	v.drawFill(x, y, nwidth, 17, 31)
	v.draw(x + nwidth, y, corner2, 0)
end

local function exprs(t, s, e, p)
	return ease.linear(t, s, e) + ease.outsine(clamping(0, t-FRACUNIT/2, FRACUNIT/4), 0, p) - ease.outsine(clamping(0, t-3*FRACUNIT/4, FRACUNIT/4), 0, p)
end

local function drawManiaTitleTextSymbol1(v, x, y, scale, patch, flags, color, i, progress)
	local jump = exprs(progress, y+patch.height*scale, y, -patch.height*scale)
	local cuts = patch.height*scale-min(max(jump-y, 0), patch.height*scale)

	v.drawCropped(x, jump, scale, scale, patch, flags, color, 0, 0, 128*FRACUNIT, cuts or 1)
end

local function drawManiaTitleTextSymbol2(v, x, y, scale, patch, flags, color, i, progress)
	local jump = exprs(progress, y-15*scale, y, patch.height*scale)
	local cuts = abs(min(jump-y, 0))

	v.drawCropped(x, jump, scale, scale, patch, flags, color, 0, cuts, 128*FRACUNIT, 128*FRACUNIT)
end

local function drawManiaTitleTextSymbol3(v, x, y, scale, patch, flags, color, i, progress)
	v.drawStretched(x, y, FixedMul(scale, progress), scale, patch, flags, color)
end

return {

	titlecard = function(v, p, t, e, bfade)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local lvlt = string.upper(""..mapheaderinfo[gamemap].lvlttl)
		local act = tostring(mapheaderinfo[gamemap].actnum)
		--local scale = FRACUNIT
		local offset = (#lvlt)*FRACUNIT
		if t < 2 then
			tryx = (200*FRACUNIT)
			tryy = -(200*FRACUNIT)
		end

		local isSpecialStage = G_IsSpecialStage(gamemap)
		local fade = isSpecialStage and 0xFB00 or (bfade and 0xFA00 or 0xFF00)
		local translation = isSpecialStage and "SPECIALSTAGE_SONIC3_TITLE" or nil
		local special_gp = isSpecialStage and 'S3KTTCARDSS' or 'S3KTTCARD'

		if t and t <= 3*TICRATE then
			local scale = v.dupx()
			local intwidth = v.width() / scale

			if t <= TICRATE/8 then
				v.fadeScreen(fade, 31)
			end

			local progress = title_lenght * (t - TICRATE/9)

			if t <= titlebgpullaway then
				local check = progress - title_delay4

				if check < FRACUNIT then
					fillstretch(v, 100, progress, 136)
					fillstretch(v, 100, progress - title_delay1, 53)
					fillstretch(v, 100, progress - title_delay2, 51)
					fillstretch(v, 100, progress - title_delay3, 123)
				end

				fillstretch(v, 100, progress - title_delay4, 65)

				local line_1_x = ease.linear(clamping(0, t-9, 9), -intwidth/2, intwidth+intwidth/2)

				if line_1_x ~= intwidth+intwidth/2 then
					v.drawFill(line_1_x, 169, 130, 9, 1|V_SNAPTOLEFT)
					v.drawFill(intwidth-line_1_x, 137, 112, 17, 31|V_SNAPTOLEFT)
				end
			else
				cuttriangle(v, 160, (t - titlebgpullaway) * titlebgpullstep, 65)
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

				local offy1 = ease.outsine(progress1, intheight, 0) + ease.outsine(progress5, 0, 	-intheight*2) - 100
				local offy2 = ease.outsine(progress2, intheight, 0) + ease.outsine(progress6, 0, 	-intheight*2) + 74
				local offy3 = ease.outsine(progress3, intheight, 0) + ease.outsine(progress7, 0, 	-intheight*2) + 121
				local offy4 = ease.outsine(progress4, intheight, 0) + ease.outsine(progress8, 0, 	-intheight*2) + 112

				tiltedlines(v, 160-64,  	offy2, 	offy2+150, 82, 53)
				tiltedlines(v, 160-106, 	offy3, 	offy3+171, 128, 34)
				tiltedlines(v, 160+46,      offy4, 	offy4+142, 28, 123)

				tiltedlines(v, 160,     	offy1, 	offy1+350, 64, 136)

				local progress9 = clamping(tiltappear+4, t-tiltdelay3, tiltappear+8)
				local progress10 = clamping(tiltappear+20, t-tiltdelay3, tiltappear+50)
				local progress11 = clamping(tiltdissappear+10, t-tiltdelay3, tiltdissappear+20)
				local progress12 = clamping(tiltdissappear+10, t-tiltdelay3, tiltdissappear+20)

				local nw_x = ease.outsine(progress9, -400, 0) + ease.outsine(progress11, 0, 400)

				local zonepatch = v.cachePatch("INTMABGZONE")

				local text_width = textlen(v, 'MATTFNT', lvlt, 0)

				local progresstext = clamping(tiltappear+11, t-tiltdelay3, tiltappear+61)-1

				if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
					v.draw(229-nw_x-zonepatch.width, 169, v.cachePatch("INTMABGZONE"))

					if progresstext > 0 then
						drawanim(v, 'MAZNFNT', (242-nw_x-zonepatch.width)*FRACUNIT, 159*FRACUNIT, FRACUNIT, "ZONE", 0, v.getColormap(TC_DEFAULT, 1), "left", 0, 0, 0, progresstext, drawManiaTitleTextSymbol2, 7*FRACUNIT/10)
					end
				end

				drawTextBG(v, 210+nw_x-text_width, 137, text_width)
				drawanim(v, 'MATTFNT', (210+nw_x-text_width)*FRACUNIT, 120*FRACUNIT, FRACUNIT, lvlt, 0, v.getColormap(TC_DEFAULT, 1), "left", 0, 0, 0, progresstext, drawManiaTitleTextSymbol1, 7*FRACUNIT/10)

				if act ~= "0" then
					local actcircleimg = v.cachePatch("INTMACIRC")
					local actcircle = clamping(FRACUNIT/8, progresstext + 1, 2*FRACUNIT/8) - 1
					local centering = FixedMul(actcircleimg.width/2*FRACUNIT, FRACUNIT-actcircle)

					local act_x = (238+nw_x/4)*FRACUNIT+centering
					local act_y = (119+nw_x/4)*FRACUNIT

					if actcircle > 0 then
						v.drawStretched(act_x, act_y, actcircle, FRACUNIT, actcircleimg, 0, nil)

						if tonumber(act) > 9 then
							drawanim(v, 'MAN2FNT', act_x+31*FRACUNIT-centering, act_y+8*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1), "center", 0, 0, 0, actcircle, drawManiaTitleTextSymbol3, FRACUNIT)
						else
							drawanim(v, 'MAN1FNT', act_x+31*FRACUNIT-centering, act_y+8*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1), "center", 0, 0, 0, actcircle, drawManiaTitleTextSymbol3, FRACUNIT)
						end
					end
				end

				v.drawString(175, 192, mapheaderinfo[gamemap].subttl, 0|V_ALLOWLOWERCASE, "center")
			end

			return true
		end
	end,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x)
		if p and p.mo then
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_MALIFE_"..skin_name
			local patch_s_name = "STYLES_SMALIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.cachePatch(patch_s_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.cachePatch(patch_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				v.draw((lives_x+10), (hudinfo[HUD_LIVES].y+13), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
				for i = 1, 4 do
					v.draw((lives_x+8+pos[i][1]), (hudinfo[HUD_LIVES].y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_ALLWHITE))
				end

				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_DEFAULT, p.mo.color))
			end

			if G_GametypeUsesLives() then
				drawf(v, 'MATNUM', (lives_x+21)*FRACUNIT, (hudinfo[HUD_LIVES].y+2)*FRACUNIT, FRACUNIT, 'X'..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1), "left")
			end
		end
	end,

	tallytitle = function(v, p, offsetx)
		local mo = p.mo

		local lvlt = string.upper(""..mapheaderinfo[gamemap].lvlttl)
		local act = tostring(mapheaderinfo[gamemap].actnum)

		if mo and mo.valid then
			local skin = skins[p.mo.skin or p.skin]

			local skin_name = string.gsub(string.upper(skin.realname), "%d", "")
			local color_2 = v.getColormap(TC_DEFAULT, skin.prefcolor)

			drawf(v, "MATAFNT", (158-offsetx)*FRACUNIT, 54*FRACUNIT, FRACUNIT, skin_name, 0, color_2, "right", 1)
		else
			local skin_name = "YOU"
			local color_1 = v.getColormap(TC_DEFAULT, SKINCOLOR_BLACK)

			drawf(v, "MATAFNT", (158-offsetx)*FRACUNIT, 54*FRACUNIT, FRACUNIT, skin_name, 0, color1, "right", 1)
		end

		local gotthrough = "THROUGH"

		if act ~= "0" then
			local act_x = (210+offsetx)*FRACUNIT
			local act_y = 43*FRACUNIT

			if tonumber(act) > 9 then
				drawf(v, 'MAN2FNT', act_x+31*FRACUNIT, act_y+8*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1), "center", 1)
			else
				drawf(v, 'MAN1FNT', act_x+31*FRACUNIT, act_y+8*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1), "center")
			end

			local text_width = textlen(v, 'MATAFNT', "GOT", 1)
			drawf(v, "MATAFNT", (166-offsetx)*FRACUNIT, 54*FRACUNIT, FRACUNIT, "GOT", 0, v.getColormap(TC_DEFAULT, SKINCOLOR_GREY), "left", 1)
			drawf(v, "MATAFNT", (166+text_width-offsetx)*FRACUNIT, 77*FRACUNIT, FRACUNIT, gotthrough, 0, v.getColormap(TC_DEFAULT, SKINCOLOR_GREY), "right", 1)
		else
			if (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				gotthrough = $..' ZONE'
			else
				gotthrough = $..' ACT'
			end

			drawf(v, "MATAFNT", (166-offsetx)*FRACUNIT, 54*FRACUNIT, FRACUNIT, "GOT", 0, v.getColormap(TC_DEFAULT, SKINCOLOR_GREY), "left")
			drawf(v, "MATAFNT", (166+text_width-offsetx)*FRACUNIT, 77*FRACUNIT, FRACUNIT, gotthrough, 0, v.getColormap(TC_DEFAULT, SKINCOLOR_GREY), "right", 1)
		end
	end,

	tallyspecial = function(v, p, offsetx, color, color2)
		local mo = p.mo
		local str = "CHAOS EMERALDS"

		if emeralds == All7Emeralds(emeralds) then
			str = " GOT THEM ALL"

			if mo then
				str = string.upper(mo.skin)..str
			else
				str = "YOU"..str
			end
		end

		drawf(v, "MATAFNT", (160-offsetx)*FRACUNIT, 48*FRACUNIT, FRACUNIT, str, 0, v.getColormap(TC_DEFAULT, SKINCOLOR_BLUE), "center", 1)
	end,
}

