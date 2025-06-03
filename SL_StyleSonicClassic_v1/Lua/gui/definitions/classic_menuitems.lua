return {
	{
		name = "GENERAL",

		-- SETTINGS

		{name = "GLOBAL PRESET", 	opt = "presets",

		desc = [[preset predefining every setting, includes custom presets saved in classic_presets.txt]],

		},

		{name = "HUD PRESET", 		opt = "hud",

		desc = [[preset predefining all HUD settings]],

		},

		{name = "SAVE PRESET", 		com = "classic_savepreset",

		desc = [[saves custom preset, appears after game restarts.]],

		},

		"DISABLE",

		{name = "HUD", 		opt = "disablegui",

		desc = [[disables all HUD elements that do replace vanilla HUD. - i.e RINGS/TIME/SCORE]],

		},

		{name = "Assets", 	opt = "disableassets",

		desc = [[disables all major asset replacements. - i.e monitors]],

		},

		{name = "Level tweaks", 	opt = "disablelevel",

		desc = [[disables level tweaks to base game levels.]],

		},

		{name = "Cutscenes", 	opt = "disablecutscenes",

		desc = [[disables singleplayer only level-transitional cutscenes in vanilla levels.]],

		},

		-- END SETTINGS

	},

	{
		name = "HEADS-UP DISPLAY",

		-- SETTINGS

		{name = "MAIN LAYOUT", 		opt = "hudlayout",

		desc = [[changes layout of RINGS/TIME/SCORE display]],

		},

		{name = "TITLES", 			opt = "hudtitle",

		desc = [[swaps titlecard and intermission titles]],

		},

		{minv = 0, maxv = 1, name = "SCORE TALLY", cv = CV_FindVar("classic_endtally"),

		desc = [[enables/disables custom in-game score tally, this change is *gameplay altering* and forcefully disabled in multiplayer.]],

		},

		{name = "FONT STYLE", 		opt = "hudfont",

		desc = [[defines how gameplay font (RINGS/SCORE/TIME and numbers) appear]],

		},


		{name = "COLOR PROFILE", 	opt = "hudcolor",

		desc = [[changes color palette of the HUD]],

		},

		{minv = 0, maxv = 1, name = "RINGS COUNTER", 	cv = CV_FindVar("classic_ringcounter"),

		desc = [[adds hud element that shows count of all the rings in the map]],

		},

		{name = "TIME FORMAT", 	opt = "timeformat",

		desc = [[changes formatting of time. this overrides vanilla option that does same thing]],

		},

		{name = "LIVES STYLE", 	opt = "lifeicon",

		desc = [[changes apperance of life counter]],

		},

		{name = "LIVES POSITION", 	opt = "lifepos",

		desc = [[arrangment of emeralds in the tab display]],

		},

		"EXTRAS",

		{minv = 0, maxv = 1, name = "HUD USERNAME", 	cv = CV_FindVar("classic_username"),

		desc = [[forces username into S1/S2/S3 life counters and tally titles]],

		},

		{name = "EMERALD DISPLAY", 	opt = "emeraldpos",

		desc = [[arrangment of emeralds in the tab display]],

		},

		{name = "EMERALD FLASH", 	opt = "emeraldanim",

		desc = [[various options on how emeralds animate in the hud]],

		},

		{minv = 0, maxv = 2, name = "DEBUG MODE", 		cv = CV_FindVar("classic_debug"),

		desc = [[adapts sonic 2/3 debug mode coordinates display, purely eye-candy change]],

		},

		{minv = 0, maxv = 3, name = "HUD BEHAVIOR", 		cv = CV_FindVar("classic_hidehudop"),

		desc = [[various hiding HUD hiding behvaiors at the intermission etc.]],

		},

		{minv = 0, maxv = 1, name = "BLUE FADING", 		cv = CV_FindVar("classic_bluefade"),

		desc = [[blue fading between levels, similar to Sonic Mania, SRB2 or rarely Genesis Games]],

		},

		-- END SETTINGS

	},

	{
		name = "GAMEPLAY",

		-- SETTINGS

		{name = "SPECIAL STAGE ENTRANCE", 	opt = "specialentrance",

		desc = [[changes way to get to special stages, this change is forcefully disabled in multiplayer]],

		},

		{name = "END-LEVEL SIGN BEHAVIOR", 	opt = "sign_movement",

		desc = [[changes way signs move at activation]],

		},

		{name = "MONITOR DISTRIBUTION", 	opt = "monitordistribution",

		desc = [[changes distribution of power up monitors to fit palette of games]],

		},

		{minv = 0, maxv = 1, name = "MONITOR HOPPING", cv = CV_FindVar("classic_monitormaniajump"),

		desc = [[adds monitor hop at destruction from Sonic Mania]],

		},

		{name = "VARIOUS POLISH", 			opt = "polish",

		desc = [[random visual polish to fading away rings/score etc.]],

		},


		-- END SETTINGS
	},

	{
		name = "PLAYER",

		-- SETTINGS

		{name = "THOK TRAIL", 				opt = "thok",

		desc = [[removes trails from "thok"/airdash ability or spinning abilities]],

		},

		{name = "SPINDASH", 				opt = "spindash",

		desc = [[swaps spindash style between CD and Classic style of spinning]],

		},

		{name = "SPRING TWIRL", 			opt = "springtwirl",

		desc = [[makes player character spin in the air in spring pose]]

		},

		{name = "SPRING ROLL", 				opt = "springroll",

		desc = [[makes player character roll in the air at diagonal spring touch]],

		},

		{name = "FALL AIRWALK", 			opt = "springairwalk",

		desc = [[replaces fall animation with air walking]],

		},

		{name = "SPRITEROLL", 				opt = "groundrot",

		desc = [[sprite rotation based on slope yaw & smoothing]],

		},		

		-- END SETTINGS
	},

	{
		name = "EYECANDY",

		-- SETTINGS

		{name = "MONITORS", 		opt = "monitor"},
		{name = "STARPOSTS", 		opt = "checkpoints"},
		{name = "EMERALDS", 		opt = "emeralds"},
		{name = "EXPLOSIONS", 		opt = "explosions"},
		{name = "POOF DUST", 		opt = "dust"},
		{name = "PITY SHIELD", 		opt = "pity"},
		{name = "INVULNERABILITY", 	opt = "invincibility"},
		{name = "TOKEN SPRITE",		opt = "tokensprite"},
		{name = "EMBLEMS",			opt = "emblems"},
		{name = "SCORE POP UP", 	opt = "score"},
		{name = "SIGN", 			opt = "sign"},

		-- END SETTINGS

	},

	{
		name = "AUDIO",

		-- SETTINGS

		{name = "1UP THEME", 		opt = "oneuptheme"},
		{name = "SPEED SHOES THEME", 	opt = "shoestheme"},
		{name = "INVULNERABILITY THEME", 		opt = "invintheme"},
		{name = "SUPER FORM THEME", 		opt = "supertheme"},
		{name = "BOSS THEME", 		opt = "bosstheme"},
		{name = "LEVEL CLEAR THEME", 		opt = "levelendtheme"},
		{name = "DROWNING THEME", 		opt = "drowntheme"},

		"SFX",

		{name = "JUMP SFX", 				opt = "jumpsfx"},
		{name = "SPIN SFX", 				opt = "spinsfx"},	
		{name = "SPINDASH SFX", 			opt = "dashsfx"},	

		-- END SETTINGS

	},

}