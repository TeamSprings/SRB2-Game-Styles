local function spfontdw(d, font, x, y, scale, value, flags, color, alligment, padding)
	local patch, val
	local str = ''..value
	local fontoffset, pad, allig, actlinelenght = 0, 0, 0, 0

	for i = 1,#str do
		val = string.sub(str, i,i)
		patch = d.cachePatch(font..''..val)
		if not d.patchExists(font..''..val) then
			if d.patchExists(font..''..string.byte(val)) then
				patch = d.cachePatch(font..''..string.byte(val))
			else
				patch = d.cachePatch('SO1FNTNONE')
			end
		end		
		actlinelenght = $+patch.width
	end
	
	if alligment == "center" then
		allig = FixedMul(-actlinelenght/2*FRACUNIT, scale)
	elseif alligment == "right" then
		allig = FixedMul(-actlinelenght*FRACUNIT, scale)	
	end
	
	for i = 1,#str do
		val = string.sub(str, i,i)
		if val ~= nil then
			patch = d.cachePatch(font..''..val)
			if not d.patchExists(font..''..val) then
				if d.patchExists(font..''..string.byte(val)) then
					patch = d.cachePatch(font..''..string.byte(val))
				else
					patch = d.cachePatch('SO1FNTNONE')
				end
			end
 		else
			return
		end
		d.drawScaled(FixedMul(x+allig+(fontoffset+(padding or 0)*pad)*FRACUNIT, scale), FixedMul(y, scale), scale, patch, flags, color)
		fontoffset = $+patch.width
		pad = $+1
	end

	
end

hud.add(function(v, p, t, e)
	hud.disable("stagetitle")
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
		spfontdw(v, 'SO1FNT', FixedMul(251*FRACUNIT, scale)-hud.trx-offset, FixedMul(76*FRACUNIT, scale), scale, lvlt, 0, v.getColormap(TC_DEFAULT, 1), "right")
		if mapheaderinfo[gamemap].levelflags &~ LF_NOZONE and mapheaderinfo[gamemap].subttl == "" then
			spfontdw(v, 'SO1FNT', FixedMul(243*FRACUNIT, scale)-hud.trx-offset, FixedMul(96*FRACUNIT, scale), scale, "zone", 0, v.getColormap(TC_DEFAULT, 1), "right")
		elseif mapheaderinfo[gamemap].subttl ~= "" then
			spfontdw(v, 'SO1FNT', FixedMul(302*FRACUNIT, scale)-hud.trx-offset, FixedMul(117*FRACUNIT, scale), scale, string.upper(""..mapheaderinfo[gamemap].subttl), 0, v.getColormap(TC_DEFAULT, 1), "right")			
		end
		if act ~= 0 then
			v.drawScaled(FixedMul(194*FRACUNIT, scale)+hud.trx-offset, FixedMul(118*FRACUNIT, scale), scale, v.cachePatch('SO1ACT'))		
			spfontdw(v, 'S1ANUM', FixedMul(221*FRACUNIT, scale)+hud.trx-offset, FixedMul(97*FRACUNIT, scale), scale, ''..act, 0, v.getColormap(TC_DEFAULT, 1))
		end
	end



end, "titlecard")