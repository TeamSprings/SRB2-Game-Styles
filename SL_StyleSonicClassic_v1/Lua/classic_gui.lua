--[[

	GUI Manager

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local modio = tbsrequire 'classic_io'
local Options = tbsrequire 'helpers/create_cvar' ---@type CvarModule
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local calc_help = tbsrequire 'helpers/c_inter'

local excp = drawlib.exception
local mono = drawlib.monospace
local write = drawlib.draw
local textlen = drawlib.text_lenght
local HOOK = customhud.SetupItem

local FU = FU
local abs = abs
local tostring = tostring
local tonumber = tonumber

excp("STTNUM", ":", "STTCOLON")
excp("STTNUM", ".", "STTPERIO")
excp("STTNUM", "-", "STTMINUS")
mono("STTNUM", 8)

local hud_select = 1
local lifeicon = 1
local titletype = 1
local titletypechange = -1
local tallyrecoloring = "SPECIALSTAGE_SONIC1_TALLY1"
local txtpadding = 0
local prefix = "S1"
local debugft = "S1"

local menu_toggle = false

--
--	External HUDs
--

local hud_data = {
	[1] = tbsrequire('gui/unique/classic_sonic1'),
	[2] = tbsrequire('gui/unique/classic_sonic2'),
	[3] = tbsrequire('gui/unique/classic_soniccd'),
	[4] = tbsrequire('gui/unique/classic_sonic3'),
	[5] = tbsrequire('gui/unique/classic_blast3d'),
	[6] = tbsrequire('gui/unique/classic_mania'),
	[7] = tbsrequire('gui/unique/classic_xtreme'),
	[8] = tbsrequire('gui/unique/classic_chaotix'),
}

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
-- SWITCHER ONLY WHEN STAGE RESTARTS
--

addHook("MapChange", function()
	if titletypechange > 0 then
		titletype = titletypechange

		titletypechange = -1
	end
end)

--
--	CVARs
--

local layout_val = 1
local layouts = tbsrequire('gui/definitions/classic_layouts')

local layout_opt = Options:new("hudlayout", "gui/cvars/layouts", function(var)
	layout_val = var.value
end, 0, 4)

local layout_cv = layout_opt.cv

local lif_opt = Options:new("lifeicon", "gui/cvars/lifeicon", function(var)
	local set = {1, 3, 4, 5, 6, 7, 8}
	lifeicon = set[var.value]
end, 0, 5)

local lif_cv = lif_opt.cv

local lifpos_opt = Options:new("lifepos",
	{
		{nil, "classic",   	"Classic"},
		{nil, "mobile", 	"Mobile"},
	},
nil, 0, 5)

local fade_cv = CV_RegisterVar{
	name = "classic_bluefade",
	defaultvalue = "off",
	flags = 0,
	PossibleValue = {off = 0, tally = 1},
}

local font_opt = Options:new("hudfont", "gui/cvars/hudfont", function(var)
	local prefixes = {"S1", "S2", "CD", "S3", "3B", "MA", "XT", "KC", "SC", "MS", "ST"}
	prefix = prefixes[var.value]

	local paddingset = {0, 0, 0, 0, -1, -1, 0, 0, 0, -1, 0, 0, 0}
	txtpadding = paddingset[var.value]

	local debugprefixes = {"S1", "S1", "S1", "S3", "S3", "S3", "S3", "SC", "SC", "S3", "S1", "S1"}
	debugft = debugprefixes[var.value]

	if var.value > 4 then
		---@diagnostic disable-next-line
		CV_Set(fade_cv, 1)
	else
		---@diagnostic disable-next-line
		CV_Set(fade_cv, 0)
	end
end, 0, 6)

local font_cv = font_opt.cv

local title_opt = Options:new("hudtitle", "gui/cvars/hudtitle", function(var)
	local titles = {1, 2, 3, 4, 6, 5}

	if gamestate == GS_LEVEL then
		titletypechange = titles[var.value]
	else
		titletype = titles[var.value]
	end
end, 0, 7)

local title_cv = title_opt.cv

local hud_opt = Options:new("hud", "gui/cvars/hudtypes", function(var)
	local prefixes = {1, 2, 3, 4, 5, 6, 7, 8}
	CV_Set(font_cv, prefixes[var.value])

	local lives = {1, 1, 2, 3, 4, 5, 6, 7}
	CV_Set(lif_cv, lives[var.value])

	local title = {1, 2, 3, 4, 6, 5, 4, 4}
	CV_Set(title_cv, title[var.value])

	local recolorersinsp = {
		"SPECIALSTAGE_SONIC1_TALLY1",
		"SPECIALSTAGE_SONIC2_TALLY",
		"SPECIALSTAGE_SONICCD_TALLY",
		"SPECIALSTAGE_SONIC3_TALLY",
		"SPECIALSTAGE_SONIC3DB_TALLY",
		nil, -- mania
		"SPECIALSTAGE_SONIC1_TALLY1",
		"SPECIALSTAGE_SONIC1_TALLY1",
	}
	tallyrecoloring = recolorersinsp[var.value]

	hud_select = var.value
end, 0, 8)

local hud_cv = hud_opt.cv

local color_profile = {}
local color_profilefield = {}

local color_changer

local function HUD_ADDCOLORSPACE(hudtype)
	color_profile[hudtype] = nil

	local opt = Options:new("hudcolor"..hudtype, "gui/cvars/hudcolor", function()
		if color_changer then
			color_changer(hudtype)
		end
	end, 0, 7)

	color_profilefield[hudtype] = opt

	return opt
end

local scorecolor_opt   = HUD_ADDCOLORSPACE('score')
local timecolor_opt    = HUD_ADDCOLORSPACE('time')
local ringscolor_opt   = HUD_ADDCOLORSPACE('rings')
local livescolor_opt   = HUD_ADDCOLORSPACE('lives')
local nightscolor_opt  = HUD_ADDCOLORSPACE('nights')
local numberscolor_opt = HUD_ADDCOLORSPACE('numbers')

local color_opt = Options:new("hudcolor", "gui/cvars/hudcolor", function(var)
	if color_changer then
		for _, opt in pairs(color_profilefield) do
			CV_Set(opt.cv, 	var.value)
		end
	end
end, 0, 8)

color_changer = function(setting)
	color_profile[setting] = Options:getPureValue("hudcolor"..setting)
end

local emeraldpos_opt = Options:new("emeraldpos",
	{
		{nil, "vanilla",   	"Vanilla"},
		{nil, "finaldemo",  "Final Demo"},
	},
nil, 0, 5)

local emeraldanim_opt = Options:new("emeraldanim",
	{
		{nil, "tally",   	"Classic Tally"},
		{nil, "full",  		"Classic Full"},
		{nil, "retro",  	"Retro Engine"},
	},
nil, 0, 5)

local easing_numbers = 0

local easenumbers_opt = Options:new("easingtonum",
	{
		[0] = {nil, "disabled",    "Disabled"},
		[1] = {nil, "smooth",  		"Smooth"},
	},
function(cvar)
	easing_numbers = cvar.value
end, 0, 5)

local time_opt = Options:new("timeformat", "gui/cvars/hudtime", nil, 0, 7)

local force_usernameinhud = CV_RegisterVar{
	name = "classic_username",
	defaultvalue = "0",
	flags = 0,
	PossibleValue = {off = 0, on = 1},
}

local allring_counter = CV_RegisterVar{
	name = "classic_ringcounter",
	defaultvalue = "0",
	flags = 0,
	PossibleValue = {off = 0, on = 1},
}

local debugcords_opt = Options:new("debug",
	{
		[0] = {nil, 	"off",   	"Off"},
		[1] = {1, 		"plane",  	"2D X/Y"},
		[2] = {2, 		"full",  	"3D X/Y/Z"},
	},
nil, 0, 5)

local hud_hide_cv = CV_RegisterVar{
	name = "classic_hidehudop",
	defaultvalue = "0",
	flags = 0,
	PossibleValue = {off = 0, tally = 1, title = 2, both = 3},
}

local emeralds_set = {
	EMERALD1,
	EMERALD2,
	EMERALD3,
	EMERALD4,
	EMERALD5,
	EMERALD6,
	EMERALD7,
}

local fake_timebonus = 0
local fake_ringbonus = 0
local fake_nightsbonus = 0
local fake_perfect = 0
local true_totalbonus = 0
local cached_tallyskincolor

--
--	HUD Elements
--

--#region BASE GAMEPLAY

local hide_offset_x = 0
local hidefull_offset_x = 0
local styles_hide_hud = false
local styles_hide_fullhud = false
local red_flashing_timer = TICRATE/4
local red_flashing_thred = red_flashing_timer/2

HOOK("lives", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end
	if modeattacking then return end

	---@diagnostic disable-next-line
	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local life_pos = lifpos_opt.cv.value
	local mo = p.mo and p.mo or p.realmo

	hud_data[lifeicon].lives(
		v, p, t, e, prefix, mo, hide_offset_x,
		v.getColormap(TC_DEFAULT, 1, color_profile.lives),
		force_usernameinhud.value and p.name or nil,
		life_pos,
		v.getColormap(TC_DEFAULT, 1, color_profile.numbers)
	)
	return true
end, "game", 1, 3)

local tally_totalcalculation = 0
local score_numupdt = 0

HOOK("score", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	local mo = p.mo and p.mo or p.realmo
	if not mo then return end

	if layouts[layout_val] and layouts[layout_val].score == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local layout_opt = layouts[layout_val]

	local hideoffset = layout_opt.score_move_dir*hidefull_offset_x

	local debugmode = debugcords_opt()

	if debugmode then
		if layout_opt.scoregraphic then
			v.draw(hudinfo[HUD_SCORE].x+hideoffset+layout_opt.xoffset_score,
			hudinfo[HUD_SCORE].y+layout_opt.yoffset_score,
			v.cachePatch(prefix..'TSCODB'),
			layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER,
			v.getColormap(TC_DEFAULT, 1, color_profile.score))
		end

		-- Debug Mode
		local bitf = FU
		local pvx, pvy = abs(mo.x/bitf)/4, abs(mo.y/bitf)/4
		local cvx, cvy = abs(t.x/bitf)/4, abs(t.y/bitf)/4

		local xval = hudinfo[HUD_SCORE].x + 32 +hideoffset + layout_opt.xoffset_score + layout_opt.xoffset_debugnum

		if debugmode == 2 then
			local pvz, cvz = abs(mo.z/bitf)/4, abs(t.z/bitf)/4

			write(v, debugft..'DBM', xval*FU, (hudinfo[HUD_SCORE].y-1+layout_opt.yoffset_score)*FU, FU,
			string.upper(string.format("%04x%04x%04x", pvx, pvy, pvz)), layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.debugalligment)
			write(v, debugft..'DBM', xval*FU, (hudinfo[HUD_SCORE].y+7+layout_opt.yoffset_score)*FU, FU,
			string.upper(string.format("%04x%04x%04x", cvx, cvy, cvz)), layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.debugalligment)
		else
			write(v, debugft..'DBM', xval*FU, (hudinfo[HUD_SCORE].y-1+layout_opt.yoffset_score)*FU, FU,
			string.upper(string.format("%04x%04x", pvx, pvy)), layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.debugalligment)
			write(v, debugft..'DBM', xval*FU, (hudinfo[HUD_SCORE].y+7+layout_opt.yoffset_score)*FU, FU,
			string.upper(string.format("%04x%04x", cvx, cvy)), layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.debugalligment)
		end
	else
		local xnum = hudinfo[HUD_SCORENUM].x+hideoffset+layout_opt.xoffset_scorenum+layout_opt.xoffset_score
		local allign = layout_opt.scorenumalligment

		if easing_numbers and (p.score - score_numupdt) > 0 then
			score_numupdt = $ + (((p.score - score_numupdt)/4) or (score_numupdt > p.score and -1 or 1))
		else
			score_numupdt = p.score
		end

		if layout_opt.scoregraphic then
			local graphic = v.cachePatch(prefix..'TSCORE')
			local _x = hudinfo[HUD_SCORE].x+hideoffset+layout_opt.xoffset_score
			local _len = textlen(v, prefix..'TNUM', ''..score_numupdt, txtpadding)
			local threshold = _x + graphic.width + 1 + txtpadding + layout_opt.score_relative_leftbound

			if allign == "left" and threshold > xnum then
				xnum = $ + (threshold - xnum)
			elseif allign == "right" and threshold > (xnum - _len) then
				xnum = threshold
				allign = "left"
			end

			-- no debug
			v.draw(_x, hudinfo[HUD_SCORE].y+layout_opt.yoffset_score,
			graphic, layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
		end

		write(v, prefix..'TNUM',
		xnum*FU,
		(hudinfo[HUD_SCORENUM].y+layout_opt.yoffset_scorenum+layout_opt.yoffset_score)*FU,
		FU,
		score_numupdt,
		layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER,
		v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, txtpadding)
	end

	return true
end, "game", 1, 3)

--
local time_display_optcv = time_opt.cv
local time_display_settingscv = CV_FindVar("timerres")

local function gettimedisplay_cv()
	if time_display_optcv.value > 0 then
		return time_display_optcv.value - 1
	else
		return time_display_settingscv.value
	end
end

local SECONDSIZE 	= 60
local TICSTOSECOND 	= TICRATE
local TICSTOMINUTE 	= TICRATE * SECONDSIZE

HOOK("time", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if layouts[layout_val] and layouts[layout_val].time == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local time_display_settings = gettimedisplay_cv()
	local layout_opt = layouts[layout_val]

	local tics = max(p.realtime + (p.style_additionaltime or 0) - (p.styles_cutscenetime_prize or 0), 0)
	local countdown = false
	local show_tic = false

	-- tics recalculation
	if (gametyperules & GTR_TIMELIMIT) and timelimit then
		tics = max(60*timelimit*TICRATE - p.realtime, 0)
		countdown = true
	elseif mapheaderinfo[gamemap].countdown then
		tics = tonumber(mapheaderinfo[gamemap].countdown) - p.realtime
		countdown = true
	end

	-- time string formatting
	local time_string = ""

	if time_display_settings == 3 then
		time_string = tostring(tics)
		show_tic = true
	else
		local sect = (tics / TICSTOSECOND) % SECONDSIZE
		local mint = tics / TICSTOMINUTE

		if time_display_settings == 2 or time_display_settings == 1 then
			time_string = string.format("%d:%02d:%02d", mint, sect, G_TicsToCentiseconds(tics))
			show_tic = true
		else
			sect = (sect < 10 and '0'..sect or sect)
			time_string = mint..":"..sect
		end
	end

	if layout_opt.force_ticspos ~= nil then
		show_tic = layout_opt.force_ticspos
	end

	local hideoffset = layout_opt.time_move_dir*hidefull_offset_x

	local tics_xcor = hudinfo[show_tic and HUD_TICS or HUD_SECONDS].x+hideoffset+layout_opt.xoffset_time+layout_opt.xoffset_timenum

	-- drawing
	if countdown and tics < 10*TICRATE and (leveltime % red_flashing_timer)/red_flashing_thred then
		local allign = layout_opt.timenumalligment

		if layout_opt.timegraphic then
			local graphic = v.cachePatch(prefix..'TRTIME')
			local graphic_x = hudinfo[HUD_TIME].x+hideoffset+layout_opt.xoffset_time
			local _len = textlen(v, prefix..'TNUM', time_string, txtpadding)
			local threshold = graphic_x + graphic.width + 1 + txtpadding + layout_opt.time_relative_leftbound

			if allign == "left" and threshold > tics_xcor then
				tics_xcor = $ + (threshold - tics_xcor)
			elseif allign == "right" and threshold > (tics_xcor - _len) then
				tics_xcor = threshold
				allign = "left"
			end

			v.draw(graphic_x, (hudinfo[HUD_TIME].y+layout_opt.yoffset_time),
			graphic, layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.time))
		end

		if prefix == "KC" then
			write(v, prefix..'RNUM', tics_xcor*FU, (hudinfo[HUD_SECONDS].y+layout_opt.yoffset_time+layout_opt.yoffset_timenum)*FU, FU, time_string,
			layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.timenumalligment, txtpadding)
		else
			write(v, prefix..'TNUM', tics_xcor*FU, (hudinfo[HUD_SECONDS].y+layout_opt.yoffset_time+layout_opt.yoffset_timenum)*FU, FU, time_string, layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER,
			v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, txtpadding)
		end
	else
		local allign = layout_opt.timenumalligment

		if layout_opt.timegraphic then
			local graphic = v.cachePatch(prefix..'TTIME')
			local graphic_x = hudinfo[HUD_TIME].x+hideoffset+layout_opt.xoffset_time
			local _len = textlen(v, prefix..'TNUM', time_string, txtpadding)
			local threshold = graphic_x + graphic.width + 1 + txtpadding + layout_opt.time_relative_leftbound

			if allign == "left" and threshold > tics_xcor then
				tics_xcor = $ + (threshold - tics_xcor)
			elseif allign == "right" and threshold > (tics_xcor - _len) then
				tics_xcor = threshold
				allign = "left"
			end

			v.draw(graphic_x, hudinfo[HUD_TIME].y+layout_opt.yoffset_time,
			graphic, layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.time))
		end

		write(v, prefix..'TNUM', tics_xcor*FU, (hudinfo[HUD_SECONDS].y+layout_opt.yoffset_time+layout_opt.yoffset_timenum)*FU, FU,
		time_string, layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, txtpadding)
	end

	return true
end, "game", 1, 3)

local rings_numupdt = 0

HOOK("rings", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if layouts[layout_val] and layouts[layout_val].rings == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local time_display_settings = gettimedisplay_cv()
	local layout_opt = layouts[layout_val]

	local hideoffset = layout_opt.rings_move_dir*hidefull_offset_x

	local option = layout_val > 1 and hudinfo[HUD_RINGSNUM].x or (time_display_settings > 1 and hudinfo[HUD_RINGSNUMTICS].x or hudinfo[HUD_RINGSNUM].x)

	local x_num = option + hideoffset + layout_opt.xoffset_rings + layout_opt.xoffset_ringsnum

	if easing_numbers and (p.rings - rings_numupdt) > 0 then
		rings_numupdt = $ + (((p.rings - rings_numupdt)/4) or (rings_numupdt > p.rings and -1 or 1))
	else
		rings_numupdt = p.rings
	end

	local rings_str = rings_numupdt .. (allring_counter.value and ("/" .. calc_help.totalcoinnum) or "")

	if p.rings < 1 and (leveltime % red_flashing_timer)/red_flashing_thred then
		local num_font = prefix == "KC" and prefix..'RNUM' or prefix..'TNUM'
		local allign = layout_opt.ringsnumalligment

		if layout_opt.ringsgraphic then
			local graphic = v.cachePatch(layout_opt.redringsgraphiccustom or (prefix..((mariomode and prefix ~= "ST") and 'TRCOIN' or 'TRRING')))
			local graphic_x = hudinfo[HUD_RINGS].x + hideoffset + layout_opt.xoffset_rings
			local threshold = graphic_x + graphic.width + 1 + txtpadding + layout_opt.rings_relative_leftbound

			local _len = textlen(v, num_font, rings_str, txtpadding)

			if allign == "left" and threshold > x_num then
				x_num = $ + (threshold - x_num)
			elseif allign == "right" and threshold > (x_num - _len) then
				x_num = threshold
				allign = "left"
			end

			v.draw(graphic_x, hudinfo[HUD_RINGS].y + layout_opt.yoffset_rings,
			graphic, layout_opt.ringsflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.rings))
		end

		write(v, num_font, x_num*FU, (hudinfo[HUD_RINGSNUM].y + layout_opt.yoffset_rings + layout_opt.yoffset_ringsnum)*FU, FU, rings_str,
		layout_opt.ringsflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, txtpadding, layout_opt.rings_padds_numb, layout_opt.rings_padds_symb)
	else
		local allign = layout_opt.ringsnumalligment

		if layout_opt.ringsgraphic then
			local graphic = v.cachePatch(layout_opt.ringsgraphiccustom or (prefix..((mariomode and prefix ~= "ST") and 'TCOINS' or 'TRINGS')))
			local graphic_x = hudinfo[HUD_RINGS].x + hideoffset + layout_opt.xoffset_rings
			local threshold = graphic_x + graphic.width + 1 + txtpadding + layout_opt.rings_relative_leftbound

			local _len = textlen(v, prefix..'TNUM', rings_str, txtpadding)

			if allign == "left" and threshold > x_num then
				x_num = $ + (threshold - x_num)
			elseif allign == "right" and threshold > (x_num - _len) then
				x_num = threshold
				allign = "left"
			end

			v.draw(graphic_x, hudinfo[HUD_RINGS].y + layout_opt.yoffset_rings,
			graphic, layout_opt.ringsflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.rings))
		end

		write(v, prefix..'TNUM', x_num*FU, (hudinfo[HUD_RINGSNUM].y + layout_opt.yoffset_rings + layout_opt.yoffset_ringsnum)*FU,
		FU, rings_str, layout_opt.ringsflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, txtpadding, layout_opt.rings_padds_numb, layout_opt.rings_padds_symb)
	end

	return true
