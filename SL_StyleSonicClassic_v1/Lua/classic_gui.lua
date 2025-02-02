--[[

	GUI Manager

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]


local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local calc_help = tbsrequire 'helpers/c_inter'

local drawf = drawlib.draw
local fontlen = drawlib.lenght
local HOOK = customhud.SetupItem

local hud_select = 1
local lifeicon = 1
local tallytitleft = 1
local txtpadding = 0
local prefix = "S1"
local tallyft = "S1"
local debugft = "S1"

local menu_toggle = false

local get_emerald_sprite = CV_FindVar("classic_emeralds")

local emeralds_sprites = {
	SPR_CEMG,
	SPR_EMERALD_S2,
	SPR_EMERALD_CD,
	SPR_EMERALD_S3,
	SPR_EMERALD_MANIA,
}

--
--	External HUDs
--

local hud_data = {
	[1] = tbsrequire('gui/classic_sonic1'),
	[2] = tbsrequire('gui/classic_sonic2'),
	[3] = tbsrequire('gui/classic_soniccd'),
	[4] = tbsrequire('gui/classic_sonic3'),
	[5] = tbsrequire('gui/classic_blast3d'),
	[6] = tbsrequire('gui/classic_mania'),
	[7] = tbsrequire('gui/classic_xtreme'),
	[8] = tbsrequire('gui/classic_chaotix'),
}

--
--	COM
--

COM_AddCommand("classic_menu", function(p)
	if menu_toggle == nil then
		menu_toggle = true
	else
		menu_toggle = not (menu_toggle)
	end
end, COM_LOCAL)

--
--	CVARs
--

local layout_val = 1
local layouts = tbsrequire('gui/definitions/classic_layouts')

local layout_cv = CV_RegisterVar{
	name = "classic_hudlayout",
	defaultvalue = "classic",
	flags = CV_CALL,
	func = function(var)
		layout_val = var.value
	end,
	PossibleValue = {classic=1, bonus=2, blast3d=3}
}

local lif_cv = CV_RegisterVar{
	name = "classic_lifeicon",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		local set = {1, 3, 4, 5, 6, 7, 8}
		lifeicon = set[var.value]
	end,
	PossibleValue = {sonic1=1, soniccd=2, sonic3=3, blast3d=4, mania=5, xtreme=6, chaotix=7}
}

local fade_cv = CV_RegisterVar{
	name = "classic_bluefade",
	defaultvalue = "off",
	flags = 0,
	PossibleValue = {off = 0, tally = 1},
}

local font_cv = CV_RegisterVar{
	name = "classic_hudfont",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		local prefixes = {"S1", "ST", "CD", "S3", "3B", "MA", "XT", "KC"}
		prefix = prefixes[var.value]
		tallyft = prefix

		local paddingset = {0, 0, 0, 0, -1, -1, 0}
		txtpadding = paddingset[var.value]

		local debugprefixes = {"S1", "S1", "S1", "S3", "S3", "S3", "S3", "S3"}
		debugft = debugprefixes[var.value]

		local tallyfonts = {1, 2, 3, 4, 4, 6, 4, 4}
		tallytitleft = tallyfonts[var.value]

		if var.value > 4 then
			CV_Set(fade_cv, 1)
		else
			CV_Set(fade_cv, 0)
		end
	end,
	PossibleValue = {sonic1=1, sonic2=2, soniccd=3, sonic3=4, blast3d=5, mania=6, xtreme=7, chaotix=8}
}

local hud_cv = CV_RegisterVar{
	name = "classic_hud",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		local prefixes = {1, 2, 3, 4, 5, 6, 7, 8}
		CV_Set(font_cv, prefixes[var.value])

		local lives = {1, 1, 2, 3, 4, 5, 6, 7}
		CV_Set(lif_cv, lives[var.value])

		hud_select = var.value
	end,
	PossibleValue = {sonic1=1, sonic2=2, soniccd=3, sonic3=4, blast3d=5, mania=6, xtreme=7, chaotix=8}
}

local debugmode_coordinates = CV_RegisterVar{
	name = "classic_debug",
	defaultvalue = "0",
	flags = 0,
	PossibleValue = {off = 0, plane = 1, full = 2},
}

local hud_hide_cv = CV_RegisterVar{
	name = "classic_hidehudop",
	defaultvalue = "0",
	flags = 0,
	PossibleValue = {off = 0, tally = 1, title = 2, both = 3},
}

--
--	HUD Elements
--

local hide_offset_x = 0
local hidefull_offset_x = 0
local styles_hide_hud = false
local styles_hide_fullhud = false
local red_flashing_timer = TICRATE/4
local red_flashing_thred = red_flashing_timer/2

HOOK("lives", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end
	if modeattacking then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local mo = p.mo and p.mo or p.realmo
	hud_data[lifeicon].lives(v, p, t, e, prefix, mo, hide_offset_x)
	return true
end, "game")

local tally_totalcalculation = 0

HOOK("score", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	local mo = p.mo and p.mo or p.realmo
	if not mo then return end

	if layouts[layout_val] and layouts[layout_val].score == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local layout_opt = layouts[layout_val]

	if debugmode_coordinates.value then
		v.draw(hudinfo[HUD_SCORE].x+hidefull_offset_x+layout_opt.xoffset_score,
		hudinfo[HUD_SCORE].y+layout_opt.yoffset_score,
		v.cachePatch(prefix..'TSCODB'),
		hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER)

		-- Debug Mode
		local bitf = FRACUNIT
		local pvx, pvy = abs(mo.x/bitf)/4, abs(mo.y/bitf)/4
		local cvx, cvy = abs(t.x/bitf)/4, abs(t.y/bitf)/4

		local xval = hudinfo[HUD_SCORE].x+32+hidefull_offset_x+layout_opt.xoffset_score

		if debugmode_coordinates.value == 2 then
			local pvz, cvz = abs(mo.z/bitf)/4, abs(t.z/bitf)/4

			drawf(v, debugft..'DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y-1+layout_opt.yoffset_score)*FRACUNIT, FRACUNIT,
			string.upper(string.format("%04x%04x%04x", pvx, pvy, pvz)), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "left")
			drawf(v, debugft..'DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y+7+layout_opt.yoffset_score)*FRACUNIT, FRACUNIT,
			string.upper(string.format("%04x%04x%04x", cvx, cvy, cvz)), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "left")
		else
			drawf(v, debugft..'DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y-1+layout_opt.yoffset_score)*FRACUNIT, FRACUNIT,
			string.upper(string.format("%04x%04x", pvx, pvy)), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "left")
			drawf(v, debugft..'DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y+7+layout_opt.yoffset_score)*FRACUNIT, FRACUNIT,
			string.upper(string.format("%04x%04x", cvx, cvy)), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "left")
		end
	else
		-- no debug
		v.draw(hudinfo[HUD_SCORE].x+hidefull_offset_x+layout_opt.xoffset_score, hudinfo[HUD_SCORE].y+layout_opt.yoffset_score, v.cachePatch(prefix..'TSCORE'), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER)
		drawf(v, prefix..'TNUM',
		(hudinfo[HUD_SCORENUM].x+hidefull_offset_x+layout_opt.xoffset_scorenum+layout_opt.xoffset_score)*FRACUNIT,
		(hudinfo[HUD_SCORENUM].y+layout_opt.yoffset_scorenum+layout_opt.yoffset_score)*FRACUNIT,
		FRACUNIT,
		p.score,
		hudinfo[HUD_SCORENUM].f|V_HUDTRANS|V_PERPLAYER,
		v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
	end

	return true
end, "game")

local time_display_settings = CV_FindVar("timerres")

HOOK("time", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if layouts[layout_val] and layouts[layout_val].time == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local layout_opt = layouts[layout_val]

	local tics = p.realtime + (p.style_additionaltime or 0)
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

	if time_display_settings.value == 3 then
		time_string = tostring(tics)
		show_tic = true
	elseif time_display_settings.value == 2 or time_display_settings.value == 1 then
		local mint = G_TicsToMinutes(tics, true)
		local sect = G_TicsToSeconds(tics)
		local cent = G_TicsToCentiseconds(tics)
		sect = (sect < 10 and '0'..sect or sect)
		cent = (cent < 10 and '0'..cent or cent)

		time_string = mint..":"..sect.."."..cent

		show_tic = true
	else
		local mint = G_TicsToMinutes(tics, true)
		local sect = G_TicsToSeconds(tics)
		sect = (sect < 10 and '0'..sect or sect)

		time_string = mint..":"..sect
	end

	local tics_xcor = hudinfo[show_tic and HUD_TICS or HUD_SECONDS].x+hidefull_offset_x+layout_opt.xoffset_time+layout_opt.xoffset_timenum

	-- drawing
	if countdown and tics < 10*TICRATE and (leveltime % red_flashing_timer)/red_flashing_thred then
		v.draw(hudinfo[HUD_TIME].x+hidefull_offset_x+layout_opt.xoffset_time, (hudinfo[HUD_TIME].y+layout_opt.yoffset_time), v.cachePatch(prefix..'TRTIME'), hudinfo[HUD_TIME].f|V_HUDTRANS|V_PERPLAYER)
		if prefix == "KC" then
			drawf(v, prefix..'RNUM', tics_xcor*FRACUNIT, (hudinfo[HUD_SECONDS].y+layout_opt.yoffset_time+layout_opt.yoffset_timenum)*FRACUNIT, FRACUNIT, time_string, hudinfo[HUD_SECONDS].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
		else
			drawf(v, prefix..'TNUM', tics_xcor*FRACUNIT, hudinfo[HUD_SECONDS].y*FRACUNIT, FRACUNIT, time_string, hudinfo[HUD_SECONDS].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
		end
	else
		v.draw(hudinfo[HUD_TIME].x+hidefull_offset_x+layout_opt.xoffset_time, hudinfo[HUD_TIME].y+layout_opt.yoffset_time, v.cachePatch(prefix..'TTIME'), hudinfo[HUD_TIME].f|V_HUDTRANS|V_PERPLAYER)
		drawf(v, prefix..'TNUM', tics_xcor*FRACUNIT, (hudinfo[HUD_SECONDS].y+layout_opt.yoffset_time+layout_opt.yoffset_timenum)*FRACUNIT, FRACUNIT, time_string, hudinfo[HUD_SECONDS].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
	end

	return true
end, "game")

HOOK("rings", "classichud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end

	if layouts[layout_val] and layouts[layout_val].rings == false then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local layout_opt = layouts[layout_val]

	local option = layout_val > 1 and hudinfo[HUD_RINGSNUM].x or (time_display_settings.value > 1 and hudinfo[HUD_RINGSNUMTICS].x or hudinfo[HUD_RINGSNUM].x)

	local x_num = (option + hide_offset_x + layout_opt.xoffset_rings + layout_opt.xoffset_ringsnum)*FRACUNIT

	if p.rings < 1 and (leveltime % red_flashing_timer)/red_flashing_thred then
		v.draw(hudinfo[HUD_RINGS].x + hide_offset_x + layout_opt.xoffset_rings, hudinfo[HUD_RINGS].y + layout_opt.yoffset_rings, v.cachePatch(prefix..'TRRING'), hudinfo[HUD_RINGS].f|V_HUDTRANS|V_PERPLAYER)
		if prefix == "KC" then
			drawf(v, prefix..'RNUM', x_num, (hudinfo[HUD_RINGSNUM].y + layout_opt.yoffset_rings + layout_opt.yoffset_ringsnum)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGSNUM].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
		else
			drawf(v, prefix..'TNUM', x_num, (hudinfo[HUD_RINGSNUM].y + layout_opt.yoffset_rings + layout_opt.yoffset_ringsnum)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGSNUM].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
		end
	else
		v.draw(hudinfo[HUD_RINGS].x + hide_offset_x + layout_opt.xoffset_rings, hudinfo[HUD_RINGS].y + layout_opt.yoffset_rings, v.cachePatch(prefix..'TRINGS'), hudinfo[HUD_RINGS].f|V_HUDTRANS|V_PERPLAYER)
		drawf(v, prefix..'TNUM', x_num, (hudinfo[HUD_RINGSNUM].y + layout_opt.yoffset_rings + layout_opt.yoffset_ringsnum)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGSNUM].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
	end

	return true
end, "game")

HOOK("styles_hudhide_manager", "classichud", function(v, p, t, e)
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
end, "game")

local fake_timebonus = 0
local fake_ringbonus = 0
local fake_nightsbonus = 0
local fake_perfect = 0
local true_totalbonus = 0
local cached_tallyskincolor

local emeralds_set = {
	EMERALD1,
	EMERALD2,
	EMERALD3,
	EMERALD4,
	EMERALD5,
	EMERALD6,
	EMERALD7,
}


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
		fake_timebonus = calc_help.Y_GetTimeBonus(p.realtime)
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

		tally_totalcalculation = true_totalbonus-fake_timebonus-fake_ringbonus-fake_perfect
		local tally_x_row1 = 80-min((timed+64)*24, 0)
		local tally_x_row2 = 80-min((timed+69)*24, 0)
		local tally_x_row3 = 80-min((timed+74)*24, 0)
		local tally_x_row4 = 80-min((timed+79)*24, 0)
		local tally_x_row5 = 80-min((timed+84)*24, 0)

		if specialstage_togg then
			local color = v.getColormap(TC_DEFAULT, SKINCOLOR_YELLOW)
			local color2 = v.getColormap(TC_DEFAULT, 0, "SPECIALSTAGE_SONIC1_TALLY1")

			if tallytitleft and hud_data[tallytitleft].tallyspecialbg then
				hud_data[tallytitleft].tallyspecialbg(v, p, min((timed+89)*24, 0), color, color2, timerfade)
			else
				hud_data[1].tallyspecialbg(v, p, min((timed+89)*24, 0), color, color2, timerfade)
			end

			if tallytitleft and hud_data[tallytitleft].tallyspecial then
				hud_data[tallytitleft].tallyspecial(v, p, min((timed+89)*24, 0), color, color2)
			else
				hud_data[1].tallyspecial(v, p, min((timed+89)*24, 0), color, color2)
			end

			local sprite = emeralds_sprites[get_emerald_sprite.value]

			if (timed % 2) then
				for i = 1, 7 do
					if emeralds & emeralds_set[i] then
						v.draw(50+i*30, 120, v.getSpritePatch(sprite, i-1, 0, 0), 0)
					end
				end
			end

			v.draw(tally_x_row2+29, 139, v.cachePatch(tallyft..'TBICON'), 0, color)
			v.draw(tally_x_row2, 140, v.cachePatch(tallyft..'TTSCORE'), 0, color2)
			drawf(v, tallyft..'TNUM', (tally_x_row2+160)*FRACUNIT, 140*FRACUNIT, FRACUNIT, p.score, 0, color2, "right", txtpadding)

			if (maptol & TOL_NIGHTS) then
				v.draw(tally_x_row3+86, 155, v.cachePatch(tallyft..'TBICON'), 0, color)
				v.draw(tally_x_row3, 156, v.cachePatch(tallyft..'TNIGHTS'), 0, color2)
				v.draw(tally_x_row3+56, 156, v.cachePatch(tallyft..'TBONUS'), 0, color2)
				drawf(v, tallyft..'TNUM', (tally_x_row3+160)*FRACUNIT, 156*FRACUNIT, FRACUNIT, fake_nightsbonus, 0, color2, "right", txtpadding)
			else
				v.draw(tally_x_row3+70, 155, v.cachePatch(tallyft..'TBICON'), 0, color)
				v.draw(tally_x_row3, 156, v.cachePatch(tallyft..'TRING'), 0, color2)
				v.draw(tally_x_row3+40, 156, v.cachePatch(tallyft..'TBONUS'), 0, color2)
				drawf(v, tallyft..'TNUM', (tally_x_row3+160)*FRACUNIT, 156*FRACUNIT, FRACUNIT, fake_ringbonus, 0, color2, "right", txtpadding)
			end
		else
			if hud_data[tallytitleft].tallytitle then
				hud_data[tallytitleft].tallytitle(v, p, min((timed+89)*24, 0), cached_tallyskincolor)
			else
				hud_data[1].tallytitle(v, p, min((timed+89)*24, 0), cached_tallyskincolor)
			end


			v.draw(tally_x_row4+70, 107, v.cachePatch(tallyft..'TBICON'), 0, cached_tallyskincolor)
			v.draw(tally_x_row3+70, 123, v.cachePatch(tallyft..'TBICON'), 0, cached_tallyskincolor)

			v.draw(tally_x_row4, 108, v.cachePatch(tallyft..'TTTIME'))
			v.draw(tally_x_row3, 124, v.cachePatch(tallyft..'TRING'))

			v.draw(tally_x_row4+40, 108, v.cachePatch(tallyft..'TBONUS'))
			v.draw(tally_x_row3+40, 124, v.cachePatch(tallyft..'TBONUS'))

			drawf(v, tallyft..'TNUM', (tally_x_row4+160)*FRACUNIT, 108*FRACUNIT, FRACUNIT, fake_timebonus, 0, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
			drawf(v, tallyft..'TNUM', (tally_x_row3+160)*FRACUNIT, 124*FRACUNIT, FRACUNIT, fake_ringbonus, 0, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)

			-- Perfect Bleh
			if fake_perfect > -1 then
				v.draw(tally_x_row2+82, 139, v.cachePatch(tallyft..'TBICON'), 0, cached_tallyskincolor)
				v.draw(tally_x_row2-12, 140, v.cachePatch(tallyft..'TPERFC'))
				v.draw(tally_x_row2+52, 140, v.cachePatch(tallyft..'TBONUS'))

				drawf(v, tallyft..'TNUM', (tally_x_row2+160)*FRACUNIT, 140*FRACUNIT, FRACUNIT, fake_perfect, 0, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
			end

			-- Total vs Score nonsense
			if hud_select > 1 and not hud_select ~= 3 then
				v.draw(tally_x_row1+50, 155, v.cachePatch(tallyft..'TBICON'), 0, cached_tallyskincolor)
				v.draw(tally_x_row1+21, 156, v.cachePatch(tallyft..'TTOTAL'))
				drawf(v, tallyft..'TNUM', (tally_x_row1+160)*FRACUNIT, 156*FRACUNIT, FRACUNIT, tally_totalcalculation, 0, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
			else
				v.draw(tally_x_row5+29, 91, v.cachePatch(tallyft..'TBICON'), 0, cached_tallyskincolor)
				v.draw(tally_x_row5, 92, v.cachePatch(tallyft..'TTSCORE'))
				drawf(v, tallyft..'TNUM', (tally_x_row5+160)*FRACUNIT, 92*FRACUNIT, FRACUNIT, p.score, 0, v.getColormap(TC_DEFAULT, 1), "right", txtpadding)
			end
		end
	end

	if p.styles_tallytimer and (p.styles_tallytimer < 0) then
		tally_totalcalculation = 0
	end

	return true
end, "game")

HOOK("stagetitle", "classichud", function(v, p, t, e)
	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local exists = min(hud_select, 4)

	if hud_data[hud_select].titlecard then
		exists = hud_select
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
end, "titlecard")

HOOK("coopemeralds", "classichud", function(v)
	if multiplayer then return end

	if mrce then
		return
	end

	local sprite = emeralds_sprites[get_emerald_sprite.value]

	for i = 1, 7 do
		if emeralds & emeralds_set[i] then
			v.draw(50+i*30, 115, v.getSpritePatch(sprite, i-1, 0, 0), 0)
		end
	end

	return true
end, "scores")

local em_timer = 0

HOOK("intermissionemeralds", "classichud", function(v)
	if not (maptol & TOL_NIGHTS) then return end
	local sprite = emeralds_sprites[get_emerald_sprite.value]

	if em_timer/2 then
		for i = 1, 7 do
			if emeralds & emeralds_set[i] then
				v.draw(50+i*30, 92, v.getSpritePatch(sprite, i-1, 0, 0), 0)
			end
		end
	end

	em_timer = (em_timer+1) % 4
	return true
end, "intermission")

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
				if item.cv then
					drawf(v, 'S3DBM', x_off*FRACUNIT, (y+17)*FRACUNIT, FRACUNIT, string.upper(string.format("%02x", item.cv.value)), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 1), "center")
					v.drawString(x_off, y+28, "\x8C"..item.cv.string, V_SNAPTOLEFT, "center")
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

			if cmd.sidemove < -25 and classic_menu_vars[menu_select].cv then
				local cv = classic_menu_vars[menu_select].cv

				local value = cv.value-1
				if value < classic_menu_vars[menu_select].minv then
					value = classic_menu_vars[menu_select].maxv
				end

				CV_Set(cv, value)
				press_delay = 8

				S_StartSound(nil, sfx_menu1, p)
			end

			if cmd.sidemove > 25 and classic_menu_vars[menu_select].cv then
				local cv = classic_menu_vars[menu_select].cv

				local value = cv.value+1
				if value > classic_menu_vars[menu_select].maxv then
					value = classic_menu_vars[menu_select].minv
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