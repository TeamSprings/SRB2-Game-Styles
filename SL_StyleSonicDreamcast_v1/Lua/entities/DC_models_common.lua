--[[

		Common Objects

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

freeslot("MT_BACKERADUMMY", "MT_BACKTIERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "MT_ROTATEOVERLAY", "MT_EXTRAINVRAY",
"S_XPLD7", "S_XPLD8", "S_XPLD9", "S_ERASMOKE1", "S_ERASMOKE2", "S_SA2FLICKYBUBBLE", "S_DIASA2SPRINGSOUND", "S_HWRSA2SPRINGSOUND", "S_INVINCIBILITYRAY",
"SPR_CA2D", "SPR_CA3D", "SPR_GEM1", "SPR_GEM2", "SPR_FLB9", "SPR_INV1",
"SPR_CHE0", "S_HWRSA2SPRING", "S_DIASA2SPRING")

local Disable_Miscs = false

addHook("MapChange", function()
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

---@diagnostic disable-next-line
mobjinfo[MT_EXTRAERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_SCENERY|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

---@diagnostic disable-next-line
mobjinfo[MT_BACKERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_SCENERY,
	dispoffset = -256
}

---@diagnostic disable-next-line
mobjinfo[MT_BACKTIERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_SCENERY,
	dispoffset = -2
}

---@diagnostic disable-next-line
mobjinfo[MT_FRONTERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_SCENERY,
	dispoffset = 2
}

---@diagnostic disable-next-line
mobjinfo[MT_ROTATEOVERLAY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

---@class mobj_t
---@field alpha fixed_t

---@class rotovrmobj_t : mobj_t
---@field bubble 	boolean?
---@field shield 	boolean?
---@field scaleup 	fixed_t?

---@param a rotovrmobj_t
addHook("MobjThinker", function(a)
	if a.target then
		if not a.shield then
			a.rollangle = $+ANG2
			P_MoveOrigin(a, a.target.x, a.target.y, a.target.z)
			if a.target.pickupinvulneribility then
				a.target.pickupinvulneribility = $-1
			end
		end

		if a.bubble then
			if a.scaleup and a.scale ~= FixedMul(a.scaleup, a.target.scale) then
				a.scale = ease.linear(FU/24, a.scale, FixedMul(a.scaleup, a.target.scale))
			end

			if a.target.valid and a.fuse > 4 then
				if not a.extravalue1 then
					a.extravalue1 = a.target.state
					a.extravalue2 = a.target.fuse
				end

				if not (a.fuse % TICRATE) then
					a.cusval = $ + P_RandomRange(-45, 45)
				end

				a.target.state = S_INVISIBLE
				a.target.sprite = states[a.extravalue1].sprite
				a.target.frame = states[a.extravalue1].frame
				a.target.flags = $ | MF_NOGRAVITY

				-- Will figure out movement logic later
				local ang_h = leveltime*ANG2 + a.cusval * ANG1

				a.target.angle = ang_h

				a.target.momx = cos(ang_h)*3
				a.target.momy = sin(ang_h)*3
				if a.floorz > a.z-96*a.scale*P_MobjFlip(a) then
					a.target.momz = $+a.scale/4*P_MobjFlip(a)
				else
					---@diagnostic disable-next-line
					a.target.momz = ease.linear(FU/2, a.target.momz, 3*sin(2*ANG1*leveltime))
				end
				a.target.fuse = a.extravalue2
			else
				if a.extravalue1 then
					a.target.state = a.extravalue1
					a.target.flags = $ &~ MF_NOGRAVITY
					a.extravalue1 = 0
				end
			end

			if a.alpha and a.fuse < 9 then
				a.alpha = $-FU/10
			end
		end
	else
		if a.bubble then
			if a.alpha then
				a.alpha = $-FU/10
			else
				P_RemoveMobj(a)
			end
		else
			P_RemoveMobj(a)
		end
	end
end, MT_ROTATEOVERLAY)


--
-- 	Animated Smoke
--

---@diagnostic disable-next-line
states[S_ERASMOKE1] = {
	sprite = SPR_CA2D,
	frame = FF_ANIMATE|FF_TRANS40|A,
	tics = 32,
	var1 = 7,
	var2 = 4
}

---@diagnostic disable-next-line
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

---@diagnostic disable-next-line
states[S_XPLDADVENTURE_1] = {
	sprite = SPR_CA3D,
	frame = A|FF_TRANS40,
	tics = 2,
	action = function(a)
	a.blendmode = AST_ADD
	a.scale = $+FU
	S_StartSound(a, sfx_advexp)
end,
	nextstate = S_XPLDADVENTURE_2
}

---@diagnostic disable-next-line
states[S_XPLDADVENTURE_2] = {
	sprite = SPR_CA3D,
	frame = B|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_3
}

---@diagnostic disable-next-line
states[S_XPLDADVENTURE_3] = {
	sprite = SPR_CA3D,
	frame = C|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_4
}

---@diagnostic disable-next-line
states[S_XPLDADVENTURE_4] = {
	sprite = SPR_CA3D,
	frame = D|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_5
}

---@diagnostic disable-next-line
states[S_XPLDADVENTURE_5] = {
	sprite = SPR_CA3D,
	frame = E|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_6
}

---@diagnostic disable-next-line
states[S_XPLDADVENTURE_6] = {
	sprite = SPR_CA3D,
	frame = F|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_7
}

---@diagnostic disable-next-line
states[S_XPLDADVENTURE_7] = {
	sprite = SPR_CA3D,
	frame = G|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_8
}

---@diagnostic disable-next-line
states[S_XPLDADVENTURE_8] = {
	sprite = SPR_CA3D,
	frame = H|FF_TRANS40,
	tics = 2,
	nextstate = S_XPLDADVENTURE_9
}

---@diagnostic disable-next-line
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

---@diagnostic disable-next-line
states[S_CEMG1] = {
	sprite = SPR_GEM1,
	frame = FF_ANIMATE|FF_TRANS10|A,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG1,
}

---@diagnostic disable-next-line
states[S_CEMG2] = {
	sprite = SPR_GEM1,
	frame = FF_ANIMATE|FF_TRANS10|E,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG2,
}

---@diagnostic disable-next-line
states[S_CEMG3] = {
	sprite = SPR_GEM1,
	frame = FF_ANIMATE|FF_TRANS10|I,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG3,
}

---@diagnostic disable-next-line
states[S_CEMG4] = {
	sprite = SPR_GEM1,
	frame = FF_ANIMATE|FF_TRANS10|M,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG4,
}

---@diagnostic disable-next-line
states[S_CEMG5] = {
	sprite = SPR_GEM2,
	frame = FF_ANIMATE|FF_TRANS10|A,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG5,
}

---@diagnostic disable-next-line
states[S_CEMG6] = {
	sprite = SPR_GEM2,
	frame = FF_ANIMATE|FF_TRANS10|E,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG6,
}

---@diagnostic disable-next-line
states[S_CEMG7] = {
	sprite = SPR_GEM2,
	frame = FF_ANIMATE|FF_TRANS10|I,
	tics = 16,
	var1 = 3,
	var2 = 4,
	nextstate = S_CEMG7,
}

--
--	Chaos Emeralds (Nights)
--

---@diagnostic disable-next-line
states[S_ORBITEM1].sprite = SPR_GEM1
states[S_ORBITEM1].frame = FF_TRANS10|A

---@diagnostic disable-next-line
states[S_ORBITEM2].sprite = SPR_GEM1
states[S_ORBITEM2].frame = FF_TRANS10|E

---@diagnostic disable-next-line
states[S_ORBITEM3].sprite = SPR_GEM1
states[S_ORBITEM3].frame = FF_TRANS10|I

---@diagnostic disable-next-line
states[S_ORBITEM4].sprite = SPR_GEM1
states[S_ORBITEM4].frame = FF_TRANS10|M

---@diagnostic disable-next-line
states[S_ORBITEM5].sprite = SPR_GEM2
states[S_ORBITEM5].frame = FF_TRANS10|A

---@diagnostic disable-next-line
states[S_ORBITEM6].sprite = SPR_GEM2
states[S_ORBITEM6].frame = FF_TRANS10|E

---@diagnostic disable-next-line
states[S_ORBITEM7].sprite = SPR_GEM2
states[S_ORBITEM7].frame = FF_TRANS10|I

--
--	Chao Key (Key to get to Chao Garden or... used to be)
--

freeslot("SPR_SA2K")
freeslot("SPR_STYLES_HEROES_KEY")

---@diagnostic disable-next-line

local heroes_key = freeslot("S_STYLES_HEROES_SPKEY")
local chao_key = freeslot("S_STYLES_CHAO_SPKEY")

states[heroes_key] = {
	sprite = SPR_STYLES_HEROES_KEY,
	frame = FF_ANIMATE|A,
	tics = 50,
	var1 = 49,
	var2 = 1,
	nextstate = heroes_key,
}

states[chao_key] = {
	sprite = SPR_SA2K,
	frame = FF_ANIMATE|A,
	tics = 70,
	var1 = 69,
	var2 = 1,
	nextstate = chao_key,
}

local tokenstyle_cv = CV_FindVar("dc_keystyle")

addHook("MobjThinker", function(mo)
	if mo.health > 0 then
		local curstate = tokenstyle_cv.value and chao_key or heroes_key

		if mo.state ~= curstate then
			mo.state = curstate
			mo.spritexscale = FU/2
			mo.spriteyscale = FU/2
		end
	else
		mo.spritexscale = FU
		mo.spriteyscale = FU
	end
end, MT_TOKEN)

addHook("TouchSpecial", function(mo, pmo)
	if not pmo.player then return end
	if pmo.player ~= consoleplayer then return end
	local p = pmo.player

	p.styles_keytouch = {
		cam_x = camera.x,
		cam_y = camera.y,
		cam_z = camera.z,
		cam_angle = camera.angle,
		cam_aiming = camera.aiming,

		x = mo.x,
		y = mo.y,
		z = mo.z,

		sprite = mo.sprite,
		frame = mo.frame,
		dur = FU,

		loop = states[tokenstyle_cv.value and chao_key or heroes_key].var1 + 1,
	}
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
	a.scale = $+FU/3
	a.state = S_YELLOWBOOSTERROLLER

	if mt.args[0] > 0 then
		a.flags2 = $ | MF2_AMBUSH
	end

	if (mt.options & MTF_AMBUSH) then
		a.flags2 = $ | MF2_AMBUSH
	end

	return true
end, MT_YELLOWBOOSTER)

addHook("MapThingSpawn", function(a, mt)
	if Disable_Miscs then return end
	a.renderflags = $|RF_OBJECTSLOPESPLAT|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
	a.scale = $+FU/3
	a.state = S_REDBOOSTERROLLER

	if mt.args[0] > 0 then
		a.flags2 = $ | MF2_AMBUSH
	end

	if (mt.options & MTF_AMBUSH) then
		a.flags2 = $ | MF2_AMBUSH
	end

	return true
end, MT_REDBOOSTER)

local function boost_sound(mo, mop)
	if Disable_Miscs then return end
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

--
--	Goal Ring
--

local goalring = freeslot("MT_SA2_GOALRING")
local goalring_state = freeslot("S_SA2_GOALRING_NORMAL")

sfxinfo[freeslot("sfx_goalrn")].caption = "Goal Ring Ambience"

---@diagnostic disable-next-line
mobjinfo[goalring] = {
	spawnstate = goalring_state,
	flags = MF_SCENERY|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT,
}

---@diagnostic disable-next-line
states[goalring_state] = {
	sprite = freeslot("SPR_SA2_GOALRING"),
	frame = FF_ANIMATE,
	var1 = 47,
	var2 = 1,
}

addHook("MobjSpawn", function(mo)
	if Disable_Miscs then return end
	if GoalRing then return end

	local gr = P_SpawnMobjFromMobj(mo, 0, 0, 8, goalring)
	gr.scale = $+FU/4
	P_RemoveMobj(mo)
end, MT_SIGN)

addHook("MobjThinker", function(a)
	if not consoleplayer then return end

	if consoleplayer.exiting and a.spritexscale then
		a.spriteyscale = 138*a.spriteyscale/128
		a.spritexscale = 118*a.spritexscale/128
	elseif a.spritexscale then
		if not S_SoundPlaying(a, sfx_goalrn) then
			S_StartSound(a, sfx_goalrn)
		end
	end

end, goalring)

--
--	EMBLEM
--

local embspr = freeslot("SPR_EMBLEM_ADVENTURE")

addHook("MobjThinker", function(a)
	if a.cusval == 1998 then
		a.state = S_INVISIBLE
		a.sprite = embspr
		a.frame = (a.frame &~ FF_FRAMEMASK) &~ FF_PAPERSPRITE
		if a.extravalue2 then
			a.extravalue2 = $ - 1
		else
			a.scale = 11*a.scale/10
			a.alpha = 9*a.alpha/10
		end

		if a.scale < FU/8 then
			P_RemoveMobj(a)
			return
		end
	else
		a.sprite = embspr
		a.frame = (a.frame &~ FF_FRAMEMASK)|FF_PAPERSPRITE
		a.angle = $ + ANG2
	end

	a.spriteyoffset = 32*FU
end, MT_EMBLEM)

addHook("MobjDeath", function(a)
	if embspr == a.sprite and a.state ~= S_INVISIBLE then
		a.state = S_INVISIBLE
		a.sprite = embspr
		a.frame = A
		a.cusval = 1998
		a.extravalue2 = TICRATE
		a.fuse = TICRATE*30
	end
end, MT_EMBLEM)


--
--	EMERALD SHARD
--

--addHook("MobjThinker", function(a)
	--if not (a.glow1 and a.glow1.valid) then
		--a.glow1 = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_OVERLAY)
		--a.glow1.colorized = true
		--a.glow1.spriteyscale = -a.scale*3
	--end

	--if not (a.glow2 and a.glow2) then
		--a.glow2 = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_OVERLAY)
		--a.glow2.colorized = true
		--a.glow2.spriteyscale = -a.scale*6
	--end

--end, MT_EMERHUNT)

--
--	RINGS
--

local ringclt = freeslot("S_STYLES_ADV_RINGCLT")

states[ringclt] = {
	sprite = freeslot("SPR_STYLES_ADV_RINGCLT"),
	frame = A|FF_ADD|FF_ANIMATE,
	tics = 16,
	var1 = 7,
	var2 = 2,
}

mobjinfo[MT_RING].deathstate = ringclt
mobjinfo[MT_FLINGRING].deathstate = ringclt
mobjinfo[MT_REDTEAMRING].deathstate = ringclt
mobjinfo[MT_BLUETEAMRING].deathstate = ringclt