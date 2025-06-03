
local ab = tbsrequire 'helpers/levels_abstr' ---@type level_abstr

local GFZ1_entrymain = {

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t        
    setup = function(player, actors, library)
        actors:create(
            448 * FU,
            224 * FU,
            192 * FU,
            MT_EGGMOBILE)

        actors:create(
            448 * FU,
            224 * FU,
            192 * FU,
            MT_JETTGUNNER)

        actors:create(
            448 * FU,
            224 * FU,
            192 * FU,
            MT_JETTGUNNER)

        P_SetOrigin(player.mo, player.mo.x - cos(player.mo.angle)*128, player.mo.y - sin(player.mo.angle)*128, player.mo.z)
    end,

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE, func = function(player, actors, library, tics, etics)
            library.moveObj("insine", actors[1],
                (etics-tics) * FU / etics,
            
                448 * FU,
                224 * FU,
                192 * FU,

                1024 * FU,
                736 * FU,
                400 * FU
            )

            library.attachMobj2Target(
                actors[2],
                actors[1], 
                -actors[1].radius * 2,
                actors[1].radius * 2,
                sin(leveltime * ANG2) * 30
            )

            library.attachMobj2Target(
                actors[3],
                actors[1], 
                actors[1].radius * 2,
                -actors[1].radius * 2,
                sin(leveltime * ANG2) * 30
            )

            actors[1].angle = ANGLE_45
            actors[2].angle = ANGLE_45
            actors[3].angle = ANGLE_45

            if player.mo.state ~= S_PLAY_WALK then
                player.mo.state = S_PLAY_WALK
            end

            player.rmomx = 8*FRACUNIT
            P_InstaThrust(player.mo, player.mo.angle, player.mo.scale*4)

            library.moveCamera("insine", camera,
                (etics-tics) * FU / etics,
            
                player.mo.x - cos(player.mo.angle + ANGLE_90)*192,
                player.mo.y - sin(player.mo.angle + ANGLE_90)*192,
                player.mo.z + player.mo.scale*64,

                player.mo.x - cos(player.mo.angle)*128,
                player.mo.y - sin(player.mo.angle)*128,
                player.mo.z + player.mo.scale*64
            )

            camera.angle = ease.linear((etics-tics) * FU / etics, player.mo.angle-ANGLE_90, player.mo.angle)

            library.spriteObj(actors[1], S_EGGMOBILE_STND)
            local jetstate = (leveltime % 2) and S_JETGLOOK1 or S_JETGLOOK2

            library.spriteObj(actors[2], jetstate)
            library.spriteObj(actors[3], jetstate)

            library.lockPlayer(player)
        end
    },  
    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer  
    {   tics = TICRATE, func = function(player, actors, library, tics, etics)
            library.moveObj("outsine", actors[1],
                (etics-tics) * FU / etics,
            
                1024 * FU,
                736 * FU,
                400 * FU,

                1324 * FU,
                1036 * FU,
                1000 * FU
            )

            library.attachMobj2Target(
                actors[2],
                actors[1], 
                -actors[1].radius * 2,
                actors[1].radius * 2,
                sin(leveltime * ANG2) * 30
            )

            library.attachMobj2Target(
                actors[3],
                actors[1], 
                actors[1].radius * 2,
                -actors[1].radius * 2,
                sin(leveltime * ANG2) * 30
            )

            actors[1].scale = ease.linear(tics * FRACUNIT / TICRATE, 0, FRACUNIT)
            actors[2].scale = actors[1].scale
            actors[3].scale = actors[1].scale
            actors[1].angle = ANGLE_45
            actors[2].angle = ANGLE_45
            actors[3].angle = ANGLE_45

            library.spriteObj(actors[1], S_EGGMOBILE_STND)
            local jetstate = (leveltime % 2) and S_JETGLOOK1 or S_JETGLOOK2

            library.spriteObj(actors[2], jetstate)
            library.spriteObj(actors[3], jetstate)

            library.lockPlayer(player)
        end
    },

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer  
    {   tics = TICRATE/2, func = function(player, actors, library, tics, etics)
            library.moveObj("linear", actors[1],
                (etics-tics) * FU / etics,
            
                1324 * FU,
                1036 * FU,
                1000 * FU,

                1424 * FU,
                1136 * FU,
                1400 * FU
            )

            library.attachMobj2Target(
                actors[2],
                actors[1], 
                -actors[1].radius * 2,
                actors[1].radius * 2,
                sin(leveltime * ANG2) * 30
            )

            library.attachMobj2Target(
                actors[3],
                actors[1], 
                actors[1].radius * 2,
                -actors[1].radius * 2,
                sin(leveltime * ANG2) * 30
            )

            actors[1].angle = ANGLE_45
            actors[2].angle = ANGLE_45
            actors[3].angle = ANGLE_45

            library.spriteObj(actors[1], S_EGGMOBILE_STND)
            local jetstate = (leveltime % 2) and S_JETGLOOK1 or S_JETGLOOK2

            library.spriteObj(actors[2], jetstate)
            library.spriteObj(actors[3], jetstate)

            library.lockPlayer(player)
        end
    },
}

