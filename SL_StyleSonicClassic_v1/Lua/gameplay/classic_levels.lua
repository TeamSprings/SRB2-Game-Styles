
--[[

    This might allow some light level changes to adjust some mod objects in certain levels

--]]

local Options = tbsrequire('helpers/create_cvar')
local lvllib = tbsrequire 'libs/lib_emb_levelverification'
local cutlib = tbsrequire 'libs/lib_emb_cutscene'

local level_opt = Options:get("disablelevel")
local cutscene_opt = Options:get("disablecutscenes")

local function LEVEL(mod, zone, act)
    return tbsrequire("gameplay/levels/"..mod.."/"..zone.."/"..act)
end

local function VANILLA(zone, act)
    return LEVEL('vanilla', zone, act)
end

local __data = {
    [1] = {
        VANILLA('greenflower', 'act1'),
    },

	[2] = {
        VANILLA('greenflower', 'act2'),
	},

	[3] = {
        VANILLA('greenflower', 'act3'),
	},

	[6] = {
        VANILLA('technohill', 'act3'),
	},

	[9] = {
        VANILLA('deepsea', 'act3'),
	},

	[12] = {
        VANILLA('castleeggman', 'act3'),
	},

	[15] = {
        VANILLA('aridcanyon', 'act3'),
	},

	[22] = {
        VANILLA('eggrock', 'act1'),
	},
}

local __playedmaps = {}

addHook("MapLoad", function()
	if __data[gamemap] and level_opt and not level_opt() then
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
                    and cutscene_opt and not cutscene_opt()
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
        if leveltime > TICRATE and p.teamsprings_scenethread and p.teamsprings_scenethread.valid then
            p.styles_cutscenetime_prize = leveltime
            
            if p.cmd and p.cmd.buttons & BT_SPIN then
                local thrd = p.teamsprings_scenethread ---@type cutscenethread_t
                thrd:interupt()
            end
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
    and p.styles_tallytimer ~= nil
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