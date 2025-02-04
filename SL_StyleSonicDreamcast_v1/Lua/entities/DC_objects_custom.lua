--[[

		Custom Monitors

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]


-- Monitors

freeslot("MT_SA5RING_BOX", "S_SA5RING_BOX", "MT_SA5RING_ICON", "S_SA5RING_ICON1", "S_SA5RING_ICON2",
"MT_SA20RING_BOX", "S_SA20RING_BOX", "MT_SA20RING_ICON", "S_SA20RING_ICON1", "S_SA20RING_ICON2",
"MT_SA25RING_BOX", "S_SA25RING_BOX", "MT_SA25RING_ICON", "S_SA25RING_ICON1", "S_SA25RING_ICON2",
"MT_SA40RING_BOX", "S_SA40RING_BOX", "MT_SA40RING_ICON", "S_SA40RING_ICON1", "S_SA40RING_ICON2",
"MT_SARANDRING_BOX", "S_SARANDRING_BOX", "MT_SARANDRING_ICON", "S_SARANDRING_ICON1", "S_SARANDRING_ICON2",
"SPR_TV_SA2RINGMONITORS")

--
--
--	NEW MONITORS MOBJINFO
--
--

mobjinfo[MT_SA5RING_BOX] = {
	spawnhealth = 1,
	reactiontime = 8,
	speed = 1,
	spawnstate = S_SA5RING_BOX,
	painstate = S_SA5RING_BOX,
	radius = 18*FRACUNIT,
	height = 40*FRACUNIT,
	deathsound = sfx_pop,
	deathstate = S_BOX_POP1,
	mass = 100,
	damage = MT_SA5RING_ICON,
	flags = MF_SOLID|MF_SHOOTABLE|MF_MONITOR
}

states[S_SA5RING_BOX] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = 21,
	tics = 2,
	nextstate = S_BOX_FLICKER
}

mobjinfo[MT_SA5RING_ICON] = {
	spawnhealth = 1,
	reactiontime = 5,
	spawnstate = S_SA5RING_ICON1,
	seesound = sfx_itemup,
	speed = 2*FRACUNIT,
	radius = 8*FRACUNIT,
	height = 14*FRACUNIT,
	damage = 62*FRACUNIT,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY|MF_NOGRAVITY|MF_BOXICON
}

states[S_SA5RING_ICON1] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = A|FF_ANIMATE,
	tics = 18,
	var1 = 3,
	var2 = 4,
	nextstate = S_SA5RING_ICON2
}

states[S_SA5RING_ICON2] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = A,
	action = A_RingBox,
	tics = 18,
}

mobjinfo[MT_SA20RING_BOX] = {
	spawnhealth = 1,
	reactiontime = 8,
	speed = 1,
	spawnstate = S_SA20RING_BOX,
	painstate = S_SA20RING_BOX,
	radius = 18*FRACUNIT,
	height = 40*FRACUNIT,
	deathsound = sfx_pop,
	deathstate = S_BOX_POP1,
	mass = 100,
	damage = MT_SA20RING_ICON,
	flags = MF_SOLID|MF_SHOOTABLE|MF_MONITOR
}

states[S_SA20RING_BOX] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = 20,
	tics = 2,
	nextstate = S_BOX_FLICKER
}

mobjinfo[MT_SA20RING_ICON] = {
	spawnhealth = 1,
	reactiontime = 20,
	spawnstate = S_SA20RING_ICON1,
	seesound = sfx_itemup,
	speed = 2*FRACUNIT,
	radius = 8*FRACUNIT,
	height = 14*FRACUNIT,
	damage = 62*FRACUNIT,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY|MF_NOGRAVITY|MF_BOXICON
}

states[S_SA20RING_ICON1] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = E|FF_ANIMATE,
	tics = 18,
	var1 = 3,
	var2 = 4,
	nextstate = S_SA20RING_ICON2
}

states[S_SA20RING_ICON2] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = E,
	action = A_RingBox,
	tics = 18,
}