end, "game", 1, 3)

--#endregion

--#region NIGHTS

local booster_anim = {
	"NIGHTS_BOOST_ANIM1",
	"NIGHTS_BOOST_ANIM2",
	"NIGHTS_BOOST_ANIM3",
	"NIGHTS_BOOST_ANIM3",
	"NIGHTS_BOOST_ANIM4",
	"NIGHTS_BOOST_ANIM4",
	"NIGHTS_BOOST_ANIM3",
	"NIGHTS_BOOST_ANIM3",
	"NIGHTS_BOOST_ANIM1",
}

local nights_boost_lastreg = 0
local nights_boost_tics = 0
local nights_boost_scale = 0

HOOK("nightsdrill", "classichud", function(v, stplyr)
	if stplyr.powers[pw_carry] == CR_NIGHTSMODE then
		local locx, locy = 16, 180;
		local sca = FU + abs(sin((nights_boost_scale * 360 * FU) / #booster_anim)) / 4

		if stplyr.drillmeter ~= nights_boost_lastreg and not nights_boost_tics then
			if stplyr.drillmeter > nights_boost_lastreg then
				nights_boost_scale = #booster_anim
			end

			nights_boost_tics = #booster_anim
			nights_boost_lastreg = stplyr.drillmeter
		end

		local fillpatch = v.getColormap(TC_DEFAULT, 0, booster_anim[nights_boost_tics])

		v.drawScaled(locx * sca, locy * sca, sca, v.cachePatch("DRILLBAR"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_HUDTRANS, fillpatch);
		for dfill = 0, 96 do
			if not (dfill < stplyr.drillmeter / 20 and dfill < 96) then break end

			v.drawScaled((locx + 2 + dfill)*sca, (locy + 3)*sca, sca, v.cachePatch("DRILLFI1"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_HUDTRANS, fillpatch);
		end

		if nights_boost_tics then
			nights_boost_tics = $ - 1
		end

		if nights_boost_scale then
			nights_boost_scale = $ - 1
		end
	end
end, "game", 1, 3)

local function P_GetNextEmerald()
	if (gamemap >= sstage_start and gamemap <= sstage_end) then
		return (gamemap - sstage_start);
	end

	if (gamemap >= smpstage_start or gamemap <= smpstage_end) then
		return (gamemap - smpstage_start);
	end

	return 0;
end

---@param v videolib
HOOK("nightsrings", "classichud", function(v, stplyr)
	if not ((maptol & TOL_NIGHTS) or G_IsSpecialStage(gamemap)) then return end

	local ssspheres = mapheaderinfo[gamemap].ssspheres

	local isspecialstage = G_IsSpecialStage(gamemap)
	local oldspecialstage = (isspecialstage and not (maptol & TOL_NIGHTS));

	local total_spherecount = 0;
	local total_ringcount = 0;

	local nights_colormap = v.getColormap(TC_DEFAULT, 0, nightscolor_opt())

	v.draw(16, 8, v.cachePatch("NBRACKET"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);

	if (isspecialstage) then
		v.draw(24, 16,
		((stplyr.bonustime and (leveltime & 4) and (states[S_BLUESPHEREBONUS].frame & FF_ANIMATE)) and v.cachePatch("NSSBON") or v.cachePatch("NSSHUD")),
		V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP);
	else
		v.draw(24, 16, (((stplyr.bonustime) and v.cachePatch("NSSBON") or v.cachePatch("NSSHUD"))+((leveltime/2)%12)), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP);
	end

	if (isspecialstage) then
		total_spherecount = 0;
		total_ringcount = 0

		for i = 0, #players-1 do
			if (not players[i]) then
				continue;
			end

			total_spherecount = $ + players[i].spheres;
			total_ringcount = $ + players[i].rings;
		end
	else
		total_spherecount = stplyr.spheres;
		total_ringcount = stplyr.spheres;
	end

	if (stplyr.capsule and stplyr.capsule.valid) then
		local amount;
		local length = 88;

		local origamount = stplyr.capsule.spawnpoint.args[1];

		v.draw(72, 8, v.cachePatch("NBRACKET"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);
		v.draw(74, 12, v.cachePatch("MINICAPS"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP);

		if (stplyr.capsule.reactiontime ~= 0) then

			local orblength = 20;

			for r = 0, 5 do
				v.draw(230 - (7*r), 144, v.cachePatch("REDSTAT"), V_PERPLAYER|V_HUDTRANS);
				v.draw(188 - (7*r), 144, v.cachePatch("ORNGSTAT"), V_PERPLAYER|V_HUDTRANS);
				v.draw(146 - (7*r), 144, v.cachePatch("YELSTAT"), V_PERPLAYER|V_HUDTRANS);
				v.draw(104 - (7*r), 144, v.cachePatch("BYELSTAT"), V_PERPLAYER|V_HUDTRANS);
			end

			amount = (origamount - stplyr.capsule.health);
			amount = (amount * orblength)/origamount;

			if (amount > 0) then
				local t;

				-- Fill up the bar with blue orbs... in reverse! (yuck)
				for r = amount, 0, -1 do
					t = r;

					if (r > 15) then t = $ + 1 end;
					if (r > 10) then t = $ + 1 end;
					if (r > 5) then t = $ + 1 end;

					v.draw(69 + (7*t), 144, v.cachePatch("BLUESTAT"), V_PERPLAYER|V_HUDTRANS);
				end
			end
		else
			-- Lil' white box!
			v.draw(15, 42, v.cachePatch("CAPSBAR"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS);

			amount = (origamount - stplyr.capsule.health);
			amount = (amount * length)/origamount;

			for cfill = 0, min(amount, length) do
				v.draw(16 + cfill, 43, v.cachePatch("CAPSFILL"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS, nights_colormap);
			end
		end

		if (total_spherecount >= stplyr.capsule.health) then
			v.draw(40, 13, v.cachePatch("NREDAR"..((leveltime&7) + 1)), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);
		else
			v.draw(40, 13, v.cachePatch("NARROW"..(((leveltime/2)&7) + 1)), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);
		end

	elseif (oldspecialstage and total_spherecount < ssspheres) then

		local length = 88;
		local amount = (total_spherecount * length)/ssspheres;

		local em = P_GetNextEmerald();
		v.draw(72, 8, v.cachePatch("NBRACKET"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);

		local sprite = Options:getPureValue("emeralds")

		if (em <= 6) then
			v.draw(88, 32, v.getSpritePatch(sprite, em, 0, 0), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP);
		end

		v.draw(40, 8 + 5, v.cachePatch("NARROW"..(((leveltime/2)&7)) + 1), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);

		-- Lil' white box!
		v.draw(15, 8 + 34, v.cachePatch("CAPSBAR"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS);

		for cfill = 0, min(amount, length) do
			v.draw(15 + cfill + 1, 8 + 35, v.cachePatch("CAPSFILL"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS);
		end
	else
		v.draw(40, 8 + 5, v.cachePatch("NARROW8"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);
	end

	if (oldspecialstage) then

		-- invert for s3k style junk
		total_spherecount = ssspheres - total_spherecount;
		if (total_spherecount < 0) then
			total_spherecount = 0;
		end

		if (calc_help.totalcoinnum > 0) then -- don't count down if there ISN'T a valid maximum number of rings, like sonic 3
			total_ringcount = calc_help.totalcoinnum - total_ringcount;
			if (total_ringcount < 0) then
				total_ringcount = 0;
			end
		end

		-- now rings! you know, for that perfect bonus.
		v.draw(272, 8, v.cachePatch("NBRACKET"), V_PERPLAYER|V_SNAPTOTOP|V_SNAPTORIGHT|V_HUDTRANS, nights_colormap);
		v.draw(280, 17, v.cachePatch("NRNG1"), V_PERPLAYER|V_SNAPTOTOP|V_SNAPTORIGHT|V_HUDTRANS);
		v.draw(280, 13, v.cachePatch("NARROW"..(((leveltime/2)&7) + 1)), V_FLIP|V_PERPLAYER|V_SNAPTOTOP|V_SNAPTORIGHT|V_HUDTRANS, nights_colormap);

		write(v, prefix..'TNUM', 262*FU, 18*FU, FU, total_ringcount, V_PERPLAYER|V_SNAPTOTOP|V_SNAPTORIGHT|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "center", txtpadding)
	end

	write(v, prefix..'TNUM', 60*FU, 18*FU, FU, total_spherecount, V_PERPLAYER|V_SNAPTOTOP|V_SNAPTOLEFT|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "center", txtpadding)


end, "game", 1, 3)

--#endregion

--#region UTILITIES

HOOK("styles_hudhide_manager", "classichud", function(v, p, t, e)
	if p.teamsprings_scenethread and p.teamsprings_scenethread.valid then
		Styles_HideHud()
	end

	if hud_hide_cv.value then
		if styles_hide_hud then
			if hide_offset_x > -160 then
				hide_offset_x = $-10
			elseif hide_offset_x < -160 then
				hide_offset_x = -160
			end

			if styles_hide_fullhud then
				hidefull_offset_x = hide_offset_x
			else
				hidefull_offset_x = 0
			end

			styles_hide_hud = false
			styles_hide_fullhud = false
		else
			if hide_offset_x < 0 then
				hide_offset_x = $+10
			elseif hide_offset_x > 0 then
				hide_offset_x = 0
			end

			if hidefull_offset_x then
				hidefull_offset_x = hide_offset_x
			else
				hidefull_offset_x = 0
			end
		end
	else
		hide_offset_x = 0
		hidefull_offset_x = 0
	end
	return true
end, "game", 1, 3)

rawset(_G, "Styles_HideHud", function()
	styles_hide_hud = true
	styles_hide_fullhud = true
end)

--#endregion

--#region INTERMISSIONS

HOOK("styles_levelendtally", "classichud", function(v, p, t, e)
	if not p.exiting then return end
	if p == secondarydisplayplayer then return end

	if hud_hide_cv.value == 1
	or hud_hide_cv.value == 3 then
		styles_hide_hud = true
	end

	-- Background stuff
	local specialstage_delay = 0
	local specialstage_togg = G_IsSpecialStage(gamemap)

	if p.styles_tallytimer ~= nil and specialstage_togg then
		local timerfade = 15+min(p.styles_tallytimer+80, 0)
		if timerfade == 15 then
			v.fadeScreen(0, 10)
		else
			v.fadeScreen(0xFB00, max(min(timerfade*31/15, 31), 0))
		end

		specialstage_delay = 20
	end

	-- Fake Calculations
	if p.styles_tallytimer and p.styles_tallytimer == -93 then
		fake_timebonus = calc_help.Y_GetTimeBonus(max(p.realtime + (p.style_additionaltime or 0) - (p.styles_cutscenetime_prize or 0), 0))
		fake_ringbonus = calc_help.Y_GetRingsBonus(p.rings)
		fake_nightsbonus = p.totalmarescore
		fake_perfect = calc_help.Y_GetPreCalcPerfectBonus(p.rings)
		true_totalbonus = fake_timebonus+fake_ringbonus+fake_perfect
		if p.mo then
			cached_tallyskincolor = v.getColormap(p.mo.skin, p.mo.color)
		else
			cached_tallyskincolor = v.getColormap(TC_DEFAULT, p.skincolor)
		end
	end

	if p.styles_tallytimer and p.styles_tallytimer > 0 then
		if (maptol & TOL_NIGHTS) then
			if fake_nightsbonus then
				fake_nightsbonus = $-222
				if fake_nightsbonus < 0 then
					fake_nightsbonus = 0
				end

				if not (p.styles_tallytimer % 3) then
					S_StartSound(nil, sfx_ptally, p)
				end
			end
		elseif G_IsSpecialStage(gamemap) then
			if fake_ringbonus then
				fake_ringbonus = $-222
				if fake_ringbonus < 0 then
					fake_ringbonus = 0
				end

				if not (p.styles_tallytimer % 3) then
					S_StartSound(nil, sfx_ptally, p)
				end
			end
		else
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

			if fake_perfect > 0 and not fake_ringbonus then
				fake_perfect = $-222
				if fake_perfect < 0 then
					fake_perfect = 0
				end

				if not (p.styles_tallytimer % 3) then
					S_StartSound(nil, sfx_ptally, p)
				end
			end
		end

		if p.styles_tallytimer == p.styles_tallyfakecounttimer+1 then
			fake_timebonus = 0
			fake_ringbonus = 0
			fake_nightsbonus = 0

			if fake_perfect > 0 then
				fake_perfect = 0
			end

			S_StartSound(nil, sfx_chchng, p)
		end
	end

	-- Display
	if p.styles_tallytimer ~= nil then
		local specialstage_delay = 0
		local specialstage_togg = G_IsSpecialStage(gamemap)

		local timed = p.styles_tallytimer+specialstage_delay
		local timerwentpast = 24*min(max(p.styles_tallytimer - (p.styles_tallyendtime + TICRATE/8), 0), 80)

		tally_totalcalculation = true_totalbonus-fake_timebonus-fake_ringbonus-fake_perfect
		local tally_title  = min((timed+89)*24, 0) 		- timerwentpast
		local tally_x_row1 = 80-min((timed+64)*24, 0) 	- timerwentpast
		local tally_x_row2 = 80-min((timed+69)*24, 0) 	- timerwentpast
		local tally_x_row3 = 80-min((timed+74)*24, 0) 	- timerwentpast
		local tally_x_row4 = 80-min((timed+79)*24, 0) 	- timerwentpast
		local tally_x_row5 = 80-min((timed+84)*24, 0) 	- timerwentpast

		if specialstage_togg then
			local color = v.getColormap(TC_DEFAULT, SKINCOLOR_YELLOW)
			local color2 = tallyrecoloring and v.getColormap(TC_DEFAULT, 0, tallyrecoloring) or v.getColormap(TC_DEFAULT, 1, color_profile.score)

			if titletype and hud_data[titletype].tallyspecialbg then
				hud_data[titletype].tallyspecialbg(v, p, tally_title, color, color2, 15+min(p.styles_tallytimer+80, 0))
			else
				hud_data[1].tallyspecialbg(v, p, tally_title, color, color2, timerfade)
			end

			if titletype and hud_data[titletype].tallyspecial then
				hud_data[titletype].tallyspecial(v, p, tally_title, color, color2)
			else
				hud_data[1].tallyspecial(v, p, tally_title, color, color2)
			end

			if (timed % 2) then
				for i = 1, 7 do
					if emeralds & emeralds_set[i] then
						v.draw(50+i*30, 120, v.getSpritePatch(Options:getvalue("emeralds")[2], i-1, 0, 0), 0)
					end
				end
			end

			v.draw(tally_x_row2+160, 140, v.cachePatch(prefix..'TBICONNUM'))
			v.draw(tally_x_row2+29, 139, v.cachePatch(prefix..'TBICON'), 0, color)
			v.draw(tally_x_row2, 140, v.cachePatch(prefix..'TTSCORE'), 0, color2)

			write(v, prefix..'TNUM', (tally_x_row2+160)*FU, 140*FU, FU, p.score, 0, color2, "right", txtpadding)

			if (maptol & TOL_NIGHTS) then
				v.draw(tally_x_row3+160, 156, v.cachePatch(prefix..'TBICONNUM'))

				v.draw(tally_x_row3+86, 155, v.cachePatch(prefix..'TBICON'), 0, color)
				v.draw(tally_x_row3, 156, v.cachePatch(prefix..'TNIGHTS'), 0, color2)
				v.draw(tally_x_row3+56, 156, v.cachePatch(prefix..'TBONUS'), 0, color2)

				write(v, prefix..'TNUM', (tally_x_row3+160)*FU, 156*FU, FU, fake_nightsbonus, 0, color2, "right", txtpadding)
			else
				local RINGS = mariomode and 'TCOIN' or 'TRING'

				v.draw(tally_x_row3+160, 156, v.cachePatch(prefix..'TBICONNUM'))

				v.draw(tally_x_row3+70, 155, v.cachePatch(prefix..'TBICON'), 0, color)
				v.draw(tally_x_row3, 156, v.cachePatch(prefix..RINGS), 0, color2)
				v.draw(tally_x_row3+40, 156, v.cachePatch(prefix..'TBONUS'), 0, color2)

				write(v, prefix..'TNUM', (tally_x_row3+160)*FU, 156*FU, FU, fake_ringbonus, 0, color2, "right", txtpadding)
			end
		else
			if titletype and hud_data[titletype].tallybg then
				hud_data[titletype].tallybg(v, p, tally_title, color, color2, 15+min(p.styles_tallytimer+80, 0))
			else
				hud_data[1].tallybg(v, p, tally_title, color, color2, timerfade)
			end

			if titletype and hud_data[titletype].tallytitle then
				hud_data[titletype].tallytitle(v, p, tally_title, cached_tallyskincolor, force_usernameinhud.value and p.name or nil)
			else
				hud_data[1].tallytitle(v, p, tally_title, cached_tallyskincolor, force_usernameinhud.value and p.name or nil)
			end

			local RINGS = mariomode and 'TCOIN' or 'TRING'

			v.draw(tally_x_row4+70, 107, v.cachePatch(prefix..'TBICON'), 0, cached_tallyskincolor)
			v.draw(tally_x_row3+70, 123, v.cachePatch(prefix..'TBICON'), 0, cached_tallyskincolor)

			v.draw(tally_x_row4, 108, v.cachePatch(prefix..'TTTIME'), 0, v.getColormap(TC_DEFAULT, 1, color_profile.time))
			v.draw(tally_x_row3, 124, v.cachePatch(prefix..RINGS), 0, v.getColormap(TC_DEFAULT, 1, color_profile.rings))

			v.draw(tally_x_row4+40, 108, v.cachePatch(prefix..'TBONUS'), 0, v.getColormap(TC_DEFAULT, 1, color_profile.score))
			v.draw(tally_x_row3+40, 124, v.cachePatch(prefix..'TBONUS'), 0, v.getColormap(TC_DEFAULT, 1, color_profile.score))

			v.draw(tally_x_row4+160, 108, v.cachePatch(prefix..'TBICONNUM'))
			v.draw(tally_x_row3+160, 124, v.cachePatch(prefix..'TBICONNUM'))

			write(v, prefix..'TNUM', (tally_x_row4+160)*FU, 108*FU, FU, fake_timebonus, 0, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", txtpadding)
			write(v, prefix..'TNUM', (tally_x_row3+160)*FU, 124*FU, FU, fake_ringbonus, 0, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", txtpadding)

			-- Perfect Bleh
			if fake_perfect > -1 then
				v.draw(tally_x_row2+82, 139, v.cachePatch(prefix..'TBICON'), 0, cached_tallyskincolor)
				v.draw(tally_x_row2-12, 140, v.cachePatch(prefix..'TPERFC'), 0, v.getColormap(TC_DEFAULT, 1, color_profile.score))
				v.draw(tally_x_row2+52, 140, v.cachePatch(prefix..'TBONUS'), 0, v.getColormap(TC_DEFAULT, 1, color_profile.score))
				v.draw(tally_x_row2+160, 140, v.cachePatch(prefix..'TBICONNUM'))

				write(v, prefix..'TNUM', (tally_x_row2+160)*FU, 140*FU, FU, fake_perfect, 0, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", txtpadding)
			end

			local mania_move = hud_select == 6 and 22 or 0

			-- Total vs Score nonsense
			if hud_select > 1 and not hud_select ~= 3 then
				v.draw(tally_x_row1+50, 155, v.cachePatch(prefix..'TBICON'), 0, cached_tallyskincolor)
				v.draw(tally_x_row1+21, 156, v.cachePatch(prefix..'TTOTAL'), 0, v.getColormap(TC_DEFAULT, 1, color_profile.score))
				v.draw(tally_x_row1+160-mania_move, 156, v.cachePatch(prefix..'TBICONNUM'))
				write(v, prefix..'TNUM', (tally_x_row1+160-mania_move)*FU, 156*FU, FU, tally_totalcalculation, 0, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", txtpadding)
			else
				v.draw(tally_x_row5+29, 91, v.cachePatch(prefix..'TBICON'), 0, cached_tallyskincolor)
				v.draw(tally_x_row5, 92, v.cachePatch(prefix..'TTSCORE'), 0, v.getColormap(TC_DEFAULT, 1, color_profile.score))
				v.draw(tally_x_row5+160, 92, v.cachePatch(prefix..'TBICONNUM'))
				write(v, prefix..'TNUM', (tally_x_row5+160)*FU, 92*FU, FU, p.score, 0, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", txtpadding)
			end
		end
	end

	if p.styles_tallytimer and (p.styles_tallytimer < 0) then
		tally_totalcalculation = 0
	end

	return true
end, "ingameintermission", 1, 3)

HOOK("stagetitle", "classichud", function(v, p, t, e)
	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	if p.styles_entercut or (p.teamsprings_scenethread and p.teamsprings_scenethread.valid)
	or p.styles_entercut_timer ~= nil or p.styles_entercut_etimer ~= nil then
		v.fadeScreen(31, max(5 - leveltime, 0) * 2)

		return
	end

	local exists = min(titletype, 4)

	if hud_data[titletype].titlecard then
		exists = titletype
	end

	if hud_hide_cv.value > 1 then
		local check = hud_data[exists].titlecard(v, p, t, e, fade_cv.value > 0)

		if check then
			styles_hide_hud = true
			styles_hide_fullhud = true
		end
	else
		hud_data[exists].titlecard(v, p, t, e, fade_cv.value > 0)
	end

	return true
end, "titlecard", 1, 3)

---@param v videolib
HOOK("stylesingame_stagetitle", "classichud", function(v, p)
	if p.styles_entercut_timer == nil or p.styles_entercut_etimer == nil then
		return
	end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local exists = min(titletype, 4)

	if hud_data[titletype].titlecard then
		exists = titletype
	end

	if hud_hide_cv.value > 1 then
		local check = hud_data[exists].titlecard(v, p, p.styles_entercut_timer, p.styles_entercut_etimer, fade_cv.value > 0)

		if check then
			styles_hide_hud = true
			styles_hide_fullhud = true
		end
	else
		hud_data[exists].titlecard(v, p, p.styles_entercut_timer, p.styles_entercut_etimer, fade_cv.value > 0)
	end

	return true
end, "ingameintermission", 4, 3)

--#endregion

--#region EMERALDS

HOOK("powerstones", "classichud", function(v, p, t, e)
	if not p.powers[pw_emeralds] then return end

	for i = 1, 7 do
		local em = emeralds_set[i]
		if (p.powers[pw_emeralds] & em) then
			v.draw(128 + (i-1) * 10, 192, v.cachePatch("TEMER"..i), V_SNAPTOBOTTOM)
		end
	end
end, "game", 1, 3)


HOOK("coopemeralds", "classichud", function(v)
	if multiplayer then return end

	if mrce then
		return
	end

	local sprite = Options:getPureValue("emeralds")

	local cv = emeraldpos_opt.cv
	local num = cv.value

	local animcv = emeraldanim_opt.cv
	local val = animcv.value or 1

	if (val == 2 and ((leveltime % 8)/4)) or val ~= 2 then
		local colormap = v.getColormap(TC_DEFAULT, 0, val > 2
		and ("RETROENGINE_CLASSICEM_ANIM" .. min(abs((leveltime/2 % 7) - 4) + 1, 4)) or nil)

		if num == 2 then -- final demo
			for i = 1, 7 do
				if emeralds & emeralds_set[i] then
					v.draw(50+i*30, 115, v.getSpritePatch(sprite, i-1, 0, 0), 0, colormap)
				end
			end
		else
			local BASEVIDWIDTH = 160
			local BASEVIDHEIGHT = 67
			local firstem = v.getSpritePatch(sprite, 0, 0, 0)

			local x = -firstem.width+firstem.leftoffset
			local y = -firstem.height+firstem.topoffset

			if (emeralds & EMERALD1) then
				v.draw(BASEVIDWIDTH-8-x, BASEVIDHEIGHT-32-y, firstem, 0, colormap)
			end

			if (emeralds & EMERALD2) then
				v.draw(BASEVIDWIDTH-8+24-x, BASEVIDHEIGHT-16-y, v.getSpritePatch(sprite, 1, 0, 0), 0, colormap)
			end

			if (emeralds & EMERALD3) then
				v.draw(BASEVIDWIDTH-8+24-x, BASEVIDHEIGHT+16-y, v.getSpritePatch(sprite, 2, 0, 0), 0, colormap)
			end

			if (emeralds & EMERALD4) then
				v.draw(BASEVIDWIDTH-8-x, BASEVIDHEIGHT+32-y, v.getSpritePatch(sprite, 3, 0, 0), 0, colormap)
			end

			if (emeralds & EMERALD5) then
				v.draw(BASEVIDWIDTH-8-24-x, BASEVIDHEIGHT+16-y, v.getSpritePatch(sprite, 4, 0, 0), 0, colormap)
			end

			if (emeralds & EMERALD6) then
				v.draw(BASEVIDWIDTH-8-24-x, BASEVIDHEIGHT-16-y, v.getSpritePatch(sprite, 5, 0, 0), 0, colormap)
			end

			if (emeralds & EMERALD7) then
				v.draw(BASEVIDWIDTH-8-x, BASEVIDHEIGHT-y, v.getSpritePatch(sprite, 6, 0, 0), 0, colormap)
			end
		end
	end

	return true
end, "scores", 1, 3)

local em_timer = 0

---@param v videolib
HOOK("intermissionemeralds", "classichud", function(v)
	if not (maptol & TOL_NIGHTS) then return end
	local sprite = Options:getPureValue("emeralds")
	local cv = emeraldanim_opt.cv
	local val = cv.value or 1

	if (val < 3 and em_timer/2) or val > 2 then
		local colormap = v.getColormap(TC_DEFAULT, 0, val > 2
		and ("RETROENGINE_CLASSICEM_ANIM" .. min(abs(em_timer/2 - 4) + 1, 4)) or nil)

		for i = 1, 7 do
			if emeralds & emeralds_set[i] then
				v.draw(50+i*30, 92, v.getSpritePatch(sprite, i-1, 0, 0), 0, colormap)
			end
		end
	end

	em_timer = (em_timer+1) % (val > 2 and 14 or 4)
	return true
end, "intermission", 1, 3)

--#endregion

--#region COLLECTIBLES

local emblemsprites = {
	[0] = "EMBVANILLA",
	[1] = "EMBCLASSIC",
	[2] = "EMBSONICR"
}

HOOK("tabemblems", "classichud", function(v)
	if menu_toggle then return end
	local cv = Options:getCV("emblems")[1]
	local value = emblemsprites[cv and cv.value or 0] or "EMBVANILLA"
	local total = (numemblems or 0)+(numextraemblems or 0)

	if total < 1 then return end

	v.draw(253, 29, v.cachePatch(value), V_SNAPTORIGHT|V_SNAPTOTOP)

	write(v, 'LIFENUM', 280*FU, 30*FU, FU, emblems, V_SNAPTORIGHT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, 0, numberscolor_opt()), "left", 1)
	write(v, 'LIFENUM', 280*FU, 37*FU, FU, "/"..total, V_SNAPTORIGHT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, 0, numberscolor_opt()), "left", 1)
end, "scores", 1, 3)

local tokensprites = {
	[0] = "TOKVANILLA",
	[1] = "TOK3DBLAST",
	[2] = "TOKSONICR",
	[3] = "TOKORIGINS",
}

HOOK("tokens", "classichud", function(v)
	if menu_toggle then return end
	if not token then return end

	local cv = Options:getCV("tokensprite")[1]
	local value = tokensprites[cv and cv.value or 0] or "TOKVANILLA"

	v.draw(257, 48, v.cachePatch(value), V_SNAPTORIGHT|V_SNAPTOTOP)

	write(v, 'LIFENUM', 280*FU, 53*FU, FU, token, V_SNAPTORIGHT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, 0, numberscolor_opt()), "left", 1)
end, "scores", 1, 3)

--#endregion

HOOK("pause", "classichud", function(v)
	if not paused then return end

	v.draw(160, 100, v.cachePatch(prefix..'TPAUSE'), 0)
end, "game", 1, 3)

HOOK("gameover", "classichud", function(v, player)
	if not player.deadtimer then return end

	if not ((G_GametypeUsesLives() or ((gametyperules & (GTR_RACE|GTR_LIVES)) == GTR_RACE)) and player.lives <= 0) then return end

	local countdown = false
	local tics = 0

	-- tics recalculation
	if (gametyperules & GTR_TIMELIMIT) and timelimit then
		tics = max(60*timelimit*TICRATE - player.realtime, 0)
		countdown = true
	elseif mapheaderinfo[gamemap].countdown then
		tics = tonumber(mapheaderinfo[gamemap].countdown) - player.realtime
		countdown = true
	end

	local ease = ease.linear(min(player.deadtimer * FU / (gameovertics/3), FU), 500, 0)

	if countdown and tics < 2 then
		v.draw(160 - ease, 100, v.cachePatch(prefix..'TGOTIME'), 0)
	else
		v.draw(160 - ease, 100, v.cachePatch(prefix..'TGOGAME'), 0)
	end

	v.draw(160 + ease, 100, v.cachePatch(prefix..'TGOOVER'), 0)
end, "game", 1, 3)


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


		if menuactive or gamestate ~= GS_LEVEL then
			MENU_DISABLE()
		end

		if press_delay then
			press_delay = $-1
		end
	end
	return true
end, "game", 16, 3)

-- Fix return
addHook("PlayerThink", function(p)
	if menu_toggle then
		p.pflags = $|PF_FORCESTRAFE|PF_JUMPDOWN|PF_USEDOWN

		if offset_x > (menufin/2) then
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

		if musicprev then
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