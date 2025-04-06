--[[

		Sonic Adventure Style's Menu Stuff

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'

local drawf = drawlib.draw
local fontlen = drawlib.lenght
local drawBG = tbsrequire 'helpers/draw_background'
local HOOK = customhud.SetupItem

local menu_toggle = false

--
--	COM
--

COM_AddCommand("dc_menu", function(p)
	if menu_toggle == nil then
		menu_toggle = true
	else
		menu_toggle = not (menu_toggle)
	end
end, COM_LOCAL)

--
--	MENU ITEMS
--

local menu_items = {
	{minv = 0, maxv = 1, 		name = "RINGBOX RANDOMIZER", cv = CV_FindVar("dc_ringboxrandomizer")},
	{minv = 0, maxv = 3, 		name = "SHIELD PALETTE", cv = CV_FindVar("dc_replaceshields")},
	{minv = 0, maxv = 2, 		name = "STAGE END TALLY", cv = CV_FindVar("dc_endtally")},
	"ITEM BOXES",
	{minv = 0, maxv = 1, 		name = "ITEM BOXES", cv = CV_FindVar("dc_itembox")},
	{minv = 0, maxv = 1, 		name = "ITEM BOX STYLE", cv = CV_FindVar("dc_itemboxstyle")},
	"OTHER ASSETS",
	{minv = 0, maxv = 1, 		name = "CHECK POINTS", 	cv = CV_FindVar("dc_checkpoints")},
	{minv = 0, maxv = 1, 		name = "SHIELDS", 		cv = CV_FindVar("dc_shields")},
	{minv = 0, maxv = 3, 		name = "PLAYER EFFECTS BETA", cv = CV_FindVar("dc_playereffects")},
	{minv = 0, maxv = 1, 		name = "MISC ASSETS", 	cv = CV_FindVar("dc_miscassets")},

}

--
--	MENU
--

local menu_select = 1
local press_delay = 0
local offset_y = 0
local offset_x = 0

HOOK("dc_menu", "dchud", function(v, p, t, e)
	if menu_toggle then
		if offset_x < 180 then
			offset_x = $+10
		else
			offset_x = 180
		end
	else
		if offset_x then
			offset_x = 2*offset_x/3
		end
	end

	if offset_x then
		local x_off = 40


		if offset_y then
			offset_y = offset_y/2
		end

		drawBG(v, v.cachePatch("SHMENUBACKGROUND"), V_50TRANS)

		local z = 60*menu_select+50+offset_y
		local scale, fxscale = v.dupy()
		local height = v.height()/scale

		for i = 1, #menu_items do
			local item = menu_items[i]
			if type(item) == "table" then
				local y = 100+i*60-z

				v.draw(x_off, y, v.cachePatch(menu_select == i and "SHMENUBUT1" or "SHMENUBUT2"))
				drawf(v, 'SH2ENUHEADFNT', (x_off+8)*2*FRACUNIT, (y+12)*2*FRACUNIT, FRACUNIT/2, string.upper(item.name), 0, v.getColormap(TC_DEFAULT, 1), "left")
				if item.cv then
					local font = "center"
					local yfnt = y+28

					if string.len(item.cv.string) > 14 then
						font = "thin-center"
						yfnt = $ + 1
					end
					drawf(v, 'SHMENUHEADFNT', (x_off+230)*2*FRACUNIT, (y+12)*2*FRACUNIT, FRACUNIT/2, string.upper(item.cv.string), 0, v.getColormap(TC_DEFAULT, 1), "right")
				end
			elseif type(item) == "string" then
				local y = 100+i*60-z
				drawf(v, 'SHMENUHEADFNT', 160*FRACUNIT, (y+16)*FRACUNIT, FRACUNIT, item, 0, v.getColormap(TC_DEFAULT, 1), "center")
			end
		end

		if menuactive or gamestate ~= GS_LEVEL then
			menu_toggle = false
		end

		if press_delay then
			press_delay = $-1
		end
	end
	return true
end, "game", 16, 3)

addHook("PlayerThink", function(p)
	if menu_toggle then
		p.pflags = $|PF_FORCESTRAFE|PF_JUMPDOWN|PF_USEDOWN
	elseif menu_toggle == false then
		p.pflags = $ &~ PF_FORCESTRAFE|PF_JUMPDOWN|PF_USEDOWN
		menu_toggle = nil
	end
end)

addHook("KeyDown", function(key_event)
	if menu_toggle and key_event.name == "escape" then
		menu_toggle = false
		return true
	end
end)

addHook("PlayerCmd", function(p, cmd)
	if menu_toggle then
		if cmd and not press_delay then
			if cmd.forwardmove < -25 then
				menu_select = (menu_select % #menu_items) + 1
				if type(menu_items[menu_select]) ~= "table" then
					menu_select = $ + 1
				end
				press_delay = 8
				offset_y = $+60

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.forwardmove > 25 then
				menu_select = menu_select - 1
				if type(menu_items[menu_select]) ~= "table" then
					menu_select = $ - 1
				end
				if menu_select < 1 then
					menu_select = #menu_items
				end
				press_delay = 8
				offset_y = $-60

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove < -25 and (menu_items[menu_select].cv or menu_items[menu_select].opt) then
				local cv = menu_items[menu_select].cv
				local ming = menu_items[menu_select].minv
				local maxg = menu_items[menu_select].maxv

				if menu_items[menu_select].opt then
					local opt = Options:getCV(menu_items[menu_select].opt)

					cv = opt[1]
					ming = opt[2]
					maxg = opt[3]
				end

				local value = cv.value-1
				if value < ming then
					value = maxg
				end

				CV_Set(cv, value)
				press_delay = 8

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove > 25 and (menu_items[menu_select].cv or menu_items[menu_select].opt) then
				local cv = menu_items[menu_select].cv
				local ming = menu_items[menu_select].minv
				local maxg = menu_items[menu_select].maxv

				if menu_items[menu_select].opt then
					local opt = Options:getCV(menu_items[menu_select].opt)

					cv = opt[1]
					ming = opt[2]
					maxg = opt[3]
				end

				local value = cv.value+1
				if value > maxg then
					value = ming
				end

				CV_Set(cv, value)
				press_delay = 8

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.buttons & BT_JUMP or cmd.buttons & BT_SPIN then
				menu_toggle = false
			end
		end

		cmd.sidemove = 0
		cmd.forwardmove = 0
		cmd.buttons = 0
	end
end)