mobjinfo[MT_SA25RING_BOX] = {
	spawnhealth = 1,
	reactiontime = 8,
	speed = 1,
	spawnstate = S_SA25RING_BOX,
	painstate = S_SA25RING_BOX,
	radius = 18*FRACUNIT,
	height = 40*FRACUNIT,
	deathsound = sfx_pop,
	deathstate = S_BOX_POP1,
	mass = 100,
	damage = MT_SA25RING_ICON,
	flags = MF_SOLID|MF_SHOOTABLE|MF_MONITOR
}

states[S_SA25RING_BOX] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = 22,
	tics = 2,
	nextstate = S_BOX_FLICKER
}

mobjinfo[MT_SA25RING_ICON] = {
	spawnhealth = 1,
	reactiontime = 25,
	spawnstate = S_SA25RING_ICON1,
	seesound = sfx_itemup,
	speed = 2*FRACUNIT,
	radius = 8*FRACUNIT,
	height = 14*FRACUNIT,
	damage = 62*FRACUNIT,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY|MF_NOGRAVITY|MF_BOXICON
}

states[S_SA25RING_ICON1] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = I|FF_ANIMATE,
	tics = 18,
	var1 = 3,
	var2 = 4,
	nextstate = S_SA25RING_ICON2
}

states[S_SA25RING_ICON2] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = I,
	action = A_RingBox,
	tics = 18,
}

mobjinfo[MT_SA40RING_BOX] = {
	spawnhealth = 1,
	reactiontime = 8,
	speed = 1,
	spawnstate = S_SA40RING_BOX,
	painstate = S_SA40RING_BOX,
	radius = 18*FRACUNIT,
	height = 40*FRACUNIT,
	deathsound = sfx_pop,
	deathstate = S_BOX_POP1,
	mass = 100,
	damage = MT_SA40RING_ICON,
	flags = MF_SOLID|MF_SHOOTABLE|MF_MONITOR
}

states[S_SA40RING_BOX] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = 23,
	tics = 2,
	nextstate = S_BOX_FLICKER
}

mobjinfo[MT_SA40RING_ICON] = {
	spawnhealth = 1,
	reactiontime = 40,
	spawnstate = S_SA40RING_ICON1,
	seesound = sfx_itemup,
	speed = 2*FRACUNIT,
	radius = 8*FRACUNIT,
	height = 14*FRACUNIT,
	damage = 62*FRACUNIT,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY|MF_NOGRAVITY|MF_BOXICON
}

states[S_SA40RING_ICON1] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = M|FF_ANIMATE,
	tics = 18,
	var1 = 3,
	var2 = 4,
	nextstate = S_SA40RING_ICON2
}

states[S_SA40RING_ICON2] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = M,
	action = A_RingBox,
	tics = 18,
}

mobjinfo[MT_SARANDRING_BOX] = {
	spawnhealth = 1,
	reactiontime = 8,
	speed = 12,
	spawnstate = S_SARANDRING_BOX,
	painstate = S_SARANDRING_BOX,
	radius = 18*FRACUNIT,
	height = 40*FRACUNIT,
	deathsound = sfx_pop,
	deathstate = S_BOX_POP1,
	mass = 100,
	damage = MT_SARANDRING_ICON,
	flags = MF_SOLID|MF_SHOOTABLE|MF_MONITOR
}

states[S_SARANDRING_BOX] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = 24,
	tics = 2,
	nextstate = S_BOX_FLICKER
}


mobjinfo[MT_SARANDRING_ICON] = {
	spawnhealth = 1,
	reactiontime = 10,
	spawnstate = S_SARANDRING_ICON1,
	seesound = sfx_itemup,
	speed = 2*FRACUNIT,
	radius = 8*FRACUNIT,
	height = 14*FRACUNIT,
	damage = 62*FRACUNIT,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

states[S_SARANDRING_ICON1] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = Q|FF_ANIMATE,
	tics = 18,
	var1 = 3,
	var2 = 4,
	nextstate = S_SARANDRING_ICON2
}

states[S_SARANDRING_ICON2] = {
	sprite = SPR_TV_SA2RINGMONITORS,
	frame = Q,
	action = function(a, var1, var2)
		if not (a.target or a.target.player) then return end

		local Randomize = {5, 10, 20, 25, 40, 50}
		P_GivePlayerRings(a.target.player, Randomize[P_RandomRange(1, #Randomize)])
		S_StartSound(a.target, a.info.seesound)

	end,
	tics = 18,
}
