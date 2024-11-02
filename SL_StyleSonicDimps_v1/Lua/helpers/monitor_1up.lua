--[[

		C->Lua Translation & Recreation of 1UP Monitor Box

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

-- Snippet from source code
freeslot("S_PLAY_NBX1", "S_1UP_NICON1", "S_1UP_NICON2")
states[S_PLAY_NBX1] = {
	sprite = SPR_PLAY,
	frame = SPR2_LIFE
}

states[S_1UP_NICON1] = {
	sprite = SPR_TV1P,
	frame = C|FF_ANIMATE,
	tics = 18,
	var1 = 3,
	var2 = 4,
	nextstate = S_1UP_NICON2,
}

states[S_1UP_NICON2] = {
	sprite = SPR_TV1P,
	frame = C,
	tics = 18,
	action = A_ExtraLife,
	var1 = 0,
	var2 = 0,
}

local function New_1upThinker(actor)
	local i, temp
	local dist = INT32_MAX
	local closestplayer = -1

	for i = 0, #players-1 do
		if not players[i] or not players[i].mo then
			continue
		end

		if players[i].bot == BOT_2PAI or players[i].bot == BOT_2PHUMAN or players[i].spectator then
			continue
		end

		if (netgame or multiplayer) and players[i].playerstate ~= PST_LIVE then
			continue
		end

		temp = P_AproxDistance(players[i].mo.x-actor.x, players[i].mo.y-actor.y)

		if temp < dist then
			closestplayer = i
			dist = temp
		end
	end

	if closestplayer == -1 or skins[players[closestplayer].skin].sprites[SPR2_LIFE].numframes == 0 then
		if actor.overlay then
			P_RemoveMobj(actor.overlay)
			actor.overlay = nil
		end
		actor.sprite = SPR_TV1U
		return
	end

	actor.sprite = SPR_TV1P

	if not actor.overlay then
		actor.overlay = P_SpawnMobj(actor.x, actor.y, actor.z, MT_OVERLAY)
		actor.overlay.target = actor
		actor.overlay.dispoffset = 3

		actor.overlay.skin = players[closestplayer].mo.skin
		actor.overlay.state = S_PLAY_NBX1
		actor.overlay.spriteyoffset = 4*FRACUNIT
	end

	actor.overlay.color = players[closestplayer].mo.color
	actor.overlay.skin = players[closestplayer].mo.skin
end

return New_1upThinker