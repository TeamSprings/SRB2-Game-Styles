local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

local ttlnum = {}

--
--	Title card by Clone Fighter
--

------------------------------
-- // PREPARATION
-- These are just handy functions

local function interpolate(x, y, per) -- Thank you, Neon
    local d = y - x
    d = FixedMul(d, per)
    return x + d
end

local function V_LevelActNumWidth(num, ttlnum) -- Ported from v_video.c, required for the function below
	local result = 0;

	if num == 0 then
		result = ttlnum[num].width
	end
	while num > 0 and num <= 99 do
		result = result + ttlnum[num%10].width+2
		num = num/10
	end

	return result
end

local function V_DrawLevelActNum(v, x, y, num, ttlnum) -- Also ported from v_video.c
	if num > 99 then
		return -- Numbers > 99 not supported
	end

	while num > 0 do
		if num > 9 then -- If there are two digits, draw second digit first
			v.draw(x + (V_LevelActNumWidth(num, ttlnum) - V_LevelActNumWidth(num%10, ttlnum)), y, ttlnum[num%10])
		else
			v.draw(x, y, ttlnum[num])
		end
		num = num/10;
	end
end

local function V_DrawTitle(v, x, y, str, flags)
	drawf(v, 'LCDFT', x*FRACUNIT, y*FRACUNIT, FRACUNIT, str, flags, v.getColormap(TC_DEFAULT, 1), "left")
end

local function V_GetLenght(v, str)
	local lenght = 0
	for i = 1, #str do
		local patch, val
		lenght = $+fontlen(v, patch, str, 'LCDFT', val, 1, i)
	end
	return lenght
end

------------------------------
-- // ACTUAL TITLECARD CODE

