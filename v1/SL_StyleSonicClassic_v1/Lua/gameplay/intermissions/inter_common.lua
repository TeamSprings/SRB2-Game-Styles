local Options = tbsrequire('helpers/create_cvar')

local module = {
    counters = {},
    layoutNormal = Options:new("tallylayout", {
        [0] = {1, "default",    "Default"},
        [1] = {0, "s1",         "Sonic 1"},
    })
}

function module:addCounter(...)
    local counters = {...}

    for _,v in ipairs(counters) do
        self.counters[v] = true
    end
end

function module:cleanUp(p)
    for k,_ in ipairs(self.counters) do
        p[k] = 0
    end
end

addHook("MapLoad", function()
    for player in players.iterate do
        module:cleanUp(player)
    end
end)

function module.rows(p, delay)
    local timed = p.styles_tallytimer + delay
	local timerwentpast = 24*min(max(p.styles_tallytimer - (p.styles_tallyendtime + TICRATE/8), 0), 80)

    return  min((timed+89)*24, 0) - timerwentpast,
            80-min((timed+64)*24, 0) - timerwentpast,
            80-min((timed+69)*24, 0) - timerwentpast,
            80-min((timed+74)*24, 0) - timerwentpast,
            80-min((timed+79)*24, 0) - timerwentpast,
            80-min((timed+84)*24, 0) - timerwentpast
end


return module