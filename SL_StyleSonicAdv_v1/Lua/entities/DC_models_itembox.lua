--[[

		Sonic Adventure Style's Item Box

Contributors: Ace Lite, Demnyx
@Team Blue Spring 2022-2024

]]


local slope_handler = tbsrequire 'helpers/mo_slope'

local Disable_ItemBox = false

addHook("MapLoad", function()
	Disable_ItemBox = false
	if CV_FindVar("dc_itembox").value == 0 then
		Disable_ItemBox = true
	end
end)

local function P_SpawnItemBox(a)
		local icon = mobjinfo[a.type].damage
		local icstate = mobjinfo[icon].spawnstate
		local icsprite = states[icstate].sprite
		local icframe = states[icstate].frame

		if a.health > 0 then
			if not a.item then
				a.item = P_SpawnMobjFromMobj(a, 0,0,25*FRACUNIT, MT_BACKTIERADUMMY)
				a.item.state = S_INVISIBLE
				a.item.target = a
				a.item.icsprite = icsprite
				a.item.icframe = icframe
				a.item.sprite = icsprite
				a.item.frame = icframe|FF_PAPERSPRITE
				a.item.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
				a.item.flags2 = $|MF2_LINKDRAW &~ MF2_OBJECTFLIP
				a.item.tfl = 1
			end

			if not a.caps then
				a.caps = P_SpawnMobjFromMobj(a, 0,0,0, MT_OVERLAY)
				a.caps.state = S_INVISIBLE
				a.caps.target = a
				a.caps.sprite = SPR_1CAP
				a.caps.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
				a.caps.flags2 = $|MF2_LINKDRAW
			end

			a.settedup = nil
		end

		a.state = S_INVISIBLE
		a.sprite = SPR_1CAP

		--a.item.dispoffset = -32*FRACUNIT

		if a.info.flags & MF_GRENADEBOUNCE then
			a.color = SKINCOLOR_GOLD
		else
			if a.info.spawnstate == S_RING_BLUEBOX1 then
				a.color = SKINCOLOR_SAPPHIRE
			elseif a.info.spawnstate == S_RING_REDBOX1 then
				a.color = SKINCOLOR_RUBY
			else
				a.color = SKINCOLOR_RED
				if not (a.type == MT_RING_BOX and a.randomring) then
					a.randomring = P_RandomKey(16)
				end
			end
		end

		a.originscale = a.scale
		mobjinfo[a.type].deathsound = sfx_advite
end

--	Item Box Switcher is a function switcing between "float" type or "ground" type capsule
--	After function runs a.settedup makes sure to not run this function again.

local function itemBoxSwitching(a, typem)
	if typem == 1 then
		a.flags = $ &~ (MF_SOLID|MF_NOGRAVITY)
		a.caps.frame = C|FF_TRANS50
		if a.info.flags & MF_GRENADEBOUNCE then
			a.frame = H
		else
			if a.health > 0 then
				a.frame = A
			else
				a.frame = B
			end
		end
	else
		a.flags = $|MF_NOGRAVITY &~ MF_SOLID
		a.frame = D
		a.item.scale = a.scale+3*FRACUNIT/4
		a.caps.frame = E|FF_TRANS50
	end
	a.settedup = true
end

local function angleway(angle)
	if angle > ANGLE_180 and angle < ANGLE_MAX then
		return 1
	else
		return -1
	end
end

--Define which sprites we'll use
local MonitorSprites = {
	[SPR_TVRI] = 0, --S_RING_BOX
	[SPR_TVPI] = 12, --S_PITY_BOX
	[SPR_TVAT] = 3, --S_ATTRACT_BOX
	[SPR_TVFO] = 9, --S_FORCE_BOX
	[SPR_TVAR] = 5, --S_ARMAGEDDON_BOX
	[SPR_TVWW] = 6, --S_WHIRLWIND_BOX
	[SPR_TVEL] = 4, --S_ELEMENTAL_BOX
	[SPR_TVSS] = 2, --S_SNEAKERS_BOX
	[SPR_TVIV] = 1, --S_INVULN_BOX
	[SPR_TVEG] = 10, --S_EGGMAN_BOX
	[SPR_TVFL] = 11, --S_FLAMEAURA_BOX
	[SPR_TVBB] = 7, --S_BUBBLEWRAP_BOX
	[SPR_TVZP] = 8, --S_THUNDERCOIN_BOX
}

