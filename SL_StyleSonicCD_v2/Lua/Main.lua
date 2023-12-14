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

------------------------------
-- // ACTUAL TITLECARD CODE

hud.add(function(v, player, tctime, etime)
	hud.disable("stagetitle")-- Disable default
	
	local ttlnum = {}
	for i = 0, 9 do -- preparing ttllnum
		ttlnum[i] = v.cachePatch("TTL0"..i)
	end
	
	local gear = v.cachePatch("LTACTBLU")
	if mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE then
		gear = v.cachePatch("LTACTRED")
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
		
		v.drawLevelTitle(interpolate(-v.levelTitleWidth(superstr), 40, fractime), 80, superstr, V_SNAPTOTOP)
		v.drawLevelTitle(interpolate(40, 400, FRACUNIT-fractime), 136, substr1, V_SNAPTOTOP)
		v.drawLevelTitle(interpolate(40, 400, FRACUNIT-fractime)+v.levelTitleWidth(substr1), 104, substr2, V_SNAPTOTOP)
		
		local iiiW = 142
		if v.levelTitleWidth(superstr) > 102 then
			iiiW = 142 + v.levelTitleWidth(superstr) - 102
		elseif v.levelTitleWidth(totalsubstr) > 102 then
			iiiW = 142 + v.levelTitleWidth(totalsubstr) - 102
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
		
	elseif tctime >= etime-1 then
		v.drawString(-999, -999, "Zone") -- Draw nothing to hide it
	
	elseif tctime > etime-11 -- Slide out
		local fractime = (etime-tctime-1)*FRACUNIT/10
	
		v.draw(30, interpolate(-168, 0, fractime), back, V_SNAPTOTOP)
		
		v.drawFill(-500, interpolate(-10, 131, fractime), 9999, 9, 31|V_SNAPTOTOP)
		local subttl = "Sonic Robo Blast CD"
		if mapheaderinfo[gamemap].subttl != "" then subttl = mapheaderinfo[gamemap].subttl end
		v.drawString(interpolate(63, 184, FRACUNIT-fractime), interpolate(-10, 131, fractime),
		subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		
		v.drawLevelTitle(interpolate(40, 400, FRACUNIT-fractime), 80, superstr, V_SNAPTOTOP)
		v.drawLevelTitle(interpolate(-v.levelTitleWidth(totalsubstr), 40, fractime), 136, substr1, V_SNAPTOTOP)
		v.drawLevelTitle(interpolate(-v.levelTitleWidth(totalsubstr), 40, fractime)+v.levelTitleWidth(substr1), 104, substr2, V_SNAPTOTOP)
		
		local iiiW = 142
		if v.levelTitleWidth(superstr) > 102 then
			iiiW = 142 + v.levelTitleWidth(superstr) - 102
		elseif v.levelTitleWidth(totalsubstr) > 102 then
			iiiW = 142 + v.levelTitleWidth(totalsubstr) - 102
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
	
	else -- Main loop
		v.draw(30, 0, back, V_SNAPTOTOP)
		
		v.drawFill(-500, 131, 9999, 9, 31|V_SNAPTOTOP)
		local subttl = "Sonic Robo Blast CD"
		if mapheaderinfo[gamemap].subttl != "" then subttl = mapheaderinfo[gamemap].subttl end
		v.drawString(63, 132, subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
		
		v.drawLevelTitle(40, 80, superstr, V_SNAPTOTOP)
		v.drawLevelTitle(40, 136, substr1, V_SNAPTOTOP)
		v.drawLevelTitle(40+v.levelTitleWidth(substr1), 104, substr2, V_SNAPTOTOP)
		
		local iiiW = 142
		if v.levelTitleWidth(superstr) > 102 then
			iiiW = 142 + v.levelTitleWidth(superstr) - 102
		elseif v.levelTitleWidth(totalsubstr) > 102 then
			iiiW = 142 + v.levelTitleWidth(totalsubstr) - 102
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
	end
end, "titlecard")


hud.add(function(v, p, t, e)
	hud.disable("lives")
	local curtm = StyleCD_Timetravel.timeline
	local pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}
	
	for i = 1, 4 do
		v.draw((hudinfo[HUD_LIVES].x+8+pos[i][1]), (hudinfo[HUD_LIVES].y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|(curtm == 0 and V_FLIP or 0), v.getColormap(TC_ALLWHITE))
	end
	v.draw(hudinfo[HUD_LIVES].x+8, hudinfo[HUD_LIVES].y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|(curtm == 0 and V_FLIP or 0), v.getColormap(TC_DEFAULT, p.mo.color))
	v.draw(hudinfo[HUD_LIVES].x+17, hudinfo[HUD_LIVES].y+7, v.cachePatch('CDXLIFE'), hudinfo[HUD_LIVES].f)
	v.drawNum(hudinfo[HUD_LIVES].x+34, hudinfo[HUD_LIVES].y+4, p.lives, hudinfo[HUD_LIVES].f)
	
	v.drawScaled((hudinfo[HUD_LIVES].x+9)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT/2, v.cachePatch('TIMEPER'..curtm) or v.cachePatch("TIMEPER0"), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS)
	v.drawScaled((hudinfo[HUD_LIVES].x+60)*FRACUNIT, (hudinfo[HUD_LIVES].y)*FRACUNIT, FRACUNIT/2, v.cachePatch("TTPER0"..curtm), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS)	
end, "game")

