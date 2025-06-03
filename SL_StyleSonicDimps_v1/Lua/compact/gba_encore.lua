-- Compatibility layer for Encore Mode
-- Uses modified code from https://mb.srb2.org/addons/encore-mode.3968/
-- All credits goes to Lactozilla, TripelTheFox, Delf and others.

local mts = {
	MT_RING_BOX,
	MT_PITY_BOX,
	MT_BUBBLEWRAP_BOX,
	MT_FLAMEAURA_BOX,
	MT_THUNDERCOIN_BOX,
	MT_SWAP_BOX,
	MT_ERND_BOX
}

return {
	pop = function(actor, item, target)
		local itemdata = 0
		local extras

		if actor.info.damage ~= MT_UNKNOWN then
			if #actor.target.player.extralist > 0 then
				itemdata = actor.info.damage
			else
				itemdata = mobjinfo[mts[item.cs]].damage
			end
		end

		if not itemdata then return end

		local newmobj = P_SpawnMobjFromMobj(actor, 0, 0, 13*FU, itemdata)

		if target then
			newmobj.target = target -- Transfer target
		end

		-- custom
		newmobj.sknn = target.player.extralist[item.cs]

		if itemdata == MT_ENC_ICON then
			if not newmobj.target
			or not target.player
			or not target.skin
			or skins[newmobj.sknn].sprites[SPR2_LIFE].numframes == 0 then
				return -- No lives icon for this player, use the default.
			else -- Spawn the lives icon.
				local livesico = P_SpawnMobjFromMobj(newmobj, 0, 0, 0, MT_OVERLAY)
				livesico.target = newmobj
				livesico.tracer = newmobj
				newmobj.tracer = livesico
				newmobj.overlay = livesico

				livesico.color = skins[newmobj.sknn].prefcolor
				livesico.skin = newmobj.sknn
				livesico.state = newmobj.info.seestate

				-- We're using the overlay, so use the overlay 1up sprite (no text)
				newmobj.sprite = SPR_TV1P

				extras = {type = "ENC", sprite = newmobj.sprite, frame = newmobj.frame, skin = livesico.skin, color = livesico.color}
			end
		else
			extras = {type = "NONE", sprite = newmobj.sprite, frame = newmobj.frame}
		end

		-- Run a linedef executor immediately upon popping
		-- You may want to delay your effects by 18 tics to sync with the reward giving
		if actor.spawnpoint and actor.lastlook then
			P_LinedefExecute(actor.lastlook, actor.target, NULL)
		end

		return extras
	end,

	think = function(actor)
		if not (actor and actor.valid) then return end

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

		if closestplayer == -1
		or (players
		and players[closestplayer]
		and players[closestplayer].valid
		and players[closestplayer].extralist
		and actor.cs
		and players[closestplayer].extralist[actor.cs]
		and skins[players[closestplayer].extralist[actor.cs]].sprites[SPR2_LIFE].numframes == 0) then

			if closestplayer ~= -1 then
				if not actor.cs then
					actor.cs = 1
				end
				if not (leveltime % 8) then
					actor.cs = $+1
				end
				if actor.cs > #players[closestplayer].extralist then
					actor.cs = 1
				end
			end
			-- Closest player not found (no players in game?? may be empty dedicated server!), or does not have correct sprite.
			if actor.overlay then
				P_RemoveMobj(actor.overlay)
				actor.overlay = nil
			end
			return
		end

		-- custom
		if players[closestplayer].extralist and #players[closestplayer].extralist > 0 then
			if not actor.cs then
				actor.cs = 1
			end
			if not (leveltime % 8) then
				actor.cs = $+1
			end
			if actor.cs > #players[closestplayer].extralist then
				actor.cs = 1
			end
			local sknn = players[closestplayer].extralist[actor.cs]

			-- We're using the overlay, so use the overlay 1up box (no text)
			actor.sprite = SPR_TV1P

			if not actor.overlay then
				actor.overlay = P_SpawnMobj(actor.x, actor.y, actor.z, MT_OVERLAY)
				actor.overlay.target = actor
				actor.overlay.skin = skins[players[closestplayer].skin].name -- required here to prevent spr2 default showing stand for a single frame
				actor.overlay.state = S_PLAY_NBX1

				-- The overlay is going to be one tic early turning off and on
				-- because it's going to get its thinker run the frame we spawned it.
				-- So make it take one tic longer if it just spawned.
				actor.overlay.tics = $ + 1

				actor.overlay.dispoffset = 3
				actor.overlay.spriteyoffset = 4*FU
			end

			if actor.flags2 & MF2_DONTDRAW then
				actor.overlay.flags2 = $|MF2_DONTDRAW
			else
				actor.overlay.flags2 = $ &~ MF2_DONTDRAW
			end

			actor.overlay.color = skins[sknn].prefcolor
			actor.overlay.skin = sknn
		elseif players[closestplayer].extralist then
			if not actor.cs then
				actor.cs = 1
			end

			if not (leveltime % 8) then
				actor.cs = $+1
			end
			if actor.cs > #mts then
				actor.cs = 1
			end
			local mt = mts[actor.cs]

			if actor.overlay then
				P_RemoveMobj(actor.overlay)
				actor.overlay = nil
			end

			actor.sprite = states[mobjinfo[mt].spawnstate].sprite
		end
		if players
		and players[closestplayer]
		and players[closestplayer].valid
		and players[closestplayer].extralist
		and actor.cs
		and players[closestplayer].extralist[actor.cs]
		and skins[players[closestplayer].extralist[actor.cs]].sprites[SPR2_LIFE].numframes == 0 then
			if actor.overlay then
				P_RemoveMobj(actor.overlay)
				actor.overlay = nil
			end
		end
	end,
}