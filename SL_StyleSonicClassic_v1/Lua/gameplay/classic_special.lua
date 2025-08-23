--[[

		Special Stage Entrance Handler

	While possible to make work in multiplayer, it makes absolutely no sense design wise.
	Therefore no multiplayer support, ever. :P

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
				print("[Classic Styles] Please restart the game or escape to the main menu for changes to take effect.")
				anotherlvl = nil
			end
		end

		change_var = var.value
	end
end, CV_NETVAR)

rawset(_G, "StylesC_SPE", function()
	return special_entrance
end)

local entrance_cv = entrance_opt.cv

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
					if a.state ~= giantring_used then
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
		storage.x = displayplayer.mo.x
		storage.y = displayplayer.mo.y
		storage.z = displayplayer.mo.z
		storage.angle = displayplayer.mo.angle
		storage.scale = displayplayer.mo.scale
		storage.starpostx = displayplayer.starpostx
		storage.starposty = displayplayer.starposty
		storage.starpostz = displayplayer.starpostz
		storage.starpostnum = displayplayer.starpostnum
		storage.starposttime = displayplayer.starposttime
		storage.starpostangle = displayplayer.starpostangle
		storage.starpostscale = displayplayer.starpostscale
		storage.flags = displayplayer.mo.flags &~ MF_NOTHINK
		storage.flags2 = displayplayer.mo.flags2
		storage.eflags = displayplayer.mo.eflags
		storage.player1 = true

		storage.leveltime = leveltime

		if splitscreen and secondarydisplayplayer then
			storage.p2x = secondarydisplayplayer.mo.x
			storage.p2y = secondarydisplayplayer.mo.y
			storage.p2z = secondarydisplayplayer.mo.z
			storage.p2angle = secondarydisplayplayer.mo.angle
			storage.p2scale = secondarydisplayplayer.mo.scale
			storage.p2starpostx = secondarydisplayplayer.starpostx
			storage.p2starposty = secondarydisplayplayer.starposty
			storage.p2starpostz = secondarydisplayplayer.starpostz
			storage.p2starpostnum = secondarydisplayplayer.starpostnum
			storage.p2starposttime = secondarydisplayplayer.starposttime
			storage.p2starpostangle = secondarydisplayplayer.starpostangle
			storage.p2starpostscale = secondarydisplayplayer.starpostscale
			storage.p2flags = secondarydisplayplayer.mo.flags &~ MF_NOTHINK
			storage.p2flags2 = secondarydisplayplayer.mo.flags2
			storage.p2eflags = secondarydisplayplayer.mo.eflags
			storage.player2 = true
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

		if data.delete then
			local checkpoint_trigger = 0

			--
			--	PLAYER 1
			--

			if displayplayer.mo and data.player1 then
				displayplayer.starpostx = data.starpostx
				displayplayer.starposty = data.starposty
				displayplayer.starpostz = data.starpostz
				displayplayer.starpostnum = data.starpostnum
				displayplayer.starposttime = max(data.starposttime, data.leveltime)
				displayplayer.starpostangle = data.starpostangle
				displayplayer.starpostscale = data.starpostscale
				checkpoint_trigger = data.starpostnum

				displayplayer.style_additionaltime = max(data.starposttime, data.leveltime)
				displayplayer.mo.alpha = FU

				displayplayer.mo.flags = data.flags &~ MF_NOTHINK
				displayplayer.mo.flags2 = data.flags2
				displayplayer.mo.eflags = data.eflags

				displayplayer.powers[pw_flashing] = 2*TICRATE

				local subsector = R_PointInSubsectorOrNil(data.x, data.y)

				if subsector and subsector.sector then
					local sector = subsector.sector

					if (sector.damagetype > 0
					or (displayplayer.mo.floorrover and displayplayer.mo.floorrover.sector and displayplayer.mo.floorrover.sector.damagetype > 0)
					or (displayplayer.mo.ceilingrover and displayplayer.mo.ceilingrover.sector and displayplayer.mo.ceilingrover.sector.damagetype > 0))
					and displayplayer.starpostnum > 0 then
						P_SetOrigin(displayplayer.mo, displayplayer.starpostx, displayplayer.starposty, displayplayer.starpostz)
						displayplayer.mo.angle = data.starpostangle
						displayplayer.mo.scale = data.starpostscale
					elseif sector.damagetype == 0
					or (displayplayer.mo.floorrover and displayplayer.mo.floorrover.sector and displayplayer.mo.floorrover.sector.damagetype > 0)
					or (displayplayer.mo.ceilingrover and displayplayer.mo.ceilingrover.sector and displayplayer.mo.ceilingrover.sector.damagetype > 0)	then
						P_SetOrigin(displayplayer.mo, data.x, data.y, data.z)
						displayplayer.mo.angle = data.angle
						displayplayer.mo.scale = data.scale
					end
				end

				data.x = nil
				data.y = nil
				data.z = nil
				data.angle = nil
				data.scale = nil
				data.starpostx = nil
				data.starposty = nil
				data.starpostz = nil
				data.starpostnum = nil
				data.starposttime = nil
				data.starpostangle = nil
				data.starpostscale = nil
				data.flags = nil
				data.flags2 = nil
				data.eflags = nil

				data.player1 = nil
			elseif displayplayer.mo then
				displayplayer.style_additionaltime = 0
			end

			--
			--	PLAYER 2
			--

			if splitscreen and secondarydisplayplayer and secondarydisplayplayer.mo and data.player2 then
				P_SetOrigin(secondarydisplayplayer.mo, data.p2x, data.p2y, data.p2z)
				secondarydisplayplayer.mo.angle = data.p2angle
				secondarydisplayplayer.mo.scale = data.p2scale
				secondarydisplayplayer.starpostx = data.p2starpostx
				secondarydisplayplayer.starposty = data.p2starposty
				secondarydisplayplayer.starpostz = data.p2starpostz
				secondarydisplayplayer.starpostnum = data.p2starpostnum
				secondarydisplayplayer.starposttime = max(data.p2starposttime, data.leveltime)
				secondarydisplayplayer.starpostangle = data.p2starpostangle
				secondarydisplayplayer.starpostscale = data.p2starpostscale
				checkpoint_trigger = max(checkpoint_trigger, data.p2starpostnum)

				secondarydisplayplayer.style_additionaltime = max(data.p2starposttime, data.leveltime)
				secondarydisplayplayer.mo.alpha = FU

				secondarydisplayplayer.mo.flags = data.p2flags &~ MF_NOTHINK
				secondarydisplayplayer.mo.flags2 = data.p2flags2
				secondarydisplayplayer.mo.eflags = data.p2eflags

				secondarydisplayplayer.powers[pw_flashing] = TICRATE

				local subsector = R_PointInSubsectorOrNil(data.x, data.y)

				if subsector and subsector.sector then
					local sector = subsector.sector

					if ((sector.damagetype > 0)
					or (secondarydisplayplayer.mo.floorrover and secondarydisplayplayer.mo.floorrover.sector and secondarydisplayplayer.mo.floorrover.sector.damagetype > 0)
					or (secondarydisplayplayer.mo.ceilingrover and secondarydisplayplayer.mo.ceilingrover.sector and secondarydisplayplayer.mo.ceilingrover.sector.damagetype > 0))
					and secondarydisplayplayer.starpostnum > 0 then
						P_SetOrigin(secondarydisplayplayer.mo, secondarydisplayplayer.starpostx, secondarydisplayplayer.starposty, secondarydisplayplayer.starpostz)
						secondarydisplayplayer.mo.angle = data.starpostangle
						secondarydisplayplayer.mo.scale = data.starpostscale
					elseif sector.damagetype == 0
					or (secondarydisplayplayer.mo.floorrover and secondarydisplayplayer.mo.floorrover.sector and secondarydisplayplayer.mo.floorrover.sector.damagetype > 0)
					or (secondarydisplayplayer.mo.ceilingrover and secondarydisplayplayer.mo.ceilingrover.sector and secondarydisplayplayer.mo.ceilingrover.sector.damagetype > 0) then
						P_SetOrigin(secondarydisplayplayer.mo, data.x, data.y, data.z)
						secondarydisplayplayer.mo.angle = data.angle
						secondarydisplayplayer.mo.scale = data.scale
					end
				end

				data.p2x = nil
				data.p2y = nil
				data.p2z = nil
				data.p2angle = nil
				data.p2scale = nil
				data.p2starpostx = nil
				data.p2starposty = nil
				data.p2starpostz = nil
				data.p2starpostnum = nil
				data.p2starposttime = nil
				data.p2starpostangle = nil
				data.p2starpostscale = nil
				data.p2flags = nil
				data.p2flags2 = nil
				data.p2eflags = nil

				data.player2 = nil
			elseif secondarydisplayplayer and secondarydisplayplayer.mo then
				secondarydisplayplayer.style_additionaltime = 0
			end

			data.leveltime = 0

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

			specialstage_returnevent("Generic", data)
		else
			displayplayer.style_additionaltime = 0
			if splitscreen and secondarydisplayplayer then
				secondarydisplayplayer.style_additionaltime = 0
			end
		end
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

addHook("GameQuit", function()
	maps_data = {}
	last_map = 0

	if change_var > -1 then
		special_entrance = change_var
		change_var = -1
	end
end)

--
--	BIG RING ENTRANCE
--

addHook("MapThingSpawn", function(a)
	if (multiplayer and not splitscreen) then return end
	if specialpackdetected then return end

	if not special_entrance or special_entrance == 3 then
		return
	end

	P_RemoveMobj(a)
end, MT_TOKEN)

addHook("MapThingSpawn", function(a)
	if (multiplayer and not splitscreen) then return end
	if not special_entrance or special_entrance ~= 1 then return end
	if specialpackdetected then return end

	if not All7Emeralds(emeralds) then
		a.ring = P_SpawnMobjFromMobj(a, -200*cos(a.angle+ANGLE_90), -200*sin(a.angle+ANGLE_90), 128*FU, MT_TOKEN)
		a.ring.endleveltoken = true
	end
end, MT_SIGN)

addHook("MobjThinker", function(a)
	if (multiplayer and not splitscreen) then return end
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
	if (multiplayer and not splitscreen) then return end
	if not special_entrance then return end
	if specialpackdetected then return end

	if special_entrance == 3 or special_entrance == 1 then
		a.radius = 89*FU
		a.height = 128*FU
	else
		a.radius = original_radius
		a.height = original_height
	end

	a.state = All7Emeralds(emeralds) and giantring_hyper
	or (special_entrance == 1 and giantring_endstage or giantring)

	a.flags = $|MF_SPECIAL
	a.shadowscale = FU/4
end, MT_TOKEN)

addHook("TouchSpecial", function(a, k)
	if (multiplayer and not splitscreen) then return end
	if not special_entrance then return end
	if specialpackdetected then return end
	return true
end, MT_TOKEN)

addHook("MobjCollide", function(a, k)
	if (multiplayer and not splitscreen) then return end
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

addHook("MobjThinker", function(a)
	-- Token Sprite Switching

	if not special_entrance or specialpackdetected or (multiplayer and not splitscreen) then
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
	if leveltime > 2 and not a.styles_sizecheck then
		P_GiantRingCheck(a)

		a.styles_sizecheck = true
	end

	if not leveltime then
		return false
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
		end
	end
end, MT_TOKEN)

--
-- Bonus Stage Entrance
--

freeslot("SPR_SSS0")

addHook("TouchSpecial", function(a, mt)
	if (multiplayer and not splitscreen) then return end
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
			stars.sprite = SPR_SSS0
			stars.frame = ((i % 2)*3)|FF_TRANS10|FF_FULLBRIGHT
			stars.renderflags = $|AST_ADD
			stars.angle = ang
			stars.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
			table.insert(a.stars, stars)
		end
	end
end,  MT_STARPOST)

addHook("MobjCollide", function(a, mt)
	if (multiplayer and not splitscreen) then return end
	if not special_entrance or special_entrance ~= 2 then return end
	if specialpackdetected then return end

	if mt.player and (mt.z < a.z+a.height+12*FU) and (mt.z > a.z+a.height-32*FU) and a.stars ~= nil and a.stars[1].valid and not a.countdownst then
		SP_SaveState(a)
	end
end,  MT_STARPOST)

addHook("MobjThinker", function(a, mt)
	if (multiplayer and not splitscreen) then return end
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