--Sorry SMS Alfredo
--Since you didn't reponded to me, at least I rewritten it for my needs
local function P_MarioExistsThink(a, typepw)
	if not mariocoins then return false end
	-- Optimalization, INT32 feels too much tbh.
	local marioconfirmed, maxdistance = false, 1000*FRACUNIT

	if (mariocoins.value and typepw == 0) or (consoleplayer and consoleplayer.valid and IsMario(consoleplayer)) then
		marioconfirmed = true
	elseif not mariopowerup.value and typepw ~= 0 and typepw ~= 1 and typepw ~= 10 then
		marioconfirmed = false
	elseif multiplayer then
		for p in players.iterate do
			if not (p.mo and p.mo.valid and not p.bot and not p.spectator and not p.playerstate) then return end

			local dist = P_AproxDistance(p.mo.x - a.x, p.mo.y - a.y)

			if dist < maxdistance then
				marioconfirmed = IsMario(mo)
				maxdistance = dist
			end
		end
	end

	return marioconfirmed
end

local mapspecific = {
	["Frozen Hillside"] = function(typepw)
		if typepw ~= 10 and gamemap ~= 30 then return typepw end
		return 7
	end,
	["Forest Fortress"] = function(typepw)
		if typepw < 3 and typepw == 10 and typepw == 9 and gamemap ~= 32 then return typepw end
		return 11
	end,
}

local function P_MarioMonitorThink(a, sprite, oldframe)
	if MonitorSprites[sprite] == nil or not mariocoins then return end
	local levelttl, typepw = mapheaderinfo[gamemap].lvlttl, MonitorSprites[sprite]

	if (typepw == 9 and mapheaderinfo[gamemap].weather == PRECIP_SNOW) then
		typepw = 7

	elseif mapspecific[levelttl] then
		typepw = mapspecific[levelttl](typepw)
	end

	local marioconfirmed = P_MarioExistsThink(a, typepw)

	if marioconfirmed then
		a.sprite = SPR_MMON
		a.frame = typepw|FF_PAPERSPRITE
		a.spriteyoffset = -FRACUNIT*16
	else
		a.sprite = sprite
		a.frame = oldframe|FF_PAPERSPRITE
	end
end


local srbshield = {
	[MT_FORCE_BOX] = 1;
	[MT_ARMAGEDDON_BOX] = 1;
	[MT_WHIRLWIND_BOX] = 1;
	[MT_ELEMENTAL_BOX] = 1;
	[MT_FLAMEAURA_BOX] = 1;
	[MT_BUBBLEWRAP_BOX] = 1;
	[MT_THUNDERCOIN_BOX] = 1;
}


local ringboxrandomizer = {
	MT_RING_BOX,
	MT_RING_BOX,
	MT_RING_BOX,
	MT_RING_BOX,
	MT_RING_BOX,
	MT_RING_BOX,
	MT_RING_BOX,
	MT_RING_BOX,
	MT_SA5RING_BOX,
	MT_SA5RING_BOX,
	MT_SA20RING_BOX,
	MT_SA25RING_BOX,
	MT_SA40RING_BOX,
	MT_SARANDRING_BOX,
	MT_SARANDRING_BOX,
	MT_SARANDRING_BOX,
}


