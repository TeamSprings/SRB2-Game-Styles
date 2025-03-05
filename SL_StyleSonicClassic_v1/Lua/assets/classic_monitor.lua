--[[

	Monitors

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

freeslot("SPR_MONITORS_CLASSIC",  "SPR_MONITORS_GOLDEN", "SPR_MONITORS_BLUE", "SPR_MONITORS_RED",
"S_DUMMYMONITOR", "S_DUMMYGMONITOR", "S_DUMMYBMONITOR", "S_DUMMYRMONITOR")

local Options = tbsrequire('helpers/create_cvar')

local life_up_thinker = tbsrequire 'helpers/monitor_1up'
local slope_handler = tbsrequire 'helpers/mo_slope'
local api = tbsrequire 'styles_api'

-- Hooks for API

local spawnhook = 	api:addHook("MonitorSpawn")
local deathhook = 	api:addHook("MonitorDeath")
local loothook = 	api:addHook("MonitorLoot")

local remhook = 	api:addHook("MonitorRemoval")

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

local style = Options:new("monitor", "assets/tables/sprites/monitor", function(var)
	local sets = {13, 0, 3, 10, 6}
	frame_offset = sets[var.value]

	local heights = {14, 14, 20, 15, 14}
	icon_height = heights[var.value]
end)

local monitor_jump_cv = CV_RegisterVar{
	name = "classic_monitormaniajump",
	defaultvalue = "disabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, enabled=1}
}

local monitor_typesa_opt = Options:new("monitordistribution", "assets/tables/monitor_distrb", nil, CV_NETVAR)
local monitor_typesa_cv = monitor_typesa_opt.cv

local MonitorSprites, P_MarioExistsThink, P_MarioMonitorThink = unpack(tbsrequire('assets/compact/classic_mario'))
local picks, sets = tbsrequire 'assets/tables/monitor_sets'

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

	local icon = mobjinfo[a.type].damage
	local icstate = mobjinfo[icon].spawnstate
	local icsprite = states[icstate].sprite
	local icframe = states[icstate].frame

	a.item = P_SpawnMobjFromMobj(a, 0,0, P_MobjFlip(a)*14*FRACUNIT, MT_FRONTTIERADUMMY)
	a.item.state = S_INVISIBLE
	a.item.sprite = icsprite
	a.item.frame = icframe
	a.item.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT

	if a.info.spawnstate == S_RING_BLUEBOX1 then
		a.state = S_DUMMYBMONITOR
	elseif a.info.spawnstate == S_RING_REDBOX1 then
		a.state = S_DUMMYRMONITOR
	elseif G_GametypeHasTeams() then
		a.color = SKINCOLOR_APPLE
		a.colorized = true
	end

	spawnhook(a.type, a, a.item, a.caps)
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
			-- Golden monitors
			if a.info.flags & MF_GRENADEBOUNCE then
				a.flags = MF_SOLID

				if not a.goldentimer then
					a.goldentimer = 0
				end

				a.goldentimer = $+1

				if a.goldentimer == 5*TICRATE then
					--local newitembox = P_SpawnMobjFromMobj(a, 0, 0, 0, a.type)
					--newitembox.scale = a.originscale
					--newitembox.alpha = FRACUNIT
					--newitembox.flags = a.info.flags
					--P_RemoveMobj(a)
					P_SpawnItemBox(a)
					a.flags = $|a.info.flags
					a.health = 1

					-- Static Animation
					if (leveltime % 3) then
						a.item.flags2 = $ &~ MF2_DONTDRAW
						a.frame = frame_offset
					else
						a.item.flags2 = $|MF2_DONTDRAW
						a.frame = frame_offset+1
					end

					return
				end
			else
				-- Dying State
				a.flags = $ &~ MF_SOLID
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
	if not loothook(a.type, a, a.item) then
		if P_MarioExistsThink(a.item) then
			A_MonitorPop(a, 0, 0)
		else
			if a.special_case then
				a.special_case(a, a.item, a.target)
			elseif mobjinfo[a.type].damage == MT_UNKNOWN then
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

				if (a.spawnpoint and a.spawnpoint.args[0]) then
					P_LinedefExecute(a.spawnpoint.args[0], a.target, nil)
				end
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

	if (itemrespawnvalue ~= nil and G_GametypeHasSpectators()) then
		a.fuse = itemrespawnvalue*TICRATE + 2
	end

	a.once_already = true

	deathhook(a.type, a, a.item, a.caps, boxicon)
	return true
end

local function P_MonitorRemoval(a, d)
	if not (gamestate & GS_LEVEL) then return end
	if not a then return end

	if a.item and a.item.valid then
		P_RemoveMobj(a.item)
	end

	remhook(a.type, a, a.item, a.caps)
end

--
--	Special 1UP_BOX handling
--

addHook("MobjSpawn", P_SpawnItemBox, MT_1UP_BOX)
addHook("MobjThinker", function(a)
	P_MonitorThinker(a)
	if a and a.valid and a.health > 0 and a.item then
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

local function P_ExcludeMonitors(...)
	local array = {...}
	if not array then return end

	for i = 1, #array do
		local item = array[i]
		monitor_database[item] = 1
	end
end

rawset(_G, "Styles_addMonitor", P_AddMonitor)

local only_monitors_with = {
	[S_BOX_POP1] = true,
	[S_GOLDBOX_OFF1] = true,
	[S_BLUEBOX_POP1] = true,
	[S_REDBOX_POP1] = true,
}

-- This checks every mobjinfo slot, parameter being start of from where it should search in the Mobjinfo list.
local function P_CheckNewMonitors(start)
	local count = 0

	for i = start, #mobjinfo do
		if i == 1675 then break end

		if mobjinfo[i] and mobjinfo[i].flags & MF_MONITOR
		and (i < 458 or only_monitors_with[mobjinfo[i].deathstate]) then
			P_AddMonitor(i)
			count = $ + 1
		end
	end

	if count then
		print("[Monitor Checker] "..count.." Monitors Types Found!")
	end
end

local encore_thinker = nil

addHook("AddonLoaded", function()
	if not encore_thinker and A_EncorePop and _G["MT_ENC_BOX"] then
		encore_thinker = tbsrequire 'assets/compact/classic_encore'

		addHook("MobjSpawn", function(a)
			P_SpawnItemBox(a)
			a.special_case = encore_thinker.pop
		end, MT_ENC_BOX)
		addHook("MobjThinker", function(a)
			P_MonitorThinker(a)
			if a and a.valid and a.health > 0 and a.item and a.item.valid then
				encore_thinker.think(a.item)
			end

			return true
		end, MT_ENC_BOX)
		addHook("MobjDeath", P_MonitorDeath, MT_ENC_BOX)
		addHook("MobjRemoved", P_MonitorRemoval, MT_ENC_BOX)

		monitor_database[MT_ENC_BOX] = 1
	end

	P_CheckNewMonitors(MT_BOXSPARKLE)
end)