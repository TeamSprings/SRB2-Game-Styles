--
--	MENU
--

local classic_menu_vars = tbsrequire('gui/definitions/classic_menuitems')

local menu_select = 1
local press_delay = 0
local offset_y = 0
local offset_x = 0

HOOK("classic_menu", "classichud", function(v, p, t, e)
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
		local x_off = offset_x-105


		if offset_y then
			offset_y = offset_y/2
		end

		local z = 60*menu_select+50+offset_y
		local scale, fxscale = v.dupy()
		local height = v.height()/scale

		v.draw(68, -24, v.cachePatch("S3KBACKGROUND"), V_SNAPTOLEFT|V_SNAPTOTOP|(ease.linear(max(offset_x-130, 0)*FRACUNIT/50, 9, 3) << V_ALPHASHIFT))

		local bg_pos = 0

		while (bg_pos < height) do
			v.draw(-133+x_off, bg_pos, v.cachePatch("MENUSRB2BACK"), V_SNAPTOLEFT|V_SNAPTOTOP)
			bg_pos = $ + 256
		end

		drawf(v, 'S3KTT', (500-offset_x)*FRACUNIT, 12*FRACUNIT, FRACUNIT, "MENU  ", V_SNAPTOTOP|V_SNAPTORIGHT, v.getColormap(TC_DEFAULT, 1), "right")

		for i = 1, #classic_menu_vars do
			local item = classic_menu_vars[i]
			if type(item) == "table" then
				local y = 100+i*60-z

				v.draw(x_off, y, v.cachePatch(menu_select == i and "S3KBUTTON2" or "S3KBUTTON1"), V_SNAPTOLEFT)
				v.drawString(x_off, y+8, "\x82*"..string.upper(item.name).."*", V_SNAPTOLEFT, "center")
				if item.opt then
					local set = Options:getvalue(item.opt)

					if set then
						local opt = set[1]
						local num = set[3]

						if num ~= nil then
							drawf(v, 'S3DBM', x_off*FRACUNIT, (y+17)*FRACUNIT, FRACUNIT, string.upper(string.format("%02x", num)), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 1), "center")
						end

						if opt ~= nil then
							local font = "center"
							local yfnt = y+28

							if string.len(opt) > 14 then
								font = "thin-center"
								yfnt = $ + 1
							end

							v.drawString(x_off, yfnt, "\x8C"..opt, V_SNAPTOLEFT, font)
						end
					end
				elseif item.cv then
					drawf(v, 'S3DBM', x_off*FRACUNIT, (y+17)*FRACUNIT, FRACUNIT, string.upper(string.format("%02x", item.cv.value)), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 1), "center")
					local font = "center"
					local yfnt = y+28

					if string.len(item.cv.string) > 14 then
						font = "thin-center"
						yfnt = $ + 1
					end

					v.drawString(x_off, yfnt, "\x8C"..item.cv.string, V_SNAPTOLEFT, font)
				end
			elseif type(item) == "string" then
				local y = 100+i*60-z
				drawf(v, 'S3KTT', x_off*FRACUNIT, (y+16)*FRACUNIT, FRACUNIT, item, V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 1), "center")
			end
		end

		local current = classic_menu_vars[menu_select]

		if current and type(current) == "table" and current.preview then
			v.draw(230, 108, v.cachePatch("S3KPREVIEW"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)
			if current.preview then
				current.preview(v, 230, 108, V_SNAPTORIGHT|V_SNAPTOBOTTOM)
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
				menu_select = (menu_select % #classic_menu_vars) + 1
				if type(classic_menu_vars[menu_select]) ~= "table" then
					menu_select = $ + 1
				end
				press_delay = 8
				offset_y = $+60

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.forwardmove > 25 then
				menu_select = menu_select - 1
				if type(classic_menu_vars[menu_select]) ~= "table" then
					menu_select = $ - 1
				end
				if menu_select < 1 then
					menu_select = #classic_menu_vars
				end
				press_delay = 8
				offset_y = $-60

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove < -25 and (classic_menu_vars[menu_select].cv or classic_menu_vars[menu_select].opt) then
				local cv = classic_menu_vars[menu_select].cv
				local ming = classic_menu_vars[menu_select].minv
				local maxg = classic_menu_vars[menu_select].maxv

				if classic_menu_vars[menu_select].opt then
					local opt = Options:getCV(classic_menu_vars[menu_select].opt)

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

			if cmd.sidemove > 25 and (classic_menu_vars[menu_select].cv or classic_menu_vars[menu_select].opt) then
				local cv = classic_menu_vars[menu_select].cv
				local ming = classic_menu_vars[menu_select].minv
				local maxg = classic_menu_vars[menu_select].maxv

				if classic_menu_vars[menu_select].opt then
					local opt = Options:getCV(classic_menu_vars[menu_select].opt)

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