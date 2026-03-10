--[[

		Special Stage Entrance Handler

Contributors: Skydusk
@Team Blue Spring 2022-2025

TODO: Copypaste Events & Document

]]

local Options = tbsrequire('helpers/create_cvar')
local api = tbsrequire 'styles_api'

-- Hooks for API

local specialstage_saveevent = 		api:addHook("SpecialEntry")
local specialstage_returnevent = 	api:addHook("SpecialReturn")

local giantring = freeslot("S_GIANTRING_CLASSIC")
states[giantring] = {
	sprite = freeslot("SPR_GIANTRING_CLASSIC"),
	frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	var1 = 23,
	var2 = 1,
}

local giantring_hyper = freeslot("S_GIANTRING_HYPER")
states[giantring_hyper] = {
	sprite = freeslot("SPR_GIANTRING_HYPER"),
	frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	var1 = 23,
	var2 = 1,
}

local giantring_tiny = freeslot("S_GIANTRING_TINY")
states[giantring_tiny] = {
	sprite = freeslot("SPR_GIANTRING_TINY"),
	frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	var1 = 23,
	var2 = 1,
}

local giantring_tinyhyper = freeslot("S_GIANTRING_HINY")
states[giantring_tinyhyper] = {
	sprite = freeslot("SPR_GIANTRING_HINY"),
	frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	var1 = 23,
	var2 = 1,
}

local giantring_flash = freeslot("S_GIANTRING_FLASH")
states[giantring_flash] = {
	sprite = freeslot("SPR_GIANTRING_FLASH"),
	frame = A|FF_ANIMATE|FF_ADD|FF_FULLBRIGHT,
	tics = 12,
	var1 = 11,
	var2 = 1,

	nextstate = S_NULL,
}

local giantring_used = freeslot("S_GIANTRING_USED")
states[giantring_used] = {
	sprite = freeslot("SPR_GIANTRING_USED"),
	frame = A|FF_ANIMATE|FF_ADD|FF_TRANS50,
	var1 = 23,
	var2 = 1,
}

local giantring_endstage = freeslot("S_GIANTRING_ENDSTAGE")
states[giantring_endstage] = {
	sprite = freeslot("SPR_GIANTRING_END"),
	frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	var1 = 23,
	var2 = 1,
}

local original_radius = mobjinfo[MT_TOKEN].radius
local original_height = mobjinfo[MT_TOKEN].height

local special_entrance = 1
local change_var = -1
local init = true
local anotherlvl = nil
local specialpackdetected = false

local token_sprite = Options:new("tokensprite", "assets/tables/sprites/tokens", nil)

local entrance_opt = Options:new("specialentrance", "gameplay/cvars/specialtoken", function(var)
	if init or gamestate == GS_TITLESCREEN then
		special_entrance = var.value
		init = nil
	else
		if multiplayer then
			if consoleplayer == displayplayer then
				print("[Classic Styles] This console variable is disabled in multiplayer.")
			end
		else
			-- first of many cheating measures
			if change_var == -1 or anotherlvl then
				print("[Classic Styles] Please restart the game for the change to take effect.")
				anotherlvl = nil
			end
		end

		change_var = var.value
	end
end, CV_NETVAR)

local force_opt = Options:new("forcespecial", {{false, "disable", "Disabled"}, {true, "enable", "Enabled"}}, nil, CV_NETVAR)

rawset(_G, "StylesC_SPE", function()
	return special_entrance
end)

rawset(_G, "Styles_SpecialEntryAvailable", function()
	local forced = force_opt()

	if forced then
		return true
	elseif (multiplayer and not splitscreen) then
		return false
	end

	return true
end)

--
--	Functions
--

local maps_data = {}
local last_map = 0

