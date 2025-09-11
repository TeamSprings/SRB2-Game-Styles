local Options = tbsrequire('helpers/create_cvar')

local EGGTRAP = freeslot("MT_STYLES_EGGTR")
local EGGTRAPPART = freeslot("MT_STYLES_EGGTRPART")
local EGGTRAPTRIGGER = freeslot("MT_STYLES_EGGTRIGGER")
local EGGTRAPTRIGGERTOUCH = freeslot("MT_STYLES_EGGTRIGGERTOUCH")
local EGGTRAPFLICKY = freeslot("MT_STYLES_EGGTRFLICKY")
local EGGTRAPFLICKYST1 = freeslot("S_STYLES_EGGTRFLICKY1")
local EGGTRAPFLICKYST2 = freeslot("S_STYLES_EGGTRFLICKY2")

mobjinfo[EGGTRAP] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 32*FU,
	height = 64*FU,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SOLID,
	dispoffset = -1
}

mobjinfo[EGGTRAPPART] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 32*FU,
	height = 64*FU,
	mass = 100,
	flags = (mobjinfo[MT_BUSH].flags|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPTHING|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION) &~ MF_NOTHINK,
}

mobjinfo[EGGTRAPTRIGGER] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 24*FU,
	height = 16*FU,
	mass = 100,
	flags = MF_SOLID|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}

mobjinfo[EGGTRAPTRIGGERTOUCH] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 24*FU,
	height = 16*FU,
	mass = 100,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP|MF_SHOOTABLE,
}

mobjinfo[EGGTRAPFLICKY] = {
	spawnstate = EGGTRAPFLICKYST1,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 24*FU,
	height = 16*FU,
	mass = 100,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING,
}

states[EGGTRAPFLICKYST1] = {
	tics = 1,
	nextstate = EGGTRAPFLICKYST2
}

local change_var = -1
local model_type = 1

Options:new("capsule", {
	{nil, "s2", "Sonic 2"},
	{nil, "cd", "Sonic CD"},
	{nil, "s3", "Sonic 3 & Knuckles"},
}, function(var)
	change_var = var.value
end, CV_NETVAR)

local FLICKYMODE_NONE     = 0
local FLICKYMODE_FLICKIES = 1
local FLICKYMODE_SEEDS    = 2
local FLICKYMODE_RINGS    = 3
local FLICKYMODE_FLKSEEDS = 4
local FLICKYMODE_RANDOMIZ = 5

local flicky_settings = {
	{FLICKYMODE_FLICKIES, "flickies",   "Flickies"},
	{FLICKYMODE_SEEDS,    "seeds",      "Seed (Sonic CD)"},
	{FLICKYMODE_RINGS,    "rings",      "Rings"},
	{FLICKYMODE_FLKSEEDS, "flickseeds", "Flickies+Seeds"},
	{FLICKYMODE_RANDOMIZ, "randomized", "Randomized"},
	{FLICKYMODE_NONE,     "none",       "None"},
}

local flickyobjects = Options:new("flickiesspawn", flicky_settings, nil, CV_NETVAR)
local flickycapsule = Options:new("flickiescapsule", flicky_settings, nil, CV_NETVAR)

function A_FlickyCapsuleSpawn(actor, var1, var2)
	local mode = flickycapsule()

	if     mode == FLICKYMODE_FLKSEEDS then
		mode = P_RandomKey(4) > 1 and FLICKYMODE_FLICKIES or FLICKYMODE_SEEDS
	elseif mode == FLICKYMODE_RANDOMIZ then
		mode = P_RandomKey(6)

		if     mode > 3 then
			mode = FLICKYMODE_RINGS
		elseif mode > 1 then
			mode = FLICKYMODE_SEEDS
		else
			mode = FLICKYMODE_FLICKIES
		end
	end

	if     mode == FLICKYMODE_FLICKIES then
		A_FlickySpawn(actor, var1, var2)
	elseif mode == FLICKYMODE_SEEDS then
		local seed = P_SpawnMobjFromMobj(actor, 0, 0, 0, MT_SEED)
		seed.momz = FixedMul(actor.height/3, actor.scale)
	elseif mode == FLICKYMODE_RINGS then
		local ring = P_SpawnMobjFromMobj(actor, 0, 0, 0, MT_FLINGRING)
		ring.momz = FixedMul(actor.height/3, actor.scale)
		ring.angle = P_RandomRange(1, 360) * ANG1
		P_Thrust(ring, ring.angle, actor.radius/8)
	end

	return
