/*
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
*/

--
-- Checkpoint Switching!
--

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
		checkpoint_current = checkpoint_sprites[var.value]

		states[S_STARPOST_IDLE].sprite = checkpoint_current
		states[S_STARPOST_FLASH].sprite = checkpoint_current
		states[S_STARPOST_STARTSPIN].sprite = checkpoint_current
		states[S_STARPOST_SPIN].sprite = checkpoint_current
		states[S_STARPOST_ENDSPIN].sprite = checkpoint_current
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
		local sprite = emeralds_sprites[var.value]

		states[S_CEMG1].sprite = sprite
		states[S_CEMG2].sprite = sprite
		states[S_CEMG3].sprite = sprite
		states[S_CEMG4].sprite = sprite
		states[S_CEMG5].sprite = sprite
		states[S_CEMG6].sprite = sprite
		states[S_CEMG7].sprite = sprite
	end,
	PossibleValue = {sonic1=1, sonic2=2, soniccd=3, sonic3=4, sonicmania=5}
}

--
--	Explosion!
--

freeslot("S_ERAEXPL1")

local explosion_sprites = {
	SPR_BOM3,
	freeslot("SPR_EXPLOSION_S1"),
	freeslot("SPR_EXPLOSION_S2"),
	freeslot("SPR_EXPLOSION_S3")
}

local expl_state = S_SONIC3KBOSSEXPLOSION1

states[S_ERAEXPL1] = {
	sprite = explosion_sprites[1],
	frame = FF_ANIMATE|A,
	tics = 21,
	var1 = 6,
	var2 = 3
}

local explosions_cv = CV_RegisterVar{
	name = "classic_explosions",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		if var.value == 0 then
			expl_state = S_SONIC3KBOSSEXPLOSION1
		else
			expl_state = S_ERAEXPL1
			local expl_var1 = {4, 6, 5}
			local expl_var2 = {3, 3, 3}
			local expl_tics = {15, 21, 15}

			states[S_ERAEXPL1].sprite = explosion_sprites[var.value]
			states[S_ERAEXPL1].var1 = expl_var1[var.value]
			states[S_ERAEXPL1].var2 = expl_var2[var.value]
		end
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
		local sprite = dust_sprites[var.value][1]
		local end_i = dust_sprites[var.value][2]

		states[S_XPLD_FLICKY].sprite = sprite

		for i = 0, end_i do
			states[S_XPLD1+i].sprite = sprite
			states[S_XPLD1+i].frame = i
			states[S_XPLD1+i].nextstate = S_XPLD1+i+1
		end
		states[S_XPLD1+end_i].nextstate = S_NULL
	end,
	PossibleValue = {sonic1=1, sonic2=2}
}

--
--	Pity Shield!
--

local pity_sprites = {
	freeslot("SPR_PITY_S1"),
}

local pity_cv = CV_RegisterVar{
	name = "classic_pity",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		local sprite = pity_sprites[var.value]

		for i = 0, 11 do
			states[S_PITY1+i].sprite = sprite
		end
	end,
	PossibleValue = {sonic1=1}
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
		local tics = {15, 32}
		local var1 = {3, 31}
		local var2 = {3, 1}

		states[S_IVSP].sprite = invincibility_sprites[var.value]
		states[S_IVSP].tics = tics[var.value]
		states[S_IVSP].var1 = var1[var.value]
		states[S_IVSP].var2 = var2[var.value]
	end,
	PossibleValue = {sonic1=1, sonic2=2}
}

--
--	Score Text!
--

local score_sprites = {
	SPR_SCOR,
	freeslot("SPR_SCORE_S3"),
}

local score_cv = CV_RegisterVar{
	name = "classic_score",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		states[S_SCRA].sprite = score_sprites[var.value]
	end,
	PossibleValue = {sonic1=1, sonic3=2}
}

--
--	Sign Post!
--

freeslot("SPR_SIGNS")

local sign_cv = CV_RegisterVar{
	name = "classic_sign",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		states[S_SIGN].sprite = SPR_SIGNS
		states[S_SIGN].frame = var.value == 1 and A or B
	end,
	PossibleValue = {sonic1=1, soniccd=2}
}

