--[[

	State Swaps for sprite options

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

--
-- Checkpoint Switching!
--

local switch = false

local checkpoint_sprites = {
	freeslot("SPR_STARPOST_S1"),
	freeslot("SPR_STARPOST_BETA"),
	SPR_STPT,
	freeslot("SPR_STARPOST_CD"),
	freeslot("SPR_STARPOST_S3"),
	freeslot("SPR_STARPOST_MANIA")
}

local checkpoint_current = SPR_STARPOST_S1

local checkpoints_cv = CV_RegisterVar{
	name = "classic_checkpoints",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		switch = true
	end,
	PossibleValue = {sonic1=1, sonic2beta=2, sonic2=3, soniccd=4, sonic3=5, sonicmania=6}
}

-- Not most efficient way to do this...
addHook("MobjThinker", function(a) a.sprite = checkpoint_current end, MT_STARPOST)

--
--	Emerald Switching!
--

local emeralds_sprites = {
	SPR_CEMG,
	freeslot("SPR_EMERALD_S2"),
	freeslot("SPR_EMERALD_CD"),
	freeslot("SPR_EMERALD_S3"),
	freeslot("SPR_EMERALD_MANIA"),
}

local emeralds_cv = CV_RegisterVar{
	name = "classic_emeralds",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		switch = true
	end,
	PossibleValue = {sonic1=1, sonic2=2, soniccd=3, sonic3=4, sonicmania=5}
}

--
--	Explosion!
--

freeslot("S_ERAEXPL1")

local explosion_sprites = {
	freeslot("SPR_EXPLOSION_S1"),
	freeslot("SPR_EXPLOSION_S2"),
	freeslot("SPR_EXPLOSION_S3")
}

local expl_state = S_ERAEXPL1

states[S_ERAEXPL1] = {
	sprite = explosion_sprites[1],
	frame = FF_ANIMATE|FF_FULLBRIGHT|A,
	tics = 21,
	var1 = 6,
	var2 = 3
}

local explosions_cv = CV_RegisterVar{
	name = "classic_explosions",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		switch = true
	end,
	PossibleValue = {sonic1=1, sonic2=2, sonic3=3}
}

addHook("MobjSpawn", function(a, tm)
	a.state = expl_state
end, MT_SONIC3KBOSSEXPLODE)

--
--	Dust!
--

local dust_sprites = {
	{freeslot("SPR_DUST_S1"), 4},
	{freeslot("SPR_DUST_S2"), 4},
}

local dust_cv = CV_RegisterVar{
	name = "classic_dust",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		switch = true
	end,
	PossibleValue = {sonic1=1, sonic2=2}
}

--
--	Pity Shield!
--

local pity_sprites = {
	freeslot("SPR_PITY_S1"),
	freeslot("SPR_PITY_S2"),
	freeslot("SPR_PITY_3B"),
	freeslot("SPR_PITY_R"),
}

local pityicon_sprites = {
	freeslot("SPR_TVPITY_S1"),
	freeslot("SPR_TVPITY_S2"),
	freeslot("SPR_TVPITY_3B"),
	freeslot("SPR_TVPITY_R"),
}

local pity_cv = CV_RegisterVar{
	name = "classic_pity",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		switch = true
	end,
	PossibleValue = {sonic1=1, sonic2=2, blast3d=3, sonicr=4}
}

--
--	Invincibility!
--

local invincibility_sprites = {
	freeslot("SPR_INVINCIBILITY_S1"),
	SPR_IVSP,
}

local invincibility_cv = CV_RegisterVar{
	name = "classic_invincibility",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		switch = true
	end,
	PossibleValue = {sonic1=1, sonic2=2}
}

--
--	Score Text!
--

local score_sprites = {
	freeslot("SPR_SCORE_S1"),
	SPR_SCOR,
	freeslot("SPR_SCORE_CD"),
	freeslot("SPR_SCORE_S3"),
}

local score_cv = CV_RegisterVar{
	name = "classic_score",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {sonic1=1, sonic2=2, soniccd=3, sonic3=4}
}

--Damn game...
addHook("MobjThinker", function(a)
	a.sprite = score_sprites[score_cv.value]
end, MT_SCORE)

--
--	Sign Post!
--

freeslot("SPR_SIGNS")

local sign_cv = CV_RegisterVar{
	name = "classic_sign",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		switch = true
	end,
	PossibleValue = {sonic1=1, soniccd=2}
}

local signmove_cv = CV_RegisterVar{
	name = "classic_sign_movement",
	flags = CV_NETVAR,
	defaultvalue = "srb2",
	flags = 0,
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

-- ... this wouldn't be necessary if for some damn reason certain part of code didn't think this was part of "Hud rendering code"
addHook("ThinkFrame", function()
	if switch then
		-- Checkpoint

		checkpoint_current = checkpoint_sprites[checkpoints_cv.value]

		states[S_STARPOST_IDLE].sprite = checkpoint_current
		states[S_STARPOST_FLASH].sprite = checkpoint_current
		states[S_STARPOST_STARTSPIN].sprite = checkpoint_current
		states[S_STARPOST_SPIN].sprite = checkpoint_current
		states[S_STARPOST_ENDSPIN].sprite = checkpoint_current

		-- Emeralds

		local sprite = emeralds_sprites[emeralds_cv.value]

		states[S_CEMG1].sprite = sprite
		states[S_CEMG2].sprite = sprite
		states[S_CEMG3].sprite = sprite
		states[S_CEMG4].sprite = sprite
		states[S_CEMG5].sprite = sprite
		states[S_CEMG6].sprite = sprite
		states[S_CEMG7].sprite = sprite

		states[S_ORBITEM1].sprite = sprite
		states[S_ORBITEM2].sprite = sprite
		states[S_ORBITEM3].sprite = sprite
		states[S_ORBITEM4].sprite = sprite
		states[S_ORBITEM5].sprite = sprite
		states[S_ORBITEM6].sprite = sprite
		states[S_ORBITEM7].sprite = sprite

		-- Explosions

		if explosions_cv.value == 0 then
			expl_state = S_SONIC3KBOSSEXPLOSION1
		else
			expl_state = S_ERAEXPL1
			local expl_var1 = {4, 6, 5}
			local expl_var2 = {3, 3, 3}
			local expl_tics = {15, 21, 15}

			states[S_ERAEXPL1].sprite = explosion_sprites[explosions_cv.value]
			states[S_ERAEXPL1].tics = expl_tics[explosions_cv.value]
			states[S_ERAEXPL1].var1 = expl_var1[explosions_cv.value]
			states[S_ERAEXPL1].var2 = expl_var2[explosions_cv.value]
		end

		-- Dust

		local sprite = dust_sprites[dust_cv.value][1]
		local end_i = dust_sprites[dust_cv.value][2]

		states[S_XPLD_FLICKY].sprite = sprite

		for i = 0, end_i do
			states[S_XPLD1+i].sprite = sprite
			states[S_XPLD1+i].frame = i
			states[S_XPLD1+i].nextstate = S_XPLD1+i+1
		end
		states[S_XPLD1+end_i].nextstate = S_NULL

		-- Pity

		local sprite = pity_sprites[pity_cv.value]

		for i = 0, 11 do
			states[S_PITY1+i].sprite = sprite
			states[S_PITY1+i].frame = (pity_cv.value == 3 and $|FF_ADD or $ &~ FF_ADD)
		end

		local sprite = pityicon_sprites[pity_cv.value]
		states[S_PITY_ICON1].sprite = sprite
		states[S_PITY_ICON2].sprite = sprite

		-- Invincibility

		local tics = {15, 32}
		local var1 = {3, 31}
		local var2 = {3, 1}

		states[S_IVSP].sprite = invincibility_sprites[invincibility_cv.value]
		states[S_IVSP].tics = tics[invincibility_cv.value]
		states[S_IVSP].var1 = var1[invincibility_cv.value]
		states[S_IVSP].var2 = var2[invincibility_cv.value]

		-- Signpost
		local sign_frame = sign_cv.value == 1 and A or B

		states[S_SIGN].sprite = SPR_SIGNS
		states[S_SIGN].frame = sign_frame
		states[S_SIGNSPIN1].sprite = SPR_SIGNS
		states[S_SIGNSPIN1].frame = sign_frame
		states[S_SIGNSPIN2].sprite = SPR_SIGNS
		states[S_SIGNSPIN2].frame = sign_frame
		states[S_SIGNSPIN3].sprite = SPR_SIGNS
		states[S_SIGNSPIN3].frame = sign_frame
		states[S_SIGNSPIN4].sprite = SPR_SIGNS
		states[S_SIGNSPIN4].frame = sign_frame
		states[S_SIGNSPIN5].sprite = SPR_SIGNS
		states[S_SIGNSPIN5].frame = sign_frame
		states[S_SIGNSPIN6].sprite = SPR_SIGNS
		states[S_SIGNSPIN6].frame = sign_frame
		states[S_SIGNSLOW].sprite = SPR_SIGNS
		states[S_SIGNSLOW].frame = sign_frame
		states[S_SIGNSTOP].sprite = SPR_SIGNS
		states[S_SIGNSTOP].frame = sign_frame
		states[S_SIGNPLAYER].sprite = SPR_SIGNS
		states[S_SIGNPLAYER].frame = sign_frame


		switch = false
	end
end)