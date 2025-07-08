--[[
		Team Blue Spring's Series of Libaries.
		General Library - lib_cutscene.lua

		Description: Cutscene library for managing cutscenes
		Primary use in Game Styles (Classic, Dimps, Adventure)

        Probable use in Mystic Realms Community Edition

		How to get to functions? Use loadfile command

        WIKI: https://github.com/TeamSprings/SRB2-Game-Styles/wiki/Cutscene-library

Contributors: Skydusk
@Team Blue Spring 2025
]]


local module = {
    globalevents = {},
    LUT = {},
}

--#region cutscene helpers

---@class cutscenelib_t
---@field lockPlayer            fun(player: player_t)
---@field moveObj               fun(easing: string, mobj: mobj_t, tic: fixed_t, x: fixed_t, y: fixed_t, z: fixed_t, tx: fixed_t, ty: fixed_t, tz: fixed_t)
---@field moveCamera            fun(easing: string, camera: camera_t, tic: fixed_t, x: fixed_t, y: fixed_t, z: fixed_t, tx: fixed_t, ty: fixed_t, tz: fixed_t)
---@field spriteObj             fun(mobj: mobj_t, state: statenum_t?, frame: number?)
---@field stateObj              fun(mobj: mobj_t, state: statenum_t)
---@field attachMobj2Target     fun(mobj: mobj_t, target: mobj_t, offx: fixed_t, offy: fixed_t, offz: fixed_t)
local library = {}

---@param player player_t
function library.lockPlayer(player)
    if player.cmd then
        player.cmd.buttons = 0
        player.cmd.forwardmove = 0
        player.cmd.sidemove = 0

        player.powers[pw_nocontrol] = 2
    end
end

function library.moveCamera(easing, camera, tic, x, y, z, tx, ty, tz)
    local move  = ease[easing] or ease.linear
    local _x    = move(tic, x, tx)
    local _y    = move(tic, y, ty)
    local _z    = move(tic, z, tz)
    camera.momx = 0
    camera.momy = 0
    camera.momz = 0

    P_TeleportCameraMove(camera, _x, _y, _z)
end


function library.moveObj(easing, mobj, tic, x, y, z, tx, ty, tz)
    local move  = ease[easing] or ease.linear
    local _x    = move(tic, x, tx)
    local _y    = move(tic, y, ty)
    local _z    = move(tic, z, tz)

    P_MoveOrigin(mobj, _x, _y, _z)
end

function library.attachMobj2Target(mobj, target, offx, offy, offz)
    P_MoveOrigin(mobj,
                target.x + offx,
                target.y + offy,
                target.z + offz)
end

function library.spriteObj(mobj, state, frame)
    local _state = states[state or mobj.info.spawnstate]

    mobj.state  = S_INVISIBLE
    mobj.sprite = states[state].sprite

    if _state.frame & FF_ANIMATE then
        local timer = (leveltime / _state.var2) % (_state.var1 + 1)

        ---@diagnostic disable-next-line
        mobj.frame  = frame or _state.frame + timer
    else
        ---@diagnostic disable-next-line
        mobj.frame  = frame or _state.frame
    end
end

function library.stateObj(mobj, state)
    if state ~= mobj.state then
        mobj.state = state
    end
end

function library.getSector(num)
    return
end

--#endregion

--#region thread methods

---@class actorslib_t
---@field create        fun(self: self, x: fixed_t, y: fixed_t, z: fixed_t, mt: integer, keep: boolean): mobj_t
---@field assign        fun(self: self, mobj: mobj_t)
---@field clean         fun(self: self)
local actors_t = {}

---@class cutscene_t
---@field tics          number
---@field func          function
---@field flags         number?

---@class cutscenethread_t
---@field valid         boolean
---@field paused        boolean
---
---@field tics          number
---@field etics         number
---@field scene         number
---@field scenes        table<cutscene_t, function>
---@field actors        table<mobj_t?, player_t?>
---@field subthreads    table<cutscenethread_t>?
---@field hudthreads    table<cutscenethread_t>?
---
---@field pause         fun(self: self)
---@field resume        fun(self: self)
---@field interupt      fun(self: self)
---@field think         function
---@field active        function
---@field newSub        function
---@field newHud        function
---@field subThink      function
---@field hudThink      function
local thread_t = {} ---@class cutscenethread_t

--
-- ACTORS
--

---creates new actor!
---@param self      self
---@param x         fixed_t
---@param y         fixed_t
---@param z         fixed_t
---@param mt        number
---@param keep      boolean
---@return mobj_t
function actors_t:create(x, y, z, mt, keep)
    local mobj = P_SpawnMobj(x, y, z, mt)
    
    if not keep then
        ---@diagnostic disable-next-line
        mobj.teamsprings_tempactor = true
    end
    
    table.insert(self, mobj)
    return mobj
