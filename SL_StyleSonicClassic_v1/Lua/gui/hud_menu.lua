local modio = tbsrequire 'classic_io'

local Options = tbsrequire 'helpers/create_cvar'
local color_profile = tbsrequire 'gui/hud_colors'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local fonts = tbsrequire('gui/hud_fonts')

local HOOK = customhud.SetupItem
local write = drawlib.draw

--
--	COM
--

local _combool = {
	["true"] = true,
	["t"]    = true,
	["yes"]  = true,
	["y"]    = true,
	["on"]   = true,
	["1"]    = true,
	["!"]    = true,

	["false"] = false,
	["f"]     = false,
	["no"]    = false,
	["n"]     = false,
	["off"]   = false,
	["0"]     = false,
	[")"]     = false,
}

local COM_MENU = "classic_menu"
local menu_toggle = false

COM_AddCommand(COM_MENU, function(p, var1)
	if consoleplayer ~= p then return end

	if modio.embedded then
		---@diagnostic disable-next-line
		menu_toggle = nil

		return
	end

	local var = _combool[var1]

	if var == nil then
		if menu_toggle == nil then
			menu_toggle = true
		else
			menu_toggle = not (menu_toggle)
		end
	else
		if var == false and menu_toggle == true then
			menu_toggle = false
		elseif var == true then
			menu_toggle = true
		end
	end
end, COM_LOCAL)

local function MENU_ENABLE()
	COM_BufInsertText(consoleplayer, COM_MENU.." true")
end

local function MENU_DISABLE()
	COM_BufInsertText(consoleplayer, COM_MENU.." false")
end


--
--	MENU
--

local classic_menu_vars = tbsrequire('gui/definitions/classic_menuitems')

-- PORT HOLDING

local menu_select = 1
local submenu_select = 1
local press_delay = 0
local offset_y = 0
local offset_x = 0
local prevsel = 0
local menufin = 180

local holding_scores = false
local holding_tics = 1
local distitems = 57
local disttimer = FRACUNIT/(distitems/12)

local musicfile = "OPTS2"
local musicprev = nil
local musicprev_pos = nil
local musicprev_looppoint = nil

