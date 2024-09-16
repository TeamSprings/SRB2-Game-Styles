local gradient = tbsrequire 'helpers/draw_gradient'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local HOOK = customhud.SetupItem

local font_type = "ADVNUM"
local icon_style = nil

local menu_toggle = false

local hud_border = 0
local hud_select = 1

local bot_existance = nil
local bot_color = nil
local bot_skin = nil

--
--	HUD Externals
--

local hud_data = {
	[1] = tbsrequire('gui/gba_sa1hud'),
	[2] = tbsrequire('gui/gba_sa2hud'),
	[3] = tbsrequire('gui/gba_sa3hud'),
	[4] = tbsrequire('gui/gba_rushhud'),
	[5] = tbsrequire('gui/gba_rushadvhud'),
	[6] = tbsrequire('gui/gba_colorsdshud'),
}

--
--	Commands
--

COM_AddCommand("gba_menu", function(p)
	print("In Development")
	if menu_toggle == nil then
		menu_toggle = true
	else
		menu_toggle = not (menu_toggle)
	end
end, COM_LOCAL)

--
--	CVARs
--

local font_cv = CV_RegisterVar{
	name = "gba_hudfont",
	defaultvalue = "advance1",
	flags = CV_CALL,
	func = function(var)
		local fonts = {"ADVNUM", "ADV2NUM", "RUSNUM", "RUANUM", "COLNUM"}
		font_type = fonts[var.value]
	end,
	PossibleValue = {advance1=1, advance2=2, rush=3, rushadventure=4, colorsds=5}
}

local icon_cv = CV_RegisterVar{
	name = "gba_iconstyle",
	defaultvalue = "advance1",
	flags = CV_CALL,
	func = function(var)
		if var.value == 1 then
			icon_style = nil
		elseif var.value == 2 then
			icon_style = false
		elseif var.value == 3 then
			icon_style = true
		end
	end,
	PossibleValue = {advance1=1, advance2=2, advance3=3}
}

local borders_cv = CV_RegisterVar{
	name = "gba_borders",
	defaultvalue = "none",
	flags = CV_CALL,
	func = function(var)
		hud_border = var.value
	end,
	PossibleValue = {none=0, javasonic1=1, javasonic2=2, advancengage=3}
}

local gba_hud = CV_RegisterVar{
	name = "gba_hud",
	defaultvalue = "advance1",
	flags = CV_CALL,
	func = function(var)
		hud_select = var.value
		hud_border = 0
		CV_Set(icon_cv, min(var.value, 3))
		CV_Set(font_cv, var.value > 2 and var.value-1 or var.value)
	end,
	PossibleValue = {advance1=1, advance2=2, advance3=3, rush=4, rushadventure=5, colorsds=6}
}

--
--	SETUP
--

addHook("PlayerThink", function(p)
	if p.bot and consoleplayer == p.botleader then
		bot_existance = p.mo
		bot_color = p.mo.color
		bot_skin = p.mo.skin
	end
end)

--
--	HUD Elements
--

HOOK("lives", "gbahud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	-- Lives
	hud_data[hud_select].lives(v, p, t, e, font_type, icon_style, bot_existance, bot_skin, bot_color)
	return true
end, "game")