addHook("MobjThinker", function(a)
	if (a.info.flags & MF_MONITOR) then
		if a.health >= 1 and not (a.item and a.item.valid and a.caps and a.caps.valid) then
			P_SpawnItemBox(a)
		end

		--	Segment for calling Item Box switch.
		if not a.settedup then
			if leveltime then
				a.dctypemonitor = 2
				if a.floorz > a.z-25*FRACUNIT or (a.flags2 & MF2_OBJECTFLIP and a.ceilingz > a.z+25*FRACUNIT) then
					a.dctypemonitor = 1
				end

				itemBoxSwitching(a, a.dctypemonitor)
			else
				a.flags = $|MF_NOGRAVITY
			end
		end

		-- Monitor Swaps by Cvar.
		if a and a.valid and a.health > 0 then
			if (srbshield[a.type] or a.type == MT_ATTRACT_BOX) and a.info.flags &~ MF_GRENADEBOUNCE then
				if CV_FindVar("dc_replaceshields").value and srbshield[a.type] then
					local replacement = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_ATTRACT_BOX)
					replacement.orgcapsule = a.type
					P_RemoveMobj(a)
				elseif not (CV_FindVar("dc_replaceshields").value) and a.type == MT_ATTRACT_BOX and a.orgcapsule then
					P_SpawnMobjFromMobj(a, 0, 0, 0, a.orgcapsule)
					P_RemoveMobj(a)
				end
			end

			if a.randomring and (a.type == ringboxrandomizer[a.randomring] or a.type == MT_RING_BOX) then
				if CV_FindVar("dc_ringboxrandomizer").value and a.type ~= ringboxrandomizer[a.randomring] then
					local replacement = P_SpawnMobjFromMobj(a, 0, 0, 0, ringboxrandomizer[a.randomring])
					replacement.randomring = a.randomring
					P_RemoveMobj(a)
				elseif not CV_FindVar("dc_ringboxrandomizer").value and a.type ~= MT_RING_BOX then
					local replacement = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_RING_BOX)
					replacement.randomring = a.randomring
					P_RemoveMobj(a)
				end
			end
		end

		if a and a.valid and a.item and a.item.valid and MonitorSprites[a.item.icsprite] ~= nil then
			P_MarioMonitorThink(a.item, a.item.icsprite, a.item.icframe)
		end

		-- Thinker

		if a and a.valid and a.dctypemonitor == 1 then
			slope_handler.slopeRotation(a)
		end

		if a and a.valid and a.item and a.item.valid and a.caps and a.caps.valid then

			if a.standingslope then
				local angle = slope_handler.slopeRotBaseReturn(a, a.standingslope)
				a.rollangle = angle
				a.caps.rollangle = angle
			else
				a.rollangle = 0
				a.caps.rollangle = 0
			end

			local questionable = min(P_MobjFlip(a) * 80, 25)

			a.item.angle = $+ANG1*4
			P_SetOrigin(a.item, a.x, a.y, a.z+questionable * a.item.scale)

			local curicon = states[mobjinfo[mobjinfo[a.type].damage].spawnstate]

			if a.health >= 1 then
				-- Scale if necessary
				local height = 73*a.scale
				local funny =  FixedDiv(a.caps.ceilingz - a.caps.floorz, height)

				if funny < FRACUNIT then
					a.spriteyscale = funny
					a.item.scale = FixedMul(funny, a.scale)
					a.caps.spriteyscale = funny
				else
					a.spritexscale = FRACUNIT
					a.spriteyscale = FRACUNIT
					a.scale = a.originscale
					a.caps.scale = a.originscale
					a.item.scale = a.spawnpoint and a.spawnpoint.scale or a.originscale
				end

				if a.info.flags & MF_GRENADEBOUNCE and (leveltime % 4)/3 then
					A_GoldMonitorSparkle(a)
					a.goldentimer = nil
				end
			elseif not (a.info.flags & MF_GRENADEBOUNCE) and a.dctypemonitor and a.dctypemonitor == 1 then
				if a.item then
					P_RemoveMobj(a.item)
				end

				if a.caps then
					P_RemoveMobj(a.caps)
				end
			end
		end

		if a and a.health < 1 and a.info.flags & MF_GRENADEBOUNCE then
			if not a.goldentimer then
				a.goldentimer = 0
			end
			a.goldentimer = $+1
			if a.goldentimer == 89 then
				local newitembox = P_SpawnMobjFromMobj(a, 0, 0, 0, a.type)
				newitembox.scale = a.originscale
				P_RemoveMobj(a)
			end
		end

		if not (a and a.valid and a.caps and a.item and a.flags & MF_NOGRAVITY and a.dctypemonitor and a.dctypemonitor > 1) then return end

		local transp = FF_TRANS30

		if a.health < 1 then
			if a.scale > a.originscale*5/2 then
				a.flags2 = $|MF2_DONTDRAW

				if a.item and a.item.valid then
					P_RemoveMobj(a.item)
				end

				if a.caps and a.caps.valid then
					P_RemoveMobj(a.caps)
				end

				P_RemoveMobj(a)
			else
				transp = $+FRACUNIT*2
				a.scale = $+FRACUNIT/14
				a.item.scale = $+FRACUNIT/14
				a.caps.scale = $+FRACUNIT/14

				a.frame = $|transp
				a.caps.frame = $|transp
				a.item.frame = $|transp
				--print(a.scale)
			end

		elseif a.health >= 1 then
			a.frame = $ &~ transp
			a.caps.frame = $ &~ transp
			a.item.frame = $ &~ transp

			transp = FF_TRANS30
			a.item.scale = a.scale+FRACUNIT/3
		end

	end
