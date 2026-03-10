local TRAPF_ENDLVL 	= 1
local TRAPF_LIFT 	= 2
local TRAPF_FLIGHT 	= 4
local TRAPF_DROP 	= 8

local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8

return 	{
    name = "Castle Eggman",
    hash = -961259410,

    _func = function()
        local center = P_SpawnMobj(0, 0, 960*FU, MT_STYLES_EGGTR)
        center.styles_flags = TRAPF_ENDLVL|TRAPF_DROP
        center.styles_tagged = 382
        center.styles_list = {mapthings[8].mobj}

        sectors[4].special = 0
        sectors[25].special = 0
        sectors[11].special = 0
        sectors[8].special = 0
        sectors[4].tag = 0
        sectors[25].tag = 0
        sectors[11].tag = 0
        sectors[8].tag = 0
    end,
}