end

states[EGGTRAPFLICKYST2] = {
	action = A_FlickyCapsuleSpawn,
	tics = 2,
	var1 = 0,
	var2 = 8*FU,
}


function A_FlickySpawn(actor, var1, var2)
	local mode = flickyobjects()

	if     mode == FLICKYMODE_FLKSEEDS then
		mode = P_RandomKey(4) > 1 and FLICKYMODE_FLICKIES or FLICKYMODE_SEEDS
	elseif mode == FLICKYMODE_RANDOMIZ then
		mode = P_RandomKey(6)

		if     mode > 3 then
			mode = FLICKYMODE_RINGS
		elseif mode > 1 then
			mode = FLICKYMODE_SEEDS
		else
			mode = FLICKYMODE_FLICKIES
		end
	end

	if     mode == FLICKYMODE_FLICKIES then
		super(actor, var1, var2)
	elseif mode == FLICKYMODE_SEEDS then
		local seed = P_SpawnMobjFromMobj(actor, 0, 0, 0, MT_SEED)
		seed.momz = FixedMul(actor.height/3, actor.scale)
	elseif mode == FLICKYMODE_RINGS then
		local ring = P_SpawnMobjFromMobj(actor, 0, 0, 0, MT_FLINGRING)
		ring.momz = FixedMul(actor.height/3, actor.scale)
		ring.angle = P_RandomRange(1, 360) * ANG1
		P_Thrust(ring, ring.angle, actor.radius/8)
	end

	return
end


addHook("MapChange", function()
	if change_var > -1 then
		model_type = change_var
		change_var = -1
	end
end)

local modes = {
	EGGTRAPPART,
	EGGTRAPTRIGGER,
	EGGTRAPTRIGGERTOUCH
}

local TRAPF_ENDLVL 	= 1
local TRAPF_LIFT 	= 2
local TRAPF_FLIGHT 	= 4
local TRAPF_DROP 	= 8

local TRAPF_VERTMOVE = TRAPF_DROP | TRAPF_LIFT

local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8
local TRPPF_DISOLVE = 16
local TRPPF_NOSOLID = 32
local TRPPF_ONLYFLY = 64
local TRPPF_NOFLIGH = 128
local TRPPF_FROTATE = 256

local TRAP_LENGHTEXPL = 2*TICRATE

---@alias eggtrapenum_types : table<function>
---| 'Sonic 2'
---| 'Sonic CD'
---| 'Sonic 3K'

---@alias eggtrap_flags
---| 'TRAPF_ENDLVL'
---| 'TRAPF_LIFT'
---| 'TRAPF_FLIGHT'
---| 'TRAPF_DROP'

---@alias eggtrappart_flags
---| 'TRPPF_CHANGE'
---| 'TRPPF_POOF'
---| 'TRPPF_HEADLOW'
---| 'TRPPF_HEADTOP'
---| 'TRPPF_DISOLVE'
---| 'TRPPF_NOSOLID'
---| 'TRPPF_ONLYFLY'
---| 'TRPPF_NOFLIGH'
---| 'TRPPF_FROTATE'

local function P_SpawnEggCapsulePart(
	source,
	x,
	y,
	z,
	angle,
	sprite,
	frame,
	trflags,
	trchange,
	trigger,
	radius,
	height,
	dist,
	revz
)
	if (trflags & TRPPF_ONLYFLY) and not (source.styles_flags & TRAPF_FLIGHT) then
		return
	elseif (trflags & TRPPF_NOFLIGH) and (source.styles_flags & TRAPF_FLIGHT) then
		return
	end

	local mode = modes[trigger]

	local part = P_SpawnMobjFromMobj(source, x,y,z,
		mode and mode or EGGTRAPPART)

	if part then
		part.offx     = x
		part.offy     = y
		part.offz     = z
		part.angle    = angle
		part.sprite   = sprite
		part.frame    = frame
		part.scale	  = source.scale
		part.target   = source

		if radius then
			part.radius = radius
		end

		if height then
			part.height = height
		end

		part.styles_trdir    = angle
		part.styles_trangle  = angle - ANGLE_90
		part.styles_trflags  = trflags
		part.styles_trchange = trchange
		part.styles_trdist   = dist
		part.styles_trrevz   = revz

		table.insert(source.capsule, part)
		return part
	end
