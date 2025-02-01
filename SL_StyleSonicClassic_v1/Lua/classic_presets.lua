--[[

	Presets

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local presets = {
	-- SONIC 1
	[1] = {
		classic_hud = 1,
		classic_checkpoints = 1,
		classic_emeralds = 1,
		classic_invincibility = 1,
		classic_explosions = 1,
		classic_dust = 1,
		classic_pity = 1,
		classic_score = 1,
		classic_sign = 1,
		classic_monitor = 1,
		classic_specialentrance = 1,

		-- Player
		classic_spindash = 0,
		classic_springtwirk = 0,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 1,
		classic_supertheme = 1,
		classic_oneuptheme = 1,
		classic_bosstheme = 1,
		classic_levelendtheme = 1,
		classic_drowntheme = 1,
		classic_shoestheme = 1,
	},

	-- SONIC 2
	[2] = {
		classic_hud = 2,
		classic_checkpoints = 3,
		classic_emeralds = 2,
		classic_invincibility = 2,
		classic_explosions = 2,
		classic_dust = 2,
		classic_pity = 2,
		classic_score = 2,
		classic_sign = 1,
		classic_monitor = 2,
		classic_specialentrance = 2,

		-- Player
		classic_spindash = 0,
		classic_springtwirk = 0,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 2,
		classic_supertheme = 1,
		classic_oneuptheme = 1,
		classic_bosstheme = 2,
		classic_levelendtheme = 1,
		classic_drowntheme = 1,
		classic_shoestheme = 1,
	},

	-- SONIC CD
	[3] = {
		classic_hud = 3,
		classic_checkpoints = 4,
		classic_emeralds = 3,
		classic_invincibility = 1,
		classic_explosions = 1,
		classic_dust = 1,
		classic_pity = 1,
		classic_score = 3,
		classic_sign = 1,
		classic_monitor = 1,
		classic_specialentrance = 1,

		-- Player
		classic_spindash = 1,
		classic_springtwirk = 1,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 3,
		classic_supertheme = 1,
		classic_oneuptheme = 1,
		classic_bosstheme = 3,
		classic_levelendtheme = 2,
		classic_drowntheme = 1,
		classic_shoestheme = 1,
	},

	-- SONIC 3
	[4] = {
		classic_hud = 4,
		classic_checkpoints = 5,
		classic_emeralds = 4,
		classic_invincibility = 2,
		classic_explosions = 3,
		classic_dust = 2,
		classic_pity = 2,
		classic_score = 4,
		classic_sign = 1,
		classic_monitor = 3,
		classic_specialentrance = 3,

		-- Player
		classic_spindash = 0,
		classic_springtwirk = 0,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 4,
		classic_supertheme = 4,
		classic_oneuptheme = 2,
		classic_bosstheme = 5,
		classic_levelendtheme = 4,
		classic_drowntheme = 2,
		classic_shoestheme = 3,
	},

	-- SONIC MANIA
	[5] = {
		classic_hud = 7,
		classic_checkpoints = 6,
		classic_emeralds = 5,
		classic_invincibility = 2,
		classic_explosions = 3,
		classic_dust = 1,
		classic_pity = 1,
		classic_score = 2,
		classic_sign = 1,
		classic_monitor = 5,
		classic_specialentrance = 3,

		-- Player
		classic_spindash = 0,
		classic_springtwirk = 1,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 8,
		classic_supertheme = 5,
		classic_oneuptheme = 4,
		classic_bosstheme = 12,
		classic_levelendtheme = 8,
		classic_drowntheme = 3,
		classic_shoestheme = 3,
	},
}

local presets_cv = CV_RegisterVar{
	name = "classic_presets",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		if presets[var.value] then
			local preset = presets[var.value]
			for strcvar, change in pairs(preset) do
				local cvar = CV_FindVar(strcvar)
				if cvar then
					CV_Set(cvar, change)
				end
			end
		end
	end,
	PossibleValue = {sonic1=1, sonic2=2, soniccd=3, sonic3=4, sonicmania=5}
}