local function DEFAULT(player)
    player.styles_stats = {}
    local stats = player.styles_stats

    stats.laps = 0
    stats.rings = 0
    stats.score = 0
    stats.lives = 0
    stats.hits = 0
    stats.deaths = 0
    stats.hitsdeathratio = '0'
end

local function CALCRATIO(num1, num2)
    return FixedDiv((num1 or 1) * FU, (num2 or 1) * FU)
end

local function UPDATEHDRATIO(stats)
    stats.hitsdeathratio = string.format('%f', CALCRATIO(stats.hits, stats.deaths))
end

addHook("MapLoad", function()
    for player in players.iterate() do
        DEFAULT(player)
    end
end)

addHook("MobjDamage", function(plmo, inflictor, source)
    local player = plmo.player
    if not player then return end

    if inflictor and inflictor.player then
        local infplayer = inflictor.player
        infplayer.styles_stats.hits = $ + 1

        UPDATEHDRATIO(infplayer.styles_stats)
    elseif source and source.player then
        local srcplayer = source.player
        srcplayer.styles_stats.hits = $ + 1

        UPDATEHDRATIO(srcplayer.styles_stats)
    end
end, MT_PLAYER)

addHook("MobjDeath", function(plmo)
    if not plmo.player then return end

    local player = plmo.player

    player.styles_stats.deaths = $ + 1
    UPDATEHDRATIO(player.styles_stats)
end, MT_PLAYER)

addHook("PlayerSpawn", function(player)
    if not player.styles_stats then
        DEFAULT(player)
    end
end)

addHook("PlayerThink", function(player)
    if not player.styles_stats then
        player.styles_stats = {}
    end

    local stats = player.styles_stats
    stats.rings = player.rings
    stats.score = player.score
    stats.lives = player.lives
    stats.laps  = player.laps
end)