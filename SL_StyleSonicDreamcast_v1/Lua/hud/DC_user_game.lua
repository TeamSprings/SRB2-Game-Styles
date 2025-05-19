--[[

		User Interfaces inspired by Sonic Adventure 2.

Contributors: Skydusk, Demnyx
@Team Blue Spring 2022-2025

]]

local HOOK = customhud.SetupItem

local CV = CV_FindVar("dc_hud")

local hud_data = {
	[1] = tbsrequire('hud/types/DC_sa1'),
	[2] = tbsrequire('hud/types/DC_sa2'),
	[3] = tbsrequire('hud/types/DC_heroes'),
	[4] = tbsrequire('hud/types/DC_06'),
}

--
-- In-Game Hook
--

-- SCORE
HOOK("score", "dchud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	hud_data[CV.value].score(v, p, t, e)

	return true
end, "game")

-- TIME
HOOK("time", "dchud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	hud_data[CV.value].time(v, p, t, e)

	return true
end, "game")

---@diagnostic disable-next-line

-- RINGS
HOOK("rings", "dchud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	hud_data[CV.value].rings(v, p, t, e)

	return true
end, "game")

addHook("PlayerThink", function(p)
	if p.styles_keytouch and p.styles_keytouch.dur > 920 then
		p.styles_keytouch.dur = p.styles_keytouch.dur-FRACUNIT/18
		p.styles_keytouch.frame = ((p.styles_keytouch.frame & FF_FRAMEMASK)+2) % p.styles_keytouch.loop
	else
		p.styles_keytouch = nil
	end
end)

-- LIVES
HOOK("lives", "dchud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end
	if modeattacking then return end

	if p.lives == INFLIVES or p.spectator then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	if not p.mo then return end

	hud_data[CV.value].lives(v, p, t, e)

	return true
end, "game")


	--local imax = 8
	--local angmax = (360/imax)*ANG1

	--for i = 1, 8 do
	--	local anlg = (i * angmax) + (leveltime * ANG1) / 8

	--	local x = (cos(anlg) * 40) / FRACUNIT
	--	local y = (sin(anlg) * 10) / FRACUNIT

	--	v.drawString(160 + x, 100 + y, "LMAO")
	--end