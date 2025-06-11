
--[[

    This might allow some light level changes to adjust some mod objects in certain levels

    TODO : Fix interactions between level editing and special entrances

--]]

local Options = tbsrequire('helpers/create_cvar') ---@type CvarModule
local lvllib = tbsrequire 'libs/lib_emb_levelverification'
local cutlib = tbsrequire 'libs/lib_emb_cutscene'

local TRAPF_ENDLVL 	= 1
local TRAPF_LIFT 	= 2
local TRAPF_FLIGHT 	= 4
local TRAPF_DROP 	= 8

local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8

local function move_mapthing(id, x, y, z)
    if mapthings[id] and mapthings[id].mobj and mapthings[id].mobj.valid then
        local mobj = mapthings[id].mobj
        P_SetOrigin(mobj,
        x == nil and mobj.x or (x * FU),
        y == nil and mobj.y or (y * FU),
        z == nil and mobj.z or (z * FU))
    end
end

local function delete_mapthing(id)
    if mapthings[id] and mapthings[id].mobj and mapthings[id].mobj.valid then
        P_RemoveMobj(mapthings[id].mobj)
    end
end

local function get_mapthing(id)
    if mapthings[id] and mapthings[id].mobj and mapthings[id].mobj.valid then
        return mapthings[id].mobj
    end
end

local function player_lock(p)
    if p.cmd then
        p.cmd.buttons = 0
        p.cmd.forwardmove = 0
        p.cmd.sidemove = 0

        p.powers[pw_nocontrol] = 2
    end
end

local __data = {
    [1] = {
        tbsrequire("gameplay/levels/gfz1"),
    },

	[3] = { -- GFZ3
		{
			name = "Greenflower",
			hash = -838659965,

			_func = function()
				local center = P_SpawnMobj(4470*FU, 3688*FU, 3552*FU, MT_STYLES_EGGTR)
				center.styles_flags = TRAPF_ENDLVL|TRAPF_LIFT
				center.styles_tagged = 382
				center.styles_list = {mapthings[112].mobj}
                center.styles_flickylist = {MT_FLICKY_01, MT_FLICKY_02}

				sectors[11].special = 0
				sectors[30].special = 0
				sectors[23].special = 0
				sectors[26].special = 0
				sectors[11].tag = 0
				sectors[30].tag = 0
				sectors[23].tag = 0
				sectors[26].tag = 0
			end,
		}
	},

	[22] = { -- EGZ1
		{
			name = "Egg Rock",
			hash = -1710163032,

			_func = function()
				if not multiplayer and StylesC_SPE() == 3 then
					local special_ring1 = get_mapthing(29)
					special_ring1.styles_nochecks = true
					special_ring1.flags2 = $ | MF2_OBJECTFLIP
				end

			end,
		}
	},

}

local __playedmaps = {}

addHook("MapLoad", function()
	if __data[gamemap] then
        local _get = lvllib:assest()
        local curr = __data[gamemap]


        -- sheet checks
        for _,sheet in ipairs(curr) do
            local skip

            if sheet then
                -- now we are checking the stuff
                for k, val in pairs(sheet) do
                    if string.sub(k, 1, 1) == "_" then continue end

                    if _get[k] ~= val then
                        skip = true
                        break
                    end
                end

                if not skip then
                    -- oh we found one!
                    if sheet._func then
                        sheet._func()
                    end



                    if not (multiplayer or modeattacking or leveltime)
                    and (sheet._in or sheet._out) then

                        if type(sheet._out) == "function" then
                            displayplayer.styles_exitcut = sheet._out(displayplayer)
                        elseif type(sheet._out) == "table" then
                            displayplayer.styles_exitcut = sheet._out
                        end

						if __playedmaps[gamemap] then
							break
						else
							__playedmaps[gamemap] = true
						end

                        if type(sheet._in) == "function" then
                            displayplayer.styles_entercut = sheet._in(displayplayer)
                        elseif type(sheet._in) == "table" then
                            displayplayer.styles_entercut = sheet._in
                        end
                    end

                    break
                end
            end
        end


    end
end)

addHook("GameQuit", function()
	__playedmaps = {}
end)

addHook("MapChange", function()
    displayplayer.styles_cutscenetime_prize = nil

    displayplayer.styles_entercut = nil
    displayplayer.styles_exitcut = nil

    displayplayer.styles_entercut_timer = nil
    displayplayer.styles_entercut_etimer = nil
end)

---@param p player_t
addHook("PlayerThink", function(p)

	--
	-- ENTER LEVEL CUTSCENES
	--

	if p.styles_entercut ~= nil then
        if leveltime > TICRATE and p.cmd and p.cmd.buttons & BT_SPIN
        and p.teamsprings_scenethread and p.teamsprings_scenethread.valid then
            local thrd = p.teamsprings_scenethread ---@type cutscenethread_t
            thrd:interupt()
        end

        if p.teamsprings_scenethread and not p.teamsprings_scenethread.valid then
			if not p.styles_entercut.notitlecard then
				p.styles_entercut_timer = 0
				p.styles_entercut_etimer = 3*TICRATE
			else
				p.styles_entercut_timer = nil
				p.styles_entercut_etimer = nil
			end

            p.styles_entercut = nil
            p.teamsprings_scenethread = nil
			p.styles_cutscenetime_prize = 3*TICRATE + leveltime
        end

        cutlib:newCutscene(p, p.styles_entercut)
    end

    if p.styles_entercut_timer ~= nil and p.styles_entercut_timer < p.styles_entercut_etimer then
        p.styles_entercut_timer = $ + 1

        if p.styles_entercut_timer >= p.styles_entercut_etimer then
            p.styles_entercut_timer = nil
            p.styles_entercut_etimer = nil
        end
    end

    if p.styles_tallyendtime
    and p.styles_exitcut ~= nil and p.styles_tallytimer > p.styles_tallyendtime-1 then
        if p.cmd and p.cmd.buttons & BT_SPIN
        and p.teamsprings_scenethread and p.teamsprings_scenethread.valid then
            local thrd = p.teamsprings_scenethread ---@type cutscenethread_t
            thrd:interupt()
        end

        if p.teamsprings_scenethread and not p.teamsprings_scenethread.valid then
            p.styles_exitcut = nil
            p.teamsprings_scenethread = nil
        end

        cutlib:newCutscene(p, p.styles_exitcut)
    end
end)