HOOK("classic_menu", "classichud", function(v, p, t, e)
	if menu_toggle then
		if offset_x < menufin then
			offset_x = $+10
		else
			offset_x = menufin
		end
	else
		if offset_x then
			offset_x = 2*offset_x/3
		end
	end

	if offset_x then
		local x_off = offset_x-105
		local slide = offset_x-180

		local menuitems = classic_menu_vars[submenu_select]


		if offset_y then
			offset_y = ease.outsine(disttimer, offset_y, 0)
			if offset_y == 1 then -- there likely will be one frame... with just one wasteful frame
				offset_y = 0
			end
		end

		local z = distitems*menu_select+50+offset_y
		local scale, fxscale = v.dupy()
		local width = v.width()/scale
		local height = v.height()/scale
		local tranpsr = ease.linear(max(offset_x-130, 0)*FU/50, 9, 3)

		local selgp_1 = v.cachePatch("S3KBUTTON1")
		local selgp_2 = v.cachePatch("S3KBUTTON2")
		local selgp_3 = v.cachePatch("S3KBUTTON3")
		local selgp_4 = v.cachePatch("S3KBUTTON4")

		if tranpsr < 9 then
			v.draw(68, -24, v.cachePatch("S3KBACKGROUND"), V_SNAPTOLEFT|V_SNAPTOTOP|(tranpsr << V_ALPHASHIFT))
		end

		local current = menuitems[menu_select]
		local selshow = menu_select

		if current and type(current) == "table" then
			-- current...
			if current.desc then

				local description = current.desc

				local len = width - 165
				local line_len = len / 5

				local words = {}

				for str in string.gmatch(description, "([^%s]+)") do
					table.insert(words, str)
				end


				local new_lines = {}
				local num_line = 1
				local num_char_per_line = 0

				for i = 1,#words do
					local word = new_lines[num_line] and " "..words[i] or words[i]
					num_char_per_line = num_char_per_line+string.len(word)
					if num_char_per_line > line_len then
						word = words[i]
						num_char_per_line = string.len(word)
						num_line = num_line+1
					end
					new_lines[num_line] = new_lines[num_line] and new_lines[num_line]..word or word
				end

				v.drawFill(0, 180 - slide - 8*#new_lines, width, 20 + 12*#new_lines, 24|V_SNAPTOLEFT|V_SNAPTOBOTTOM)

				local yt = 190 - slide - 8*#new_lines

				for i = 1, #new_lines do
					local substr = new_lines[i]

					v.drawString(310, yt, string.upper(substr), V_SNAPTORIGHT|V_SNAPTOBOTTOM, "thin-right")

					yt = $ + 8
				end
			else
				v.drawFill(0, 180 - slide, width, 20, 24|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
			end
		else
			v.drawFill(0, 180 - slide, width, 20, 24|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
		end

		local bg_pos = 0
		local bg_trps = tranpsr > 3 and (tranpsr-3) << V_ALPHASHIFT or 0

		while (bg_pos < height) do
			v.draw(-133+x_off, bg_pos, v.cachePatch("MENUSRB2BACK"), V_SNAPTOLEFT|V_SNAPTOTOP|bg_trps)
			bg_pos = $ + 256
		end

		for i = 1, #menuitems do
			local item = menuitems[i]
			if type(item) == "table" then
				local y = 78+i*distitems-z

				local selgp = selgp_1

				if item.opt then
					local set = Options:getvalue(item.opt)

					if Options:available(item.opt) then
						if selshow == i then
							selgp = selgp_2
						end
					else
						if selshow == i then
							selgp = selgp_4
						else
							selgp = selgp_3
						end
					end

					if set then
						local opt = set[1]
						local num = set[3]

						if num ~= nil then
							write(v, 'S3DBM', x_off*FU, (y+32)*FU, FU, string.upper(string.format("%02x", num)), V_SNAPTOLEFT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, 1), "center")
						end

						if opt ~= nil then
							local font = "center"
							local yfnt = y+17

							if string.len(opt) > 14 then
								font = "thin-center"
								yfnt = $ + 1
							end

							v.drawString(x_off, yfnt, "\x8C"..opt, V_SNAPTOLEFT|V_SNAPTOTOP, font)
						end
					end
				elseif item.cv then
					write(v, 'S3DBM', x_off*FU, (y+32)*FU, FU, string.upper(string.format("%02x", item.cv.value)), V_SNAPTOLEFT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, 1), "center")
					local font = "center"
					local yfnt = y+17

					if selshow == i then
						selgp = selgp_2
					end

					if string.len(item.cv.string) > 14 then
						font = "thin-center"
						yfnt = $ + 1
					end

					v.drawString(x_off, yfnt, "\x8C"..item.cv.string, V_SNAPTOLEFT|V_SNAPTOTOP, font)
				elseif item.com then
					if selshow == i then
						selgp = selgp_2
					end

					v.drawString(x_off, y+32, "\x8Cpress jump to activate", V_SNAPTOLEFT|V_SNAPTOTOP, "thin-center")
				end

				local font = "center"
				local yfnt = y+8

				if string.len(item.name) > 14 then
					font = "thin-center"
					yfnt = $+1
				end

				v.draw(x_off, y, selgp, V_SNAPTOLEFT|V_SNAPTOTOP)
				v.drawString(x_off, yfnt, "\x82*"..string.upper(item.name).."*", V_SNAPTOLEFT|V_SNAPTOTOP, font)
			elseif type(item) == "string" then
				local y = 100+i*distitems-z
				write(v, 'S3KTT', x_off*FU, (y-8)*FU, FU, item, V_SNAPTOLEFT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, 1), "center")
			end
		end

		v.drawFill(88, slide + 18, 144, 4, 24|V_SNAPTOTOP)

		v.drawFill(0, slide, width, 14, 154|V_SNAPTOTOP|V_SNAPTOLEFT)
		v.drawFill(0, slide + 14, width, 2, 74|V_SNAPTOTOP|V_SNAPTOLEFT)
		v.drawFill(0, slide + 16, width, 4,	24|V_SNAPTOTOP|V_SNAPTOLEFT)

		local scroller 		= v.cachePatch("MENUCLSTSCROLL")
		local scroller_x 	= (leveltime % scroller.width) - scroller.width + slide

		while (width > scroller_x) do
			v.draw(scroller_x, slide, scroller, V_SNAPTOLEFT|V_SNAPTOTOP)
			scroller_x = $ + scroller.width
		end

		v.drawFill(88, slide, 144, 18, 74|V_SNAPTOTOP)
		v.drawFill(90, slide, 140, 16, 154|V_SNAPTOTOP)

		local fontsubmenu = "thin-center"
		local ysubmenu = slide + 5

		local strv = string.upper(menuitems.name)

		if not ((leveltime/4) % 2) then
			strv = "\x82<   "..strv.."   >"
		else
			strv = "\x82<  "..strv.."  >"
		end


		v.drawString(100, ysubmenu, "C1", V_SNAPTOTOP, fontsubmenu)

		v.drawString(160, ysubmenu, strv, V_SNAPTOTOP, fontsubmenu)

		v.drawString(220, ysubmenu, "C3", V_SNAPTOTOP, fontsubmenu)

		if press_delay then
			press_delay = $-1
		end
	end
	return true
end, "game", 16, 3)

