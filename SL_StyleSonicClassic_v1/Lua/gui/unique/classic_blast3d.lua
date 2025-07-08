--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local nametrim = tbsrequire 'helpers/string_trimnames'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local textlen = drawlib.text_lenght
local fontlen = drawlib.lenght

local clamping = tbsrequire 'helpers/anim_clamp'

local tryx, tryy = 0, 0

return{

	titlecard = function(v, p, t, e, bfade)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local lvlt = string.upper(nametrim(""..mapheaderinfo[gamemap].lvlttl))
		local act = tostring(mapheaderinfo[gamemap].actnum)
		--local scale = FU
		local offset = (#lvlt)*FU

		local isSpecialStage = G_IsSpecialStage(gamemap)
		local fade = isSpecialStage and 0xFB00 or (bfade and 0xFA00 or 0xFF00)
		local translation = isSpecialStage and "SPECIALSTAGE_SONIC3_TITLE" or nil
		local titlelenm = textlen(v, 'S3BTFNT', lvlt, 0)

		if t and t <= e then
			local easet = clamping(0, t, TICRATE/3) - clamping(e-TICRATE/3, t, e)

			tryx = ease.linear(easet, 200*FU, 0)
			tryy = -tryx

			if act ~= "0" and titlelenm then
				v.draw(303-titlelenm-offset*3/FU, 112+tryy/FU, v.cachePatch('S3BTFNTACT'), 0)
				drawf(v, 'S3BTFNT', (331-titlelenm)*FU-offset*3, 97*FU+tryy, FU, act, 0, v.getColormap(TC_DEFAULT, 1))
			end

			if p.styles_entercut_timer == nil then

				if t and t <= 3*TICRATE/2 then
					v.fadeScreen(fade, 31)
				elseif t <= TICRATE+31 and t > TICRATE then
					v.fadeScreen(fade, 31-(t-TICRATE))
				end
			end

			---@diagnostic disable-next-line			
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				drawf(v, 'S3BTFNT', (262-titlelenm)*FU-tryx-offset*3, 90*FU, FU, "ZONE", 0, v.getColormap(TC_DEFAULT, 1, translation), "left")
			end

			v.drawString(175, 158, mapheaderinfo[gamemap].subttl, 0|V_ALLOWLOWERCASE, "center")
			drawf(v, 'S3BTFNT', 262*FU+tryx-offset*3, 72*FU, FU, lvlt, 0, v.getColormap(TC_DEFAULT, 1, translation), "right")

			return true
		end
	end,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x, colorprofile, overwrite, lifepos)
		if p and p.mo then

			local lives_f = hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x
			local lives_y = hudinfo[HUD_LIVES].y

			if lifepos > 1 then
				lives_f = ($|V_SNAPTORIGHT|V_SNAPTOTOP) &~ (V_SNAPTOLEFT|V_SNAPTOBOTTOM)
				lives_x = 281-hudinfo[HUD_LIVES].x-hide_offset_x
				lives_y = 184-hudinfo[HUD_LIVES].y
			end

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_B3DLIFE_"..skin_name
			local patch_s_name = "STYLES_SB3DLIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, 	lives_y+11, v.cachePatch(patch_s_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, 	lives_y+11, v.cachePatch(patch_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				v.draw(lives_x, 	lives_y-1, v.cachePatch('3BLIVBLANK1'), lives_f)
				v.draw(lives_x+8, 	lives_y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_DEFAULT, p.mo.color))
				v.draw(lives_x, 	lives_y-1, v.cachePatch('3BLIVBLANK2'), lives_f)
			end

			if G_GametypeUsesLives() then
				drawf(v, prefix..'TNUM', (lives_x+18)*FU, (lives_y+1)*FU, FU, 'X'..p.lives, lives_f, colorprofile, "left")
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(lives_x+22, lives_y, v.cachePatch('CLASSICIT'), lives_f)
			end
		end
	end,

	tallytitle = function(v, p, offsetx, color, overwrite)
		local mo = p.mo
		local act = tostring(mapheaderinfo[gamemap].actnum)

		if mo then
			local skin_name = nametrim(skins[mo.skin].realname)
			drawf(v, 'S3BTFNT', (96-offsetx)*FU, 48*FU, FU, string.upper((overwrite and overwrite or skin_name).." got"))
		else
			drawf(v, 'S3BTFNT', (72-offsetx)*FU, 48*FU, FU, "YOU GOT")
		end

		local gotthrough = "THROUGH "

		---@diagnostic disable-next-line
		if (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
			gotthrough = $..'ZONE'
		else
			gotthrough = $..'ACT'
		end

		drawf(v, 'S3BTFNT', (72-offsetx)*FU, 66*FU, FU, gotthrough)

		-- TODO: Check for level long (ZONE) in S3K and 3D Blast
		if act ~= "0" then
			drawf(v, 'S3BTFNT', (200-offsetx)*FU, 72*FU, FU, act, 0, v.getColormap(TC_DEFAULT, 1))
		end
	end,

	tallyspecial = function(v, p, offsetx, color, color2)
		local mo = p.mo
		local act = tostring(mapheaderinfo[gamemap].actnum)

		local str = "CHAOS EMERALDS"

		if emeralds == All7Emeralds(emeralds) then
			str = " GOT THEM ALL"

			if mo then
				str = string.upper(mo.skin)..str
			else
				str = "YOU"..str
			end
		end

		drawf(v, 'S3BTFNT', 160*FU, 48*FU, FU, str, 0, v.getColormap(TC_DEFAULT, 0, "SPECIALSTAGE_SONIC3DB_TALLY"), "center")
	end,

	tallybg = function(v, p, offsetx, color, color2, fading)
		v.fadeScreen(156, max(min(fading*10/15, 10), 0))
	end,
}

