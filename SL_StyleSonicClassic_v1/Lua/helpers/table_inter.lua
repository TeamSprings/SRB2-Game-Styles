local inter = tbsrequire('helpers/c_inter')
local hudcfg = 	tbsrequire('gui/hud_conf')

local I_NONE     = 0
local I_GAMEPLAY = 1
local I_BOSS     = 2
local I_ERZ3     = 3
local I_NIGHTS   = 4
local I_MPSPEC   = 5

local function GetValue(func, player)
    if type(func) == "function" then
        return func(player)
    end

    return func
end

local module = {
    [I_GAMEPLAY] = {
        {
            field   = 'totalbonus',
            graphic = 'TTSCORE',
            calc = function(rings, time)
                return inter.Y_GetTimeBonus(rings) + inter.Y_GetRingsBonus(time)
            end,
            base    = function(player)
                return player.score
            end,
            value   = function(player)
                return player.rings, max(player.realtime + (player.style_additionaltime or 0) - (player.styles_cutscenetime_prize or 0), 0)
            end,
            xoffset = {0, 0},
            toggle  = function(player)
                return not (hudcfg.hudselect > 1 and not hudcfg.hudselect ~= 3)
            end,
            bonus   = false,
        },
        {
            field   = 'timebonus',
            graphic = 'TTTIME',
            calc    = inter.Y_GetTimeBonus,
            base    = 0,
            value   = function(player)
                return max(player.realtime + (player.style_additionaltime or 0) - (player.styles_cutscenetime_prize or 0), 0)
            end,
            xoffset = {0, 0},
            toggle  = true,
            bonus   = true,
        },
        {
            field   = 'ringbonus',
            graphic = function() return mariomode and 'TCOIN' or 'TRING' end,
            calc    = inter.Y_GetRingsBonus,
            base    = 0,
            value   = function(player)
                return player.rings
            end,
            xoffset = {0, 0},
            toggle  = true,
            bonus   = true,
        },
        {
            field   = 'perfect',
            graphic = 'TPERFC',
            calc    = inter.Y_GetPerfectBonus,
            base    = 0,
            value   = function(player)
                return player.rings
            end,
            xoffset = {0, 0},
            toggle  = function(player)
                return inter.Y_GetPerfectBonus(player.rings) > 0
            end,
            bonus   = true,
        },
        {
            field   = 'totalbonus',
            graphic = 'TTOTAL',
            calc = function(rings, time)
                return inter.Y_GetTimeBonus(rings) + inter.Y_GetRingsBonus(time)
            end,
            base    = 0,
            value   = function(player)
                return player.rings, max(player.realtime + (player.style_additionaltime or 0) - (player.styles_cutscenetime_prize or 0), 0)
            end,
            xoffset = function(player)
                return {0, hudcfg.hudselect == 6 and 22 or 0}
            end,
            toggle  = function(player)
                return (hudcfg.hudselect > 1 and not hudcfg.hudselect ~= 3)
            end,
            bonus   = false,
        },
    },

    [I_BOSS] = {
        {
            field   = 'totalbonus',
            graphic = 'TTSCORE',
            calc = function(rings, time)
                return inter.Y_GetTimeBonus(rings) + inter.Y_GetRingsBonus(time)
            end,
            base    = function(player)
                return player.score
            end,
            value   = function(player)
                return player.rings, max(player.realtime + (player.style_additionaltime or 0) - (player.styles_cutscenetime_prize or 0), 0)
            end,
            xoffset = {0, 0},
            toggle  = function(player)
                return not (hudcfg.hudselect > 1 and not hudcfg.hudselect ~= 3)
            end,
            bonus   = false,
        },
        {
            field   = 'timebonus',
            graphic = 'TTTIME',
            calc    = inter.Y_GetTimeBonus,
            base    = 0,
            value   = function(player)
                return max(player.realtime + (player.style_additionaltime or 0) - (player.styles_cutscenetime_prize or 0), 0)
            end,
            xoffset = {0, 0},
            toggle  = true,
            bonus   = true,
        },
        {
            field   = 'guardbonus',
            graphic = function() return mariomode and 'TCOIN' or 'TRING' end,
            calc    = inter.Y_GetRingsBonus,
            base    = 0,
            value   = function(player)
                return player.rings
            end,
            xoffset = {0, 0},
            toggle  = true,
            bonus   = true,
        },
        {
            field   = 'perfect',
            graphic = 'TPERFC',
            calc    = inter.Y_GetPerfectBonus,
            base    = 0,
            value   = function(player)
                return player.rings
            end,
            xoffset = {0, 0},
            toggle  = function(player)
                return inter.Y_GetPerfectBonus(player.rings) > 0
            end,
            bonus   = true,
        },
        {
            field   = 'totalbonus',
            graphic = 'TTOTAL',
            calc = function(rings, time)
                return inter.Y_GetTimeBonus(rings) + inter.Y_GetRingsBonus(time)
            end,
            base    = 0,
            value   = function(player)
                return player.rings, max(player.realtime + (player.style_additionaltime or 0) - (player.styles_cutscenetime_prize or 0), 0)
            end,
            xoffset = function(player)
                return {0, hudcfg.hudselect == 6 and 22 or 0}
            end,
            toggle  = function(player)
                return (hudcfg.hudselect > 1 and not hudcfg.hudselect ~= 3)
            end,
            bonus   = false,
        },
    },

    [I_ERZ3] = {
        {},
        {},
        {},
        {}
    },

    [I_NIGHTS] = {
        {},
        {},
        {},
        {}
    },

    [I_MPSPEC] = {
        {},
        {},
        {},
        {}
    },
}


function module.getType()

end

return module