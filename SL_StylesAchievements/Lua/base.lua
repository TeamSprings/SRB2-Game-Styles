--
-- DATABASE
--

local module = {
    List = {},
    CategoryLUT = {},
    StringLUT = {},

    total = 0,
    totalmin = 0, -- minimum required for 100%
    totalUnlocked = 0,
}

local internal = {}

--
-- CONSTANTS
--

-- Error Types
local ERR_FAILURE   = 1
local ERR_WRONGTYPE = 2

local ERR_MESSAGES = {
    [ERR_FAILURE]   = "",
    [ERR_WRONGTYPE] = "",    
}

local REQ_ACHIVEMENT = 1

local REQ_PLAYERHIGH = 2
local REQ_PLAYEREQUL = 3
local REQ_PLAYERLOWR = 4
local REQ_PLAYERCUST = 5

local REQ_CUSTOM     = 6

local REQ_TYPES = {

    -- BASIC REQUIREMENT

    [REQ_ACHIVEMENT] = function(player, value, field)
        if module.StringLUT[value] then
            return module.StringLUT[value].unlocked
        end

        return false
    end,

    -- PLAYER

    [REQ_PLAYERHIGH] = function(player, value, field)
        if not (player and player.valid and player[field] ~= nil) then return false end
        return (player[field] > value)
    end,

    [REQ_PLAYEREQUL] = function(player, value, field)
        if not (player and player.valid and player[field] ~= nil) then return false end
        return (player[field] == value)
    end,

    [REQ_PLAYERLOWR] = function(player, value, field)
        if not (player and player.valid and player[field] ~= nil) then return false end
        return (player[field] < value)
    end,

    [REQ_PLAYERCUST] = function(player, value, field)
        if not (player and player.valid) then return false end
        return (value(player) or false)
    end,

    -- CUSTOM

    [REQ_CUSTOM] = function(player, value, field)
        return (value() or false)
    end
}

--
-- ACHIEVEMENT
--

local achievement_t = { 
    name =      "NULL",
    desc =      "NULL",

    stringid =  "NULL",
    category =  "GLOBAL",

    unlocked =  false,
    flags =     0,
    
    metadata =  nil,
    required =  nil,
}

function achievement_t:unlock()
    if self:checkconditions() then return end

    self.unlocked = true

    module.totalUnlocked = $ + 1
end

local achivement_meta = {
    __index = achievement_t,
}

--
-- METHODS
--

function internal:error(type, string)
    print("[Styles] "..ERR_MESSAGES[type]..string)
    
    return true
end

function internal:loadSaveFile(file)
    module.totalUnlocked = 0

    for key, entry in pairs(module.StringLUT) do
        if file[key] then
            entry.unlocked = true
            module.totalUnlocked = $ + 1
        else
            entry.unlocked = false
        end
    end
end

-- TODO: DO THIS ONE
function internal:validateConditions(name, requirements)
    for key, req in ipairs(requirements) do
        if type(req.type) ~= "number" then
            return internal:error(ERR_WRONGTYPE, 
            name.."->required..["..key.."]->type; expected: enumtype (number max "..#REQ_TYPES..", min 1); got: "..type(req.type))
        end

        if req.type < 1 or req.type > #REQ_TYPES then
            return internal:error(ERR_WRONGTYPE, 
            name.."->required..["..key.."]->type; expected: enum max "..#REQ_TYPES..", min 1; got: "..req.type)
        end
    end

    return false
end

function internal:validate(draft)

    --
    -- TYPE VALIDATION
    --

    if type(draft.stringid) ~= "string" then
        return internal:error(ERR_WRONGTYPE, "achievement->stringid; expected: string; got: "..type(draft.stringid))
    end

    if type(draft.category) ~= "string" then
        return internal:error(ERR_WRONGTYPE, draft.stringid.."->category; expected: string; got: "..type(draft.stringid))
    end

    if draft.name and type(draft.name) ~= "string" then
        return internal:error(ERR_WRONGTYPE, draft.stringid.."->name; expected: string; got: "..type(draft.name))
    end

    if draft.desc and type(draft.desc) ~= "string" then
        return internal:error(ERR_WRONGTYPE, draft.stringid.."->desc; expected: string; got: "..type(draft.desc))
    end       

    if draft.flags and type(draft.flags) ~= "number" then
        return internal:error(ERR_WRONGTYPE, draft.flags.."->category; expected: number; got: "..type(draft.flags))
    end

    if draft.required and type(draft.required) ~= "table" then
        return internal:error(ERR_WRONGTYPE, draft.required.."->category; expected: table<conditions>; got: "..type(draft.required))
    else
        local failure = internal:validateConditions(draft.stringid, draft.required)

        if failure then
            return true
        end
    end

    if draft.metadata and type(draft.metadata) ~= "table" then
        return internal:error(ERR_WRONGTYPE, draft.metadata.."->category; expected: table<any>; got: "..type(draft.metadata))
    end

    return false
end

function module:new(draft)
    if internal:validate(draft) then return end
    
    local init = setmetatable({}, achivement_meta)

    init.name =     draft.name or $
    init.desc =     draft.desc or $

    init.stringid = draft.stringid
    init.category = draft.category

    init.flags =    draft.flags
    init.required = draft.required

    init.metadata = draft.metadata

    -- Registering the link
    if draft.category and not self.CategoryLUT then
        self.CategoryLUT[draft.category] = {}
    end

    table.insert(self.List, init)
    table.insert(self.CategoryLUT[init.category], init)
    
    self.StringLUT[init.stringid] = init
    
    self.total = $ + 1
    self.totalmin = $ + 1

    return init
end

function module:search(id)
    if self.StringLUT[id] then
        return self.StringLUT[id]
    end

    return internal:error(ERR_FAILURE, "failed to get achievement with "..id)
end

function module:progress()
    return (self.totalUnlocked * FRACUNIT) / self.totalmin
end

return module