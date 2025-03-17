--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local nametrim = tbsrequire 'helpers/string_trimnames'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local textlen = drawlib.text_lenght
local fontlen = drawlib.lenght

local tryx, tryy = 0, 0

return{

	titlecard = function(v, p, t, e, bfade)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local lvlt = string.upper(nametrim(""..mapheaderinfo[gamemap].lvlttl))
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
		local titlelenm = textlen(v, 'S3BTFNT', lvlt, 0)

		if act ~= "0" and titlelenm then
			v.draw(315-titlelenm-offset*3/FRACUNIT, 123+tryy/FRACUNIT, v.cachePatch('S3BTFNTACT'), 0)
			drawf(v, 'S3BTFNT', (343-titlelenm)*FRACUNIT-offset*3, 108*FRACUNIT+tryy, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1))
		end

		if t and t <= 3*TICRATE/2 then
			v.fadeScreen(fade, 31)
		elseif t <= TICRATE+31 and t > TICRATE then
			v.fadeScreen(fade, 31-(t-TICRATE))
		end
		if t and t <= 3*TICRATE then
			if t <= TICRATE/3 then
				tryx = max($-17*FRACUNIT, 0)
				tryy = min($+17*FRACUNIT, 0)
			end
			if t >= (3*TICRATE - TICRATE/3) then
				tryx = $-17*FRACUNIT
				tryy = $-17*FRACUNIT
			end

			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				drawf(v, 'S3BTFNT', (288-titlelenm)*FRACUNIT-tryx-offset*3, 90*FRACUNIT, FRACUNIT, "ZONE", 0, v.getColormap(TC_DEFAULT, 1, translation), "left")
			end

			v.drawString(175, 158, mapheaderinfo[gamemap].subttl, 0|V_ALLOWLOWERCASE, "center")
			drawf(v, 'S3BTFNT', (262-tryx)*FRACUNIT+tryx-offset*3, 72*FRACUNIT, FRACUNIT, lvlt, 0, v.getColormap(TC_DEFAULT, 1, translation), "right")

			return true
		end
	end,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x)
		if p and p.mo then
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_B3DLIFE_"..skin_name
			local patch_s_name = "STYLES_SB3DLIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.cachePatch(patch_s_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.cachePatch(patch_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				v.draw(lives_x, hudinfo[HUD_LIVES].y-1, v.cachePatch('3BLIVBLANK1'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
				v.draw(lives_x, hudinfo[HUD_LIVES].y-1, v.cachePatch('3BLIVBLANK2'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
			end

			if G_GametypeUsesLives() then
				drawf(v, prefix..'TNUM', (lives_x+18)*FRACUNIT, (hudinfo[HUD_LIVES].y+1)*FRACUNIT, FRACUNIT, 'X'..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1), "left")
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(lives_x+22, hudinfo[HUD_LIVES].y, v.cachePatch('CLASSICIT'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
			end
		end
	end,

	tallytitle = function(v, p, offsetx)
		local mo = p.mo
		local act = tostring(mapheaderinfo[gamemap].actnum)

		if mo then
			local skin_name = nametrim(skins[mo.skin].realname)
			drawf(v, 'S3BTFNT', (96-offsetx)*FRACUNIT, 48*FRACUNIT, FRACUNIT, string.upper(skin_name.." got"))
		else
			drawf(v, 'S3BTFNT', (72-offsetx)*FRACUNIT, 48*FRACUNIT, FRACUNIT, "YOU GOT")
		end

		local gotthrough = "THROUGH "

		if (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
			gotthrough = $..'ZONE'
		else
			gotthrough = $..'ACT'
		end

		drawf(v, 'S3BTFNT', (72-offsetx)*FRACUNIT, 66*FRACUNIT, FRACUNIT, gotthrough)

		if act ~= "0" and titlelenm then
			drawf(v, 'S3BTFNT', (200-offsetx)*FRACUNIT, 72*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1))
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

		drawf(v, 'S3BTFNT', 160*FRACUNIT, 48*FRACUNIT, FRACUNIT, str, 0, v.getColormap(TC_DEFAULT, 0, "SPECIALSTAGE_SONIC3DB_TALLY"), "center")
	end,

	tallybg = function(v, p, offsetx, color, color2, fading)
		v.fadeScreen(156, max(min(fading*10/15, 10), 0))
	end,
}

