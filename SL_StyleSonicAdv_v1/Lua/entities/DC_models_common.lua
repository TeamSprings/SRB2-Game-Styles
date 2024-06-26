--[[

		Sonic Adventure Style's Common Objects

Contributors: Ace Lite
@Team Blue Spring 2022-2024

]]

freeslot("MT_BACKERADUMMY", "MT_BACKTIERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "MT_ROTATEOVERLAY", "MT_EXTRAINVRAY",
"S_XPLD7", "S_XPLD8", "S_XPLD9", "S_ERASMOKE1", "S_ERASMOKE2", "S_SA2FLICKYBUBBLE", "S_DIASA2SPRINGSOUND", "S_HWRSA2SPRINGSOUND", "S_INVINCIBILITYRAY",
"SPR_CA2D", "SPR_CA3D", "SPR_1CAP", "SPR_GEM1", "SPR_GEM2", "SPR_FLB9", "SPR_INV1",
"SPR_CHE0", "S_HWRSA2SPRING", "S_DIASA2SPRING")

local Disable_Miscs = false

addHook("MapLoad", function()
	Disable_Miscs = false
	if CV_FindVar("dc_miscassets").value == 0 then
		Disable_Miscs = true
	end
end)

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
		if not a.shield then
			a.rollangle = $+ANG2
			P_MoveOrigin(a, a.target.x, a.target.y, a.target.z)
			if a.target.pickupinvulneribility then
				a.target.pickupinvulneribility = $-1
			end
		end
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

freeslot("S_XPLDADVENTURE_1", "S_XPLDADVENTURE_2", "S_XPLDADVENTURE_3", "S_XPLDADVENTURE_4", "S_XPLDADVENTURE_5", "S_XPLDADVENTURE_6", "S_XPLDADVENTURE_7", "S_XPLDADVENTURE_8", "S_XPLDADVENTURE_9")

states[S_XPLD_FLICKY].sprite = SPR_CA3D
states[S_XPLD_FLICKY].frame = A|FF_TRANS30
states[S_XPLD_FLICKY].nextstate = S_XPLDADVENTURE_1

states[S_XPLDADVENTURE_1] = {
	sprite = SPR_CA3D,
	frame = A|FF_TRANS40,
	tics = 2,
	action = function(a)
	a.blendmode = AST_ADD
	a.scale = $+FRACUNIT
	S_StartSound(a, sfx_advexp)
end,
	nextstate = S_XPLDADVENTURE_2
}

states[S_XPLDADVENTURE_2] = {
	sprite = SPR_CA3D,
	frame = B|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_3
}

states[S_XPLDADVENTURE_3] = {
	sprite = SPR_CA3D,
	frame = C|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_4
}

states[S_XPLDADVENTURE_4] = {
	sprite = SPR_CA3D,
	frame = D|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_5
}


states[S_XPLDADVENTURE_5] = {
	sprite = SPR_CA3D,
	frame = E|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_6
}

states[S_XPLDADVENTURE_6] = {
	sprite = SPR_CA3D,
	frame = F|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_7
}

states[S_XPLDADVENTURE_7] = {
	sprite = SPR_CA3D,
	frame = G|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_8
}


states[S_XPLDADVENTURE_8] = {
	sprite = SPR_CA3D,
	frame = H|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_9
}

states[S_XPLDADVENTURE_9] = {
	sprite = SPR_CA3D,
	frame = I|FF_TRANS40,
	tics = 2
}

addHook("MobjSpawn", function(a, tm)
	a.state = S_XPLDADVENTURE_1
	a.scale = $*2
end, MT_SONIC3KBOSSEXPLODE)

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

states[S_TOKEN] = {
	sprite = SPR_SA2K,
	frame = FF_ANIMATE|A,
	tics = 70,
	var1 = 69,
	var2 = 1,
	nextstate = S_TOKEN,
}

addHook("MapThingSpawn", function(mo)
	mo.spritexscale = mo.spritexscale/2
	mo.spriteyscale = mo.spriteyscale/2
end, MT_TOKEN)

--
--	Boosters/ Dash Panels
--

sfxinfo[freeslot("sfx_advdas")].caption = "Dash"

mobjinfo[MT_YELLOWBOOSTER].painsound = sfx_advdas
mobjinfo[MT_REDBOOSTER].painsound = sfx_advdas

sfxinfo[freeslot("sfx_advite")].caption = "Pop"

addHook("MapThingSpawn", function(a, mt)
	if Disable_Miscs then return end
	a.renderflags = $|RF_OBJECTSLOPESPLAT|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
	a.scale = $+FRACUNIT/3
	a.state = S_YELLOWBOOSTERROLLER
	return true
end, MT_YELLOWBOOSTER)

addHook("MapThingSpawn", function(a, mt)
	if Disable_Miscs then return end
	a.renderflags = $|RF_OBJECTSLOPESPLAT|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
	a.scale = $+FRACUNIT/3
	a.state = S_REDBOOSTERROLLER
	return true
end, MT_REDBOOSTER)

local function boost_sound(mo, mop)
	if mop.player and mop.z + mop.height > mo.z
	and mo.z + mo.height > mop.z and not S_SoundPlaying(mop, mo.info.painsound) then
		S_StartSound(mop, mo.info.painsound)
	end
end

addHook("MobjCollide", boost_sound, MT_YELLOWBOOSTER)
addHook("MobjCollide", boost_sound, MT_REDBOOSTER)

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
	if Disable_Miscs then return end
	if a.tracer and a.tracer.valid then
		if not a.chainconnect then
			a.chainconnect = P_SpawnMobjFromMobj(a, 0,0,0, MT_EXTRAERADUMMY)
			a.chainconnect.state = S_INVISIBLE
			a.chainconnect.sprite = SPR_RSPB
			a.chainconnect.frame = G
			a.chainconnect.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
		else
			local ang = R_PointToAngle2(a.x, a.y, a.tracer.x, a.tracer.y)
			P_SetOrigin(a.chainconnect, a.x+24*cos(ang), a.y+24*sin(ang), a.z)
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
				P_SetOrigin(pr, a.x-8*cos(pr.angle), a.y-8*sin(pr.angle), a.z)
			end
		end
	end
end

local function removalPropellerSpring(a)
	if Disable_Miscs then return end
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

