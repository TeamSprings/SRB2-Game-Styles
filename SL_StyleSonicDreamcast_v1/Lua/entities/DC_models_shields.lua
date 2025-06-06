--[[

		Shields

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local Disable_Miscs = false
local Disable_Shields = false

local function copyState(state)
	return {
		sprite = state.sprite,
		frame = state.frame,
		tics = state.tics,
		var1 = state.var1,
		var2 = state.var2,
		nextstate = state.nextstate
	}
end

local function assignState(state, new)
	if state.sprite then
		state.sprite = new.sprite
	end

	if state.frame then
		state.frame = new.frame
	end

	if state.tics then
		state.tics = new.tics
	end

	if state.var1 then
		state.var1 = new.var1
	end

	if state.var2 then
		state.var2 = new.var2
	end

	if state.nextstate then
		state.nextstate = new.nextstate
	end
end

local ogS_PITY1 = copyState(states[S_PITY1])
local ogS_MAGN1 = copyState(states[S_MAGN1])
local ogS_MAGN13 = copyState(states[S_MAGN13])

addHook("MapChange", function()
	Disable_Miscs = false
	if CV_FindVar("dc_miscassets").value == 0 then
		Disable_Miscs = true
	end

	if CV_FindVar("dc_shields") == 0 then
		Disable_Shields = true
		assignState(states[S_PITY1], 	ogS_PITY1)
		assignState(states[S_MAGN1], 	ogS_MAGN1)
		assignState(states[S_MAGN13], 	ogS_MAGN13)
	else
		Disable_Shields = false
		assignState(states[S_PITY1], {
			sprite = SPR_PITY,
			frame = FF_ANIMATE|FF_ADD|FF_SEMIBRIGHT|B,
			tics = 136,
			var1 = 67,
			var2 = 2,
			nextstate = S_PITY1,
		})
		assignState(states[S_MAGN1], {
			sprite = SPR_MAGN,
			frame = FF_ANIMATE|FF_ADD|FF_SEMIBRIGHT|A,
			tics = 182,
			var1 = 91,
			var2 = 2,
			nextstate = S_MAGN1,
		})
		assignState(states[S_MAGN13], {
			sprite = SPR_MAGN,
			frame = FF_TRANS20|FF_SEMIBRIGHT|92,
			tics = 2,
			nextstate = S_MAGN1,
		})
	end
end)

states[S_PITY1] = {
	sprite = SPR_PITY,
	frame = FF_ANIMATE|FF_ADD|FF_SEMIBRIGHT|B,
	tics = 136,
	var1 = 67,
	var2 = 2,
	nextstate = S_PITY1,
}

states[S_MAGN1] = {
	sprite = SPR_MAGN,
	frame = FF_ANIMATE|FF_ADD|FF_SEMIBRIGHT|A,
	tics = 182,
	var1 = 91,
	var2 = 2,
	nextstate = S_MAGN1,
}

states[S_MAGN13] = {
	sprite = SPR_MAGN,
	frame = FF_TRANS20|FF_SEMIBRIGHT|92,
	tics = 2,
	nextstate = S_MAGN1,
}

freeslot("S_MAGN14")

-- Shocks
states[S_MAGN14] = {
	sprite = SPR_MAGN,
	frame = FF_TRANS40|FF_ANIMATE|FF_ADD|FF_PAPERSPRITE|FF_SEMIBRIGHT|93,
	tics = 16,
	var1 = 8,
	var2 = 2,
	nextstate = S_NULL,
}


addHook("MobjThinker", function(mo)
	if not mo.target.track then
		mo.target.track = {}
	end

	if not (leveltime % 3) then
		local shock = P_SpawnMobjFromMobj(mo, -4069*FU, -4069*FU, -4069*FU, MT_METALJETFUME)
		shock.state = S_MAGN14
		shock.scale = mo.scale/2
		shock.angle = P_RandomRange(1, 360) * ANG1
		shock.rollangle = P_RandomRange(1, 360) * ANG1
		shock.target = mo
		shock.dispoffset = P_RandomRange(-1, 1) * 2
		table.insert(mo.target.track, shock)
	end
end, MT_ATTRACT_ORB)


addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid) then return end

	if 	p.shieldscale == skins[p.mo.skin].shieldscale
	and p.shieldscale == FU then
		-- This needs increase!
		p.shieldscale = tofixed('1.15')
	end

	if p.mo.track then
		for k, v in ipairs(p.mo.track) do
			if v and v.valid then
				if v.target then
					P_MoveOrigin(v, p.mo.x, p.mo.y, p.mo.z + FixedMul(v.target.height/3, v.target.scale))
					v.momx = p.mo.momx
					v.momy = p.mo.momy
					v.momz = p.mo.momz
				else
					P_RemoveMobj(v)
				end
			else
				table.remove(p.mo.track, k)
			end
		end
	end
end)


--
-- Invincibility
--

mobjinfo[MT_EXTRAINVRAY] = {
	spawnhealth = 1,
	spawnstate = S_INVINCIBILITYRAY,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

-- Type of rays
-- TODO: Clean up this mess

local n_1 = freeslot("S_INVINCIBILITYRAY1")
states[n_1] = {
	sprite = SPR_INV1,
	frame = 1|FF_TRANS60|FF_ADD|FF_SEMIBRIGHT|FF_ANIMATE,
	tics = 16,
	var1 = 7,
	var2 = 2,
	nextstate = n_1
}

local amount_rays = 1
local mid_index = amount_rays + 1
local angle_div = 360*FU/amount_rays

local function invincibilityModel(a, p)
	if Disable_Shields then return end
	if not (p.mo and p.mo.valid) then return end
	if not a.raylist and p.powers[pw_invulnerability] then
		local ray = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_OVERLAY)
		ray.state = n_1
		ray.spritexscale = 2*FU/9
		ray.spriteyscale = 2*FU/9
		ray.target = p.mo
		ray.fuse = 8
		ray.dispoffset = 20
		a.raylist = {ray}
	end

	if a.raylist and not a.raylist[mid_index] then
		local mid = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_ROTATEOVERLAY)
		mid.target = a
		mid.scale = 5*FU/4
		mid.state = S_INVISIBLE
		mid.sprite = SPR_INV1
		mid.frame = A|FF_ADD|FF_TRANS40|FF_SEMIBRIGHT
		mid.fuse = 8
		mid.dispoffset = 20

		a.raylist[mid_index] = mid
	end

	if a.raylist and not p.powers[pw_invulnerability] then
		for v, k in ipairs(a.raylist) do
			P_RemoveMobj(k)
		end
		a.raylist = nil
	end

	if a.raylist and p.powers[pw_invulnerability] then
		for k,v in ipairs(a.raylist) do
			local x,y,z
			if k == mid_index then
				P_MoveOrigin(v, a.x, a.y, a.z + FixedMul(p.mo.height/2, a.scale))
			end

			v.fuse = 8
		end
	end
end

addHook("PlayerThink", function(p)
	if Disable_Shields then return end
	invincibilityModel(p.mo, p)
end)

addHook("MobjThinker", function(a)
	if Disable_Shields then return end
	local transparency = 4 << FF_TRANSSHIFT
	if a.transparencytimer then
		a.transparencytimer = $-1
	end

	if a.transparencytimer == 0 then
		a.transparencytimer = 50
	end

	a.rollangle = a.offsv

	a.frame = $|transparency
end, MT_EXTRAINVRAY)

addHook("MobjThinker", function(a)
	if Disable_Shields then return end
	P_RemoveMobj(a)
end, MT_IVSP)