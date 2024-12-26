--[[

	State Swaps for sprite options

Contributors: Skydusk
@Team Blue Spring 2022-2025

Taken from Classic Style, will be expanded upon maybe.

]]

--
-- Checkpoint Switching!
--


--[[local switch = false

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
}--]]

-- Not most efficient way to do this...
--- addHook("MobjThinker", function(a) a.sprite = checkpoint_current end, MT_STARPOST)


freeslot("SPR_GBPT")

-- Not most efficient way to do this...
addHook("MobjThinker", function(a) a.sprite = SPR_GBPT end, MT_STARPOST)

states[S_STARPOST_IDLE].sprite = SPR_GBPT
states[S_STARPOST_FLASH].sprite = SPR_GBPT
states[S_STARPOST_STARTSPIN].sprite = SPR_GBPT
states[S_STARPOST_SPIN].sprite = SPR_GBPT
states[S_STARPOST_ENDSPIN].sprite = SPR_GBPT