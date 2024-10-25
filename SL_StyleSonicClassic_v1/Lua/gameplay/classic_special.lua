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



local original_radius = mobjinfo[MT_TOKEN].radius
local original_height = mobjinfo[MT_TOKEN].height

local special_entrance = 1
local change_var = -1
local entrance_cv = CV_RegisterVar{
	name = "classic_specialentrance",
	defaultvalue = "sonic1",
	flags = CV_CALL|CV_NETVAR,
	func = function(var)
		if multiplayer then
			CONS_Printf(consoleplayer, "[Classic Styles] This console variable has no use in multiplayer.")
		end

		change_var = var.value
	end,
	PossibleValue = {vanilla=0, sonic1=1, sonic2=2, sonic3=3}
}

--
--	Functions
--

local maps_data = {}
local last_map = 0

local function P_GiantRingCheck(a)
	if not special_entrance then return end

	if a.type == MT_TOKEN or a.type == MT_GFZFLOWER2 then

		-- Mappers can disable it's size changes
		if not (a.spawnpoint and a.spawnpoint.args[3]) then
			if (a.ceilingz-a.z) > a.height
			and ((abs(a.z-a.floorz) < 128*FRACUNIT)
			or (abs(a.ceilingz-a.z-a.height) < 128*FRACUNIT)) then
				return
			else
				if a.state ~= giantring_used then
					a.state = (a.state == giantring and giantring_tiny or giantring_tinyhyper)
				end
				a.scale = a.scale/4
			end
		end
	end
end

