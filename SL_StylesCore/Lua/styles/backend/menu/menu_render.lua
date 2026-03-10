local Menu = styleslocal("backend/menu/menu_vars")
local HOOK = customhud.SetupItem

addHook("HUD", function(v)
	if not Menu.toggle then
		v.draw(320, 0, v.cachePatch("CLASSICMENUCIR" .. Menu.scoreholdtics), V_SNAPTORIGHT|V_SNAPTOTOP)
	end

	Menu.scorehold = true
end, "scores")

local types = {
	opt = function(item)
		local set = Options:getvalue(item.opt)
		local toggle = true
		local index = 0
		local value = "MISSING"

		if not Options:available(item.opt) then
			toggle = false
		end

		if set then
			value = set[1]
			index = set[3]
		end

		return toggle, index, value
	end,

	com = function(item)
		return true, nil, "jump to activate"
	end,

	cv = function(item)
		local index = 0
		local value = "MISSING"

		if item.cv then
			index = item.cv.value
			value = item.cv.string
		end

		return true, index, value
	end,
}

HOOK("classic_menu", "classichud", function(v, p, t, e)
	if consoleplayer ~= p then return end

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

		local depth = distitems*menu_select + 50+offset_y
		local scale,_ = v.dupy()
		local width = v.width()/scale
		local height = v.height()/scale
		local opacity = ease.linear(max(offset_x-130, 0)*FU/50, 9, 3)

		if not cache then
			cache = {
				buttonA = v.cachePatch("S3KBUTTON1"),
				buttonB = v.cachePatch("S3KBUTTON2"),
				buttonC = v.cachePatch("S3KBUTTON3"),
				buttonD = v.cachePatch("S3KBUTTON4"),

				background = v.cachePatch("S3KBACKGROUND"),
			}
		end

		if opacity < 9 then
			v.draw(68, -24, cache.background, V_TOPLEFT|(opacity << V_ALPHASHIFT), v.getColormap(TC_DEFAULT, 0, color_profile.menu))
		end

		local currentindex = menu_select
		local current = menuitems[currentindex]

		if current and type(current) == "table"
		and current.desc then
			local len = (width - 165) / 5
			lines, _, _ = split(current.desc, len)

			v.drawFill(0, 180 - slide - 8*#lines, width, 20 + 12*#lines, 24|V_SNAPTOLEFT|V_SNAPTOBOTTOM)

			local yt = 190 - slide - 8*#lines

			for i = 1, #lines do
				local substr = lines[i]

				v.drawString(310, yt, string.upper(substr), V_SNAPTORIGHT|V_SNAPTOBOTTOM, "thin-right")

				yt = $ + 8
			end
		else
			v.drawFill(0, 180 - slide, width, 20, 24|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
		end

		local bg_pos = 0
		local bg_trps = opacity > 3 and (opacity-3) << V_ALPHASHIFT or 0
		local bg_frame = 1 + (leveltime*TICRATE/24) % 12

		while (bg_pos < height) do
			v.draw(-133+x_off, bg_pos, v.cachePatch("MENUSRB2BACK"..bg_frame), V_SNAPTOLEFT|V_SNAPTOTOP|bg_trps)
			bg_pos = $ + 256
		end

		local buttongpx

		for i = 1, #menuitems do
			local item = menuitems[i]
			if type(item) == "table" then
				buttongpx = cache.buttonA
				
				local y = 78 + i*distitems - depth

				local toggle = true
				local index = nil
				local value = nil

				if item.opt then
					toggle, index, value = types.opt(item)
				elseif item.cv then
					toggle, index, value = types.cv(item)
				elseif item.com then
					toggle, index, value = types.com(item)
				elseif item.addon then
					v.draw(x_off - 48, y + 32, v.cachePatch(item.addon.icon), V_TOPLEFT)
					v.drawString(x_off + 48, y + 24, "\x8C"..item.addon.version, V_TOPLEFT, "right")
				end

				if toggle then
					if currentindex == i then
						buttongpx = cache.buttonB
					end
				else
					if currentindex == i then
						buttongpx = cache.buttonD
					else
						buttongpx = cache.buttonC
					end
				end

				if index ~= nil then
					write(
						v,
						'S3DBM',
						x_off*FU,
						(y+32)*FU,
						FU,
						string.upper(string.format("%02x", index)),
						V_TOPLEFT,
						v.getColormap(TC_DEFAULT, 1),
						"center"
					)
				end

				if value ~= nil then
					local font = "center"
					local yfnt = y+17

					if string.len(value) > 14 then
						font = "thin-center"
						yfnt = $ + 1
					end

					v.drawString(x_off, yfnt, "\x8C"..value, V_TOPLEFT, font)
				end

				local font = "center"
				local yfnt = y+8

				if string.len(item.name) > 14 then
					font = "thin-center"
					yfnt = $+1
				end

				v.draw(x_off, y, buttongpx, V_TOPLEFT)
				v.drawString(x_off, yfnt, "\x82*"..string.upper(item.name).."*", V_TOPLEFT, font)
			elseif type(item) == "string" then
				local y = 100+i*distitems-depth
				write(v, 'S3KTT', x_off*FU, (y-8)*FU, FU, item, V_TOPLEFT, v.getColormap(TC_DEFAULT, 1), "center")
			end
		end

		v.drawFill(88, slide + 18, 144, 4, 24|V_SNAPTOTOP)

		v.drawFill(0, slide, width, 14, 154|V_TOPLEFT)
		v.drawFill(0, slide + 14, width, 2, 74|V_TOPLEFT)
		v.drawFill(0, slide + 16, width, 4,	24|V_TOPLEFT)

		local scroller 		= v.cachePatch("MENUCLSTSCROLL")
		local scroller_x 	= (leveltime % scroller.width) - scroller.width + slide

		while (width > scroller_x) do
			v.draw(scroller_x, slide, scroller, V_SNAPTOLEFT|V_SNAPTOTOP)
			scroller_x = $ + scroller.width
		end

		v.drawFill(88, slide, 144, 18, 74|V_SNAPTOTOP)
		v.drawFill(90, slide, 140, 16, 154|V_SNAPTOTOP)

		local strv = string.upper(menuitems.name)
		local fontsubmenu = "thin-center"
		local ysubmenu = slide + 5

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