end

-- TODO: ADD MORE CAPSULES (S1, MANIA and finish CD)
-- TODO: ADD MORE FEATURES (flight, drop)
-- TODO: MAKE IT FIRST UDMF CUSTOMIZABLE OBJECT
---@enum eggtrap_types
local models = tbsrequire("assets/tables/capsule_models")

addHook("MobjSpawn", function(a, tm)
	a.styles_flags = $ or 0

	a.radius = 46*FU
	a.height = 84*FU
	a.capsule = {}
	a.scale = $+FU/4

	a.styles_flickyflip = false
	a.styles_scaletarget = a.scale
	a.styles_seed = P_RandomRange(0, 999)

	a.disty = 0
	a.activatable = true
end, EGGTRAP)

---@enum flickies_types
local list_flickies = {
	MT_FLICKY_01,
	MT_FLICKY_02,
	MT_FLICKY_03,
	MT_FLICKY_04,
	MT_FLICKY_05,
	MT_FLICKY_06,
	MT_FLICKY_07,
	MT_FLICKY_08,
	MT_FLICKY_09,
	MT_FLICKY_10,
	MT_FLICKY_11,
	MT_FLICKY_12,
	MT_FLICKY_13,
	MT_FLICKY_14,
	MT_FLICKY_15,
	MT_FLICKY_16,
	MT_SECRETFLICKY_01,
	MT_SECRETFLICKY_02,
}

local RANGE = (FU * 3) / 2

