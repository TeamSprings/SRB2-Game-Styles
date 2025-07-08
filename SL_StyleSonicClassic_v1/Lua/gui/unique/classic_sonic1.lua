--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local nametrim = tbsrequire 'helpers/string_trimnames'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

local clamping = tbsrequire 'helpers/anim_clamp'

local min_lifelen = 6*4
local min_lifexap = 6*5+2
local max_lifelen = 7*9

local titledur = TICRATE/5 - TICRATE/16
local titledel = TICRATE/12
local trx, trx2

return{

	titlecard = function(v, p, t, e, bfade)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local lvlt = string.lower(nametrim(""..mapheaderinfo[gamemap].lvlttl))
		local act = tostring(mapheaderinfo[gamemap].actnum)
		local scale = FU
		local offset = 0 --(#lvlt)*FU

		local isSpecialStage = G_IsSpecialStage(gamemap)
		local fade = isSpecialStage and 0xFB00 or (bfade and 0xFA00 or 0xFF00)
		local translation = isSpecialStage and "SPECIALSTAGE_SONIC1_TALLY1" or nil
		local color_choice = isSpecialStage and SKINCOLOR_YELLOW or nil

		if p.styles_entercut_timer == nil then

			if t and t <= 3*TICRATE/2 then
				v.fadeScreen(fade, 31)
			elseif t <= 3*TICRATE/2+31 and t > 3*TICRATE/2 then
				v.fadeScreen(fade, 31-(t-3*TICRATE/2))
			end
		end

		if t and t <= e then

			local out = ease.outquad(clamping(e - titledur, t, e), 0, 400*FU)

			trx = ease.outquad(clamping(0, t, titledur), 400*FU, 0) + out
			trx2 = ease.outquad(clamping(titledel, t, titledur+titledel), 400*FU, 0) + out

			local mo = p.mo
			if mo then
				v.drawScaled(FixedMul(179*FU, scale) + trx - offset/2, FixedMul(78*FU, scale), scale, v.cachePatch('SO1SPI'), 0, v.getColormap(mo.skin, color_choice or mo.color))
			else
				v.drawScaled(FixedMul(179*FU, scale) + trx - offset/2, FixedMul(78*FU, scale), scale, v.cachePatch('SO1SPI'), 0, v.getColormap(TC_DEFAULT, color_choice or p.skincolor))
			end

			drawf(v, 'SO1FNT', FixedMul(231*FU, scale) - trx - offset, FixedMul(76*FU, scale), scale, string.lower(lvlt), 0, v.getColormap(TC_DEFAULT, 1, translation), "right")
			
			---@diagnostic disable-next-line
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				drawf(v, 'SO1FNT', FixedMul(215*FU, scale) - trx2 - offset, FixedMul(96*FU, scale), scale, "zone", 0, v.getColormap(TC_DEFAULT, 1, translation), "right")
			end

			if act ~= "0" then
				v.drawScaled(FixedMul(188*FU, scale)+ trx2 - offset, FixedMul(118*FU, scale), scale, v.cachePatch('SO1ACT'))
				drawf(v, 'S1ANUM', FixedMul(215*FU, scale) + trx2 - offset, FixedMul(97*FU, scale), scale, string.upper(act), 0, v.getColormap(TC_DEFAULT, 1))
			end

			v.drawString(160 - trx, 135, mapheaderinfo[gamemap].subttl, V_ALLOWLOWERCASE, "center")

			return true
		end
	end,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x, colorprofile, overwrite, lifepos)
		if p and p.mo then
			local lifename = string.upper(''..(overwrite and overwrite or skins[p.mo.skin].hudname))
			local lifenamelenght = 0
			for i = 1, #lifename do
				local patch, val
				lifenamelenght = $+fontlen(v, patch, lifename, 'HUS2NAM', val, 1, i)
			end

			lifenamelenght = min(max(lifenamelenght, min_lifelen), max_lifelen)

			local lives_f = hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x
			local lives_y = hudinfo[HUD_LIVES].y

			if lifepos > 1 then
				lives_f = ($|V_SNAPTORIGHT|V_SNAPTOTOP) &~ (V_SNAPTOLEFT|V_SNAPTOBOTTOM)
				lives_x = 281 - hudinfo[HUD_LIVES].x - hide_offset_x - max(lifenamelenght - min_lifexap, 0)
				lives_y = 184 - hudinfo[HUD_LIVES].y
			end

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_S1LIFE_"..skin_name
			local patch_s_name = "STYLES_SS1LIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, lives_y+12, v.cachePatch(patch_s_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, lives_y+12, v.cachePatch(patch_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				v.draw(lives_x, lives_y, v.cachePatch('S2LIVBLANK1'), lives_f)
				v.draw(lives_x+8, lives_y+12, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
				v.draw(lives_x, lives_y, v.cachePatch('S2LIVBLANK2'), lives_f)
			end

			if G_GametypeUsesLives() then
				drawf(v, 'HUS2NAM', (lives_x+17)*FU, (lives_y+1)*FU, FU, lifename, lives_f, colorprofile, 0, 1)

				if lifenamelenght > min_lifexap then
					v.draw(lives_x+22, lives_y+10, v.cachePatch('S2CROSS'), lives_f, colorprofile)
				end

				drawf(v, 'LIFENUM', (lives_x+17+lifenamelenght)*FU, (lives_y+9)*FU, FU, p.lives, lives_f, colorprofile, "right", 1)
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(lives_x+22, lives_y, v.cachePatch('CLASSICIT'), lives_f)
			end
		end
	end,

	tallytitle = function(v, p, offsetx, color, overwrite)
		local mo = p.mo
		local act = tostring(mapheaderinfo[gamemap].actnum)

		v.draw(176-offsetx, 43, v.cachePatch('SO1SPI'), 0, color)


		if mo then
			local skin_name = skins[mo.skin].realname

			drawf(v, 'SO1FNT', (160-offsetx)*FU, 43*FU, FU, string.lower((overwrite and overwrite or skin_name).." has"), 0, v.getColormap(TC_DEFAULT, 1), "center")
		else
			drawf(v, 'SO1FNT', (160-offsetx)*FU, 43*FU, FU, "you have", 0, v.getColormap(TC_DEFAULT, 1), "center")
		end

		drawf(v, 'SO1FNT', (160-offsetx)*FU, 64*FU, FU, "passed", 0, v.getColormap(TC_DEFAULT, 1), "center")

		if act ~= "0" then
			v.draw(184-offsetx, 86, v.cachePatch('SO1ACT'), 0)
			drawf(v, 'S1ANUM', (213-offsetx)*FU, 67*FU+FU/2, FU, string.upper(act), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1))
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

		drawf(v, 'SO1FNT', (160-offsetx)*FU, 57*FU, FU, str, 0, color2, "center")
	end,

	tallybg = function(v, p, offsetx, color, color2, fading)
		return
	end,

	tallyspecialbg = function(v, p, offsetx, color, color2, fading)
		return
	end,
}