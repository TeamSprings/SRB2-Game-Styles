local module = {}

-- TODO: CUSTOM LEADERBOARDS

tbsrequire("gui/leaderboards/lead_stats") -- stats collection

local BOARD_COOP    = 0
local BOARD_MATCH   = 1
local BOARD_COMP    = 2
local BOARD_RACE    = 3
local BOARD_SPEC    = 4

module.types = {
    [BOARD_COOP] = tbsrequire("gui/leaderboards/types/lead_coop"),
    [BOARD_MATCH] = tbsrequire("gui/leaderboards/types/lead_match"),
    [BOARD_COMP] = tbsrequire("gui/leaderboards/types/lead_comp"),
    [BOARD_RACE] = tbsrequire("gui/leaderboards/types/lead_race"),
    [BOARD_SPEC] = tbsrequire("gui/leaderboards/types/lead_coop"),
}

module.setups = {
    [BOARD_COOP] = {},
    [BOARD_MATCH] = {},
    [BOARD_COMP] = {},
    [BOARD_RACE] = {},
    [BOARD_SPEC] = {},
}

function module:charbudget(v, mono, scale, width_boundary)
    local _width = self.basewidth
    local _scale = v.dupx()

    self.reserve = 0
    self.xpos = width_boundary + self.reserve
    self.width = _width / _scale - width_boundary * 2 - self.reserve
    self.budget = FixedMul(self.width * FU, scale) / FU
    self.mono = mono
end

function module:res(data, size)
    local budget = self.budget or 0
    if budget == 0 then return end

    local pos = 0

    local right = {}
    local middle = {}

    local result = {}

    local gsplit = budget / (data and #data or 1)

    for _, var in ipairs(data) do
        if budget < 5 then break end

        if var.max_size and size > var.max_size then continue end

        if var.type == "left" then
            local len = min(gsplit, max(var.min or self.mono, budget))
            result[var.name] = {start = pos, len = len, value = var.value, render = var.render, type = var.vartype or "global"}

            budget = $ - len
            pos = $ + len
        elseif var.type == "right" then
            local len = min(gsplit, max(var.min or self.mono, budget))
            table.insert(right, {name = var.name, len = len, value = var.value, render = var.render, type = var.vartype or "global"})

            budget = $ - len
        else
            table.insert(middle, var)
        end
    end

    if middle then
        local split = budget / (middle and #middle or 1)

        for i = 1, #middle do
            if budget < 10 then break end

            local var = middle[i]
            local piecesplit = split -- min(max(split, var.min), budget)
            --if i == #middle then piecesplit = budget end

            result[var.name] = {start = pos, len = piecesplit, value = var.value, render = var.render, type = var.vartype or "global"}
            budget = $ - piecesplit
            pos = $ + piecesplit
        end
    end

    if right then
        for i = 1, #right do
            if budget < 10 then break end

            local var = right[i]

            result[var.name] = {start = pos, len = var.lenght, value = var.value, render = var.render, type = var.vartype}

            pos = $ + var.lenght
        end
    end

    return result
end

function module:setup(v)
    self:charbudget(v, 8, FU, 8)

    for key,data in pairs(self.types) do
        self.setups[key] = {
            self:res(data, 1),
            self:res(data, 2),
            self:res(data, 3),
            self:res(data, 4),

            _main = data.main or "score"
        }
    end
end

function module:current()
    local specialstage = G_IsSpecialStage(gamemap)

    local rules = gametyperules

    if rules & GTR_CAMPAIGN or rules & GTR_SPECIALSTAGES then
        if specialstage then
            return module.setups[BOARD_SPEC]
        else
            return module.setups[BOARD_COOP]
        end
    elseif rules & GTR_RINGSLINGER then
        return module.setups[BOARD_MATCH]
    elseif rules & GTR_RACE then
        if gametype == GT_COMPETITION then
            return module.setups[BOARD_COMP]
        else
            return module.setups[BOARD_RACE]
        end
    else
        return module.setups[BOARD_COOP]
    end
end

customhud.SetupItem("classic_resolutionrefresh", "classichud", function(v)
    local base = v.width()

    if not module.basewidth or base ~= module.basewidth then
        module.basewidth = base
        module:setup(v)
    end
end, "system")

return module