HOOK("score", "gbahud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	-- Due to draw order, it has to be here...
	-- Borders
	local scale, fscale = v.dupx()
	local width = v.width()/scale

	if hud_border == 1 then
		v.drawFill(0, 0, width, 30, 135|V_SNAPTOLEFT|V_SNAPTOTOP)
		for i = 0, 27, 3 do
			v.drawFill(0, i, width, 1, 136|V_SNAPTOLEFT|V_SNAPTOTOP)
		end

		v.drawFill(0, 177, width, 23, 135|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
		for i = 0, 21, 3 do
			v.drawFill(0, 179+i, width, 1, 136|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
		end
	elseif hud_border == 2 then
		v.drawFill(0, 0, width, 30, 117|V_SNAPTOLEFT|V_SNAPTOTOP)
		v.drawFill(0, 177, width, 23, 117|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	elseif hud_border == 3 then
		gradient.ngage(v, 0, 0, width, 30, 135|V_SNAPTOLEFT|V_SNAPTOTOP, 154|V_SNAPTOLEFT|V_SNAPTOTOP)
		for i = 0, 27, 3 do
			gradient.ngage(v, 0, i, width, 1, 136|V_SNAPTOLEFT|V_SNAPTOTOP, 156|V_SNAPTOLEFT|V_SNAPTOTOP)
		end

		gradient.ngage(v, 0, 177, width, 23, 135|V_SNAPTOLEFT|V_SNAPTOBOTTOM, 154|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
		for i = 0, 21, 3 do
			gradient.ngage(v, 0, 179+i, width, 1, 136|V_SNAPTOLEFT|V_SNAPTOBOTTOM, 156|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
		end
	end

	hud_data[hud_select].score(v, p, t, e, font_type)
	return true
end, "game")

HOOK("time", "gbahud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy
	hud_data[hud_select].time(v, p, t, e, font_type)
	return true
end, "game")

HOOK("rings", "gbahud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	hud_data[hud_select].rings(v, p, t, e, font_type)
	return true
end, "game")

HOOK("advancekey", "gbahud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy
	hud_data[hud_select].key(v, p, t, e, font_type)
	return true
end, "game")

--
-- MENU
--

local gba_menu_vars = {
	{name = "HUD PRESET", cv = gba_hud},
	{name = "MONITOR STYLE", cv = CV_FindVar("gba_monitorstyle")},
	{name = "EGGMAN VOICE", cv = CV_FindVar("gba_eggmanvoice")},
	"None",
	{name = "HUD FONT", cv = font_cv},
	{name = "HUD ICON STYLE", cv = icon_cv},
	{name = "HUD BORDERS", cv = borders_cv},
}

local menu_select = 1
local press_delay = 0

HOOK("gba_menu", "gbahud", function(v, p, t, e)
	if menu_toggle then
		v.fadeScreen(136, 8)
		v.draw(-23, -32, v.cachePatch("GBA_MENU_BG1"))
		v.draw(123, 10, v.cachePatch("GBA_MENU_BG2"))
		v.draw(50, 45, v.cachePatch("GBA_MENU_BG"))

		for i = 1, #gba_menu_vars do
			local item = gba_menu_vars[i]
			if type(item) == "table" then
				drawf(v, menu_select == i and 'RUSSFNT' or 'RUSHFNT', 63*FRACUNIT, (52+i*14)*FRACUNIT, FRACUNIT, string.upper(item.name), 0, v.getColormap(TC_DEFAULT, 0), "left", 1, 0)
				drawf(v, menu_select == i and 'RUSSFNT' or 'RUSHFNT', 259*FRACUNIT, (52+i*14)*FRACUNIT, FRACUNIT, string.upper(item.cv.string), 0, v.getColormap(TC_DEFAULT, 0), "right", 1, 0)
			end
		end

		if menuactive or gamestate ~= GS_LEVEL then
			menu_toggle = false
		end

		if p.cmd and not press_delay then
			local cmd = p.cmd

			if cmd.forwardmove < -25 then
				menu_select = (menu_select % #gba_menu_vars) + 1
				if type(gba_menu_vars[menu_select]) ~= "table" then
					menu_select = $ + 1
				end
				press_delay = 3
			end

			if cmd.forwardmove > 25 then
				menu_select = menu_select - 1
				if type(gba_menu_vars[menu_select]) ~= "table" then
					menu_select = $ - 1
				end
				if menu_select < 1 then
					menu_select = #gba_menu_vars
				end
				press_delay = 3
			end

			if cmd.sidemove < -25 then
				CV_AddValue(gba_menu_vars[menu_select].cv, 1)
				press_delay = 3
			end

			if cmd.sidemove > 25 then
				CV_AddValue(gba_menu_vars[menu_select].cv, -1)
				press_delay = 3
			end

			if cmd.buttons & BT_JUMP or cmd.buttons & BT_SPIN then
				menu_toggle = false
			end
		end

		if press_delay then
			press_delay = $-1
		end
	end
	return true
end, "game", 2)

addHook("PlayerThink", function(p)
	if menu_toggle then
		p.mo.flags = $|MF_NOTHINK
	elseif menu_toggle == false then
		p.mo.flags = $ &~ MF_NOTHINK
		menu_toggle = nil
	end
end)