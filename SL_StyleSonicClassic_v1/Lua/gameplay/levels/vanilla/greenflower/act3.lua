local TRAPF_ENDLVL 	= 1
local TRAPF_LIFT 	= 2
local TRAPF_FLIGHT 	= 4
local TRAPF_DROP 	= 8

local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8

return 	{
    name = "Greenflower",
    hash = -838659965,

    _func = function()
        local center = P_SpawnMobj(4470*FU, 3688*FU, 3552*FU, MT_STYLES_EGGTR)
        center.styles_flags = TRAPF_ENDLVL|TRAPF_FLIGHT
        center.styles_tagged = 382
        center.styles_list = {mapthings[112].mobj}

        sectors[11].special = 0
        sectors[30].special = 0
        sectors[23].special = 0
        sectors[26].special = 0
        sectors[11].tag = 0
        sectors[30].tag = 0
        sectors[23].tag = 0
        sectors[26].tag = 0
    end,
}