return{

	titlecard = function(v, player, tctime, etime)
		if tctime > etime-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		if #ttlnum == 0 then
			for i = 0, 9 do -- preparing ttllnum
				ttlnum[i] = v.cachePatch("CDTTL"..i)
			end
		end

		local gear = v.cachePatch("LTCDACTBLU")
		if mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE then
			gear = v.cachePatch("LTCDACTRED")
		end

		local back = v.cachePatch("LTCDBACK")
		local iii = v.cachePatch("LTCDLINE")
		local zonegr = v.cachePatch("LTCDZONE")

		-- Level title thing
		local superstr = ""
		local substr1 = ""
		local substr2 = ""
		if string.find(mapheaderinfo[gamemap].lvlttl, " ") then
			local found = string.find(mapheaderinfo[gamemap].lvlttl, " ")
			superstr = string.sub(mapheaderinfo[gamemap].lvlttl, 1, found)
			substr1 = string.sub(mapheaderinfo[gamemap].lvlttl, found+1, found+1)
			substr2 = string.sub(mapheaderinfo[gamemap].lvlttl, found+2, string.len(mapheaderinfo[gamemap].lvlttl))
		else
			superstr = mapheaderinfo[gamemap].lvlttl
		end
		local totalsubstr = substr1..substr2

		if tctime < 10 then -- Slide in
			local fractime = tctime*FRACUNIT/10

			v.draw(30, interpolate(-168, 0, fractime), back, V_SNAPTOTOP)

			v.drawFill(-500, interpolate(131, 250, FRACUNIT-fractime), 9999, 9, 31|V_SNAPTOTOP)
			local subttl = "Sonic Robo Blast CD"
			if mapheaderinfo[gamemap].subttl != "" then subttl = mapheaderinfo[gamemap].subttl end
			v.drawString(interpolate(-v.stringWidth(subttl), 63, fractime), interpolate(132, 251, FRACUNIT-fractime),
			subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")

			V_DrawTitle(v, interpolate(-V_GetLenght(v, superstr), 40, fractime), 80, superstr, V_SNAPTOTOP)
			V_DrawTitle(v, interpolate(40, 400, FRACUNIT-fractime), 136, substr1, V_SNAPTOTOP)
			V_DrawTitle(v, interpolate(40, 400, FRACUNIT-fractime)+V_GetLenght(v, substr1), 104, substr2, V_SNAPTOTOP)

			local iiiW = 142
			if V_GetLenght(v, superstr) > 102 then
				iiiW = 142 + V_GetLenght(v, superstr) - 102
			elseif V_GetLenght(v, totalsubstr) > 102 then
				iiiW = 142 + V_GetLenght(v, totalsubstr) - 102
			end
			v.draw(interpolate(iiiW, iiiW+360, FRACUNIT-fractime), 80, iii, V_SNAPTOTOP)

			if mapheaderinfo[gamemap].actnum != 0 then v.draw(142, interpolate(150, 320, FRACUNIT-fractime), gear) end
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then v.draw(interpolate(-48, 104, fractime), 147, zonegr) end
			if mapheaderinfo[gamemap].actnum != 0 then
				local actw = 142
				if mapheaderinfo[gamemap].actnum/10 > 0 then
					actw = 134
				end
				V_DrawLevelActNum(v, actw, interpolate(150, 320, FRACUNIT-fractime), mapheaderinfo[gamemap].actnum, ttlnum)
			end

			return true
		elseif tctime >= etime-1 then
			v.drawString(-999, -999, "Zone") -- Draw nothing to hide it

			return true
		elseif tctime > etime-11 -- Slide out
			local fractime = (etime-tctime-1)*FRACUNIT/10

			v.draw(30, interpolate(-168, 0, fractime), back, V_SNAPTOTOP)

			v.drawFill(-500, interpolate(-10, 131, fractime), 9999, 9, 31|V_SNAPTOTOP)
			local subttl = "Sonic Robo Blast CD"
			if mapheaderinfo[gamemap].subttl != "" then subttl = mapheaderinfo[gamemap].subttl end
			v.drawString(interpolate(63, 184, FRACUNIT-fractime), interpolate(-10, 131, fractime),
			subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")

			V_DrawTitle(v, interpolate(40, 400, FRACUNIT-fractime), 80, superstr, V_SNAPTOTOP)
			V_DrawTitle(v, interpolate(-V_GetLenght(v, totalsubstr), 40, fractime), 136, substr1, V_SNAPTOTOP)
			V_DrawTitle(v, interpolate(-V_GetLenght(v, totalsubstr), 40, fractime)+V_GetLenght(v, substr1), 104, substr2, V_SNAPTOTOP)

			local iiiW = 142
			if V_GetLenght(v, superstr) > 102 then
				iiiW = 142 + V_GetLenght(v, superstr) - 102
			elseif V_GetLenght(v, totalsubstr) > 102 then
				iiiW = 142 + V_GetLenght(v, totalsubstr) - 102
			end
			v.draw(interpolate(iiiW, iiiW+360, FRACUNIT-fractime), 80, iii, V_SNAPTOTOP)

			if mapheaderinfo[gamemap].actnum != 0 then v.draw(142, interpolate(150, 320, FRACUNIT-fractime), gear) end
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then v.draw(interpolate(104, 320, FRACUNIT-fractime), 147, zonegr) end
			if mapheaderinfo[gamemap].actnum != 0 then
				local actw = 142
				if mapheaderinfo[gamemap].actnum/10 > 0 then
					actw = 134
				end
				V_DrawLevelActNum(v, actw, interpolate(150, 320, FRACUNIT-fractime), mapheaderinfo[gamemap].actnum, ttlnum)
			end

			return true
		else -- Main loop
			v.draw(30, 0, back, V_SNAPTOTOP)

			v.drawFill(-500, 131, 9999, 9, 31|V_SNAPTOTOP)
			local subttl = "Sonic Robo Blast 2 CD"
			if mapheaderinfo[gamemap].subttl != "" then subttl = mapheaderinfo[gamemap].subttl end
			v.drawString(63, 132, subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")

			V_DrawTitle(v, 40, 80, superstr, V_SNAPTOTOP)
			V_DrawTitle(v, 40, 136, substr1, V_SNAPTOTOP)
			V_DrawTitle(v, 40+V_GetLenght(v, substr1), 104, substr2, V_SNAPTOTOP)

			local iiiW = 142
			if V_GetLenght(v, superstr) > 102 then
				iiiW = 142 + V_GetLenght(v, superstr) - 102
			elseif V_GetLenght(v, totalsubstr) > 102 then
				iiiW = 142 + V_GetLenght(v, totalsubstr) - 102
			end
			v.draw(iiiW, 80, iii, V_SNAPTOTOP)

			if mapheaderinfo[gamemap].actnum != 0 then v.draw(142, 150, gear) end
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then v.draw(104, 147, zonegr) end
			if mapheaderinfo[gamemap].actnum != 0 then
				local actw = 142
				if mapheaderinfo[gamemap].actnum/10 > 0 then
					actw = 134
				end
				V_DrawLevelActNum(v, actw, 150, mapheaderinfo[gamemap].actnum, ttlnum)
			end

			return true
		end
	end,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x)
		if p and p.mo then
			local curtm = 0 --StyleCD_Timetravel.timeline
			local pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}

			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x

			for i = 1, 4 do
				v.draw((lives_x+8+pos[i][1]), (hudinfo[HUD_LIVES].y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|(curtm == 0 and V_FLIP or 0), v.getColormap(TC_ALLWHITE))
			end
			v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|(curtm == 0 and V_FLIP or 0), v.getColormap(TC_DEFAULT, p.mo.color))
			v.draw(lives_x+17, hudinfo[HUD_LIVES].y+7, v.cachePatch('CDXLIFE'), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS)
			drawf(v, 'S1TNUM', (lives_x+25)*FRACUNIT, (hudinfo[HUD_LIVES].y+4)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1), "left")

			v.drawScaled((lives_x+9)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT/2, v.cachePatch('TIMEPER'..curtm) or v.cachePatch("TIMEPER0"), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS)
			v.drawScaled((lives_x+60)*FRACUNIT, (hudinfo[HUD_LIVES].y)*FRACUNIT, FRACUNIT/2, v.cachePatch("TTPER0"..curtm), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS)
		end
	end,
}