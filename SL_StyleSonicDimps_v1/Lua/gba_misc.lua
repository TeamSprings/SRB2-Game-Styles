--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

freeslot("MT_BACKERADUMMY", "MT_BACKTIERADUMMY", "MT_FRONTTIERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "S_DUMMYMONITOR", "S_ERASMOKE1", "S_ERASMOKE2", "S_ERADEBREE1", "S_ERADEBREE2", "S_ERADEBREE3", "SPR_CA1D", "SPR_CA2D", "SPR_1CAP", "SPR_ADVANCEKEY", "SPR_CHE0", "SPR_1MOA")

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
	dispoffset = -1
}

mobjinfo[MT_FRONTERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = 1
}

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

mobjinfo[MT_FRONTTIERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_SCENERY,
	dispoffset = 2
}

states[S_PITY1] = {
	sprite = SPR_PITY,
	frame = FF_ANIMATE|FF_TRANS40|FF_SEMIBRIGHT|A,
	tics = 18,
	var1 = 5,
	var2 = 3,
	nextstate = S_PITY1,
}


states[S_ERASMOKE1] = {
	sprite = SPR_CA2D,
	frame = FF_ANIMATE|A,
	tics = 15,
	var1 = 4,
	var2 = 3
}

states[S_ERASMOKE2] = {
	sprite = SPR_CA1D,
	frame = FF_ANIMATE|A,
	tics = 32,
	var1 = 7,
	var2 = 4
}

states[S_ERADEBREE1] = {
	sprite = SPR_CA2D,
	frame = FF_ANIMATE|F,
	tics = TICRATE*4,
	var1 = 3,
	var2 = 3,
	nextstate = S_NULL
}

states[S_ERADEBREE2] = {
	sprite = SPR_CA2D,
	frame = FF_ANIMATE|J,
	tics = TICRATE*4,
	var1 = 3,
	var2 = 3,
	nextstate = S_NULL
}

states[S_ERADEBREE3] = {
	sprite = SPR_CA2D,
	frame = FF_ANIMATE|N,
	tics = TICRATE*4,
	var1 = 3,
	var2 = 3,
	nextstate = S_NULL
}

states[S_DUMMYMONITOR] = {
	sprite = SPR_1MOA,
	frame = B
}

states[S_TOKEN] = {
	sprite = SPR_ADVANCEKEY,
	frame = FF_ANIMATE,
	var1 = 49,
	var2 = 1,
}

addHook("MapThingSpawn", function(mo)
	mo.spritexscale = mo.spritexscale/3
	mo.spriteyscale = mo.spriteyscale/3
end, MT_TOKEN)

states[S_XPLD_FLICKY].sprite = SPR_CA1D
states[S_XPLD_FLICKY].frame = A
states[S_XPLD1].sprite = SPR_CA1D
states[S_XPLD1].frame = A
states[S_XPLD1].tics = 4
states[S_XPLD2].sprite = SPR_CA1D
states[S_XPLD2].frame = B
states[S_XPLD2].tics = 4
states[S_XPLD3].sprite = SPR_CA1D
states[S_XPLD3].frame = C
states[S_XPLD3].tics = 4
states[S_XPLD4].sprite = SPR_CA1D
states[S_XPLD4].frame = D
states[S_XPLD4].tics = 4
states[S_XPLD4].nextstate = S_NULL

addHook("MobjSpawn", function(a, tm)
	a.state = S_ERASMOKE1

	if P_RandomRange(0, 2) then
		local debree = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_BROKENROBOT)
		local randoma = P_RandomRange(0, 360)*ANG1
		debree.state = S_ERADEBREE1+P_RandomRange(0, 2)
		debree.momx = 9*cos(randoma)
		debree.momy = 9*sin(randoma)
		debree.momz = P_RandomRange(7,10)*a.scale
		debree.scale = FRACUNIT/2
		debree.fuse = 8*TICRATE
	end
end, MT_SONIC3KBOSSEXPLODE)

-- Eggman Stuff

