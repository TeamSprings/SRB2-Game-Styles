--[[

	Monitors

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local life_up_thinker = tbsrequire 'helpers/monitor_1up'
local slope_handler = tbsrequire 'helpers/mo_slope'

freeslot("SPR_MONITORS_CLASSIC",  "SPR_MONITORS_GOLDEN", "SPR_MONITORS_BLUE", "SPR_MONITORS_RED",
"S_DUMMYMONITOR", "S_DUMMYGMONITOR", "S_DUMMYBMONITOR", "S_DUMMYRMONITOR")

states[S_DUMMYMONITOR] = {
	sprite = SPR_MONITORS_CLASSIC,
	frame = A
}

states[S_DUMMYGMONITOR] = {
	sprite = SPR_MONITORS_GOLDEN,
	frame = A
}

states[S_DUMMYBMONITOR] = {
	sprite = SPR_MONITORS_BLUE,
	frame = A
}

states[S_DUMMYRMONITOR] = {
	sprite = SPR_MONITORS_RED,
	frame = A
}

local frame_offset = 0
local icon_height = 0
local monitor_cv = CV_RegisterVar{
	name = "classic_monitor",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		local sets = {0, 3, 10, 6}
		frame_offset = sets[var.value]

		local heights = {14, 20, 15, 14}
		icon_height = heights[var.value]
	end,
	PossibleValue = {sonic1=1, sonic3=2, blast3d=3, mania=4}
}

local monitor_jump_cv = CV_RegisterVar{
	name = "classic_monitormaniajump",
	defaultvalue = "disabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, enabled=1}
}

local monitor_typesa_cv = CV_RegisterVar{
	name = "classic_monitordistribution",
	defaultvalue = "disabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, sonic1=1, sonic3=2, sonicmania=3}
}

local picks = {
	[MT_ATTRACT_BOX] = true,
	[MT_ARMAGEDDON_BOX] = true,
	[MT_WHIRLWIND_BOX] = true,
	[MT_ELEMENTAL_BOX] = true,
	[MT_FORCE_BOX] = true,
	[MT_ATTRACT_GOLDBOX] = true,
	[MT_ARMAGEDDON_GOLDBOX] = true,
	[MT_WHIRLWIND_GOLDBOX] = true,
	[MT_ELEMENTAL_GOLDBOX] = true,
	[MT_FORCE_GOLDBOX] = true,
}

local sets = {
	[1] = { -- Sonic 1
		[MT_ATTRACT_BOX] = MT_PITY_BOX,
		[MT_ARMAGEDDON_BOX] = MT_PITY_BOX,
		[MT_WHIRLWIND_BOX] = MT_PITY_BOX,
		[MT_ELEMENTAL_BOX] = MT_PITY_BOX,
		[MT_FORCE_BOX] = MT_PITY_BOX,
		[MT_ATTRACT_GOLDBOX] = MT_PITY_GOLDBOX,
		[MT_ARMAGEDDON_GOLDBOX] = MT_PITY_GOLDBOX,
		[MT_WHIRLWIND_GOLDBOX] = MT_PITY_GOLDBOX,
		[MT_ELEMENTAL_GOLDBOX] = MT_PITY_GOLDBOX,
		[MT_FORCE_GOLDBOX] = MT_PITY_GOLDBOX,
	},

	[2] = { -- Sonic 3
		[MT_ATTRACT_BOX] = MT_THUNDERCOIN_BOX,
		[MT_ARMAGEDDON_BOX] = MT_BUBBLEWRAP_BOX,
		[MT_WHIRLWIND_BOX] = MT_THUNDERCOIN_BOX,
		[MT_ELEMENTAL_BOX] = MT_BUBBLEWRAP_BOX,
		[MT_FORCE_BOX] = MT_FLAMEAURA_BOX,
		[MT_ATTRACT_GOLDBOX] = MT_THUNDERCOIN_GOLDBOX,
		[MT_ARMAGEDDON_GOLDBOX] = MT_BUBBLEWRAP_GOLDBOX,
		[MT_WHIRLWIND_GOLDBOX] = MT_THUNDERCOIN_GOLDBOX,
		[MT_ELEMENTAL_GOLDBOX] = MT_BUBBLEWRAP_GOLDBOX,
		[MT_FORCE_GOLDBOX] = MT_FLAMEAURA_GOLDBOX,
	},

	[3] = { -- Mania
		[MT_ATTRACT_BOX] = MT_FLAMEAURA_BOX,
		[MT_ARMAGEDDON_BOX] = MT_PITY_BOX,
		[MT_WHIRLWIND_BOX] = MT_THUNDERCOIN_BOX,
		[MT_ELEMENTAL_BOX] = MT_BUBBLEWRAP_BOX,
		[MT_FORCE_BOX] = MT_PITY_BOX,
		[MT_ATTRACT_GOLDBOX] = MT_FLAMEAURA_GOLDBOX,
		[MT_ARMAGEDDON_GOLDBOX] = MT_PITY_GOLDBOX,
		[MT_WHIRLWIND_GOLDBOX] = MT_THUNDERCOIN_GOLDBOX,
		[MT_ELEMENTAL_GOLDBOX] = MT_BUBBLEWRAP_GOLDBOX,
		[MT_FORCE_GOLDBOX] = MT_PITY_GOLDBOX,
	},
}


local function P_SpawnItemBox(a)
	if not multiplayer and monitor_typesa_cv.value and picks[a.type] then
		if sets[monitor_typesa_cv.value][a.type] then
			P_SpawnMobjFromMobj(a, 0, 0, 0, sets[monitor_typesa_cv.value][a.type])
		end

		P_RemoveMobj(a)
		return
	end

	if a.info.flags & MF_GRENADEBOUNCE then
		a.state = S_DUMMYGMONITOR
	else
		a.state = S_DUMMYMONITOR
	end

	if a.type == MT_RING_REDBOX then
		a.state = S_DUMMYRMONITOR
	end

	if a.type == MT_RING_BLUEBOX then
		a.state = S_DUMMYBMONITOR
	end

	local icon = mobjinfo[a.type].damage
	local icstate = mobjinfo[icon].spawnstate
	local icsprite = states[icstate].sprite
	local icframe = states[icstate].frame

	a.item = P_SpawnMobjFromMobj(a, 0,0, P_MobjFlip(a)*14*FRACUNIT, MT_FRONTTIERADUMMY)
	a.item.state = S_INVISIBLE
	a.item.sprite = icsprite
	a.item.frame = icframe
	a.item.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
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
		a.frame = typepw
		a.spriteyoffset = -FRACUNIT*16
	else
		a.sprite = sprite
		a.frame = oldframe
	end
end

local function P_MonitorThinker(a)
	if (a and a.valid and a.info.flags & MF_MONITOR) then
		if not a.originscale then
			a.originscale = (a.spawnpoint and a.spawnpoint.scale or a.scale)
		end

		-- Handle things even while dead
		slope_handler.slopeRotation(a)

		if a.health > 0 then
			-- Alive state
			if a.item and a.item.valid then
				a.flags = $|MF_SOLID

				local flip = (P_MobjFlip(a) < 0) or false

				-- Static Behavior
				P_SetOrigin(a.item, a.x, a.y, a.z+(P_MobjFlip(a) * (icon_height + (flip and -16 or 0)))*a.item.spriteyscale)
				a.item.rollangle = a.rollangle

				-- Static Animation
				if (leveltime % 3) then
					a.item.flags2 = $ &~ MF2_DONTDRAW
					a.frame = frame_offset
				else
					a.item.flags2 = $|MF2_DONTDRAW
					a.frame = frame_offset+1

				end

				-- Mario Monitors
				if MonitorSprites[a.item.icsprite] then
					P_MarioMonitorThink(a.item, a.item.icsprite, a.item.icframe)
				end

				-- Golden Monitors
				if a.info.flags & MF_GRENADEBOUNCE and (leveltime % 4)/3 then
					A_GoldMonitorSparkle(a)
					a.goldentimer = nil
				end

				-- Squash in tiny spaces
				local height = 64*a.scale
				local funny = flip and FixedDiv(a.ceilingz - a.floorz, height) or FixedDiv(a.ceilingz - a.z, height)

				if funny < FRACUNIT then
					a.spriteyscale = funny
					a.item.spriteyscale = funny
				else
					a.spriteyscale = FRACUNIT
					a.item.spriteyscale = FRACUNIT
				end
			else
				-- Spawns all necessary components
				P_SpawnItemBox(a)
			end
		else
			-- Dying State
			a.flags = $ &~ MF_SOLID

			-- Golden monitors
			if a.info.flags & MF_GRENADEBOUNCE then
				if not a.goldentimer then
					a.goldentimer = 0
				end

				a.goldentimer = $+1

				if a.goldentimer == TICRATE then
					local newitembox = P_SpawnMobjFromMobj(a, 0, 0, 0, a.type)
					newitembox.scale = a.originscale
					newitembox.alpha = FRACUNIT
					P_RemoveMobj(a)
					return
				end
			end

			if a.item and a.item.valid then
				P_RemoveMobj(a.item)
			end
		end
	end
end

local function P_MonitorDeath(a, d, s)
	if a.health < 0 and a.once_already then return end

	if not a.target then
		if s or d then
			a.target = (s or d)
		else
			a.target = P_LookForPlayers(a, FixedMul(64*FRACUNIT, a.scale), yes)
		end
	end

	if (monitor_jump_cv.value > 0) then
		a.momz = $+4*P_MobjFlip(a)*a.scale
	end

	S_StartSound(a, a.info.deathsound)

	local boxicon

	if P_MarioExistsThink(a.item) then
		A_MonitorPop(a, 0, 0)
	else
		if mobjinfo[a.type].damage == MT_UNKNOWN then
			A_MonitorPop(a, 0, 0)
		else
			boxicon = P_SpawnMobjFromMobj(a.item, 0,0,0, mobjinfo[a.type].damage)
			boxicon.scale = a.item.scale
			boxicon.target = a.target

			-- Clipped code from Source code for life icons
			if boxicon.type == MT_1UP_ICON and boxicon.target then
				-- Spawn the lives icon.
				local livesico = P_SpawnMobjFromMobj(boxicon, 0, 0, 0, MT_OVERLAY)
				livesico.target = boxicon
				livesico.color = boxicon.target.player.mo.color
				livesico.skin = boxicon.target.player.mo.skin
				livesico.state = S_PLAY_ICON1
				livesico.dispoffset = 2

				boxicon.state = S_1UP_NICON1
			end
		end
	end

	if boxicon and boxicon.valid and a.flags & MF_NOGRAVITY then
		boxicon.flags2 = $|MF2_DONTDRAW
	else
		local smuk = P_SpawnMobjFromMobj(a, 0,0,0, MT_EXTRAERADUMMY)
		smuk.state = S_XPLD1
		smuk.fuse = 32
		smuk.scale = a.scale
		a.frame = frame_offset + 2
		P_RemoveMobj(a.item)
	end

	local itemrespawnvalue = CV_FindVar("respawnitemtime").value

	if (itemrespawnvalue and G_GametypeHasSpectators()) then
		a.fuse = itemrespawnvalue*TICRATE + 2
	end

	a.once_already = true

	return true
end

local function P_MonitorRemoval(a, d)
	if not (gamestate & GS_LEVEL) then return end
	if not (a and a.valid) then return end

	if a.item and a.item.valid then
		P_RemoveMobj(a.item)
	end
end

--
--	Special 1UP_BOX handling
--

addHook("MobjSpawn", P_SpawnItemBox, MT_1UP_BOX)
addHook("MobjThinker", function(a)
	P_MonitorThinker(a)
	if a.health > 0 and a.item then
		life_up_thinker(a.item)
	end
end, MT_1UP_BOX)
addHook("MobjDeath", P_MonitorDeath, MT_1UP_BOX)
addHook("MobjRemoved", P_MonitorRemoval, MT_1UP_BOX)

--
--	Special Random Monitor handling
--

addHook("MobjSpawn", P_SpawnItemBox, MT_MYSTERY_BOX)
addHook("MobjThinker", function(a)
	if Disable_ItemBox then return end

	P_MonitorThinker(a)
	if a.item and a.item.valid then
		a.item.sprite = SPR_TVMY
		a.item.frame = C|(a.item.frame &~ FF_FRAMEMASK)
	end
end, MT_MYSTERY_BOX)
addHook("MobjDeath", P_MonitorDeath, MT_MYSTERY_BOX)
addHook("MobjRemoved", P_MonitorRemoval, MT_MYSTERY_BOX)

--
--	Monitor Register
--

local monitor_database = {}
monitor_database[MT_1UP_BOX] = 1
monitor_database[MT_MYSTERY_BOX] = 1

local function P_AddMonitor(mobjtype)
	if not monitor_database[mobjtype] then
		addHook("MobjSpawn", P_SpawnItemBox, mobjtype)
		addHook("MobjThinker", P_MonitorThinker, mobjtype)
		addHook("MobjDeath", P_MonitorDeath, mobjtype)
		addHook("MobjRemoved", P_MonitorRemoval, mobjtype)
		monitor_database[mobjtype] = 1
	end
end

-- This checks every mobjinfo slot, parameter being start of from where it should search in the Mobjinfo list.
local function P_CheckNewMonitors(start)
	local count = 0

	for i = start, #mobjinfo do
		if i == 1675 then break end

		if mobjinfo[i] and mobjinfo[i].flags & MF_MONITOR then
			P_AddMonitor(i)
			count = $ + 1
		end
	end

	if count then
		print("[Monitor Checker] "..count.." Monitors Types Found!")
	end
end

addHook("AddonLoaded", function()
	P_CheckNewMonitors(MT_BOXSPARKLE)
end)