local function SP_SaveState(mobj)
	if All7Emeralds(emeralds) then
		consoleplayer.rings = $+50
		P_RemoveMobj(mobj)
		return
	end

	if not maps_data[gamemap] then
		maps_data[gamemap] = {}
	end

	local mapthing = mobj.spawnpoint

	if mapthing then
		local storage = maps_data[gamemap]
		storage.x = consoleplayer.mo.x
		storage.y = consoleplayer.mo.y
		storage.z = consoleplayer.mo.z
		storage.angle = consoleplayer.mo.angle
		storage.scale = consoleplayer.mo.scale
		storage.starpostx = consoleplayer.starpostx
		storage.starposty = consoleplayer.starposty
		storage.starpostz = consoleplayer.starpostz
		storage.starpostnum = consoleplayer.starpostnum
		storage.starposttime = consoleplayer.starposttime
		storage.starpostangle = consoleplayer.starpostangle
		storage.starpostscale = consoleplayer.starpostscale

		storage.leveltime = leveltime

		if not maps_data[gamemap].delete then
			maps_data[gamemap].delete = {}
		end

		if mobj.type == MT_TOKEN then
			table.insert(maps_data[gamemap].delete, #mapthing)
		end
	end

	last_map = gamemap
	if not token then
		token = 1
	end
	G_SetCustomExitVars(nil, 1)
	G_ExitLevel()
end


local function SP_LoadState(map)
	if maps_data[map] then
		local data = maps_data[map]

		if data.delete then
			if consoleplayer.mo then
				P_SetOrigin(consoleplayer.mo, data.x, data.y, data.z)
				consoleplayer.mo.angle = data.angle
				consoleplayer.mo.scale = data.scale
				consoleplayer.starpostx = data.starpostx
				consoleplayer.starposty = data.starposty
				consoleplayer.starpostz = data.starpostz
				consoleplayer.starpostnum = data.starpostnum
				consoleplayer.starposttime = data.starposttime
				consoleplayer.starpostangle = data.starpostangle
				consoleplayer.starpostscale = data.starpostscale

				consoleplayer.style_additionaltime = data.leveltime

				consoleplayer.mo.flags = $ &~ MF_NOTHINK
				consoleplayer.mo.alpha = FRACUNIT
			end

			for _,v in ipairs(data.delete) do
				if mapthings[v].mobj then
					local replacement = P_SpawnMobjFromMobj(mapthings[v].mobj, 0, 0, 0, MT_GFZFLOWER2)
					P_RemoveMobj(mapthings[v].mobj)
					replacement.state = giantring_used
					replacement.flags = $|MF_NOGRAVITY
					P_GiantRingCheck(replacement)
				end
			end
		else
			consoleplayer.style_additionaltime = 0
		end
	end
end

addHook("MapLoad", function()
	if last_map then
		G_SetCustomExitVars(last_map, 0)
		last_map = 0
	end

	if maps_data[gamemap] then
		SP_LoadState(gamemap)
	end
end)

addHook("MapChange", function()
	if change_var > -1 then
		special_entrance = change_var

		if special_entrance then
			mobjinfo[MT_TOKEN].radius = 89*FRACUNIT
			mobjinfo[MT_TOKEN].height = 128*FRACUNIT
		else
			mobjinfo[MT_TOKEN].radius = original_radius
			mobjinfo[MT_TOKEN].height = original_height
		end

		change_var = -1
	end
end)

addHook("GameQuit", function()
	maps_data = {}
	last_map = 0
end)

--
--	BIG RING ENTRANCE
--

addHook("MapThingSpawn", function(a)
	if multiplayer then return end
	if not special_entrance or special_entrance == 3 then return end

	P_RemoveMobj(a)
end, MT_TOKEN)

addHook("MapThingSpawn", function(a)
	if multiplayer then return end
	if not special_entrance or special_entrance ~= 1 then return end

	if not All7Emeralds(emeralds) then
		a.ring = P_SpawnMobjFromMobj(a, -200*cos(a.angle+ANGLE_90), -200*sin(a.angle+ANGLE_90), 128*FRACUNIT, MT_TOKEN)
		a.ring.endleveltoken = true
	end
end, MT_SIGN)

addHook("MobjThinker", function(a)
	if multiplayer then return end
	if not special_entrance or special_entrance ~= 1 then return end

	if a.ring and a.ring.valid then
		if consoleplayer and consoleplayer.rings >= 50 then
			a.ring.flags2 = $ &~ MF2_DONTDRAW
		else
			a.ring.flags2 = $|MF2_DONTDRAW
		end
	end
end, MT_SIGN)

addHook("MobjSpawn", function(a)
	if multiplayer then return end
	if not special_entrance then return end
	a.state = All7Emeralds(emeralds) and giantring_hyper or giantring
	a.flags = $|MF_SPECIAL
	a.shadowscale = FRACUNIT/4
end, MT_TOKEN)

addHook("TouchSpecial", function(a, k)
	if multiplayer then return end
	if not special_entrance then return end
	return true
end, MT_TOKEN)

addHook("MobjCollide", function(a, k)
	if multiplayer then return false end
	if not special_entrance then return false end
	if not k.player then return false end

	if a.levelcountdown then
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
				S_StartSound(nil, sfx_s3kb3, k.player)
			elseif a.state == giantring_hyper or a.state == giantring_tinyhyper then
				a.state = giantring_flash
				P_GivePlayerRings(k.player, 50)
				S_StartSound(nil, sfx_token, k.player)
			end
		elseif special_entrance == 1 then
			if a.state == giantring or a.state == giantring_tiny then
				a.state = giantring_flash

				a.levelcountdown = 10
				S_StartSound(nil, sfx_s3kb3, k.player)
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
	-- Making sure that FOFs are loaded before checking, can't use mobj spawn due to order of things.
	if leveltime == 3 then
		P_GiantRingCheck(a)
	end


	if a.levelcountdown then
		a.levelcountdown = $-1

		if not a.levelcountdown then
			if special_entrance == 3 then
				SP_SaveState(a)
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
			P_RandomRange(0, a.height/FRACUNIT)*FRACUNIT, MT_SUPERSPARK)
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
	if not special_entrance or special_entrance ~= 2 then return end

	if mt.player and mt.player.rings >= 25 and a.state == a.info.spawnstate and a.stars == nil then
		a.stars = {}
		a.stfuse = 350
		a.countdownst = 50

		for i = 1,16 do
			local ang = a.angle + i*ANG1*((360*FRACUNIT/16)/FRACUNIT)
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
	if not special_entrance or special_entrance ~= 2 then return end

	if mt.player and (mt.z < a.z+a.height+12*FRACUNIT) and (mt.z > a.z+a.height-32*FRACUNIT) and a.stars ~= nil and a.stars[1].valid and not a.countdownst then
		SP_SaveState(a)
	end
end,  MT_STARPOST)

addHook("MobjThinker", function(a, mt)
	if not special_entrance or special_entrance ~= 2 then return end

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
			star.alpha = FRACUNIT-a.countdownst*FRACUNIT/100

			P_SetOrigin(star, a.x+(55-a.countdownst)*cos(star.angle), a.y+(55-a.countdownst)*sin(star.angle), a.z+a.height+(12-a.countdownst/4)*sin(a.vangle+star.angle))
			if a.stfuse == 0 then
				a.stars = nil
				P_RemoveMobj(star)
			end
		end
	end
end,  MT_STARPOST)