local function P_GiantRingCheck(a)
	if not special_entrance then return end

	if a.type == MT_TOKEN or a.type == MT_GFZFLOWER2 then
		local height = a.height * P_MobjFlip(a)

		-- Mappers can disable it's size changes
		if not (a.styles_nochecks or (a.spawnpoint and a.spawnpoint.args[3])) then
			if (a.ceilingz - a.z) >= height
			and (a.z - a.floorz) < height then
				return
			else
				if a.state ~= giantring_endstage then
					if a.state == giantring_used then
						a.flags2 = MF2_DONTDRAW
					else
						a.state = (a.state == giantring and giantring_tiny or giantring_tinyhyper)
					end
					a.scale = a.scale/4
				end
			end
		end
	end
end

local function SP_SaveState(mobj, toucher)
	if All7Emeralds(emeralds) then
		if toucher.player then
			toucher.player.rings = $+50
		end

		P_RemoveMobj(mobj)
		return
	end

	if not maps_data[gamemap] then
		maps_data[gamemap] = {}
	end

	local mapthing = mobj.spawnpoint

	if mapthing then
		local storage = maps_data[gamemap]

		storage.leveltime = leveltime
		storage.players = {}

		for player in players.iterate() do
			if not ((player.mo and player.mo.valid) or (player.realmo and player.realmo.valid)) then continue end

			storage.players[#player] = {}
			local store = storage.players[#player]
			local mo = player.realmo or player.mo

			store.x = mo.x
			store.y = mo.y
			store.z = mo.z

			store.angle = mo.angle
			store.scale = mo.scale

			store.starpostx      = player.starpostx
			store.starposty      = player.starposty
			store.starpostz      = player.starpostz

			store.starpostnum    = player.starpostnum
			store.starposttime   = player.starposttime
			store.starpostangle  = player.starpostangle
			store.starpostscale  = player.starpostscale

			store.flags          = mo.flags &~ MF_NOTHINK
			store.flags2         = mo.flags2
			store.eflags         = mo.eflags
		end

		if not maps_data[gamemap].delete then
			maps_data[gamemap].delete = {}
		end

		if mobj.type == MT_TOKEN and mobj.spawnpoint and mobj.spawnpoint.valid then
			table.insert(maps_data[gamemap].delete, #mapthing)
		end

		specialstage_saveevent(mobj.type, storage, last_map)
	end

	last_map = gamemap
	if not token then
		token = 1
	end

	displayplayer.styles_exitcut = nil
	G_SetCustomExitVars(nil, 1, nil, nil)
	G_ExitLevel()
end

local function SP_LoadState(map)
	if maps_data[map] then
		local data = maps_data[map]
		local checkpoint_trigger = 0

		if data.players then
			for player in players.iterate() do
				if not ((player.mo and player.mo.valid) or (player.realmo and player.realmo.valid)) then
					continue
				end

				local mo = player.realmo or player.mo

				if not data.players[#player] then
					if mo then player.style_additionaltime = 0 end
					continue
				end

				local store = data.players[#player]

				player.starpostx     = store.starpostx
				player.starposty     = store.starposty
				player.starpostz     = store.starpostz
				player.starpostnum   = store.starpostnum
				player.starposttime  = max(store.starposttime, data.leveltime or 0)
				player.starpostangle = store.starpostangle
				player.starpostscale = store.starpostscale

				checkpoint_trigger   = max(store.starpostnum, checkpoint_trigger)

				mo.alpha = FU

				mo.flags  = store.flags &~ MF_NOTHINK
				mo.flags2 = store.flags2
				mo.eflags = store.eflags

				player.powers[pw_flashing] = 2*TICRATE
				player.style_additionaltime = max(store.starposttime, data.leveltime or 0)

				local subsector = R_PointInSubsectorOrNil(store.x, store.y)

				if subsector and subsector.sector then
					local sector = subsector.sector

					if (sector.damagetype > 0
					or (mo.floorrover and mo.floorrover.sector and mo.floorrover.sector.damagetype > 0)
					or (mo.ceilingrover and mo.ceilingrover.sector and mo.ceilingrover.sector.damagetype > 0))
					and player.starpostnum > 0 then
						P_SetOrigin(mo, store.starpostx, store.starposty, store.starpostz)
						mo.angle = store.starpostangle
						mo.scale = store.starpostscale
					elseif sector.damagetype == 0
					or (mo.floorrover and mo.floorrover.sector and mo.floorrover.sector.damagetype > 0)
					or (mo.ceilingrover and mo.ceilingrover.sector and mo.ceilingrover.sector.damagetype > 0)	then
						P_SetOrigin(mo, store.x, store.y, store.z)
						mo.angle = store.angle
						mo.scale = store.scale
					end
				end

				data.players[#player] = nil
			end
		end

		if data.delete then
			for _,v in ipairs(data.delete) do
				if mapthings[v] and mapthings[v].mobj then
					local replacement = P_SpawnMobjFromMobj(mapthings[v].mobj, 0, 0, 0, MT_GFZFLOWER2)
					P_RemoveMobj(mapthings[v].mobj)
					replacement.state = giantring_used
					replacement.flags = $|MF_NOGRAVITY
					P_GiantRingCheck(replacement)

					replacement.styles_sizecheck = true
				end
			end
		end

		if checkpoint_trigger then
			for mobj in mobjs.iterate() do
				if mobj.type ~= MT_STARPOST then
					continue
				end

				if mobj.health > checkpoint_trigger then
					continue
				end

				mobj.state = S_STARPOST_FLASH
			end
		end

		data.leveltime = 0

		specialstage_returnevent("Generic", data)
	end
end

addHook("MapLoad", function()
	if not special_entrance then return end

	if last_map then
		G_SetCustomExitVars(last_map, 0, nil, nil)
		last_map = nil
	end

	if maps_data[gamemap] and not specialpackdetected then
		SP_LoadState(gamemap)
	else
		for p in players.iterate do
			p.style_additionaltime = 0
		end
	end

	anotherlvl = true
end)

local init_ch = true
local list = tbsrequire 'gameplay/compact/specialpacks'

addHook("AddonLoaded", function()
	if init_ch and change_var > -1 then
		special_entrance = change_var
		change_var = -1

		init_ch = nil
	end

	if list and not specialpackdetected then
		for _,v in ipairs(list) do
			if _G[v] then
				specialpackdetected = true
				return
			end
		end
	end
end)

addHook(demoplayback == nil and "GameQuit" or "GameStart", function()
	maps_data = {}
	last_map = 0

	if change_var > -1 then
		special_entrance = change_var
		change_var = -1
	end
end)

addHook("NetVars", function(net)
	special_entrance = net($)
	last_map = net($)

	maps_data = net($)
end)

--
--	BIG RING ENTRANCE
--

addHook("MapThingSpawn", function(a)
	if not Styles_SpecialEntryAvailable() then return end
	if specialpackdetected then return end

	if not special_entrance or special_entrance == 3 then
		return
	end

	P_RemoveMobj(a)
end, MT_TOKEN)

addHook("MapThingSpawn", function(a)
	if not Styles_SpecialEntryAvailable() then return end
	if not special_entrance or special_entrance ~= 1 then return end
	if specialpackdetected then return end

	if not All7Emeralds(emeralds) then
		a.ring = P_SpawnMobjFromMobj(a, -200*cos(a.angle+ANGLE_90), -200*sin(a.angle+ANGLE_90), 128*FU, MT_TOKEN)
		a.ring.endleveltoken = true
	end
end, MT_SIGN)

addHook("MobjThinker", function(a)
	if not Styles_SpecialEntryAvailable() then return end
	if not special_entrance or special_entrance ~= 1 then return end
	if specialpackdetected then return end

	if a.ring and a.ring.valid then
		if consoleplayer and consoleplayer.rings >= 50 then
			a.ring.flags2 = $ &~ MF2_DONTDRAW
		else
			a.ring.flags2 = $|MF2_DONTDRAW
		end
	end
end, MT_SIGN)

addHook("MobjSpawn", function(a)
	if not Styles_SpecialEntryAvailable() then return end
	if not special_entrance then return end
	if specialpackdetected then return end

	if special_entrance == 3 or special_entrance == 1 then
		a.radius = 89*FU
		a.height = 128*FU
	else
		a.radius = original_radius
		a.height = original_height
	end

	if All7Emeralds(emeralds) then
		a.state = giantring_hyper
	else
		a.state = (special_entrance == 1 and giantring_endstage or giantring)
	end

	if special_entrance == 3 then
		a.styles_scalingtimer = 0
		a.styles_scaling = a.spritexscale
	end

	a.flags = $|MF_SPECIAL
	a.shadowscale = FU/4
end, MT_TOKEN)

addHook("TouchSpecial", function(a, k)
	if not Styles_SpecialEntryAvailable() then return end
	if not special_entrance then return end
	if specialpackdetected then return end
	return true
end, MT_TOKEN)

addHook("MobjCollide", function(a, k)
	if not Styles_SpecialEntryAvailable() then return end
	if not special_entrance then return false end
	if specialpackdetected then return end
	if not k.player then return false end

	if a.levelcountdown then
		return false
	end

	if not leveltime then
		return false
	end

	if not (a.flags2 & MF2_DONTDRAW) then
		if special_entrance == 3
		and a.z < k.z+k.height and a.z+a.height > k.z then
			if a.state == giantring or a.state == giantring_tiny then
				a.state = giantring_flash
				k.flags = $|MF_NOTHINK
				k.alpha = 0

				a.levelcountdown = 10
				a.playertoucher = k
				k.player.powers[pw_shield] = 0
				k.player.powers[pw_invulnerability] = 0
				k.player.powers[pw_sneakers] = 0

				S_StartSound(nil, sfx_s3kb3, k.player)
				S_FadeMusic(0, MUSICRATE/4, k.player)
			elseif a.state == giantring_hyper or a.state == giantring_tinyhyper then
				a.state = giantring_flash
				P_GivePlayerRings(k.player, 50)
				S_StartSound(nil, sfx_token, k.player)
			end
		elseif special_entrance == 1 then
			if a.state == giantring_endstage or a.state == giantring_tiny then
				a.state = giantring_flash

				displayplayer.styles_exitcut = nil

				S_StartSound(nil, sfx_s3kb3, k.player)
				k.player.powers[pw_shield] = 0
				k.player.powers[pw_invulnerability] = 0
				k.player.powers[pw_sneakers] = 0
				k.alpha = 0

				if not token then
					token = 1
				end
			end
		end
	end

	return false
end, MT_TOKEN)

local ringsize_playerdist = 2048
local ringsize_speed = FU / (3 * TICRATE / 2)

addHook("MobjThinker", function(a)
	-- Token Sprite Switching

	if not special_entrance or specialpackdetected or not Styles_SpecialEntryAvailable() then
		local sprite = Options:getPureValue("tokensprite")

		if a.health > 0 and a.state ~= sprite[1] then
			a.state = sprite[1]
			a.spritexscale = sprite[2]
			a.spriteyscale = sprite[2]
			a.extravalue1 = 1991
		elseif a.health < 1 and a.extravalue1 then
			a.spritexscale = FU
			a.spriteyscale = FU
			a.extravalue1 = 0
		end

		return
	end

	-- Making sure that FOFs are loaded before checking, can't use mobj spawn due to order of things.
	if not a.styles_sizecheck and leveltime > 2 then
		P_GiantRingCheck(a)

		if a.state ~= giantring and a.state ~= giantring_hyper then
			a.styles_noscaling = true
		end

		a.styles_sizecheck = true
	end

	if not leveltime then
		return false
	end

	if a.styles_sizecheck and special_entrance == 3 and not a.styles_noscaling then
		local nearbyplayer = P_LookForPlayers(a, ringsize_playerdist * a.scale, true)

		if nearbyplayer and a.target and P_CheckSight(a.target, a) then
			if a.styles_scalingtimer < FU then
				a.styles_scalingtimer = $ + ringsize_speed

				if a.styles_scalingtimer > FU then
					a.styles_scalingtimer = FU
				end
			end
		else
			if a.styles_scalingtimer > 0 then
				a.styles_scalingtimer = $ - ringsize_speed

				if a.styles_scalingtimer < 0 then
					a.styles_scalingtimer = 0
				end
			end
		end

		
		a.spritexscale = ease.linear(a.styles_scalingtimer, 8, a.styles_scaling)
		a.spriteyscale = a.spritexscale

		a.spriteyoffset = ease.linear(a.styles_scalingtimer, 168*FU, 0)
	end

	if a.levelcountdown then
		a.levelcountdown = $-1

		if a.levelcountdown == 1 then
			if special_entrance == 3 then
				SP_SaveState(a, a.playertoucher)
				return true
			else
				G_ExitLevel()
			end
		end
	end
	if a.state == giantring_flash then
		if leveltime % 2 then
			local star = P_SpawnMobjFromMobj(a,
			FixedMul(a.radius, cos(ANG1*P_RandomRange(0,360))),
			FixedMul(a.radius, sin(ANG1*P_RandomRange(0,360))),
			P_RandomRange(0, a.height/FU)*FU, MT_SUPERSPARK)
			star.color = SKINCOLOR_GOLD
			star.colorized = true
			star.rollangle = P_RandomKey(360) * ANG1
		end
	end
end, MT_TOKEN)

--
-- Bonus Stage Entrance
--

freeslot("SPR_SPECIALENTRANCE_S2")

addHook("TouchSpecial", function(a, mt)
	if not Styles_SpecialEntryAvailable() then return end
	if not special_entrance or special_entrance ~= 2 then return end
	if specialpackdetected then return end

	if mt.player and mt.player.rings >= 25 and a.state == a.info.spawnstate and a.stars == nil then
		a.stars = {}
		a.stfuse = 350
		a.countdownst = 50

		for i = 1,16 do
			local ang = a.angle + i*ANG1*((360*FU/16)/FU)
			local stars = P_SpawnMobjFromMobj(a, 4*cos(ang), 4*sin(ang), a.height, MT_BUSH)
			stars.state = S_INVISIBLE
			stars.sprite = SPR_SPECIALENTRANCE_S2
			stars.frame = ((i % 2)*3)|FF_TRANS10|FF_FULLBRIGHT
			stars.renderflags = $|AST_ADD
			stars.angle = ang
			stars.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
			table.insert(a.stars, stars)
		end
	end
end,  MT_STARPOST)

addHook("MobjCollide", function(a, mt)
	if not Styles_SpecialEntryAvailable() then return end
	if not special_entrance or special_entrance ~= 2 then return end
	if specialpackdetected then return end

	if mt.player and (mt.z < a.z+a.height+12*FU) and (mt.z > a.z+a.height-32*FU) and a.stars ~= nil and a.stars[1].valid and not a.countdownst then
		SP_SaveState(a)
	end
end,  MT_STARPOST)

addHook("MobjThinker", function(a, mt)
	if not Styles_SpecialEntryAvailable() then return end
	if not special_entrance or special_entrance ~= 2 then return end
	if specialpackdetected then return end

	if a.vangle == nil then
		a.vangle = 0
	end

	a.vangle = $+ANG1*5
	if a.stars ~= nil then
		if a.countdownst > 0 and a.stfuse > 50 then
			a.countdownst = $-1
		end
		if a.stfuse > 0 then
			a.stfuse = $-1
		end

		if a.stfuse <= 50 then
			a.countdownst = $+1
		end

		for i,star in ipairs(a.stars) do
			star.angle = $+4*ANG1
			star.frame = (((i % 2)*3+a.stfuse/4) % 6)|FF_TRANS10|FF_FULLBRIGHT
			star.alpha = FU-a.countdownst*FU/100

			P_SetOrigin(star, a.x+(55-a.countdownst)*cos(star.angle), a.y+(55-a.countdownst)*sin(star.angle), a.z+a.height+(12-a.countdownst/4)*sin(a.vangle+star.angle))
			if a.stfuse == 0 then
				a.stars = nil
				P_RemoveMobj(star)
			end
		end
	end
end,  MT_STARPOST)