local GFZ1_entryall = {

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t        
    setup = function(player, actors, library)
        P_SetOrigin(player.mo, player.mo.x - cos(player.mo.angle)*128, player.mo.y - sin(player.mo.angle)*128, player.mo.z)
    end,

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE, func = function(player, actors, library, tics, etics)
            if player.mo.state ~= S_PLAY_WALK then
                player.mo.state = S_PLAY_WALK
            end

            player.rmomx = 8*FRACUNIT
            P_InstaThrust(player.mo, player.mo.angle, player.mo.scale*4)

            library.moveCamera("insine", camera,
                (etics-tics) * FU / etics,
            
                player.mo.x - cos(player.mo.angle + ANGLE_90)*192,
                player.mo.y - sin(player.mo.angle + ANGLE_90)*192,
                player.mo.z + player.mo.scale*64,

                player.mo.x - cos(player.mo.angle)*128,
                player.mo.y - sin(player.mo.angle)*128,
                player.mo.z + player.mo.scale*64
            )

            camera.angle = ease.linear((etics-tics) * FU / etics, player.mo.angle-ANGLE_90, player.mo.angle)

            library.lockPlayer(player)
        end
    }
}

local GFZ1_entryfang = {

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t        
    setup = function(player, actors, library)
        P_SetOrigin(player.mo, 2603*FU, 1637*FU, 320*FU)
        player.mo.angle = InvAngle(player.mo.angle)
    end,

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE, func = function(player, actors, library, tics, etics)
            if player.mo.state ~= S_PLAY_WAIT then
                player.mo.state = S_PLAY_WAIT
            end

            P_TeleportCameraMove(camera,
                player.mo.x + cos(ANGLE_247h + ANGLE_90)*400,
                player.mo.y + sin(ANGLE_247h + ANGLE_90)*400,
                player.mo.z + player.mo.scale*64
            )

            camera.momx = 0
            camera.momy = 0
            camera.momz = 0

            library.lockPlayer(player)
        end
    },

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE/2, func = function(player, actors, library, tics, etics)
            if player.mo.state ~= S_FANG_INTRO12 then
                player.mo.state = S_FANG_INTRO12
            end

            P_TeleportCameraMove(camera,
                player.mo.x + cos(ANGLE_247h + ANGLE_90)*400,
                player.mo.y + sin(ANGLE_247h + ANGLE_90)*400,
                player.mo.z + player.mo.scale*64
            )

            camera.momx = 0
            camera.momy = 0
            camera.momz = 0


            library.lockPlayer(player)
        end
    },

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE/2, func = function(player, actors, library, tics, etics)
            if player.mo.state ~= S_PLAY_WALK then
                player.mo.state = S_PLAY_WALK
            end

            P_TeleportCameraMove(camera,
                player.mo.x + cos(ANGLE_247h + ANGLE_90)*400,
                player.mo.y + sin(ANGLE_247h + ANGLE_90)*400,
                player.mo.z + player.mo.scale*64
            )
            
            camera.momx = 0
            camera.momy = 0
            camera.momz = 0  

            player.rmomx = 8*FRACUNIT
            P_InstaThrust(player.mo, player.mo.angle, player.mo.scale*4)

            library.lockPlayer(player)
        end
    },    

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE/2, func = function(player, actors, library, tics, etics)
            local anglex = (ANG1 * 45) / etics

            player.mo.angle = $ + anglex

            P_TeleportCameraMove(camera,
                player.mo.x + cos(ANGLE_247h + ANGLE_90)*400,
                player.mo.y + sin(ANGLE_247h + ANGLE_90)*400,
                player.mo.z + player.mo.scale*64
            )

            camera.momx = 0
            camera.momy = 0
            camera.momz = 0            

            library.lockPlayer(player)
        end
    },    

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE/2, func = function(player, actors, library, tics, etics)
            library.moveCamera("outsine", camera,
                (etics-tics) * FU / etics,
            
                player.mo.x + cos(ANGLE_247h + ANGLE_90)*400,
                player.mo.y + sin(ANGLE_247h + ANGLE_90)*400,
                player.mo.z + player.mo.scale*64,

                player.mo.x - cos(player.mo.angle)*128,
                player.mo.y - sin(player.mo.angle)*128,
                player.mo.z + player.mo.scale*64
            )          

            library.lockPlayer(player)
        end
    },   

}


