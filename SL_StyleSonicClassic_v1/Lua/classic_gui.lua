--[[

	GUI Manager

Contributors: Skydusk
@Team Blue Spring 2022-2025

-- TODO: Make sure Menu is MP-Compatible

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local calc_help = tbsrequire 'helpers/c_inter'

local write = drawlib.draw
local textlen = drawlib.text_lenght
local HOOK = customhud.SetupItem

local FU = FU
local abs = abs
local tostring = tostring
local tonumber = tonumber

local hudcfg = 	tbsrequire('gui/hud_conf')
local hudvars = tbsrequire('gui/hud_vars')
local fonts = 	tbsrequire('gui/hud_fonts')

local color_profile = tbsrequire('gui/hud_colors')
local timeformat_opt = hudcfg.timeformat_opt
local force_usernameinhud = hudcfg.forceusername_cv
local totalring_counter = hudcfg.totalringcounter_cv
local debugcords_opt = hudcfg.debug_opt
local hudspecifics = hudcfg.hudspecifics

--
--	HUD Elements
--

--#region BASE GAMEPLAY

local red_flashing_timer = TICRATE/4
local red_flashing_thred = red_flashing_timer/2

HOOK("lives", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end
	if modeattacking then return end

	---@diagnostic disable-next-line
	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local life_pos = hudcfg.livespos
	local mo = p.realmo and p.realmo or p.mo
	local name = force_usernameinhud.value and p.name or nil

	if name == nil and mo and mo.valid and mo.skin
	and skins[mo.skin] and skins[mo.skin].name then
		name = hudcfg.livesnames[skins[mo.skin].name]
	end

	hudspecifics[hudcfg.livestype].lives(
		v, p, t, e, fonts.font, mo, hudvars.hide_offsetx,
		v.getColormap(TC_DEFAULT, 1, color_profile.lives),
		name,
		life_pos,
		v.getColormap(TC_DEFAULT, 1, color_profile.numbers)
	)
	return true
end, "game", 1, 3)

local score_numupdt = 0

HOOK("score", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	local mo = p.mo and p.mo or p.realmo
	if not mo then return end

	if hudcfg.currentlayout and hudcfg.currentlayout.score == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local layout_opt = hudcfg.currentlayout

	local hideoffset = layout_opt.score_move_dir*hudvars.hidefull_offsetx

	local debugmode = debugcords_opt()

	if debugmode then
		if layout_opt.scoregraphic then
			v.draw(hudinfo[HUD_SCORE].x+hideoffset+layout_opt.xoffset_score,
			hudinfo[HUD_SCORE].y+layout_opt.yoffset_score,
			v.cachePatch(fonts.font..'TSCODB'),
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

			write(v, fonts.debugfont..'DBM', xval*FU, (hudinfo[HUD_SCORE].y-1+layout_opt.yoffset_score)*FU, FU,
			string.upper(string.format("%04x%04x%04x", pvx, pvy, pvz)), layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.debugalligment)
			write(v, fonts.debugfont..'DBM', xval*FU, (hudinfo[HUD_SCORE].y+7+layout_opt.yoffset_score)*FU, FU,
			string.upper(string.format("%04x%04x%04x", cvx, cvy, cvz)), layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.debugalligment)
		else
			write(v, fonts.debugfont..'DBM', xval*FU, (hudinfo[HUD_SCORE].y-1+layout_opt.yoffset_score)*FU, FU,
			string.upper(string.format("%04x%04x", pvx, pvy)), layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.debugalligment)
			write(v, fonts.debugfont..'DBM', xval*FU, (hudinfo[HUD_SCORE].y+7+layout_opt.yoffset_score)*FU, FU,
			string.upper(string.format("%04x%04x", cvx, cvy)), layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.debugalligment)
		end
	else
		local xnum = hudinfo[HUD_SCORENUM].x+hideoffset+layout_opt.xoffset_scorenum+layout_opt.xoffset_score
		local allign = layout_opt.scorenumalligment

		if hudcfg.numbereasing and (p.score - score_numupdt) > 0 then
			score_numupdt = $ + (((p.score - score_numupdt)/4) or (score_numupdt > p.score and -1 or 1))
		else
			score_numupdt = p.score
		end

		if layout_opt.scoregraphic then
			local graphic = v.cachePatch(fonts.font..'TSCORE')
			local _x = hudinfo[HUD_SCORE].x+hideoffset+layout_opt.xoffset_score
			local _len = textlen(v, fonts.font..'TNUM', ''..score_numupdt, fonts.padding)
			local threshold = _x + graphic.width + 1 + fonts.padding + layout_opt.score_relative_leftbound

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

		write(v, fonts.font..'TNUM',
		xnum*FU,
		(hudinfo[HUD_SCORENUM].y+layout_opt.yoffset_scorenum+layout_opt.yoffset_score)*FU,
		FU,
		score_numupdt,
		layout_opt.scoreflags|V_HUDTRANS|V_PERPLAYER,
		v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, fonts.padding)
	end

	return true
end, "game", 1, 3)

local time_display_settingscv = CV_FindVar("timerres")

local function gettimedisplay_cv()
	if timeformat_opt:index() > 0 then
		return timeformat_opt:index() - 1
	else
		return time_display_settingscv.value
	end
end

local SECONDSIZE 	= 60
local TICSTOSECOND 	= TICRATE
local TICSTOMINUTE 	= TICRATE * SECONDSIZE

HOOK("time", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if hudcfg.currentlayout and hudcfg.currentlayout.time == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local time_display_settings = gettimedisplay_cv()
	local layout_opt = hudcfg.currentlayout

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

	local hideoffset = layout_opt.time_move_dir*hudvars.hidefull_offsetx

	local tics_xcor = hudinfo[show_tic and HUD_TICS or HUD_SECONDS].x+hideoffset+layout_opt.xoffset_time+layout_opt.xoffset_timenum

	-- drawing
	if countdown and tics < 10*TICRATE and (leveltime % red_flashing_timer)/red_flashing_thred then
		local allign = layout_opt.timenumalligment

		if layout_opt.timegraphic then
			local graphic = v.cachePatch(fonts.font..'TRTIME')
			local graphic_x = hudinfo[HUD_TIME].x+hideoffset+layout_opt.xoffset_time
			local _len = textlen(v, fonts.font..'TNUM', time_string, fonts.padding)
			local threshold = graphic_x + graphic.width + 1 + fonts.padding + layout_opt.time_relative_leftbound

			if allign == "left" and threshold > tics_xcor then
				tics_xcor = $ + (threshold - tics_xcor)
			elseif allign == "right" and threshold > (tics_xcor - _len) then
				tics_xcor = threshold
				allign = "left"
			end

			v.draw(graphic_x, (hudinfo[HUD_TIME].y+layout_opt.yoffset_time),
			graphic, layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.time))
		end

		if fonts.font == "KC" then
			write(v, fonts.font..'RNUM', tics_xcor*FU, (hudinfo[HUD_SECONDS].y+layout_opt.yoffset_time+layout_opt.yoffset_timenum)*FU, FU, time_string,
			layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), layout_opt.timenumalligment, fonts.padding)
		else
			write(v, fonts.font..'TNUM', tics_xcor*FU, (hudinfo[HUD_SECONDS].y+layout_opt.yoffset_time+layout_opt.yoffset_timenum)*FU, FU, time_string, layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER,
			v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, fonts.padding)
		end
	else
		local allign = layout_opt.timenumalligment

		if layout_opt.timegraphic then
			local graphic = v.cachePatch(fonts.font..'TTIME')
			local graphic_x = hudinfo[HUD_TIME].x+hideoffset+layout_opt.xoffset_time
			local _len = textlen(v, fonts.font..'TNUM', time_string, fonts.padding)
			local threshold = graphic_x + graphic.width + 1 + fonts.padding + layout_opt.time_relative_leftbound

			if allign == "left" and threshold > tics_xcor then
				tics_xcor = $ + (threshold - tics_xcor)
			elseif allign == "right" and threshold > (tics_xcor - _len) then
				tics_xcor = threshold
				allign = "left"
			end

			v.draw(graphic_x, hudinfo[HUD_TIME].y+layout_opt.yoffset_time,
			graphic, layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.time))
		end

		write(v, fonts.font..'TNUM', tics_xcor*FU, (hudinfo[HUD_SECONDS].y+layout_opt.yoffset_time+layout_opt.yoffset_timenum)*FU, FU,
		time_string, layout_opt.timeflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, fonts.padding)
	end

	return true
end, "game", 1, 3)

