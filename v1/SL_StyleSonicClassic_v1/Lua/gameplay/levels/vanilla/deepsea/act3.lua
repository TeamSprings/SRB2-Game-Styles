local TRAPF_ENDLVL 	= 1
local TRAPF_LIFT 	= 2
local TRAPF_FLIGHT 	= 4
local TRAPF_DROP 	= 8

local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8

return 	{
    name = "Deep Sea",
    hash = -222129934,

    _func = function()
        local center = P_SpawnMobj(0, 0, 1536*FU, MT_STYLES_EGGTR)
        center.styles_flags = TRAPF_ENDLVL|TRAPF_LIFT
        center.styles_tagged = 382
        center.styles_list = {mapthings[5].mobj}

        sectors[1].special = 0
        sectors[17].special = 0
        sectors[29].special = 0
        sectors[27].special = 0
        sectors[1].tag = 0
        sectors[17].tag = 0
        sectors[29].tag = 0
        sectors[27].tag = 0
    end,
}