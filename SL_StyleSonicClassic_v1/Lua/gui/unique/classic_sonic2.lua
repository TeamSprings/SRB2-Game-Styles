--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local nametrim = tbsrequire 'helpers/string_trimnames'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local textlen = drawlib.text_lenght

local uniquecolors = tbsrequire 'gui/definitions/classic_s2title'

local trx1, trx2, try

return{
	-- TODO: FIX SONIC 2 TITLECARD FOR CUTSCENES -> EASING
	titlecard = function(v, p, t, e, bfade)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local lvlt = string.lower(nametrim(""..mapheaderinfo[gamemap].lvlttl))
		local act = ''..mapheaderinfo[gamemap].actnum
		local rightflg = textlen(v, 'S2IFT', lvlt, 1)
		local zonelenght = textlen(v, 'S2IFT', 'zone', 1)
		local scalexint, _ = v.dupx()
		local scaleyint, _ = v.dupy()
		local screenw = v.width()/scalexint
		local screenh = v.height()/scaleyint
		local extscrw = screenw-320
		local extscrh = screenh-200
		if t < 3 then
			trx1 = screenw-20
			trx2 = screenw-120
			try = screenh
		elseif t > (3*TICRATE+TICRATE/5+1) then
			trx1 = nil
			trx2 = nil
			try = nil
		end
		if t and t <= 3*TICRATE+TICRATE/5 then
			if t <= TICRATE/4 then
				trx1 = $-((screenw-20)/(35/4))
				try = $-(screenh/(35/4))
			end
			if t >= TICRATE/5 and t <= 2*TICRATE/5 then
				trx2 = $-((screenw-120)/(35/4))
			end
			if t >= (3*TICRATE - TICRATE/4-TICRATE) and t <= 3*TICRATE-TICRATE then
				trx1 = $+((screenw-20)/(35/4))
				try = $+(screenh/(35/4))
			end
			if t >= (3*TICRATE) then
				trx2 = $+((screenw-120)/(35/4))+4
			end

			---@cast trx1 number
			---@cast trx2 number
			---@cast try number
			trx1 = max(min(trx1, screenw*2), 0)
			trx2 = max(min(trx2, screenw*2), 0)
			try = max(min(try, screenh*2), 0)

			local pskin = "none"
			if p.mo then
				pskin = p.mo.skin
			end

			v.drawFill(0-extscrw/2, 0-try-extscrh, screenw+extscrw/2, screenh, (uniquecolors[pskin] or 153))
			v.drawFill(trx1-extscrw/2, 136, screenw+extscrw/2, 64+extscrh, 74)
			v.drawFill(-trx1-extscrw/2-23, -extscrh, 111, screenh+extscrh, 37)
			v.draw(88-trx1-extscrw/2, -extscrh, v.cachePatch('S2TTCOR'), 0)
			v.draw(138+trx1-extscrw/2, 144, v.cachePatch('S2TTANAM'), 0)

			drawf(v, 'S2IFT', (287+trx2-rightflg)*FU, 51*FU, FU, lvlt, 0, nil, 'left', 1)
			local offset_x = max(rightflg, 164)

			---@diagnostic disable-next-line
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				drawf(v, 'S2IFT', (382-trx2-offset_x)*FU, 76*FU, FU, 'zone', 0, nil, 'left', 1)
			end

			if act ~= "0" then
				drawf(v, 'S2IACTNUM',(382-trx2-offset_x+zonelenght)*FU, 80*FU, FU, act, 0, v.getColormap(TC_DEFAULT, 1))
			end

			v.drawString(160-trx1, 105, mapheaderinfo[gamemap].subttl, V_ALLOWLOWERCASE, "center")

			return true
		end
	end,

	tallytitle = function(v, p, offsetx, color, overwrite)
		local mo = p.mo

		if mo then
			local skin_name = string.lower((overwrite and overwrite or skins[mo.skin].realname))

			drawf(v, 'S2IFT', (232-offsetx)*FU, 48*FU, FU, skin_name.." got", V_PERPLAYER, nil, 'right', 1)
		else
			drawf(v, 'S2IFT', (232-offsetx)*FU, 48*FU, FU, "you got", V_PERPLAYER, nil, 'right', 1)
		end

		local gotthrough = "through "

		---@diagnostic disable-next-line
		if (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
			gotthrough = $..'zone'
		else
			gotthrough = $..'act'

			local act = ''..mapheaderinfo[gamemap].actnum

			if act ~= "0" then
				drawf(v, 'S2IACTNUM',(78 + textlen(v, 'S2IFT', gotthrough, 1) - offsetx)*FU, 57*FU, FU, act, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1))
			end
		end

		drawf(v, 'S2IFT', (72-offsetx)*FU, 66*FU, FU, gotthrough, V_PERPLAYER, nil, 'left', 1)
	end,

	tallyspecial = function(v, p, offsetx, color, color2)
		local mo = p.mo
		local act = tostring(mapheaderinfo[gamemap].actnum)

		local str = "chaos emeralds"

		if emeralds == All7Emeralds(emeralds) then
			str = " got them all"

			if mo then
				str = string.lower(mo.skin)..str
			else
				str = "you"..str
			end
		end

		drawf(v, 'S2IFT', (160 - textlen(v, 'S2IFT', str, 1) / 2 -offsetx)*FU, 48*FU, FU, str, V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "SPECIALSTAGE_SONIC2_TALLYTITLE"), 'left', 1)
	end,
}