addHook("ThinkFrame", function()
	if menuactive or gamestate ~= GS_LEVEL then
		MENU_DISABLE()
	end
end)

-- Fix return
addHook("PlayerThink", function(p)
	if menu_toggle then
		p.pflags = $|PF_FORCESTRAFE|PF_JUMPDOWN|PF_USEDOWN

		if p == consoleplayer and offset_x > (menufin/2) then
			local current = S_MusicName(p)

			if current ~= nil and current ~= musicfile then
				musicprev = current
				musicprev_pos = S_GetMusicPosition()
				musicprev_looppoint = S_GetMusicLoopPoint(p)
				S_ChangeMusic(musicfile, true, p)
			end
		end
	elseif menu_toggle == false then
		p.pflags = $ &~ PF_FORCESTRAFE|PF_JUMPDOWN|PF_USEDOWN
		menu_toggle = nil

		if p == consoleplayer and musicprev then
			S_ChangeMusic(musicprev, musicprev_looppoint ~= nil, p, nil, musicprev_pos, MUSICRATE/4)
			musicprev = nil
			musicprev_pos = nil
			musicprev_looppoint = nil
		end
	end
end)

addHook("KeyDown", function(key_event)
	if menu_toggle and key_event.name == "escape" then
		MENU_DISABLE()
		return true
	end
end)

addHook("HUD", function(v)
	if not menu_toggle then
		v.draw(320, 0, v.cachePatch("CLASSICMENUCIR" .. holding_tics), V_SNAPTORIGHT|V_SNAPTOTOP)
	end

	holding_scores = true
end, "scores")

addHook("PlayerCmd", function(p, cmd)
	if menu_toggle then

		local menuitems = classic_menu_vars[submenu_select]

		if cmd and not press_delay then
			if cmd.forwardmove < -25 then
				prevsel = menu_select
				menu_select = (menu_select % #menuitems) + 1
				if type(menuitems[menu_select]) ~= "table" then
					menu_select = $ + 1
				end
				press_delay = 8
				offset_y = $-distitems

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.forwardmove > 25 then
				prevsel = menu_select
				menu_select = menu_select - 1
				if type(menuitems[menu_select]) ~= "table" then
					menu_select = $ - 1
				end
				if menu_select < 1 then
					menu_select = #menuitems
				end
				press_delay = 8
				offset_y = $+distitems

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove < -25 and (menuitems[menu_select].cv or menuitems[menu_select].opt) then
				local cv = menuitems[menu_select].cv
				local ming = menuitems[menu_select].minv
				local maxg = menuitems[menu_select].maxv

				if menuitems[menu_select].opt then
					local opt = Options:getCV(menuitems[menu_select].opt)

					if Options:available(opt) then
						S_StartSound(nil, sfx_menu1, p)
						press_delay = 8
						return
					end

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

			if cmd.sidemove > 25 and (menuitems[menu_select].cv or menuitems[menu_select].opt) then
				local cv = menuitems[menu_select].cv
				local ming = menuitems[menu_select].minv
				local maxg = menuitems[menu_select].maxv

				if menuitems[menu_select].opt then
					local opt = Options:getCV(menuitems[menu_select].opt)

					if Options:available(opt) then
						S_StartSound(nil, sfx_menu1, p)
						press_delay = 8
						return
					end

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

			if menuitems[menu_select].com and cmd.buttons & BT_JUMP then
				COM_BufInsertText(p, menuitems[menu_select].com)

				press_delay = 8
				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.buttons & BT_SPIN then
				MENU_DISABLE()
			end

			if cmd.buttons & BT_CUSTOM1 then
				submenu_select = $ - 1
				menu_select = 1

				if submenu_select < 1 then
					submenu_select = #classic_menu_vars
				end

				press_delay = 8
			end

			if cmd.buttons & BT_CUSTOM3 then
				submenu_select = $ + 1
				menu_select = 1

				if submenu_select > #classic_menu_vars then
					submenu_select = 1
				end

				press_delay = 8
			end
		end

		cmd.sidemove = 0
		cmd.forwardmove = 0
		cmd.buttons = 0
	elseif holding_scores then
		if not modio.embedded and cmd and cmd.buttons & BT_TOSSFLAG then
			holding_tics = $ + 1

			if holding_tics == TICRATE then
				holding_scores = nil
				holding_tics = 1

				MENU_ENABLE()
				press_delay = 16
			end

			cmd.sidemove = 0
			cmd.forwardmove = 0
			cmd.buttons = 0
		else
			holding_tics = 1
		end

		holding_scores = nil
	end
end)