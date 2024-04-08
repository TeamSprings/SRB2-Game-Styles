--[[
		Sonic Adventure Style's Common Objects

Contributors: Ace Lite
@Team Blue Spring 2022-2023

]]

freeslot("MT_BACKERADUMMY", "MT_BACKTIERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "MT_ROTATEOVERLAY", "MT_EXTRAINVRAY",
"S_XPLD7", "S_XPLD8", "S_XPLD9", "S_ERASMOKE1", "S_ERASMOKE2", "S_DIASA2SPRINGSOUND", "S_HWRSA2SPRINGSOUND", "S_INVINCIBILITYRAY",
"SPR_CA2D", "SPR_CA3D", "SPR_1CAP", "SPR_GEM1", "SPR_GEM2", "SPR_FLB9", "SPR_INV1",
"SPR_CHE0", "S_HWRSA2SPRING", "S_DIASA2SPRING")

--
--
--	DUMMY/OVERLAY OBJECT MOBJINFO
--
--

mobjinfo[MT_EXTRAERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

mobjinfo[MT_BACKERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = -256
}

mobjinfo[MT_BACKTIERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = -2
}

mobjinfo[MT_FRONTERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = 2
}


mobjinfo[MT_ROTATEOVERLAY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

addHook("MobjThinker", function(a)
	if a.target then
		a.rollangle = $+ANG2
		P_TeleportMove(a, a.target.x, a.target.y, a.target.z)
	else
		P_RemoveMobj(a)
	end
end, MT_ROTATEOVERLAY)


--
-- 	Animated Smoke
--

states[S_ERASMOKE1] = {
	sprite = SPR_CA2D,
	frame = FF_ANIMATE|FF_TRANS40|A,
	tics = 32,
	var1 = 7,
	var2 = 4
}

states[S_ERASMOKE2] = {
	sprite = SPR_CA1D,
	frame = FF_ANIMATE|A,
	tics = 32,
	var1 = 7,
	var2 = 4
}

--
-- 	Animated Explosion + Flicky Bubble spawn
--

sfxinfo[freeslot("sfx_advexp")].caption = "Boom"

states[S_XPLD_FLICKY].sprite = SPR_CA3D
states[S_XPLD_FLICKY].frame = A|FF_TRANS30
states[S_XPLD1].sprite = SPR_CA3D
states[S_XPLD1].frame = A|FF_TRANS30
states[S_XPLD1].action = function(a)
	a.blendmode = AST_ADD
	a.scale = $+FRACUNIT
	S_StartSound(a, sfx_advexp)
end
states[S_XPLD2].sprite = SPR_CA3D
states[S_XPLD2].frame = B|FF_TRANS30
states[S_XPLD3].sprite = SPR_CA3D
states[S_XPLD3].frame = C|FF_TRANS30
states[S_XPLD4].sprite = SPR_CA3D
states[S_XPLD4].frame = D|FF_TRANS30
states[S_XPLD5].sprite = SPR_CA3D
states[S_XPLD5].frame = E|FF_TRANS30
states[S_XPLD6].sprite = SPR_CA3D
states[S_XPLD6].frame = F|FF_TRANS30
states[S_XPLD6].nextstate = S_XPLD7

states[S_XPLD7] = {
	sprite = SPR_CA3D,
	frame = G|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLD8
}

states[S_XPLD8] = {
	sprite = SPR_CA3D,
	frame = H|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLD9
}

states[S_XPLD9] = {
	sprite = SPR_CA3D,
	frame = I|FF_TRANS40,
	tics = 2
}

addHook("MobjSpawn", function(a, tm)
	a.state = S_XPLD1
	a.scale = $*2
end, MT_SONIC3KBOSSEXPLODE)

local function bubbleflicky(a)
	local overlay = P_SpawnMobjFromMobj(a, 0,0,0, MT_ROTATEOVERLAY)
	overlay.state = S_INVISIBLE
	overlay.sprite = SPR_FLB9
	overlay.frame = FF_ADD|FF_TRANS20
	overlay.target = a
	overlay.fuse = TICRATE*6
end

local Flickylist = {
	MT_FLICKY_01;
	MT_FLICKY_02;
	MT_FLICKY_03;
	MT_FLICKY_04;
	MT_FLICKY_05;
	MT_FLICKY_06;
	MT_FLICKY_07;
	MT_FLICKY_08;
	MT_FLICKY_09;
	MT_FLICKY_10;
	MT_FLICKY_11;
	MT_FLICKY_12;
	MT_FLICKY_13;
	MT_FLICKY_14;
	MT_FLICKY_15;
	MT_FLICKY_16;
	MT_SECRETFLICKY_01;
	MT_SECRETFLICKY_02;
}

rawset(_G, "SA_BubbleFlickylist", Flickylist)

for k,v in ipairs(Flickylist) do

addHook("MobjSpawn", bubbleflicky, v)

end

--
--	Chaos Emeralds
--

states[S_CEMG1] = {
	sprite = SPR_GEM1,
	frame = FF_ANIMATE|FF_TRANS10|A,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG1,
}

states[S_CEMG2] = {
	sprite = SPR_GEM1,
	frame = FF_ANIMATE|FF_TRANS10|E,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG2,
}

states[S_CEMG3] = {
	sprite = SPR_GEM1,
	frame = FF_ANIMATE|FF_TRANS10|I,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG3,
}

states[S_CEMG4] = {
	sprite = SPR_GEM1,
	frame = FF_ANIMATE|FF_TRANS10|M,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG4,
}

states[S_CEMG5] = {
	sprite = SPR_GEM2,
	frame = FF_ANIMATE|FF_TRANS10|A,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG5,
}

states[S_CEMG6] = {
	sprite = SPR_GEM2,
	frame = FF_ANIMATE|FF_TRANS10|E,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG6,
}

states[S_CEMG7] = {
	sprite = SPR_GEM2,
	frame = FF_ANIMATE|FF_TRANS10|I,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG7,
}

--
--	Chao Key (Key to get to Chao Garden)
--

freeslot("SPR_SA2K")

addHook("MapThingSpawn", function(a)
	a.state = S_INVISIBLE
	a.sprite = SPR_SA2K
	a.frame = B|FF_PAPERSPRITE
	a.nsides = {}
	for i = 1,2 do
		local sideSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_EXTRAERADUMMY)
		sideSpawn.target = a
		sideSpawn.scale = a.scale
		sideSpawn.state = S_INVISIBLE
		sideSpawn.sprite = SPR_SA2K
		sideSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
		sideSpawn.frame = A|FF_PAPERSPRITE|(i == 2 and FF_HORIZONTALFLIP or 0)
		table.insert(a.nsides, sideSpawn)
	end
	local Dot = P_SpawnMobjFromMobj(a, 0,0,0, MT_OVERLAY)
	Dot.target = a
	Dot.state = S_INVISIBLE
	Dot.sprite = SPR_SA2K
	Dot.frame = C

end, MT_TOKEN)


addHook("MobjDeath", function(a)
	for _,key in ipairs(a.nsides) do
		P_RemoveMobj(key)
	end
end, MT_TOKEN)

addHook("MobjThinker", function(a)
	if a and a.valid then
		a.angle = $ + ANG1*3
		for k,key in ipairs(a.nsides) do
			if key and key.valid then
				local ang = a.angle + k*ANGLE_180
				key.angle = ang+ANGLE_270
				P_TeleportMove(key, a.x + 2*cos(ang), a.y + 2*sin(ang), a.z)
			end
		end
	end
end, MT_TOKEN)


--
--	Boosters/ Dash Panels
--

sfxinfo[freeslot("sfx_advdas")].caption = "Dash"

mobjinfo[MT_YELLOWBOOSTER].painsound = sfx_advdas
mobjinfo[MT_REDBOOSTER].painsound = sfx_advdas

sfxinfo[freeslot("sfx_advite")].caption = "Pop"

addHook("MapThingSpawn", function(a, mt)
	a.renderflags = $|RF_OBJECTSLOPESPLAT|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
	a.scale = $+FRACUNIT/3
	a.state = S_YELLOWBOOSTERROLLER
	return true
end, MT_YELLOWBOOSTER)

addHook("MapThingSpawn", function(a, mt)
	a.renderflags = $|RF_OBJECTSLOPESPLAT|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
	a.scale = $+FRACUNIT/3
	a.state = S_REDBOOSTERROLLER
	return true
end, MT_REDBOOSTER)


--
--	Springs
--

sfxinfo[freeslot("sfx_advspr")].caption = "Spring"

mobjinfo[MT_BLUESPRING].painsound = sfx_advspr
mobjinfo[MT_YELLOWSPRING].painsound = sfx_advspr
mobjinfo[MT_REDSPRING].painsound = sfx_advspr

mobjinfo[MT_BLUEHORIZ].painsound = sfx_advspr
mobjinfo[MT_YELLOWHORIZ].painsound = sfx_advspr
mobjinfo[MT_REDHORIZ].painsound = sfx_advspr

mobjinfo[MT_BLUEDIAG].painsound = sfx_advspr
mobjinfo[MT_YELLOWDIAG].painsound = sfx_advspr
mobjinfo[MT_REDDIAG].painsound = sfx_advspr

local function propellerSpringThinker(a)
	if a.tracer and a.tracer.valid then
		if not a.chainconnect then
			a.chainconnect = P_SpawnMobjFromMobj(a, 0,0,0, MT_EXTRAERADUMMY)
			a.chainconnect.state = S_INVISIBLE
			a.chainconnect.sprite = SPR_RSPB
			a.chainconnect.frame = G
			a.chainconnect.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
		else
			local ang = R_PointToAngle2(a.x, a.y, a.tracer.x, a.tracer.y)
			P_TeleportMove(a.chainconnect, a.x+24*cos(ang), a.y+24*sin(ang), a.z)
		end
	else
		if not a.properer then
			a.properer = {}
			for i = 1,3 do
				local properer = P_SpawnMobjFromMobj(a, 0,0,0, MT_EXTRAERADUMMY)
				properer.state = S_INVISIBLE
				properer.sprite = SPR_RSPB
				properer.angle = ((360/3)*ANG1)*i
				properer.frame = F|FF_PAPERSPRITE
				properer.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
				table.insert(a.properer, properer)
			end
		else
			--local ang = (360/3)*ANG1
			for k,pr in ipairs(a.properer) do
				pr.angle = $+ANG1*5
				P_TeleportMove(pr, a.x-8*cos(pr.angle), a.y-8*sin(pr.angle), a.z)
			end
		end
	end
end

local function removalPropellerSpring(a)
	if a.chainconnect then
		P_RemoveMobj(a.chainconnect)
	end

	if a.properer then
		for i = 1,3 do
			P_RemoveMobj(a.properer[i])
		end
		a.properer = nil
	end
end

addHook("MobjThinker", propellerSpringThinker, MT_YELLOWSPRINGBALL)
addHook("MobjThinker", propellerSpringThinker, MT_REDSPRINGBALL)

addHook("MobjRemoved", removalPropellerSpring, MT_YELLOWSPRINGBALL)
addHook("MobjRemoved", removalPropellerSpring, MT_REDSPRINGBALL)

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

states[S_INVINCIBILITYRAY] = {
	sprite = SPR_INV1,
	frame = B|FF_PAPERSPRITE|FF_ADD|FF_SEMIBRIGHT|FF_ANIMATE,
	tics = 16,
	var1 = 7,
	var2 = 2,
	nextstate = S_INVINCIBILITYRAY
}

local invAngles = {
	[1] = {0, 0},
	[2] = {ANGLE_270, 0},
	[3] = {ANGLE_45, ANGLE_45},
	[4] = {ANGLE_135, ANGLE_45},
	[5] = {ANGLE_225, ANGLE_45},
	[6] = {ANGLE_90, 0},
	[7] = {ANGLE_225, -ANGLE_45},
	[8] = {ANGLE_315, -ANGLE_45},
	[9] = {0, ANGLE_180},
	[10] = {0, -ANGLE_180},
	[11] = {ANGLE_180, 0},
	[12] = {ANGLE_315, ANGLE_45},
	[13] = {ANGLE_45, -ANGLE_45},
	[14] = {ANGLE_135, -ANGLE_45},
	[15] = {0, ANGLE_180-ANG10},
	[16] = {0, ANGLE_180+ANG10},
}


local function invincibilityModel(a, p)
	if not a.raylist and p.powers[pw_invulnerability] then
		a.raylist = {}

		for i = 1,16 do
			local ray = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_EXTRAINVRAY)
			ray.transparencytimer = (50+15*i) % 50
			ray.offsh = invAngles[i][1]
			ray.offsv = invAngles[i][2]
			table.insert(a.raylist, ray)
		end
	end

	if a.raylist and not a.raylist[17] then
		a.raylist[17] = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_OVERLAY)
		a.raylist[17].target = a
		a.raylist[17].state = S_INVISIBLE
		a.raylist[17].sprite = SPR_INV1
		a.raylist[17].frame = A|FF_ADD|FF_TRANS40|FF_SEMIBRIGHT
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
			if k ~= 17 then
				v.angle = a.angle+v.offsh

				x = 18*FixedMul(cos(v.angle), cos(v.offsv))
				y = 18*FixedMul(sin(v.angle), cos(v.offsv))
				z = 28*sin(v.offsv)+26*a.scale

				P_TeleportMove(v, a.raylist[17].x+(x or 0), a.raylist[17].y+(y or 0), a.raylist[17].z+(z or 0))
				v.momx = a.momx
				v.momy = a.momy
				v.momz = a.momz
			end
		end
	end
end

addHook("PlayerThink", function(p)
	invincibilityModel(p.mo, p)
end)

addHook("MobjThinker", function(a)
	local transparency = 4 << FF_TRANSSHIFT
	if a.transparencytimer then
		a.transparencytimer = $-1
	end

	if a.transparencytimer == 0 then
		a.transparencytimer = 50
	end

	a.spritexscale = abs(ease.linear((a.transparencytimer*FRACUNIT)/50, -5*FRACUNIT/2, 5*FRACUNIT/2))
	a.spriteyscale = 2*FRACUNIT/3

	a.rollangle = a.offsv

	a.frame = $|transparency
end, MT_EXTRAINVRAY)

addHook("MobjThinker", function(a)
	P_RemoveMobj(a)
end, MT_IVSP)



