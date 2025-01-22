--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

return{

	titlecard = function(v, p, t, e)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local lvlt = string.lower(""..mapheaderinfo[gamemap].lvlttl)
		local act = tostring(mapheaderinfo[gamemap].actnum)
		local scale = FRACUNIT
		local offset = 0 --(#lvlt)*FRACUNIT
		if (hud.trx == nil and t <= 3*TICRATE) or t < 2 then
			hud.trx = (200*FRACUNIT)
			hud.try = -(200*FRACUNIT)
		elseif t > (3*TICRATE+1) then
			hud.trx = nil
		end

		local isSpecialStage = G_IsSpecialStage(gamemap)
		local fade = isSpecialStage and 0xFB00 or 0xFF00
		local translation = isSpecialStage and "SPECIALSTAGE_SONIC1_TALLY1" or nil
		local color_choice = isSpecialStage and SKINCOLOR_YELLOW or nil

		if t and t <= 3*TICRATE/2 then
			v.fadeScreen(fade, 31)
		elseif t <= 3*TICRATE/2+31 and t > 3*TICRATE/2 then
			v.fadeScreen(fade, 31-(t-3*TICRATE/2))
		end
		if t and t <= 3*TICRATE then
			if t <= TICRATE/5 then
				hud.trx = $-27*FRACUNIT
			end
			if t >= (3*TICRATE - TICRATE/5) then
				hud.trx = $+27*FRACUNIT
			end

			local mo = p.mo
			if mo then
				v.drawScaled(FixedMul(179*FRACUNIT, scale)+hud.trx-offset/2, FixedMul(78*FRACUNIT, scale), scale, v.cachePatch('SO1SPI'), 0, v.getColormap(mo.skin, color_choice or mo.color))
			else
				v.drawScaled(FixedMul(179*FRACUNIT, scale)+hud.trx-offset/2, FixedMul(78*FRACUNIT, scale), scale, v.cachePatch('SO1SPI'), 0, v.getColormap(TC_DEFAULT, color_choice or p.skincolor))
			end

			drawf(v, 'SO1FNT', FixedMul(251*FRACUNIT, scale)-hud.trx-offset, FixedMul(76*FRACUNIT, scale), scale, string.lower(lvlt), 0, v.getColormap(TC_DEFAULT, 1, translation), "right")
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				drawf(v, 'SO1FNT', FixedMul(243*FRACUNIT, scale)-hud.trx-offset, FixedMul(96*FRACUNIT, scale), scale, "zone", 0, v.getColormap(TC_DEFAULT, 1, translation), "right")
			end

			if act ~= "0" then
				v.drawScaled(FixedMul(194*FRACUNIT, scale)+hud.trx-offset, FixedMul(118*FRACUNIT, scale), scale, v.cachePatch('SO1ACT'))
				drawf(v, 'S1ANUM', FixedMul(221*FRACUNIT, scale)+hud.trx-offset, FixedMul(97*FRACUNIT, scale), scale, string.upper(act), 0, v.getColormap(TC_DEFAULT, 1))
			end

			v.drawString(160-hud.trx, 135, mapheaderinfo[gamemap].subttl, V_ALLOWLOWERCASE, "center")

			return true
		end
	end,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x)
		if p and p.mo then
			local lifename = string.upper(''..skins[p.mo.skin].hudname)
			local lifenamelenght = 0
			for i = 1, #lifename do
				local patch, val
				lifenamelenght = $+fontlen(v, patch, lifename, 'HUS2NAM', val, 1, i)
			end

			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_S1LIFE_"..skin_name
			local patch_s_name = "STYLES_SS1LIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+12, v.cachePatch(patch_s_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+12, v.cachePatch(patch_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				v.draw(lives_x, hudinfo[HUD_LIVES].y, v.cachePatch('S2LIVBLANK1'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+12, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
				v.draw(lives_x, hudinfo[HUD_LIVES].y, v.cachePatch('S2LIVBLANK2'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
			end

			drawf(v, 'HUS2NAM', (lives_x+17)*FRACUNIT, (hudinfo[HUD_LIVES].y+1)*FRACUNIT, FRACUNIT, string.upper(''..skins[p.mo.skin].hudname), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), 0, 1)

			if G_GametypeUsesLives() then
				v.draw(lives_x+22, hudinfo[HUD_LIVES].y+10, v.cachePatch('S2CROSS'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
				drawf(v, 'LIFENUM', (lives_x+17+lifenamelenght)*FRACUNIT, (hudinfo[HUD_LIVES].y+9)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", 1)
			end
		end
	end,

	tallytitle = function(v, p, offsetx, color)
		local mo = p.mo
		local act = tostring(mapheaderinfo[gamemap].actnum)

		v.draw(176-offsetx, 43, v.cachePatch('SO1SPI'), 0, color)


		if mo then
			local skin_name = skins[mo.skin].realname

			drawf(v, 'SO1FNT', (160-offsetx)*FRACUNIT, 43*FRACUNIT, FRACUNIT, string.lower(skin_name.." has"), 0, v.getColormap(TC_DEFAULT, 1), "center")
		else
			drawf(v, 'SO1FNT', (160-offsetx)*FRACUNIT, 43*FRACUNIT, FRACUNIT, "you have", 0, v.getColormap(TC_DEFAULT, 1), "center")
		end

		drawf(v, 'SO1FNT', (160-offsetx)*FRACUNIT, 64*FRACUNIT, FRACUNIT, "passed", 0, v.getColormap(TC_DEFAULT, 1), "center")

		if act ~= "0" then
			v.draw(184-offsetx, 86, v.cachePatch('SO1ACT'), 0)
			drawf(v, 'S1ANUM', (213-offsetx)*FRACUNIT, 67*FRACUNIT+FRACUNIT/2, FRACUNIT, string.upper(act), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1))
		end
	end,

	tallyspecial = function(v, p, offsetx, color, color2)
		local mo = p.mo
		local act = tostring(mapheaderinfo[gamemap].actnum)

		v.draw(136-offsetx, 43, v.cachePatch('SO1SPI'), 0, color)
		local str = "chaos emeralds"

		if emeralds == All7Emeralds(emeralds) then
			str = " got them all"

			if mo then
				str = string.lower(mo.skin)..str
			else
				str = "you"..str
			end
		end

		drawf(v, 'SO1FNT', (160-offsetx)*FRACUNIT, 57*FRACUNIT, FRACUNIT, str, 0, color2, "center")
	end,
}