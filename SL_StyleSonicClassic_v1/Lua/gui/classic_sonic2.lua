local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

return{
	titlecard = function(v, p, t, e)
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
				drawf(v, 'TTL0',(382-hud.trx2-rightflg+zonelenght)*FRACUNIT, 80*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1))
			end
		end
	end,
}