addHook("MobjThinker", function(a)
	-- Thinker

	if not a.capsule or not a.capsulesetup then
		local model = models[model_type]

		for i = 1, #model do
			local part = model[i]

			P_SpawnEggCapsulePart(
				a,
				part.x or 0,
				part.y or 0,
				part.z or 0,
				part.angle or 0,
				model.sprite or 0,
				part.frame or 0,
				part.trflags or 0,
				part.trchange or 0,
				part.trigger or false,
				part.radius,
				part.height,
				part.dist,
				part.revz
			)
		end

		a.styles_destroytics = model.destroytics or TRAP_LENGHTEXPL
		a.capsulesetup = true
	end

	if not a.styles_xorigin then
		a.styles_xorigin = a.x
		a.styles_yorigin = a.y
	end

	if a.styles_tagged then
		local count = 0


		if a.styles_list then
			for _,mo in ipairs(a.styles_list) do
				if mo and mo.health > 0 then
					count = $ + 1
				end
			end
		else
			for mo in mapthings.tagged(a.styles_tagged) do
				if mo and mo.health > 0 then
					count = $ + 1
				end
			end
		end

		if count == 0 then
			a.styles_tagged = nil
			for _,v in ipairs(a.capsule) do
				if v then
					v.alpha = FU

					if v.info.flags & MF_SOLID then
						v.flags = $ | MF_SOLID
					end
				end
			end

			a.alpha = FU
		else
			if not a.styles_movement then
				for _,v in ipairs(a.capsule) do
					if v then
						v.alpha = 0
					end

					if v.flags & MF_SOLID then
						v.flags = $ &~ MF_SOLID
					end
				end

				a.styles_movetarget = a.z
				a.styles_movement = 1
				a.alpha = 0
				a.flags = $|(MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP)

				if a.styles_flags & TRAPF_LIFT then
					a.styles_movement = TICRATE
					a.styles_movestart = a.z - 400*FU*P_MobjFlip(a)
					P_SetOrigin(a, a.x, a.y, a.styles_movestart)
				elseif a.styles_flags & TRAPF_DROP then
					a.styles_movement = TICRATE
					a.styles_movestart = a.z + 400*FU*P_MobjFlip(a)
					P_SetOrigin(a, a.x, a.y, a.styles_movestart)
				elseif a.styles_flags & TRAPF_FLIGHT then
					a.styles_movement = TICRATE * 4

					if P_MobjFlip(a) > 0 then
						a.styles_flags2 = MF2_OBJECTFLIP
						a.flags2 = $ | MF2_OBJECTFLIP
						a.eflags = $ | MFE_VERTICALFLIP

						a.styles_movestart = a.z + 400*FU
						a.styles_movetarget = a.z + 80*FU + a.height
					else
						a.styles_flags2 = 0
						a.flags2 = $ &~ MF2_OBJECTFLIP
						a.eflags = $ &~ MFE_VERTICALFLIP

						a.styles_movestart = a.z - 400*FU
						a.styles_movetarget = a.z - 80*FU - a.height
					end

					a.styles_flickyflip = true
					P_SetOrigin(a, a.x, a.y, a.styles_movestart)

					a.scale = 0
				end
			end
		end
	else
		if a.styles_movement then
			if a.styles_flags & TRAPF_VERTMOVE then
				a.flags = $ | (MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP)

				P_SetOrigin(a, a.x, a.y, ease.linear(a.styles_movement * FU / TICRATE, a.styles_movetarget, a.styles_movestart))
				a.styles_movement = $ - 1

				if a.styles_movement == 0 then
					a.flags = $ &~ (MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP)
					a.styles_movement = nil
				end
			elseif a.styles_flags & TRAPF_FLIGHT then
				local tics = a.styles_movement * FU / (TICRATE*4)

				if a.styles_movement and a.styles_movement > 1 then
					a.styles_movement = $ - 1
				else
					tics = 0
				end

				if a.styles_flags2 & MF2_OBJECTFLIP then
					a.flags2 = $|MF2_OBJECTFLIP
					a.eflags = $|MFE_VERTICALFLIP
				else
					a.flags2 = $ &~ MF2_OBJECTFLIP
					a.eflags = $ &~ MFE_VERTICALFLIP
				end

				local ang = a.angle + (leveltime + a.styles_seed) * (ANG1 / 4)
				local dist = (a.radius*6/FU - a.styles_movement * 2) * a.scale

				local updw = sin(leveltime * ANG2) * (a.height/6/FU)

				local x = a.styles_xorigin + FixedMul(cos(ang), dist)
				local y = a.styles_yorigin + FixedMul(sin(ang), dist)
				local z = ease.insine(tics, a.styles_movetarget, a.styles_movestart) + updw

				a.scale = ease.insine(tics, a.styles_scaletarget, 8)


				P_SetOrigin(a, x, y, z)
			end
		end
	end

	if a.boss and a.boss.valid and a.boss.health <= 0 then
		a.activate = true
		a.flags = $|MF_SOLID & ~(MF_NOSECTOR|MF_NOBLOCKMAP)
	end

	if a.activated == true and not a.openinganim and not a.openedup then
		a.openinganim = TRAP_LENGHTEXPL
	end

	if a.openinganim and a.openinganim > TICRATE then
				local fa = P_RandomRange(1,360) *ANG1
				local ns = FixedMul(a.radius, RANGE)

				local _x = FixedMul(sin(fa), ns)
				local _y = FixedMul(cos(fa), ns)
				local _z = (P_RandomKey(a.height/FU) * FU)

				local x = a.x + _x
				local y = a.y + _y
				local z = a.z + FU + _z * P_MobjFlip(a)

				local mo2 = P_SpawnMobj(x, y, z, MT_EXPLODE)
				mo2.state = S_XPLD1
				--ns = 2*FU
				--mo2.momx = _x
				--mo2.momy = _y
				mo2.angle = fa
				S_StartSound(mo2, sfx_pop)

				local list = a.styles_flickylist
				local randm = P_RandomKey(list == nil and 1 or #list)

				if not (leveltime % 4) then
					if list and list[randm] then
						local flicky = P_SpawnMobjFromMobj(a, _x, _y, _z, list[randm])
						flicky.scale = a.scale - FU/4
						flicky.state = flicky.info.raisestate

						if a.styles_flickyflip then
							if P_MobjFlip(a) > 0 then
								flicky.eflags = $ | MFE_VERTICALFLIP
								flicky.flags2 = $ | MF2_OBJECTFLIP
							else
								flicky.eflags = $ &~ MFE_VERTICALFLIP
								flicky.flags2 = $ &~ MF2_OBJECTFLIP
							end
						end
					else
						local flicky = P_SpawnMobjFromMobj(a, _x, _y, _z, EGGTRAPFLICKY)
						flicky.scale = a.scale - FU/4
						flicky.angle = fa

						if a.styles_flickyflip then
							if P_MobjFlip(a) > 0 then
								flicky.eflags = $ | MFE_VERTICALFLIP
								flicky.flags2 = $ | MF2_OBJECTFLIP
							else
								flicky.eflags = $ &~ MFE_VERTICALFLIP
								flicky.flags2 = $ &~ MF2_OBJECTFLIP
							end
						end
					end
				end

				a.openedup = true
	elseif a.openinganim == 1
	and a.styles_flags & TRAPF_ENDLVL then
		for p in players.iterate do
			p.exiting = 20
			p.styles_capsule_exit = true
		end
	end

	if a.openinganim then
		a.openinganim  = $ - 1
	end

	if a.press then
		a.press = $ - 1
		if a.press == 0 then
			a.press = nil
		end
	end
end, EGGTRAP)

addHook("MobjThinker", function(a)
	if a.target then
		local flip = P_MobjFlip(a.target)

		if not a.styles_deattached then
			local dir = a.target.angle + a.styles_trdir
			local ang = a.target.angle + a.styles_trangle
			local dis = a.styles_trdist or 0

			local _cos = FixedMul(cos(ang), a.target.scale) * dis
			local _sin = FixedMul(sin(ang), a.target.scale) * dis
			local offz = (flip < 0 and (a.styles_trrevz or a.offz) or a.offz) or 0
			local z = offz - ((flip < 0 and offz ~= 0) and 64*FU or 0)

			P_SetOrigin(a, a.target.x + _cos,
						a.target.y + _sin,
						a.target.z + FixedMul(z, a.target.scale) * flip)

			if a.styles_trflags and (a.styles_trflags & TRPPF_FROTATE) then
				a.angle = $+ANG1 * 8
			else
				a.angle = dir
			end

			a.scale = a.target.scale
		end
	
		if not (a.frame & FF_FLOORSPRITE) then
			if flip > 0 then
				a.flags2 = $ &~ MF2_OBJECTFLIP
				a.frame = $ &~ FF_VERTICALFLIP
			else
				a.flags2 = $|MF2_OBJECTFLIP
				a.frame = $|FF_VERTICALFLIP
			end
		end

		if not a.activated and
		a.target.openinganim and a.target.openinganim < a.target.styles_destroytics then
			if a.styles_trflags then
				if (a.styles_trflags & TRPPF_CHANGE) then
					a.frame = a.styles_trchange
				end

				if (a.styles_trflags & TRPPF_NOSOLID) then
					a.flags = $ &~ MF_SOLID
				end

				if (a.styles_trflags & TRPPF_POOF) then
					a.momx = a.offx / 4
					a.momy = a.offy / 4
					a.momz = a.offy / 4 * flip

					a.fuse = 8*TICRATE
					a.flags = ($|MF_NOCLIPHEIGHT|MF_NOCLIP|MF_NOCLIPTHING) &~ MF_NOGRAVITY

					a.styles_deattached = true
				end
			end

			a.activated = true
		end

		if a.styles_trflags then
			if a.target.press and (a.styles_trflags & TRPPF_HEADTOP) or (a.styles_trflags & TRPPF_HEADLOW) then
				local dir = a.target.angle + a.styles_trdir
				local ang = a.target.angle + a.styles_trangle
				local dis = a.styles_trdist or 0
				local offz = (flip < 0 and (a.styles_trrevz or a.offz) or a.offz) or 0
				local z = offz - ((flip < 0 and offz ~= 0) and 64*FU or 0)

				local _cos = FixedMul(cos(ang), a.target.scale) * dis
				local _sin = FixedMul(sin(ang), a.target.scale) * dis

				P_SetOrigin(a, a.target.x + _cos,
							a.target.y + _sin,
							a.target.z + FixedMul(z - 16*FU, a.target.scale) * flip)

				a.angle = dir
				a.scale = a.target.scale
			end
		end
	else
		P_RemoveMobj(a)
	end
end, EGGTRAPPART)

addHook("MobjThinker", function(a)
	if a.target then
		local flip = P_MobjFlip(a.target)

		if not a.styles_deattached then
			local dir = a.target.angle + a.styles_trdir
			local ang = a.target.angle + a.styles_trangle
			local dis = a.styles_trdist or 0

			local _cos = FixedMul(cos(ang), a.target.scale) * dis
			local _sin = FixedMul(sin(ang), a.target.scale) * dis
			local offz = (flip < 0 and (a.styles_trrevz or a.offz) or a.offz) or 0
			local z = offz - ((flip < 0 and offz ~= 0) and 64*FU or 0)

			P_SetOrigin(a, a.target.x + _cos,
						a.target.y + _sin,
						a.target.z + FixedMul(z, a.target.scale) * flip)

			if a.styles_trflags and (a.styles_trflags & TRPPF_FROTATE) then
				a.angle = $+ANG1 * 8
			else
				a.angle = dir
			end

			a.scale = a.target.scale
		end

		if not (a.frame & FF_FLOORSPRITE) then
			if flip > 0 then
				a.flags2 = $ &~ MF2_OBJECTFLIP
				a.frame = $ &~ FF_VERTICALFLIP
			else
				a.flags2 = $|MF2_OBJECTFLIP
				a.frame = $|FF_VERTICALFLIP
			end
		end


		if a.styles_trflags then
			if a.target.press then
				if a.target.press and (a.styles_trflags & TRPPF_HEADTOP) or (a.styles_trflags & TRPPF_HEADLOW) then
					local dir = a.target.angle + a.styles_trdir
					local ang = a.target.angle + a.styles_trangle
					local dis = a.styles_trdist or 0
					local offz = (flip < 0 and (a.styles_trrevz or a.offz) or a.offz) or 0
					local z = offz - ((flip < 0 and offz ~= 0) and 64*FU or 0)

					local _cos = FixedMul(cos(ang), a.target.scale) * dis
					local _sin = FixedMul(sin(ang), a.target.scale) * dis

					P_SetOrigin(a, a.target.x + _cos,
								a.target.y + _sin,
								a.target.z + FixedMul(z - 16*FU, a.target.scale) * flip)

					a.angle = dir
					a.scale = a.target.scale

					if (a.styles_trflags & TRPPF_HEADLOW) then
						a.alpha = 0
					end
				end

				if (a.styles_trflags & TRPPF_NOSOLID) then
					a.flags = $ &~ MF_SOLID
				end

				if (a.styles_trflags & TRPPF_DISOLVE) 
				and a.target.openinganim and a.target.openinganim < a.target.styles_destroytics then
					P_RemoveMobj(a)
				end
			else
				if (a.styles_trflags & TRPPF_HEADLOW) then
					a.alpha = FU
				end
			end
		end
	else
		P_RemoveMobj(a)
	end
end, EGGTRAPTRIGGER)

addHook("MobjThinker", function(a)
	if a.target then
		local flip = P_MobjFlip(a.target)

		if not a.styles_deattached then
			local dir = a.target.angle + a.styles_trdir
			local ang = a.target.angle + a.styles_trangle
			local dis = a.styles_trdist or 0

			local _cos = FixedMul(cos(ang), a.target.scale) * dis
			local _sin = FixedMul(sin(ang), a.target.scale) * dis
			local offz = (flip < 0 and (a.styles_trrevz or a.offz) or a.offz) or 0
			local z = offz - ((flip < 0 and offz ~= 0) and 64*FU or 0)

			P_SetOrigin(a, a.target.x + _cos,
						a.target.y + _sin,
						a.target.z + FixedMul(z, a.target.scale) * flip)

			if a.styles_trflags and (a.styles_trflags & TRPPF_FROTATE) then
				a.angle = $+ANG1 * 8
			else
				a.angle = dir
			end

			a.scale = a.target.scale
		end

		if not (a.frame & FF_FLOORSPRITE) then
			if flip > 0 then
				a.flags2 = $ &~ MF2_OBJECTFLIP
				a.frame = $ &~ FF_VERTICALFLIP
			else
				a.flags2 = $|MF2_OBJECTFLIP
				a.frame = $|FF_VERTICALFLIP
			end
		end

		if a.styles_trflags then
			if a.target.press then
				if a.target.press and (a.styles_trflags & TRPPF_HEADTOP) or (a.styles_trflags & TRPPF_HEADLOW) then
					local dir = a.target.angle + a.styles_trdir
					local ang = a.target.angle + a.styles_trangle
					local dis = a.styles_trdist or 0
					local offz = (flip < 0 and (a.styles_trrevz or a.offz) or a.offz) or 0
					local z = offz - ((flip < 0 and offz ~= 0) and 64*FU or 0)

					local _cos = FixedMul(cos(ang), a.target.scale) * dis
					local _sin = FixedMul(sin(ang), a.target.scale) * dis

					P_SetOrigin(a, a.target.x + _cos,
								a.target.y + _sin,
								a.target.z + FixedMul(z - 16*FU, a.target.scale) * flip)

					a.angle = dir
					a.scale = a.target.scale

					if (a.styles_trflags & TRPPF_HEADLOW) then
						a.alpha = 0
					end
				end

				if (a.styles_trflags & TRPPF_NOSOLID) then
					a.flags = $ &~ MF_SOLID
				end

				if (a.styles_trflags & TRPPF_DISOLVE)
				and a.target.openinganim and a.target.openinganim < a.target.styles_destroytics then
					P_RemoveMobj(a)
				end
			else
				if (a.styles_trflags & TRPPF_HEADLOW) then
					a.alpha = FU
				end
			end
		end
	else
		P_RemoveMobj(a)
	end
end, EGGTRAPTRIGGERTOUCH)

local function HITBOX(a, mt, hordistance, triggerdist)
	local incenter = (R_PointToDist2(a.x, a.y, mt.x, mt.y) < hordistance)

	if incenter then
		local oz1, oz2
		local pz1, pz2

		if P_MobjFlip(a) < 0 then
			oz1 = a.z - a.height - triggerdist
			oz2 = a.z + triggerdist
		else
			oz1 = a.z - triggerdist
			oz2 = a.z + a.height + triggerdist
		end

		if P_MobjFlip(mt) < 0 then
			pz1 = mt.z-mt.height
			pz2 = mt.z
		else
			pz1 = mt.z
			pz2 = mt.z+mt.height
		end

		return (oz1 < pz2 and oz2 > pz1)
	end

	return 0
end

local function collision(a, mt)
	if mt.player then
		if a.target then
			local hit = HITBOX(a, mt, 36 * a.scale, 2 * a.scale)

			if a.target.activatable == true and hit then
				if ((a.target.styles_flags & TRAPF_LIFT) and not a.target.styles_movement)
				or ((a.target.styles_flags & TRAPF_LIFT) ~= 1) then
					a.target.activated = true
				end

				a.target.press = 4
			end
		end
	else
		return false
	end
end

addHook("MobjCollide", collision, EGGTRAPTRIGGER)
addHook("MobjMoveCollide", collision, EGGTRAPTRIGGER)

addHook("TouchSpecial", function(a,mt)
	if mt.player then
		if a.target and a.target.activatable == true then
			if ((a.target.styles_flags & TRAPF_LIFT) and not a.target.styles_movement)
			or ((a.target.styles_flags & TRAPF_LIFT) ~= 1) then
				a.target.activated = true
			end

			a.target.press = 4
		end
	end

	return true
end, EGGTRAPTRIGGERTOUCH)