local eggman_toggle = 1
local icon_cv = CV_RegisterVar{
	name = "gba_eggmanvoice",
	defaultvalue = "english",
	flags = CV_CALL,
	func = function(var)
		eggman_toggle = var.value
	end,
	PossibleValue = {disabled=0, english=1, japanese=2}
}

local eggsounds = {
	--
	-- Japanese
	--

	-- hurt
	freeslot("sfx_adegj1"),
	freeslot("sfx_adegj2"),
	-- death
	freeslot("sfx_adegj3"),

	--
	-- English
	--

	-- hurt
	freeslot("sfx_adege1"),
	freeslot("sfx_adege2"),

	-- death
	freeslot("sfx_adege3"),
}

-- I needed somehow stored those sounds... leaving freeslots outside somehow makes it lose reference

-- Japanese
sfxinfo[eggsounds[1]].caption = "Eggman Hurt"
sfxinfo[eggsounds[2]].caption = "Eggman Hurt"
sfxinfo[eggsounds[3]].caption = "Eggman Escaping"
-- English
sfxinfo[eggsounds[4]].caption = "Eggman Hurt"
sfxinfo[eggsounds[5]].caption = "Eggman Hurt"
sfxinfo[eggsounds[6]].caption = "Eggman Escaping"

for _,egg in ipairs{
	MT_EGGMOBILE,
	MT_EGGMOBILE2,
	MT_EGGMOBILE3,
	MT_EGGMOBILE4,
	MT_BLACKEGGMAN,
	MT_CYBRAKDEMON,
} do
	addHook("MobjDamage", function(mo)
		if mo.health > 1 and eggman_toggle and P_RandomRange(0, 2) then
			S_StartSound(mo, eggsounds[eggman_toggle == 2 and P_RandomRange(1, 2) or P_RandomRange(4, 5)])
		end
	end, egg)

	addHook("MobjDeath", function(mo)
		if eggman_toggle then
			S_StartSound(mo, eggsounds[eggman_toggle == 2 and 3 or 6])
		end
	end, egg)
end

--
--	Sign Post!
--


local signmove_cv = CV_RegisterVar{
	name = "gba_sign_movement",
	flags = CV_NETVAR,
	defaultvalue = "stand",
	PossibleValue = {srb2=0, stand=1}
}

addHook("MobjThinker", function(a)
	if signmove_cv.value then
		if not a.style_spin then
			a.style_z = a.z
			a.style_spin = 1
		end

		if a.state > S_SIGNSPIN1-1 and a.state < S_SIGNSPIN6+1 then
			if a.state == S_SIGNSPIN1 then
				a.style_spin = $+1
			end

			if a.style_spin < 32 then
				a.momz = 0
				a.z = a.style_z+1
			end
		end
	end
end, MT_SIGN)

--
--	Invincibility
--

local invincbl = freeslot("SPR_INVINCIBILITYADVA")
local invinc_state = freeslot("S_INVINCIBILITY_ADVANCE")

states[S_INVINCIBILITY_ADVANCE] = {
	sprite = SPR_INVINCIBILITYADVA,
	frame = FF_ANIMATE|FF_ADD|FF_TRANS30,
	var1 = 5,
	var2 = 4,
}

addHook("MobjThinker", function(a)
	P_RemoveMobj(a)
end, MT_IVSP)

addHook("PlayerThink", function(p)
	if not p.mo then return end

	if p.powers[pw_invulnerability] then
		if not (p.advance_shine_fol and p.advance_shine_fol.valid) then
			p.advance_shine_fol = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_OVERLAY)
			p.advance_shine_fol.target = p.mo
			p.advance_shine_fol.state = S_INVINCIBILITY_ADVANCE
			p.advance_shine_fol.spritexscale = 3*FRACUNIT/2
			p.advance_shine_fol.spriteyscale = 3*FRACUNIT/2
		end
	else
		if p.advance_shine_fol then
			if p.advance_shine_fol.valid then
				P_RemoveMobj(p.advance_shine_fol)
			end
			p.advance_shine_fol = nil
		end
	end
end)