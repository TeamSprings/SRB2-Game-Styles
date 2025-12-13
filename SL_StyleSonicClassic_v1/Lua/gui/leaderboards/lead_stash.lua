local fonts = 	tbsrequire('gui/hud_fonts')

return {
    players = function(v, _x, y, len, write, icon, player, order, flags, ingame)
        local x = _x + 15

        local num = order
        local disply = (displayplayer == player and fonts.menuyellow or fonts.menuwhite)..'NAM'

        if num > 9 then
            write(v, disply, (x-8)*FU, (y+1)*FU, FU, order,
                V_SNAPTOLEFT|V_SNAPTOTOP|flags, nil, "center", 1)
        else
            write(v, disply, (x-4)*FU, (y+1)*FU, FU, order,
                V_SNAPTOLEFT|V_SNAPTOTOP|flags, nil, "center", 1)
        end

        if player.ping then
            v.drawFill(x + 16, y-5, 3, 16, 253|V_SNAPTOLEFT|V_SNAPTOTOP|flags)

            local pingsize = min(max(16 - max((player.ping - 33)/8, 0), 0), 16)
            local color = 253

            if pingsize > 9 then
                color = 100
            elseif pingsize > 5 then
                color = 74
            elseif pingsize > 1 then
                color = 38
            end

            v.drawFill(x + 17, y-5, 2, pingsize, color|V_SNAPTOLEFT|V_SNAPTOTOP|flags)
        end

        if player.mo then
            icon(
                v, x, (y-5), FU, V_SNAPTOLEFT|V_SNAPTOTOP|flags, player
            )

            if ingame then
                if player.exiting then
                    v.draw(x-1, y-5, v.cachePatch("STYLESRANKING_FINISH"), V_SNAPTOLEFT|V_SNAPTOTOP|flags)
                end

                if player.gotflag then
                    if player.gotflag == 1 then
                        v.draw(x+8, y-5, v.cachePatch("STYLESRANKING_FLAGRED"), V_SNAPTOLEFT|V_SNAPTOTOP|flags)
                    else
                        v.draw(x+8, y-5, v.cachePatch("STYLESRANKING_FLAGBLUE"), V_SNAPTOLEFT|V_SNAPTOTOP|flags)
                    end
                end
            end

            if player.pflags & PF_TAGIT then
                v.draw(x+8, y-5, v.cachePatch("STYLESRANKING_IT"), V_SNAPTOLEFT|V_SNAPTOTOP|flags)
            end
        end

        if player.bot then
            v.draw(x-1, y+4, v.cachePatch("STYLESRANKING_AI"), V_SNAPTOLEFT|V_SNAPTOTOP|flags)
        end

        if IsPlayerAdmin(player) then
            v.draw(x, y+4, v.cachePatch("STYLESRANKING_ADMIN"), V_SNAPTOLEFT|V_SNAPTOTOP|flags)
        end

        local lenoff = (len - 20)/8 - 1
        local name = string.upper(player.name or "NULL")
        local namelen = string.len(name)

        local cut = lenoff-4

        if cut > 0 or lenoff > 6 then
            if namelen > lenoff then
                name = string.sub(name, 0, cut).."..."
            end

            write(v, disply, (x+20)*FU, (y+1)*FU, FU, name,
                V_SNAPTOLEFT|V_SNAPTOTOP|flags, nil, "left", 1)
        end
    end,

    time = function(v, x, y, len, write, icon, player)
        local minutes = G_TicsToMinutes(player.realtime, true)
        local seconds = G_TicsToSeconds(player.realtime)
        local centiseconds = G_TicsToCentiseconds(player.realtime)

        local _string = string.format("%d:%02d", minutes, seconds)
        local basestringlen = string.len(_string)

        if len > basestringlen + 3 then
            _string = string.format("%s.%02d", _string, centiseconds)
        end

        write(v, fonts.livesnum..'NUM', x*FU, y*FU, FU, _string, V_SNAPTOLEFT|V_SNAPTOTOP)
    end,
}