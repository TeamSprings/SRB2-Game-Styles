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
local ERR_WRONGSIZE = 3

local ERR_MESSAGES = {
    [ERR_FAILURE]   = "Failure to register %s",
    [ERR_WRONGTYPE] = "Wrong datatype in %s; expected: %s; got: %s",
    [ERR_WRONGSIZE] = "Wrong range in %s; expected: enumtype (number max %d, min %d); got: %s",
}

--
-- REQUIREMENTS
--

local REQ_ACHIVEMENT = 1

local REQ_PLAYERHIGH = 2
local REQ_PLAYEREQUL = 3
local REQ_PLAYERLOWR = 4
local REQ_PLAYERCUST = 5

local REQ_CUSTOM     = 6

local REQ_STATS      = 7

local REQ_TYPES = {

    -- BASIC REQUIREMENT

    [REQ_ACHIVEMENT] = function(player, value, field)
        if module.StringLUT[field] then
            return module.StringLUT[field].unlocked
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
        return (field(player) or false)
    end,

    -- CUSTOM

    [REQ_CUSTOM] = function(player, value, field)
        return (field() or false)
    end,

    -- STATS

    [REQ_STATS] = function(player, value, field)
        return (field() or false)
    end
}

--
-- AUTOTRIGGERS
--

local TRI_ACHIEVEMENT = 1
local TRI_MAPCHANGE   = 2

local TRI_MAX = TRI_ACHIEVEMENT | TRI_MAPCHANGE

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

function internal:error(type, ...)
    print(string.format("[Styles] "..ERR_MESSAGES[type], unpack({...})))
    
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

function internal:validateConditions(name, requirements)
    for key, req in ipairs(requirements) do
        if type(req.type) ~= "number" then
            return internal:error(ERR_WRONGTYPE, name.."->required..["..key.."]->type", "number", type(req.type))
        end

        if req.type < 1 or req.type > #REQ_TYPES then
            return internal:error(ERR_WRONGSIZE, name.."->required..["..key.."]->type", #REQ_TYPES, 1, req.type)
        end

        if type(req.field) == "nil" then
            return internal:error(ERR_WRONGTYPE, name.."->required..["..key.."]->field", "any", "nil")
        end

        if type(req.trigger) ~= "number" then
            return internal:error(ERR_WRONGTYPE, name.."->required..["..key.."]->trigger", "number", type(req.triggr))
        end

        if req.trigger < 0 or req.trigger > TRI_MAX then
            return internal:error(ERR_WRONGSIZE, name.."->required..["..key.."]->trigger", TRI_MAX, 0, req.trigger)
        end
    end

    return false
end

function internal:validate(draft)

    --
    -- TYPE VALIDATION
    --

    if type(draft.stringid) ~= "string" then
        return internal:error(ERR_WRONGTYPE, "achievement->stringid", "string", type(draft.stringid))
    end

    if type(draft.category) ~= "string" then
        return internal:error(ERR_WRONGTYPE, "achievement->category", "string", type(draft.category))
    end

    if draft.name and type(draft.name) ~= "string" then
        return internal:error(ERR_WRONGTYPE, "achievement->name", "string", type(draft.name))
    end

    if draft.desc and type(draft.desc) ~= "string" then
        return internal:error(ERR_WRONGTYPE, "achievement->desc", "string", type(draft.desc))
    end  

    if draft.flags and type(draft.flags) ~= "number" then
        return internal:error(ERR_WRONGTYPE, "achievement->flags", "number", type(draft.flags))
    end

    if draft.required and type(draft.required) ~= "table" then
        return internal:error(ERR_WRONGTYPE, "achievement->required", "table<conditions>", type(draft.required))
    else
        local failure = internal:validateConditions(draft.stringid, draft.required)

        if failure then
            return true
        end
    end

    if draft.metadata and type(draft.metadata) ~= "table" then
        return internal:error(ERR_WRONGTYPE, "achievement->metadata", "table<any>", type(draft.metadata))
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
end

function module:progress()
    return (self.totalUnlocked * FRACUNIT) / self.totalmin
end

return module