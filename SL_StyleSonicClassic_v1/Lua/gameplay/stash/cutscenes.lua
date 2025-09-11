local ab = tbsrequire 'helpers/levels_abstr' ---@type level_abstr

return {
    walkOff = {
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
        }
    },


    fallOff = {
        ---@param player    player_t
        ---@param actors    actorslib_t
        ---@param library   cutscenelib_t        
        setup = function(player, actors, library)
            if not player.mo then return end
            
            P_SetOrigin(player.mo, player.mo.x, player.mo.y, player.mo.z + 1024*FU)
            player.mo.momz = -7*FU*P_MobjFlip(player.mo)

            if player.mo.state ~= S_PLAY_FALL then
                player.mo.state = S_PLAY_FALL
            end
        end,

        ---@param player    player_t
        ---@param actors    actorslib_t
        ---@param library   cutscenelib_t
        ---@param tics      integer
        ---@param etics     integer        
        {   tics = 7*TICRATE/3, func = function(player, actors, library, tics, etics)
                library.lockPlayer(player)
            end
        }
    },
}