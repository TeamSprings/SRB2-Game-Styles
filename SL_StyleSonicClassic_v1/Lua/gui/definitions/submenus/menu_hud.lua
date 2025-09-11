return 	{
    {name = "MAIN LAYOUT", 		opt = "hudlayout",

    desc = [[changes layout of RINGS/TIME/SCORE display]],

    },

    {name = "TITLES", 			opt = "hudtitle",

    desc = [[swaps titlecard and intermission titles]],

    },

    {minv = 0, maxv = 1, name = "SCORE TALLY", cv = CV_FindVar("classic_endtally"),

    desc = [[enables/disables custom in-game score tally, this change is *gameplay altering*.]],

    },

    {name = "FONT STYLE", 		opt = "hudfont",

    desc = [[defines how gameplay font (RINGS/SCORE/TIME and numbers) appear]],

    },

    {minv = 0, maxv = 1, name = "RINGS COUNTER", 	cv = CV_FindVar("classic_ringcounter"),

    desc = [[adds hud element that shows total ammount of rings in the current level]],

    },

    {name = "TIME FORMAT", 	opt = "timeformat",

    desc = [[changes formatting of time (ex. MM:SS:TT vs MM:SS).]],

    },

    {name = "LIVES STYLE", 	opt = "lifeicon",

    desc = [[changes apperance of life counter]],

    },

    {name = "LIVES POSITION", 	opt = "lifepos",

    desc = [[changes position of life counter]],

    },

    {name = "COUNTER EASING", 	opt = "easingtonum",

    desc = [[makes RING/SCORE counters smoothly ease into new values]],

    },

    "COLORS",

    {name = "SCORE COLOR", 	opt = "hudcolorscore",

    desc = [[changes color palette of the SCORE GRAPHIC]],

    },

    {name = "TIME COLOR", 	opt = "hudcolortime",

    desc = [[changes color palette of the TIME GRAPHIC]],

    },

    {name = "RINGS COLOR", 	opt = "hudcolorrings",

    desc = [[changes color palette of the RINGS GRAPHIC]],

    },

    {name = "NIGHTS COLOR", 	opt = "hudcolornights",

    desc = [[changes color palette of the NIGHTS GRAPHIC]],

    },

    {name = "LIVES COLOR", 	opt = "hudcolorlives",

    desc = [[changes color palette of the LIVES ELEMENTS]],

    },

    {name = "NUMBERS COLOR", 	opt = "hudcolornumbers",

    desc = [[changes color palette of each COUNTER'S NUMBERS]],

    },

    "EXTRAS",

    {minv = 0, maxv = 1, name = "HUD USERNAME", 	cv = CV_FindVar("classic_username"),

    desc = [[swaps character name in life counters and tally titles for MULTIPLAYER USERNAME]],

    },

    {name = "EMERALD DISPLAY", 	opt = "emeraldpos",

    desc = [[arrangment of EMERALDS in the tab display]],

    },

    {name = "EMERALD FLASH", 	opt = "emeraldanim",

    desc = [[animation options for HUD EMERALDS]],

    },

    {minv = 0, maxv = 2, name = "DEBUG MODE", 		cv = CV_FindVar("classic_debug"),

    desc = [[adapts sonic 2/3 debug mode's coordinates display, functional yet purely eye-candy change]],

    },

    {minv = 0, maxv = 3, name = "HUD BEHAVIOR", 	cv = CV_FindVar("classic_hidehudop"),

    desc = [[various hiding HUD hiding behvaiors at the intermission etc.]],

    },

    {minv = 0, maxv = 1, name = "BLUE FADING", 		cv = CV_FindVar("classic_bluefade"),

    desc = [[blue fading between levels, similar to Sonic Mania, SRB2 or in some Genesis Games]],

    },
}