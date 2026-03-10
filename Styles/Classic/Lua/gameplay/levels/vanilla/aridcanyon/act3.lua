local TRAPF_ENDLVL 	= 1
local TRAPF_LIFT 	= 2
local TRAPF_FLIGHT 	= 4
local TRAPF_DROP 	= 8

local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8

return 	{
    name = "Arid Canyon",
    hash = 7242001,

    _func = function()
        local center = P_SpawnMobj(-15872*FU, 4992*FU, 192*FU, MT_STYLES_EGGTR)
        center.styles_flags = TRAPF_ENDLVL|TRAPF_LIFT
        center.styles_tagged = 382
        center.styles_list = {mapthings[20].mobj}

        sectors[14].special = 0
        sectors[15].special = 0
        sectors[19].special = 0
        sectors[6].special = 0
        sectors[14].tag = 0
        sectors[15].tag = 0
        sectors[19].tag = 0
        sectors[6].tag = 0
    end,
}