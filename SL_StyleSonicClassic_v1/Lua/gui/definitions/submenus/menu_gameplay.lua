return {
		name = "GAMEPLAY",

    -- SETTINGS

    {name = "SPECIAL STAGE ENTRANCE", 	opt = "specialentrance",

    desc = [[changes ways to reach special stages - disabled in multiplayer]],

    },

    {name = "FORCE SP ENTRANCES", 	opt = "forcespecial",

    desc = [[forces in multiplayer special stage entrances, not reccomended in public lobby]],

    },

    {name = "PRESERVE SHIELD",			opt = "preserveshield",

    desc = [[preserves shields between maps]],

    },

    {name = "END-LEVEL SIGN BEHAVIOR", 	opt = "sign_movement",

    desc = [[changes goal sign behavior]],

    },

    {name = "MONITOR DISTRIBUTION", 	opt = "monitordistribution",

    desc = [[changes distribution of power up monitors]],

    },

    {minv = 0, maxv = 1, name = "MONITOR HOPPING", cv = CV_FindVar("classic_monitormaniajump"),

    desc = [[adds small hop at destruction from SONIC MANIA]],

    },

    {name = "CAPSULE TYPE",			opt = "capsule",

    desc = [[changes CAPSULE TYPE of unset classic style's capsules]],

    },

    {name = "FLICKIES GENERAL",			opt = "flickiesspawn",

    desc = [[changes FLICKY spawn from badniks]],

    },

    {name = "FLICKIES CAPSULE",			opt = "flickiescapsule",

    desc = [[changes FLICKY spawn from unset classic style's CAPSULES]],

    },

    {name = "VARIOUS POLISH", 			opt = "polish",

    desc = [[random visual polish to fading away rings/score etc.]],

    },

}