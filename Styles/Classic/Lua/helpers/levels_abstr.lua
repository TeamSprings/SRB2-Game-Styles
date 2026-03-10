
---@class level_abstr
---@field movething     function
---@field deletething   function
---@field getthing      function

local module = {
    ---moves mapthing in the map
    ---@param id number
    ---@param x number
    ---@param y number
    ---@param z number
    movething = function(id, x, y, z)
        if mapthings[id] and mapthings[id].mobj and mapthings[id].mobj.valid then
            local mobj = mapthings[id].mobj
            P_SetOrigin(mobj,
            x == nil and mobj.x or (x * FU),
            y == nil and mobj.y or (y * FU),
            z == nil and mobj.z or (z * FU))
        end
    end,

    ---deletes a mapthing from map
    ---@param id number
    deletething = function(id)
        if mapthings[id] and mapthings[id].mobj and mapthings[id].mobj.valid then
            P_RemoveMobj(mapthings[id].mobj)
        end
    end,

    ---gets a mapthing in the map
    ---@param id number    
    getthing = function(id)
        if mapthings[id] and mapthings[id].mobj and mapthings[id].mobj.valid then
            return mapthings[id].mobj
        end
    end
} ---@type level_abstr

return module