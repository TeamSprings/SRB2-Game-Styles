local gradient = tbsrequire 'helpers/draw_gradient'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local calc_help = tbsrequire 'helpers/c_inter'
local drawScroll = drawlib.drawScroll
local drawf = drawlib.draw
local fontl = drawlib.lenght
local drawan = drawlib.drawAnim

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
--	SCORES LAYER STUFF
--

local emeralds_set = {
	EMERALD1,
	EMERALD2,
	EMERALD3,
	EMERALD4,
	EMERALD5,
	EMERALD6,
	EMERALD7,
}

HOOK("coopemeralds", "gbahud", function(v)
	if multiplayer then return end

	for i = 1, 7 do
		local x = 8+i*38

		v.draw(x-3, 113, v.cachePatch("CHAOSEMPTY"), 0)
		if emeralds & emeralds_set[i] then
			v.draw(x, 115, v.cachePatch("CHAOS"..i), 0)
		end
	end

	return true
end, "scores")

--
-- STAGECARD
--

HOOK("stagetitle", "gbahud", function(v, p, t, e)
	if skins["modernsonic"] then return end	-- whyyyy
	if t > 3*TICRATE then return end

	-- setup name
	local name = string.upper(""..mapheaderinfo[gamemap].lvlttl) .. ((mapheaderinfo[gamemap].levelflags & LF_NOZONE) and "" or " ZONE")
	local name_lenght = 0

	for i = 1, #name do
		name_lenght = $ + fontl(v, patch, name, 'ADV1TTF', val, 0, i)
	end

	name = $..string.rep(" ", max(216 - name_lenght, 1)/9)
	local long_name = string.rep(name, 12)

	local act = tostring(mapheaderinfo[gamemap].actnum)

	-- variables

	local width, fxw = v.height()
	local height, fxh = v.height()

	local scale = v.dupy()
	local width_c = min(width/scale/14, 48)
	local fill = 0

	local player_c = v.getColormap(p.skin, p.skincolor)

	local awaytime = max(24*t-70*TICRATE, 0)


	-- Allocation of elements

	local bg = v.cachePatch("ADV1TITBG")
	local bg_x = min(t*24-bg.width, 0) - awaytime - (48-width_c)

	local bgtxt = v.cachePatch("ADV1TITBGTXT")
	local bgtxt_y = min(t*24-bg.width-20-bg.height/4, 0) - awaytime + width_c/4

	local txtbg_x = min(t*24-bg.width-16, 0) + awaytime

	-- Render

	v.fadeScreen(0xFF00, max(32-t/3, 0))

	while (height/scale > fill)
		v.draw(bg_x, fill, bg, V_SNAPTOTOP|V_SNAPTOLEFT, player_c)
		fill = $ + bg.height
	end

	v.draw(70-width_c, 5+bgtxt_y, bgtxt, V_SNAPTOTOP|V_SNAPTOLEFT, player_c)

	local textbox_x = -txtbg_x*scale

	v.drawFill(textbox_x, 166, width/scale*2, 20, 1|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	drawScroll(v, 'ADV1TTF', textbox_x*FRACUNIT, 169*FRACUNIT, FRACUNIT, long_name, V_SNAPTOLEFT|V_SNAPTOBOTTOM, v.getColormap(0, 0), "left", 0, 0, 0, 3*t, width/scale*2)

	if act ~= "0" then
		local act_y = 187 - min(t*8-2*bg.width/3-bgtxt.height, 0) + awaytime/8

		v.draw(260, act_y, v.cachePatch("ADV1ACT"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)
		drawf(v, 'ADV1ACTNUM', 292*FRACUNIT, act_y*FRACUNIT, FRACUNIT, act, V_SNAPTORIGHT|V_SNAPTOBOTTOM, v.getColormap(0, 0), "left")
	end

	return true
end, "titlecard")


--
-- TALLY
--

local function scale_updraw(v, x, y, scale, patch, flags, color, i, progress)
	local scl = FixedMul(scale, progress)
	v.drawStretched(x, y+patch.height*(scale-scl), scale, scl, patch, flags, color)
end

local function clampTimer(min_, x, max_)
	return abs(max(min(x, max_), min_) - min_) * FRACUNIT / (max_ - min_)
end

local fake_timebonus = 0
local fake_ringbonus = 0

HOOK("styles_levelendtally", "gbahud", function(v, p, t, e)
	if skins["modernsonic"] then return end	-- whyyyy
	if p.styles_tallytimer == nil then return end

	if p.styles_tallytimer and p.styles_tallytimer == -98 then
		fake_timebonus = calc_help.Y_GetTimeBonus(p.realtime)
		fake_ringbonus = calc_help.Y_GetRingsBonus(p.rings)
	end

	if p.styles_tallytimer and p.styles_tallytimer > 0 and not paused then
		if fake_timebonus then
			fake_timebonus = $-222
			if fake_timebonus < 0 then
				fake_timebonus = 0
			end

			if not (p.styles_tallytimer % 3) then
				S_StartSound(nil, sfx_ptally, p)
			end
		end

		if fake_ringbonus and not fake_timebonus then
			fake_ringbonus = $-222
			if fake_ringbonus < 0 then
				fake_ringbonus = 0
			end

			if not (p.styles_tallytimer % 3) then
				S_StartSound(nil, sfx_ptally, p)
			end
		end

		if p.styles_tallytimer == p.styles_tallyfakecounttimer+1 then
			fake_timebonus = 0
			fake_ringbonus = 0

			S_StartSound(nil, sfx_chchng, p)
		end
	end

	local width, fxw = v.height()
	local height, fxh = v.height()
	local scale = v.dupy()

	local act = tostring(mapheaderinfo[gamemap].actnum)
	if act ~= "0" then
		act = "ACT"..act
	else
		act = "ZONE"
	end

	local txt = string.upper(skins[p.skin].realname).." GOT THROUGH "..act.."               "
	local name = string.rep(txt, 8)
	local name_lenght = 0

	for i = 1, #txt do
		name_lenght = $ + fontl(v, patch, txt, 'ADV1MENFNT', val, 0, i)
	end

	local offset_ytxtb = ease.linear(clampTimer(-90, p.styles_tallytimer, -75), 0, 3*height/scale/5)
	local offset_x = ease.linear(clampTimer(-100, p.styles_tallytimer, -96), 2*width/scale, 0)

	local first_up = max(clampTimer(-75, p.styles_tallytimer, -40)-1, 0)
	local secon_up = max(clampTimer(-65, p.styles_tallytimer, -30)-1, 0)
	local third_up = max(clampTimer(-55, p.styles_tallytimer, -20)-1, 0)
	local fourt_up = max(clampTimer(-45, p.styles_tallytimer, -10)-1, 0)

	v.drawFill(offset_x, 166-offset_ytxtb, width/scale*2, 20, 1|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	drawScroll(v, 'ADV1MENFNT', offset_x*FRACUNIT, (171-offset_ytxtb)*FRACUNIT, FRACUNIT, name, V_SNAPTOLEFT|V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, 1), "left", 0, 0, 0, name_lenght+((3*leveltime) % (name_lenght+1)), width/scale*2)

	drawan(v, 'ADV1TAFNT', 92*FRACUNIT, 100*FRACUNIT, FRACUNIT, "TIME BONUS", 0, v.getColormap(0, 0), "left", 0, 5, ' ', first_up, scale_updraw, 8*FRACUNIT/10)
	drawan(v, 'ADVNUM', 175*FRACUNIT, 97*FRACUNIT, FRACUNIT, fake_timebonus, 0, v.getColormap(0, 0), "left", 0, 5, ' ', secon_up, scale_updraw, 8*FRACUNIT/10)

	drawan(v, 'ADV1TAFNT', 92*FRACUNIT, 122*FRACUNIT, FRACUNIT, "RING BONUS", 0, v.getColormap(0, 0), "left", 0, 5, ' ', third_up, scale_updraw, 8*FRACUNIT/10)
	drawan(v, 'ADVNUM', 175*FRACUNIT, 119*FRACUNIT, FRACUNIT, fake_ringbonus, 0, v.getColormap(0, 0), "left", 0, 5, ' ', fourt_up, scale_updraw, 8*FRACUNIT/10)
	return true
end, "game")


--
-- MENU
--

local gba_menu_vars = {
	{name = "HUD PRESET", cv = gba_hud},
	{name = "HUD FONT", cv = font_cv},
	{name = "HUD ICON STYLE", cv = icon_cv},
	{name = "HUD BORDERS", cv = borders_cv},
	"None",
	{name = "GOALSIGN ANIMATION", cv = CV_FindVar("gba_sign_movement")},
	{name = "MONITOR STYLE", cv = CV_FindVar("gba_monitorstyle")},
	{name = "EGGMAN VOICE", cv = CV_FindVar("gba_eggmanvoice")},
	{name = "SCORE TALLY", cv = CV_FindVar("gba_endtally")},
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

		if press_delay then
			press_delay = $-1
		end
	end
	return true
end, "game", 2)


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
				menu_select = (menu_select % #gba_menu_vars) + 1
				if type(gba_menu_vars[menu_select]) ~= "table" then
					menu_select = $ + 1
				end
				press_delay = 3
				S_StartSound(nil, sfx_menu1, p)
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
				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove < -25 and gba_menu_vars[menu_select].cv then
				local cv = gba_menu_vars[menu_select].cv
				CV_Set(cv, cv.value-1)
				press_delay = 3

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove > 25 and gba_menu_vars[menu_select].cv then
				local cv = gba_menu_vars[menu_select].cv
				CV_Set(cv, cv.value+1)
				press_delay = 3

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