end

---assigns actor
---@param self  self
---@param mobj mobj_t
function actors_t:assign(mobj)
    table.insert(self, mobj)
end

---cleans actors
---@param self  self
function actors_t:clean()
    for _,v in ipairs(self) do
        if v and v.teamsprings_tempactor and v.valid then
            P_RemoveMobj(v)
        end
    end
end

--
-- CUTSCENE MANAGER
--


-- cutscene thinker
---@param self      self
---@param v         videolib
---@param player    player_t
---@param actors    actorslib_t
---@param gtics     number
---@param getics    number
function thread_t:hudThink(v, player, actors, gtics, getics)
    if not self.valid then return end

    if self.scenes then
        
        -- next scene
        if self.tics == 0 then
            self.scene = $ + 1

            if self.scenes[self.scene] then
                self.tics = self.scenes[self.scene].tics
                self.etics = self.tics
            
                if self.scenes[self.scene].func then
                    self.scenes[self.scene].func(
                        v,
                        player,
                        actors,
                        self.tics,
                        self.etics,
                        gtics,
                        getics
                    )
                end
            else
                self.valid  = false
                self.tics   = -1
            end
        elseif self.tics > 0 then
            if not self.paused then
                self.tics = $ - 1
            end

            if self.scenes[self.scene].func then
                self.scenes[self.scene].func(
                    v,
                    player,
                    actors,
                    self.tics,
                    self.etics,
                    gtics,
                    getics
                )
            end
        end
    else
        self.tics   = -1
        self.valid  = false
    end
end

-- cutscene thinker
---@param self      self
---@param player    player_t
---@param actors    actorslib_t
---@param library   cutscenelib_t
---@param gtics     number
---@param getics    number
function thread_t:subThink(player, actors, library, gtics, getics)
    if not self.valid then return end

    if self.scenes then
        
        -- next scene
        if self.tics == 0 then
            self.scene = $ + 1

            if self.scenes[self.scene] then
                self.tics = self.scenes[self.scene].tics
                self.etics = self.tics
            
                if self.scenes[self.scene].func then
                    self.scenes[self.scene].func(
                        player,
                        actors,
                        library,
                        self.tics,
                        self.etics,                        
                        gtics,
                        getics
                    )
                end
            else
                self.valid  = false
                self.tics   = -1
            end
        elseif self.tics > 0 then
            if not self.paused then
                self.tics = $ - 1
            end

            if self.scenes[self.scene].func then
                self.scenes[self.scene].func(
                    player,
                    actors,
                    library,
                    self.tics,
                    self.etics,
                    gtics,
                    getics
                )
            end
        end
    else
        self.tics   = -1
        self.valid  = false
    end
end

-- cutscene thinker
---@param self  self
---@param player player_t    
function thread_t:think(player)
    if not self.valid then return end

    if self.scenes then
        
        -- next scene
        if self.tics == 0 then
            if self.scene == 0 and self.scenes.setup then
                self.scenes.setup(
                    player,
                    self.actors,
                    library
                )
            end
            
            self.scene = $ + 1

            if self.scenes[self.scene] then
                self.tics = self.scenes[self.scene].tics
                self.etics = self.tics         
            
                if self.scenes[self.scene].func then
                    self.scenes[self.scene].func(
                        player,
                        self.actors,
                        library,
                        self.tics,
                        self.etics
                    )
                end
            else
                if self.scenes.finish then
                    self.scenes.finish(
                        player,
                        self.actors,
                        library
                    )
                end

                self.valid  = false
                self.tics   = -1
                self.actors:clean()
            end
        elseif self.tics > 0 then
            if not self.paused then
                self.tics = $ - 1
            end

            if self.scenes[self.scene].func then
                self.scenes[self.scene].func(
                    player,
                    self.actors,
                    library,
                    self.tics,
                    self.etics
                )
            end

            if self.subthreads then
                for _,v in ipairs(self.subthreads) do
                    v:subThink(
                        player,
                        self.actors,
                        library,
                        self.tics,
                        self.etics
                    )
                end
            end
        end
    else
        self.tics   = -1
        self.valid  = false
        self.actors:clean()
    end
end

---@param self  self
function thread_t:pause()
    self.paused = true
end

---@param self  self
function thread_t:resume()
    self.paused = false
end

---@param self  self
function thread_t:interupt()
    self.valid  = false
    self.tics   = -1
    
    if self.actors then
        self.actors:clean()
    end
end

-- cutscene check if active
---@param self  self
---@return boolean ifactive
function thread_t:active()
    return (self.tics > -1)
end

local actors_meta = {__index = actors_t}
local thread_meta = {__index = thread_t}

