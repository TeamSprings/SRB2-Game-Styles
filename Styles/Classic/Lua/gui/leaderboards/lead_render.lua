local Rankings = tbsrequire 'gui/leaderboards/lead_manager'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local hudcfg = 	tbsrequire('gui/hud_conf')
local fonts = 	tbsrequire('gui/hud_fonts')
local write = drawlib.draw

local function WRITETYPE(v, len, x, y, scale, value, flags, color, alligment, spacing, padding, padsymbol)
    local typeval = type(value)

    if typeval == "number" then
        local strnum = ""..value
        local lennum = string.len(strnum)

        if (len / 8) + 1 > lennum then
            write(v, fonts.livesnum..'NUM', x, y, scale, value, flags, color, alligment, spacing, padding, padsymbol)
        else
            if value > 999999 then
                strnum = string.sub(strnum, 1, lennum-6).."M"
            elseif value > 999 then
                strnum = string.sub(strnum, 1, lennum-3).."K"
            end

            write(v, fonts.menuwhite..'NAM', x, y, scale, strnum, flags, color, alligment, spacing, padding, padsymbol)
        end
    elseif typeval == "string" then
        local lenoff = (len - 20)/8 - 1
        local va = string.upper(typeval or "NULL")
        local valen = string.len(va)

        local cut = lenoff-4

        if cut > 0 or lenoff > 6 then
            if valen > lenoff then
                va = string.sub(va, 0, cut).."..."
            end

            write(v, fonts.menuwhite..'NAM', x, y, scale, va, flags, color, alligment, spacing, padding, padsymbol)
        end
    end
end

local function sortPlayerByTeam(a, b)
    return a.ctfteam > b.ctfteam
end

local comp = {
    ["score"] = function(a, b)
        return (a.score > b.score) or true
    end,
    ["laps"] = function(a, b)
        return (a.laps > b.laps) or true
    end,
    ["time"] = function(a, b)
        return ((a.realtime or 0) > (b.realtime or 0)) or true
    end,
}

