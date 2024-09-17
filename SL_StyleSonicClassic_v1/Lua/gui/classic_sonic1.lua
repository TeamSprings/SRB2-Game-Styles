local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

return{

	titlecard = function(v, p, t, e)
		local lvlt = string.lower(""..mapheaderinfo[gamemap].lvlttl)
		local act = mapheaderinfo[gamemap].actnum
		local scale = FRACUNIT
		local offset = 0 --(#lvlt)*FRACUNIT
		if hud.trx == nil and t <= 3*TICRATE then
			hud.trx = (200*FRACUNIT)
			hud.try = -(200*FRACUNIT)
		elseif t > (3*TICRATE+1) then
			hud.trx = nil
		end
		if t and t <= 3*TICRATE/2 then
			v.fadeScreen(0xFF00, 31)
		elseif t <= 3*TICRATE/2+31 and t > 3*TICRATE/2 then
			v.fadeScreen(0xFF00, 31-(t-3*TICRATE/2))
		end
		if t and t <= 3*TICRATE then
			if t <= TICRATE/5 then
				hud.trx = $-27*FRACUNIT
			end
			if t >= (3*TICRATE - TICRATE/5) then
				hud.trx = $+27*FRACUNIT
			end
			v.drawScaled(FixedMul(179*FRACUNIT, scale)+hud.trx-offset/2, FixedMul(78*FRACUNIT, scale), scale, v.cachePatch('SO1SPI'))
			drawf(v, 'SO1FNT', FixedMul(251*FRACUNIT, scale)-hud.trx-offset, FixedMul(76*FRACUNIT, scale), scale, lvlt, 0, v.getColormap(TC_DEFAULT, 1), "right")
			if mapheaderinfo[gamemap].levelflags &~ LF_NOZONE and mapheaderinfo[gamemap].subttl == "" then
				drawf(v, 'SO1FNT', FixedMul(243*FRACUNIT, scale)-hud.trx-offset, FixedMul(96*FRACUNIT, scale), scale, "zone", 0, v.getColormap(TC_DEFAULT, 1), "right")
			elseif mapheaderinfo[gamemap].subttl ~= "" then
				drawf(v, 'SO1FNT', FixedMul(302*FRACUNIT, scale)-hud.trx-offset, FixedMul(117*FRACUNIT, scale), scale, string.upper(""..mapheaderinfo[gamemap].subttl), 0, v.getColormap(TC_DEFAULT, 1), "right")
			end
			if act ~= 0 then
				v.drawScaled(FixedMul(194*FRACUNIT, scale)+hud.trx-offset, FixedMul(118*FRACUNIT, scale), scale, v.cachePatch('SO1ACT'))
				drawf(v, 'S1ANUM', FixedMul(221*FRACUNIT, scale)+hud.trx-offset, FixedMul(97*FRACUNIT, scale), scale, ''..act, 0, v.getColormap(TC_DEFAULT, 1))
			end
		end
	end,

	lives = function(v, p, t, e)
		local lifename = string.upper(''..skins[p.mo.skin].hudname)
		local lifenamelenght = 0
		for i = 1, #lifename do
			local patch, val
			lifenamelenght = $+fontlen(v, patch, lifename, 'HUS2NAM', val, 1, i)
		end
		v.draw(hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y, v.cachePatch('S2LIVBLANK1'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
		v.draw(hudinfo[HUD_LIVES].x+22, hudinfo[HUD_LIVES].y+10, v.cachePatch('S2CROSS'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
		v.draw(hudinfo[HUD_LIVES].x+8, hudinfo[HUD_LIVES].y+12, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
		v.draw(hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y, v.cachePatch('S2LIVBLANK2'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)

		drawf(v, 'HUS2NAM', (hudinfo[HUD_LIVES].x+17)*FRACUNIT, (hudinfo[HUD_LIVES].y+1)*FRACUNIT, FRACUNIT, string.upper(''..skins[p.mo.skin].hudname), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), 0, 1)
		drawf(v, 'LIFENUM', (hudinfo[HUD_LIVES].x+17+lifenamelenght)*FRACUNIT, (hudinfo[HUD_LIVES].y+9)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", 1)
	end,
}