-- cutscene subthread
---@param self  self
---@param subscenes table<cutscene_t> 
function thread_t:newSub(subscenes)
    table.insert(
        self.subthreads,
        setmetatable({  
            valid = true;
            paused = false;

            tics    = 0;
            etics   = 0;            
            scene   = 0;
            scenes  = subscenes;
        }, thread_meta)
    )
end

-- cutscene subthread
---@param self  self
---@param subscenes table<cutscene_t> 
function thread_t:newHud(subscenes)
    table.insert(
        self.hudthreads,
        setmetatable({  
            valid = true;
            paused = false;

            tics    = 0;
            etics   = 0;         
            scene   = 0;
            scenes  = subscenes;
        }, thread_meta)
    )
end

--#endregion

--#region module methods

---This creates a cutscene thread, on its own it doesn't run. You will need to use thread:think(). This version of function is not handled automatically. 
---@param self  self
---@param scenes table<cutscene_t>
---@return cutscenethread_t
function module:newThread(scenes)
    local thread = {
        actors  = setmetatable({}, actors_meta);

        valid = true;
        paused = false;

        tics    = 0;
        etics   = 0;        
        scene   = 0;
        scenes  = scenes;

        subthreads = {};
    }

    return setmetatable(thread, thread_meta) ---@type cutscenethread_t
end

---This creates a cutscene thread and is handled internally unlike module:newThread. Pretty much global.
---@param self  self
---@param scenes table<cutscene_t>
---@return cutscenethread_t
function module:newEvent(scenes)
    local _thread = self:newThread(scenes)
    
    table.insert(
        self.globalevents,
        _thread
    )

    return _thread ---@type cutscenethread_t
end

---This is player-centric-POV cutscene activator, not exactly global event or level event you would want in multiplayer. Use module:newEvent instead.
---@param self  self
---@param player player_t
---@param scenes table<cutscene_t>
function module:newCutscene(player, scenes)
    if player.teamsprings_scenethread and player.teamsprings_scenethread.valid then
        return
    end

    ---@diagnostic disable-next-line
    player.teamsprings_scenethread = self:newThread(scenes)
end

--This method is optional, but useful for linedef execution triggers, it ver zmuch just stores scene into LUT assigns string key allowing you to look it up.
---@param scenes table<cutscene_t>
---@param name string
function module:registerCutscene(scenes, name)
    if not self.LUT[name] then
        self.LUT[name] = scenes
    end
end

--This method is optional, but useful for linedef execution triggers, it ver zmuch just stores scene into LUT assigns string key allowing you to look it up.
---@param name string
function module:getCutscene(name)
    return self.LUT[name]
end

---clears all activated cutscenes
---@param self  self
function module:clear()
    for player in players.iterate() do
        if player.teamsprings_scenethread then
            local thread = player.teamsprings_scenethread ---@type cutscenethread_t
            
            thread:interupt()
            player.teamsprings_scenethread = nil
        end
    end

    if module.globalevents then
        for _,v in ipairs(module.globalevents) do
            v:interupt()
        end

        module.globalevents = nil
    end
end

--#endregion

--#region hooks

--Linedef executor for activating player POV cutscene - event
--String argument 2 (internal 1) - ID
addHook("LinedefExecute", function(line, mobj, sector)
    if not mobj.player then return end    
    
    if line.stringargs[1] then
        local cutscene = module:getCutscene(line.stringargs[1])
    
        if cutscene then
            module:newCutscene(mobj.player, cutscene)
        end    
    end
end, "TSCUTPL")

--Linedef executor for activating non-player POV cutscene - event
--String argument 2 (internal 1) - ID
addHook("LinedefExecute", function(line, mobj, sector)
    if line.stringargs[1] then
        local cutscene = module:getCutscene(line.stringargs[1])
    
        if cutscene then
            module:newEvent(cutscene)
        end    
    end
end, "TSEVENT")

addHook("HUD", function(player)
    if player.teamsprings_scenethread and player.teamsprings_scenethread.valid then
        local thread = player.teamsprings_scenethread ---@type cutscenethread_t
        
        if thread.hudthreads then
            for _, v in ipairs(thread.hudthreads) do
                thread:hudThink(v, player, thread.actors, thread.tics, thread.etics)
            end
        end
    end
end, "game")

addHook("NetVars", function(net)
    module.globalevents = net($)
end)

addHook("ThinkFrame", function()
    if module.globalevents then
        for _,v in ipairs(module.globalevents) do
            v:think()
        end
    end
end)

addHook("MapChange", function()
    module:clear()
end)

addHook("PlayerThink", function(player)
    if player.teamsprings_scenethread then
        local thread = player.teamsprings_scenethread
        
        if not thread.valid then
            player.teamsprings_scenethread = nil
            return
        end

        player.teamsprings_scenethread:think(player)
    end
end)

--#endregion

return module
