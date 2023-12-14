local function getactualstrlenght(d, patch, str, font, val, padding, i)
	val = string.sub(str, i,i)
	patch = d.cachePatch(font..''..val)
	if not d.patchExists(font..''..val) then
		if d.patchExists(font..''..string.byte(val)) then
			patch = d.cachePatch(font..''..string.byte(val))
		else
			patch = d.cachePatch('S2SSNONE')
		end
	end
	return patch.width+(padding or 0)
end

local function spfontdw(d, font, x, y, scale, value, flags, color, alligment, padding, leftadd)
	local patch, val
	local str = ''..value
	local fontoffset, allig, actlinelenght = 0, 0, 0
	local trans = V_TRANSLUCENT

	if leftadd ~= nil and leftadd ~= 0 then
		local strlefttofill = leftadd-#str
		if strlefttofill > 0 then
			for i = 1,strlefttofill do
				str = ";"..str
			end
		end
	end

	for i = 1,#str do	
		actlinelenght = $+getactualstrlenght(d, patch, str, font, val, padding, i)
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
					patch = d.cachePatch('S2SSNONE')
				end
			end
 		else
			return
		end
		d.drawScaled(FixedMul(x+allig+(fontoffset)*FRACUNIT, scale), FixedMul(y, scale), scale, patch, (val == ";" and flags|trans or flags), color)
		fontoffset = $+patch.width+(padding or 0)
	end

	
end

hud.add(function(v, p, t, e)
	hud.disable("stagetitle")
	local lvlt = string.lower(""..mapheaderinfo[gamemap].lvlttl)
	local act = ''..mapheaderinfo[gamemap].actnum
	local rightflg = v.levelTitleWidth(lvlt)
	local zonelenght = v.levelTitleWidth('zone')
	local scalexint, scalexfr = v.dupx()
	local scaleyint, scaleyfr = v.dupy()
	local screenw = v.width()/scalexint
	local screenh = v.height()/scaleyint
	local extscrw = screenw-320
	local extscrh = screenh-200
	if t == 1 then
		hud.trx1 = screenw-20
		hud.trx2 = screenw-120
		hud.try = screenh
	elseif t > (3*TICRATE+TICRATE/5+1) then
		hud.trx1 = nil
		hud.trx2 = nil
		hud.try = nil
	end
	if t and t <= 3*TICRATE+TICRATE/5 then
		if t <= TICRATE/4 then
			hud.trx1 = $-((screenw-20)/(35/4))
			hud.try = $-(screenh/(35/4))			
		end
		if t >= TICRATE/5 and t <= 2*TICRATE/5 then
			hud.trx2 = $-((screenw-120)/(35/4))
		end		
		if t >= (3*TICRATE - TICRATE/4-TICRATE) and t <= 3*TICRATE-TICRATE then
			hud.trx1 = $+((screenw-20)/(35/4))
			hud.try = $+(screenh/(35/4))
		end
		if t >= (3*TICRATE) then
			hud.trx2 = $+((screenw-120)/(35/4))+4
		end
		v.drawFill(0-extscrw/2, 0-hud.try-extscrh, screenw+extscrw/2, screenh, 153)		
		v.drawFill(hud.trx1-extscrw/2, 136, screenw+extscrw/2, 64+extscrh, 74)
		v.drawFill(-hud.trx1-extscrw/2-23, -extscrh, 111, screenh+extscrh, 37)
		v.draw(88-hud.trx1-extscrw/2, -extscrh, v.cachePatch('S2TTCOR'))
		v.draw(138+hud.trx1-extscrw/2, 144, v.cachePatch('S2TTANAM'))		
		v.drawLevelTitle(287+hud.trx2-rightflg, 51, lvlt)
		if act ~= 0 then
			v.drawLevelTitle(382-hud.trx2-rightflg, 76, 'zone')
			spfontdw(v, 'TTL0',(382-hud.trx2-rightflg+zonelenght)*FRACUNIT, 80*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1))
		end
	end



end, "titlecard")

hud.add(function(v, p, t, e)
	--if not hud.enabled("lives") then return end
	hud.disable("lives")
	local lifename = string.upper(''..skins[p.mo.skin].hudname)
	local lifenamelenght = 0
	for i = 1, #lifename do
		local patch, val
		lifenamelenght = $+getactualstrlenght(v, patch, lifename, 'HUS2NAM', val, 1, i)
	end
	v.draw(hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y, v.cachePatch('S2LIVBLANK1'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
	v.draw(hudinfo[HUD_LIVES].x+22, hudinfo[HUD_LIVES].y+10, v.cachePatch('S2CROSS'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
	
	--v.drawScaled((hudinfo[HUD_LIVES].x+16)*FRACUNIT, hudinfo[HUD_LIVES].y*FRACUNIT, FRACUNIT/2, v.getSprite2Patch(p.mo.skin, SPR2_XTRA, (p.powers[pw_super] and true or false), A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
	--v.drawCropped((hudinfo[HUD_LIVES].x+8)*FRACUNIT, (hudinfo[HUD_LIVES].y+13)*FRACUNIT, FRACUNIT, FRACUNIT, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color), 0, FRACUNIT, 16*FRACUNIT, 14*FRACUNIT)
	v.draw(hudinfo[HUD_LIVES].x+8, hudinfo[HUD_LIVES].y+12, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
	v.draw(hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y, v.cachePatch('S2LIVBLANK2'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)	
	
	spfontdw(v, 'HUS2NAM', (hudinfo[HUD_LIVES].x+17)*FRACUNIT, (hudinfo[HUD_LIVES].y+1)*FRACUNIT, FRACUNIT, string.upper(''..skins[p.mo.skin].hudname), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), 0, 1)
	spfontdw(v, 'LIFENUM', (hudinfo[HUD_LIVES].x+17+lifenamelenght)*FRACUNIT, (hudinfo[HUD_LIVES].y+9)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", 1)	
end, "game")