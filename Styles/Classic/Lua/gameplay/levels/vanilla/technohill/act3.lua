local TRAPF_ENDLVL 	= 1
local TRAPF_LIFT 	= 2
local TRAPF_FLIGHT 	= 4
local TRAPF_DROP 	= 8

local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8

return 	{
    name = "Techno Hill",
    hash = -348200440,

    _func = function()
        local center = P_SpawnMobj(2176*FU, 704*FU, 136*FU, MT_STYLES_EGGTR)
        center.styles_flags = TRAPF_ENDLVL|TRAPF_LIFT
        center.styles_tagged = 382
        center.styles_list = {mapthings[9].mobj}

        sectors[37].special = 0
        sectors[28].special = 0
        sectors[30].special = 0
        sectors[32].special = 0
        sectors[37].tag = 0
        sectors[28].tag = 0
        sectors[30].tag = 0
        sectors[32].tag = 0
    end,
}