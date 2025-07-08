--[[

	State Swaps for sprite options

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local Options = tbsrequire('helpers/create_cvar')

local api = tbsrequire 'styles_api'

-- Hooks for API

local swaphook = 	api:addHook("SwapMisc")

-- Background

local switch = false

local function switchon()
	switch = true
end

--
-- Checkpoint Switching!
--

local starpost = Options:new("checkpoints", "assets/tables/sprites/checkpoint", switchon)
local checkpoint_current = SPR_STPT

-- Not most efficient way to do this...
addHook("MobjThinker", function(a) a.sprite = checkpoint_current end, MT_STARPOST)

--
--	Emerald Switching!
--

local emeralds = Options:new("emeralds", "assets/tables/sprites/emeralds", switchon)

--
--	Explosion!
--

freeslot("S_ERAEXPL1")

local expl_state = S_ERAEXPL1

local explosion = Options:new("explosions", "assets/tables/sprites/explosion", switchon)

states[S_ERAEXPL1] = {
	sprite = states[S_SONIC3KBOSSEXPLOSION1].sprite or SPR_EXPLOSION_S1,
	frame = FF_ANIMATE|A,
	tics = 21,
	var1 = 6,
	var2 = 3
}

addHook("MobjSpawn", function(a, tm)
	a.state = expl_state
end, MT_SONIC3KBOSSEXPLODE)

--
--	Dust!
--

local dust = Options:new("dust", "assets/tables/sprites/dust", switchon)

--
--	Pity Shield!
--

local pity = Options:new("pity", "assets/tables/sprites/pity", switchon)

--
--	Invincibility!
--

local invincibility = Options:new("invincibility", "assets/tables/sprites/invincibility", switchon)

--
--	Score Text!
--

local score = Options:new("score", "assets/tables/sprites/score", switchon)

--Damn game...
addHook("MobjThinker", function(a)
	a.sprite = Options:getvalue("score")[2]
end, MT_SCORE)

--
--	Sign Post!
--

freeslot("SPR_SIGNS")

local sign_opt = Options:new("sign", "assets/tables/sprites/sign", switchon)
local sign_cv = sign_opt.cv

local signmove_opt = Options:new("sign_movement", "assets/tables/sprites/sign", nil, CV_NETVAR)
local signmove_cv = signmove_opt.cv

-- TODO: Multiple behaviors
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
--	Emblems!
--

local emblemsprites = Options:new("emblems", "assets/tables/sprites/emblems", nil)

addHook("MobjThinker", function(a)
	if a.health > 0 then
		a.sprite = Options:getPureValue("emblems")
		a.frame = ((a.frame & FF_FRAMEMASK) % 5)|(a.frame &~ FF_FRAMEMASK)
	end
end, MT_EMBLEM)

-- ... this wouldn't be necessary if for some damn reason certain part of code didn't think this was part of "Hud rendering code"
addHook("ThinkFrame", function()
	if switch then
		-- Checkpoint

		checkpoint_current = Options:getvalue("checkpoints")[2]

		states[S_STARPOST_IDLE].sprite = checkpoint_current
		states[S_STARPOST_FLASH].sprite = checkpoint_current
		states[S_STARPOST_STARTSPIN].sprite = checkpoint_current
		states[S_STARPOST_SPIN].sprite = checkpoint_current
		states[S_STARPOST_ENDSPIN].sprite = checkpoint_current

		-- Emeralds

		local sprite = Options:getvalue("emeralds")[2]

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

		local expl = Options:getvalue("explosions")[2]

		if expl then
			expl_state = S_ERAEXPL1
			local sprite = expl[1]
			local len_stateexp = expl[2]
			local dur_stateexp = expl[3]
			local ext_stateexp = expl[4] or 0

			states[S_ERAEXPL1].sprite = sprite
			states[S_ERAEXPL1].tics = (len_stateexp + 1) * dur_stateexp
			states[S_ERAEXPL1].var1 = len_stateexp
			states[S_ERAEXPL1].var2 = dur_stateexp
			states[S_ERAEXPL1].frame = A|FF_ANIMATE|ext_stateexp
		else
			expl_state = S_SONIC3KBOSSEXPLOSION1
		end

		-- Dust

		local _x = Options:getvalue("dust")[2]
		local sprite = _x[1]
		local len_stateexp = _x[2]
		local dur_stateexp = _x[3]
		local ext_stateexp = _x[4] or 0

		states[S_XPLD_FLICKY].sprite = sprite

		states[S_XPLD1].sprite = sprite
		states[S_XPLD1].frame = A|FF_ANIMATE|ext_stateexp
		states[S_XPLD1].var1 = len_stateexp
		states[S_XPLD1].var2 = dur_stateexp
		states[S_XPLD1].tics = (len_stateexp + 1) * dur_stateexp

		states[S_XPLD1].nextstate = S_NULL

		-- Pity

		local pity = Options:getvalue("pity")[2]
		local pitycv_value = Options:getCV("pity")[1].value
		local sprite = pity[1]

		for i = 0, 11 do
			states[S_PITY1+i].sprite = sprite
			states[S_PITY1+i].frame = (pitycv_value == 3 and $|FF_ADD or $ &~ FF_ADD)
		end

		local sprite = pity[2]

		states[S_PITY_ICON1].sprite = sprite
		states[S_PITY_ICON2].sprite = sprite

		-- Invincibility

		local invinc = Options:getvalue("invincibility")[2]

		states[S_IVSP].sprite = invinc[1]
		states[S_IVSP].tics = invinc[2]
		states[S_IVSP].var1 = invinc[3]
		states[S_IVSP].var2 = invinc[4]

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

		swaphook("Generic")
	end
end)

--
-- RING COLLECT PARTICLE
--

local ringclt = freeslot("S_STYLES_CLASSIC_RINGCLT")

states[ringclt] = {
	sprite = freeslot("SPR_STYLES_CLASSIC_RINGCLT"),
	frame = A|FF_TRANS30|FF_ANIMATE,
	tics = 18,
	var1 = 8,
	var2 = 2,
}

mobjinfo[MT_RING].deathstate = ringclt
mobjinfo[MT_FLINGRING].deathstate = ringclt
mobjinfo[MT_REDTEAMRING].deathstate = ringclt
mobjinfo[MT_BLUETEAMRING].deathstate = ringclt