local GFZ1_entrymetal = {

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t        
    setup = function(player, actors, library)
        P_SetOrigin(player.mo, 1095*FU, 1496*FU, 704*FU)
    end,

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE, func = function(player, actors, library, tics, etics)
            player.viewrollangle = ANG1*18

            P_TeleportCameraMove(camera,
                player.mo.x - cos(player.mo.angle)*400,
                player.mo.y - sin(player.mo.angle)*400,
                player.mo.scale*64+704*FU
            )

            camera.momx = 0
            camera.momy = 0
            camera.momz = 0
        
            player.mo.sprite2 = SPR2_CNT1
            player.mo.frame = A

            player.drawangle = ANGLE_180

            library.lockPlayer(player)
        end
    },

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = 3*TICRATE/4, func = function(player, actors, library, tics, etics)
            player.viewrollangle = ANG1*18
            
            P_TeleportCameraMove(camera,
                player.mo.x - cos(player.mo.angle)*400,
                player.mo.y - sin(player.mo.angle)*400,
                player.mo.scale*64+704*FU
            )

            camera.momx = 0
            camera.momy = 0
            camera.momz = 0   

            player.mo.sprite2 = SPR2_CNT1
            player.mo.frame = E+((tics/4) % 2)

            player.drawangle = ANGLE_180

            library.lockPlayer(player)
        end
    },

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = 11*TICRATE/4, func = function(player, actors, library, tics, etics)
            player.viewrollangle = ANG1*18

            P_TeleportCameraMove(camera,
                player.mo.x - cos(player.mo.angle)*400,
                player.mo.y - sin(player.mo.angle)*400,
                player.mo.scale*64+704*FU
            )

            camera.momx = 0
            camera.momy = 0
            camera.momz = 0   

            player.mo.state = S_PLAY_FALL
            player.mo.sprite2 = SPR2_MSC0
            player.mo.frame = A
            player.mo.momz = FRACUNIT

            player.drawangle = ANGLE_180

            library.lockPlayer(player)
        end
    },

    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = TICRATE, func = function(player, actors, library, tics, etics)
            player.viewrollangle = ANG1*18

            P_TeleportCameraMove(camera,
                player.mo.x - cos(player.mo.angle)*400,
                player.mo.y - sin(player.mo.angle)*400,
                player.mo.scale*64+704*FU
            )

            camera.momx = 0
            camera.momy = 0
            camera.momz = 0   

            player.mo.state = S_PLAY_FALL
            player.mo.sprite2 = SPR2_MSC0
            player.mo.frame = A
            player.mo.momz = 1

            player.drawangle = ANGLE_180

            library.lockPlayer(player)
        end
    },


    ---@param player    player_t
    ---@param actors    actorslib_t
    ---@param library   cutscenelib_t
    ---@param tics      integer
    ---@param etics     integer        
    {   tics = 2*TICRATE, func = function(player, actors, library, tics, etics)
            player.viewrollangle = 0

            if etics == tics then
                P_StartQuake(FRACUNIT*16, 12, {player.mo.x, player.mo.y, player.mo.z})
            end
        
            player.mo.state = S_PLAY_SKID
            player.mo.sprite2 = SPR2_SKID
            player.mo.frame = A
            player.mo.momz = -432*FRACUNIT

            player.drawangle = ANGLE_270-ANGLE_180
            library.lockPlayer(player)            
        end
    },    

}


local function GFZ1_entry(player)
    if not player.mo then return end
    
    if (player.mo.skin == "sonic" or
        player.mo.skin == "tails" or
        player.mo.skin == "knuckles") then
        return GFZ1_entrymain
    elseif player.mo.skin == "fang" then
        return GFZ1_entryfang
    elseif player.mo.skin == "metalsonic" then
        return GFZ1_entrymetal
    else
        return GFZ1_entryall
    end
end

return {
    name    = "Greenflower",
    hash    = -1131512167,
    --actnum  = 1,

    _func = function()
        if not multiplayer and StylesC_SPE() == 3 then
            local special_ring1 = ab.getthing(567)
            
            if special_ring1 then
                special_ring1.styles_nochecks = true
            end
            
            ab.deletething(233)
            ab.deletething(234)
            ab.deletething(235)
            ab.deletething(236)
            ab.deletething(237)
            ab.deletething(238)
        end
    end,

    -- Cutscenes
    _in = GFZ1_entry,

    _out = {

        ---@param player    player_t
        ---@param actors    actorslib_t
        ---@param library   cutscenelib_t        
        setup = function(player, actors, library)
            return
        end,        

        ---@param player    player_t
        ---@param actors    actorslib_t
        ---@param library   cutscenelib_t
        ---@param tics      integer
        ---@param etics     integer        
        {   tics = TICRATE, func = function(player, actors, library, tics, etics)
                if player.mo.state ~= S_PLAY_WALK then
                    player.mo.state = S_PLAY_WALK
                end

                player.rmomx = 8*FRACUNIT
                P_InstaThrust(player.mo, player.mo.angle, player.mo.scale*4)
            end
        },

    }
}