local rings_numupdt = 0

HOOK("rings", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if hudcfg.currentlayout and hudcfg.currentlayout.rings == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local time_display_settings = gettimedisplay_cv()
	local layout_opt = hudcfg.currentlayout

	local hideoffset = layout_opt.rings_move_dir*hudvars.hidefull_offsetx

	local option = hudcfg.layoutindex > 1 and hudinfo[HUD_RINGSNUM].x or (time_display_settings > 1 and hudinfo[HUD_RINGSNUMTICS].x or hudinfo[HUD_RINGSNUM].x)

	local x_num = option + hideoffset + layout_opt.xoffset_rings + layout_opt.xoffset_ringsnum

	if hudcfg.numbereasing and (p.rings - rings_numupdt) > 0 then
		rings_numupdt = $ + (((p.rings - rings_numupdt)/4) or (rings_numupdt > p.rings and -1 or 1))
	else
		rings_numupdt = p.rings
	end

	local rings_str = rings_numupdt .. (totalring_counter.value and ("/" .. calc_help.totalcoinnum) or "")

	if p.rings < 1 and (leveltime % red_flashing_timer)/red_flashing_thred then
		local num_font = fonts.font == "KC" and fonts.font..'RNUM' or fonts.font..'TNUM'
		local allign = layout_opt.ringsnumalligment

		if layout_opt.ringsgraphic then
			local graphic = v.cachePatch(layout_opt.redringsgraphiccustom or (fonts.font..((mariomode and fonts.font ~= "ST") and 'TRCOIN' or 'TRRING')))
			local graphic_x = hudinfo[HUD_RINGS].x + hideoffset + layout_opt.xoffset_rings
			local threshold = graphic_x + graphic.width + 1 + fonts.padding + layout_opt.rings_relative_leftbound

			local _len = textlen(v, num_font, rings_str, fonts.padding)

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
		layout_opt.ringsflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, fonts.padding, layout_opt.rings_padds_numb, layout_opt.rings_padds_symb)
	else
		local allign = layout_opt.ringsnumalligment

		if layout_opt.ringsgraphic then
			local graphic = v.cachePatch(layout_opt.ringsgraphiccustom or (fonts.font..((mariomode and fonts.font ~= "ST") and 'TCOINS' or 'TRINGS')))
			local graphic_x = hudinfo[HUD_RINGS].x + hideoffset + layout_opt.xoffset_rings
			local threshold = graphic_x + graphic.width + 1 + fonts.padding + layout_opt.rings_relative_leftbound

			local _len = textlen(v, fonts.font..'TNUM', rings_str, fonts.padding)

			if allign == "left" and threshold > x_num then
				x_num = $ + (threshold - x_num)
			elseif allign == "right" and threshold > (x_num - _len) then
				x_num = threshold
				allign = "left"
			end

			v.draw(graphic_x, hudinfo[HUD_RINGS].y + layout_opt.yoffset_rings,
			graphic, layout_opt.ringsflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.rings))
		end

		write(v, fonts.font..'TNUM', x_num*FU, (hudinfo[HUD_RINGSNUM].y + layout_opt.yoffset_rings + layout_opt.yoffset_ringsnum)*FU,
		FU, rings_str, layout_opt.ringsflags|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), allign, fonts.padding, layout_opt.rings_padds_numb, layout_opt.rings_padds_symb)
	end

	return true
end, "game", 1, 3)

--#endregion

tbsrequire('gui/hud_nights')
tbsrequire('gui/hud_inter')
tbsrequire('gui/hud_misc')
tbsrequire('gui/hud_menu')
tbsrequire('gui/hud_comp')