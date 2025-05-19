
--[[

    This might allow some light level changes to adjust some mod objects in certain levels

    TODO : (Will only do Vanilla and maybe MRCE, however anyone is free to add here anything)

--]]

local Options = tbsrequire('helpers/create_cvar')
local lvllib = tbsrequire 'libs/lib_emb_levelverification'

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
        x == nil and mobj.x or (x * FRACUNIT),
        y == nil and mobj.y or (y * FRACUNIT),
        z == nil and mobj.z or (z * FRACUNIT))
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
    [1] = { -- GFZ1

        {
            name = "Greenflower",
            hash = -1131512167,

            _func = function()
				if not multiplayer and StylesC_SPE() == 3 then
					local special_ring1 = get_mapthing(567)
					special_ring1.styles_nochecks = true

					delete_mapthing(233)
					delete_mapthing(234)
					delete_mapthing(235)
					delete_mapthing(236)
					delete_mapthing(237)
					delete_mapthing(238)
				end

                --print("SUCCESS!")
            end,

            -- Cutscenes
            _in = {
                {   tics = 0, func = function(p, mo)
						mo.styles_cutscenethink = {
							P_SpawnMobj(448 * FRACUNIT,
                            224 * FRACUNIT,
                            192 * FRACUNIT,
                            MT_EGGMOBILE)
						}

                        mo.styles_cutscenethink[1].state = S_INVISIBLE
						mo.styles_cutscenethink[1].sprite = states[S_EGGMOBILE_STND].sprite
						mo.styles_cutscenethink[1].frame = states[S_EGGMOBILE_STND].frame
                        mo.styles_cutscenethink[1].angle = ANGLE_225

						mo.styles_cutscenethink[1].flag = MF_SPECIAL|MF_SHOOTABLE|MF_FLOAT|MF_NOGRAVITY

                        player_lock(p)
					end
                },
                {   tics = 5 * TICRATE / 2, func = function(p, mo)
                        local tic = FRACUNIT - ((p.styles_cutscene_tics * FRACUNIT) / (5 * TICRATE / 2))
                        local x = ease.outsine(tic, 448 * FRACUNIT, 1024 * FRACUNIT)
                        local y = ease.outsine(tic, 224 * FRACUNIT, 736 * FRACUNIT)
                        local z = ease.outsine(tic, 192 * FRACUNIT, 224 * FRACUNIT)

						mo.styles_cutscenethink[1].state = S_INVISIBLE
						mo.styles_cutscenethink[1].sprite = states[S_EGGMOBILE_STND].sprite
						mo.styles_cutscenethink[1].frame = states[S_EGGMOBILE_STND].frame
                        mo.styles_cutscenethink[1].angle = ANGLE_45

                        P_MoveOrigin(mo.styles_cutscenethink[1], x, y, z)

                        player_lock(p)
                    end
                },
                {   tics = TICRATE, func = function(p, mo)
                        local tic = FRACUNIT - ((p.styles_cutscene_tics * FRACUNIT) / TICRATE)
                        local x = ease.outsine(tic, 1024 * FRACUNIT, 1824 * FRACUNIT)

						mo.styles_cutscenethink[1].state = S_INVISIBLE
						mo.styles_cutscenethink[1].sprite = states[S_EGGMOBILE_STND].sprite
						mo.styles_cutscenethink[1].frame = states[S_EGGMOBILE_STND].frame
                        mo.styles_cutscenethink[1].angle = 0

                        P_MoveOrigin(mo.styles_cutscenethink[1], x, 736 * FRACUNIT, 224 * FRACUNIT)
                    end
                },
                {   tics = 0, func = function(p, mo)
                        P_RemoveMobj(mo.styles_cutscenethink[1])
                        mo.styles_cutscenethink = nil
                    end
                },
            },
        },
    },

	[3] = { -- GFZ3
		{
			name = "Greenflower",
			hash = -838659965,

			_func = function()
				local center = P_SpawnMobj(4470*FRACUNIT, 3688*FRACUNIT, 3552*FRACUNIT, MT_STYLES_EGGTR)
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

    [8] = { -- DSZ1
		{
			name = "Deep Sea",
			hash = -888824694,

            -- Cutscenes
            _in = {
                {   tics = 0, func = function(p, mo)
                        P_SetOrigin(mo, mo.x, mo.y, mo.z + 256 * FRACUNIT)
                        P_InstaThrust(mo, mo.angle, 35 * FRACUNIT)

                        if p.mo then
                            p.mo.state = S_PLAY_PAIN
                        end
                    end
                },
                {  tics = 3 * TICRATE / 2,
                },
            },
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


						if __playedmaps[gamemap] then
							break
						else
							__playedmaps[gamemap] = true
						end

						displayplayer.styles_entercut = sheet._in
                        displayplayer.styles_exitcut = sheet._out
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

    displayplayer.styles_cutscene_tics = nil
    displayplayer.styles_cutscene_seq = nil
end)

---@param p player_t
addHook("PlayerThink", function(p)

	--
	-- ENTER LEVEL CUTSCENES
	--

	if p.styles_entercut then
        if not p.styles_cutscene_tics then
            if p.styles_cutscene_seq == nil then
                p.styles_cutscene_seq = 0
            end

            p.styles_cutscene_seq = $ + 1

            if p.styles_entercut[p.styles_cutscene_seq] then
                p.styles_cutscene_tics = p.styles_entercut[p.styles_cutscene_seq].tics

                if p.styles_entercut[p.styles_cutscene_seq].func and p.realmo and p.realmo.valid then
                    p.styles_entercut[p.styles_cutscene_seq].func(p, p.realmo)
                end
            else
                p.styles_entercut = nil
                p.styles_cutscene_tics = nil
                p.styles_cutscene_seq = nil
                p.styles_entercut_timer = 0
                p.styles_entercut_etimer = 3*TICRATE

                -- Well, it is kinda prize, though mostly cut cost of the cutscene time
                p.styles_cutscenetime_prize = leveltime + p.styles_entercut_etimer
            end


        else
            p.styles_cutscene_tics = $ - 1

            if p.styles_entercut[p.styles_cutscene_seq].func and p.realmo and p.realmo.valid then
                p.styles_entercut[p.styles_cutscene_seq].func(p, p.realmo)
            end
        end

        Styles_HideHud()
    end

    if p.styles_entercut_timer ~= nil and p.styles_entercut_timer < p.styles_entercut_etimer then
        p.styles_entercut_timer = $ + 1

        if p.styles_entercut_timer >= p.styles_entercut_etimer then
            p.styles_entercut_timer = nil
            p.styles_entercut_etimer = nil
        end
    end
end)