end)

local function insertPlayerItemToHud(p, sprite, frame)
	if p and not p.boxdisplay then
		p.boxdisplay = {}
	end
	if p and not p.boxdisplay.item then
		p.boxdisplay.item = {}
	end
	p.boxdisplay.timer = TICRATE*3
	table.insert(p.boxdisplay.item, {sprite, frame})
end


addHook("MobjDeath", function(a, d, s)
	if Disable_ItemBox then return end
	if a.info.flags & MF_MONITOR then
		if not a.target then
			if s or d then
				a.target = (s or d)
			else
				a.target = P_LookForPlayers(a, FixedMul(64*FRACUNIT, a.scale), yes)
			end
		end

		S_StartSound(a, a.info.deathsound)

		local boxicon

		if P_MarioExistsThink(a.item) then
			A_MonitorPop(a, 0, 0)
		else
			boxicon = P_SpawnMobjFromMobj(a.item, 0,0,0, mobjinfo[a.type].damage)
			boxicon.scale = a.item.scale
			boxicon.target = a.target
		end

		if a.target.player then
			insertPlayerItemToHud(a.target.player, a.item.sprite, a.item.frame)
		end

		if boxicon and boxicon.valid and a.flags & MF_NOGRAVITY and a.dctypemonitor and a.dctypemonitor > 1 then
			boxicon.flags2 = $|MF2_DONTDRAW
		else
			local smuk = P_SpawnMobjFromMobj(a, 0,0,0, MT_EXTRAERADUMMY)
			smuk.renderflags = a.flags2 & MF2_OBJECTFLIP and ($|RF_VERTICALFLIP) or $
			smuk.state = S_ERASMOKE1
			smuk.fuse = 32
			smuk.scale = a.scale*8/3
			a.state = S_INVISIBLE
			a.sprite = SPR_1CAP
			a.frame = B
			P_RemoveMobj(a.item)
			P_RemoveMobj(a.caps)
		end

		local itemrespawnvalue = CV_FindVar("respawndelay").value

		if (itemrespawnvalue and G_GametypeHasSpectators()) then
			a.fuse = itemrespawnvalue*TICRATE + 2
			a.item.fuse = itemrespawnvalue*TICRATE + 2
		end

		return true
	end
end)

addHook("MobjRemoved", function(a, d)
	if Disable_ItemBox then return end
	if not (gamestate & GS_LEVEL) then return false end
	if a and a.valid and ((a.item and a.item.valid) or (a.caps and a.caps.valid)) and a.info.flags & MF_MONITOR then
		if a.item and a.item.valid then
			P_RemoveMobj(a.item)
		end
		if a.caps and a.caps.valid then
			P_RemoveMobj(a.caps)
		end
	end
end)

addHook("MobjMoveCollide", function(a, mt)
	if Disable_ItemBox then return end
	if mt and mt.valid and (mt.flags & MF_MONITOR) and a.player and a.z <= mt.z+mt.height and a.z >= mt.z and
	not ((a.player.ctfteam == 1 and monitor.type == MT_RING_BLUEBOX) or (a.player.ctfteam == 2 and monitor.type == MT_RING_REDBOX))	then
		mt.target = a
		P_KillMobj(mt, a, a)
		return false
	end
end, MT_PLAYER)