---@param v videolib
return function (v, xoff, yoff, ingame, gflags)
    local type = Rankings:current()

    if not type then return end

    local basey = 35

    local height = v.height()
    local scale = v.dupx()

    local heightsplit = height/scale
    local size = heightsplit - (basey + 3) - 27
    size = size - (size % 16)

    local playerspercollumn = size/16
    local teambased = G_GametypeHasTeams()

    local plnum = 0

    local act_players = {}

    local blueteamnum = 0
    local redteamnum = 0

    for player in players.iterate() do
        if not teambased or (teambased and player.ctfteam) then
            table.insert(act_players, player)
        end

        if teambased then
            if player.ctfteam == 1 then
                redteamnum = $ + 1
            elseif player.ctfteam == 2 then
                blueteamnum = $ + 1
            end
        end

        plnum = $ + 1
    end

    local ranking_order = {}

    pcall(table.sort, act_players, comp[Rankings._main])

    for order, player in ipairs(act_players) do
        ranking_order[#player] = order
    end

    pcall(table.sort, act_players, sortPlayerByTeam)

    local collumns = 0
    if teambased then
        collumns = max(min((blueteamnum / playerspercollumn + redteamnum / playerspercollumn) + 2, 4), 2)
    else
        collumns = max(min(plnum / playerspercollumn + 1, 4), 1)
    end

    local table = type[collumns]

    if not table then return end

    local afterfirst = false
    local collumnx = Rankings.xpos + xoff

    v.drawFill(
        collumnx - Rankings.reserve,
        basey + 4 + yoff,
        Rankings.width + Rankings.reserve,
        2,
        73|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)

    v.drawFill(
        collumnx - Rankings.reserve + 1,
        basey + 7 + yoff,
        Rankings.width + Rankings.reserve + 1,
        1,
        31|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)

    for i = 1, playerspercollumn do
        if not (i % 2) then continue end

        if teambased then
            local piece = Rankings.width / collumns
            local bluelen = piece * min(max((blueteamnum or 1) / playerspercollumn + 1, 1), 2) - 8
            local redlen = Rankings.width - bluelen

            v.drawFill(
                collumnx - Rankings.reserve,
                basey + 6 + (i-1) * 16 + yoff,
                bluelen + Rankings.reserve,
                16,
                157|V_40TRANS|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)

            v.drawFill(
                collumnx - Rankings.reserve + bluelen,
                basey + 6 + (i-1) * 16 + yoff,
                redlen + Rankings.reserve,
                16,
                43|V_40TRANS|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)

        else
            v.drawFill(
                collumnx - Rankings.reserve,
                basey + 6 + (i-1) * 16 + yoff,
                Rankings.width + Rankings.reserve,
                16,
                157|V_40TRANS|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)
        end
    end

    basey = $-5

    -- headers

    for col = 0, collumns - 1 do
        local x = collumnx + col * (Rankings.width / collumns)

        for name, conf in pairs(table) do
            local start = x + conf.start / collumns

            if afterfirst then
                v.drawFill(
                start - 9,
                basey - 4 + yoff,
                1,
                13,
                73|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)

                v.drawFill(
                start - 7,
                basey - 4 + yoff,
                1,
                13,
                31|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)
            end

            write(v, fonts.menuyellow..'NAM', (start - 5)*FU, (basey + yoff)*FU, FU, name,
                    V_SNAPTOLEFT|V_SNAPTOTOP|gflags, nil, "left", 1)

            if afterfirst then
                v.drawFill(
                start - 9,
                basey + 13 + yoff,
                1,
                size,
                V_SNAPTOLEFT|V_SNAPTOTOP|gflags)

                v.drawFill(
                start - 7,
                basey + 13 + yoff,
                1,
                size,
                31|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)
            end

            afterfirst = true
        end
    end

    local plrs = 1
    local col = 0
    local plx = collumnx + col * (Rankings.width / collumns)
    local currentteam = 2

    for _, player in ipairs(act_players) do
        if teambased and currentteam ~= player.ctfteam then
            currentteam = 1

            plrs = 1
            col = $ + 1

            plx = collumnx + col * (Rankings.width / collumns)
        elseif plrs > playerspercollumn then
            plrs = 1
            col = $ + 1

            plx = collumnx + col * (Rankings.width / collumns)

            if col > 4 then
                break
            end
        end

        local flags = 0

        if gflags then
            flags = gflags
        elseif player.playerstate == PST_DEAD or player.spectator then
            flags = V_40TRANS
        end

        if not player.quittime or (player.quittime and (leveltime % 8)/4) then
            for _, conf in pairs(table) do
                local start = conf.start / collumns

                if conf.render then
                    conf.render(v,
                        (plx + start - 5),
                        basey+16*plrs + yoff,
                        conf.len / collumns,
                        write,
                        hudcfg.livesrenderfunc,
                        player,
                        ranking_order[#player],
                        flags,
                        ingame
                    )
                elseif player.styles_stats then
                    WRITETYPE(v, conf.len / collumns, (plx + start - 5)*FU, (basey+1+16*plrs + yoff)*FU, FU, player.styles_stats[conf.value],
                        V_SNAPTOLEFT|V_SNAPTOTOP|flags, nil, "left", 1)
                end
            end
        end

        plrs = $ + 1
    end

    basey = $ + size + 14

    v.drawFill(
        Rankings.xpos - Rankings.reserve,
        basey - 3 + yoff,
        Rankings.width + Rankings.reserve,
        2,
        73|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)

    v.drawFill(
        Rankings.xpos - Rankings.reserve + 1,
        basey + yoff,
        Rankings.width + Rankings.reserve + 1,
        1,
        31|V_SNAPTOLEFT|V_SNAPTOTOP|gflags)
end