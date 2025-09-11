
local HOOK = customhud.SetupItem
local talcalc = tbsrequire 'helpers/c_inter'
local Options = tbsrequire 'helpers/create_cvar'
local hudcfg = 	tbsrequire('gui/hud_conf')
local hudvars = tbsrequire('gui/hud_vars')
local fonts = 	tbsrequire('gui/hud_fonts')
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'

local color_profile = tbsrequire('gui/hud_colors')
local write = drawlib.draw

local fade_cv = hudcfg.bluefade_cv
local hudspecifics = hudcfg.hudspecifics
local hud_hide_cv = hudcfg.hidehud_cv
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

HOOK("stagetitle", "classichud", function(v, p, t, e)
	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	if p.styles_entercut or (p.teamsprings_scenethread and p.teamsprings_scenethread.valid)
	or p.styles_entercut_timer ~= nil or p.styles_entercut_etimer ~= nil then
		v.fadeScreen(31, max(5 - leveltime, 0) * 2)

		return
	end

	local exists = min(hudcfg.titletype, 4)

	if hudspecifics[hudcfg.titletype].titlecard then
		exists = hudcfg.titletype
	end

	if hud_hide_cv.value > 1 then
		local check = hudspecifics[exists].titlecard(v, p, t, e, fade_cv.value > 0)

		if check then
			hudvars.hide = true
			hudvars.hidefull = true
		end
	else
		hudspecifics[exists].titlecard(v, p, t, e, fade_cv.value > 0)
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

	local exists = min(hudcfg.titletype, 4)

	if hudspecifics[hudcfg.titletype].titlecard then
		exists = hudcfg.titletype
	end

	if hud_hide_cv.value > 1 then
		local check = hudspecifics[exists].titlecard(v, p, p.styles_entercut_timer, p.styles_entercut_etimer, fade_cv.value > 0)

		if check then
			hudvars.hide = true
			hudvars.hidefull = true
		end
	else
		hudspecifics[exists].titlecard(v, p, p.styles_entercut_timer, p.styles_entercut_etimer, fade_cv.value > 0)
	end

	return true
end, "ingameintermission", 4, 3)

local tally_totalcalculation = 0

HOOK("styles_levelendtally", "classichud", function(v, p, t, e)
	if not p.exiting then return end

	if hud_hide_cv.value == 1
	or hud_hide_cv.value == 3 then
		hudvars.hide = true
	end

	-- Background stuff
	local specialstage_delay = 0
	local specialstage_togg = G_IsSpecialStage(gamemap)
	local timerfade = 0

	if p.styles_tallytimer ~= nil and specialstage_togg then
		timerfade = 15+min(p.styles_tallytimer+80, 0)

		if timerfade == 15 then
			v.fadeScreen(0, 10)
		else
			v.fadeScreen(0xFB00, max(min(timerfade*31/15, 31), 0))
		end
	end

	-- Fake Calculations
	if p.styles_tallytimer and p.styles_tallytimer == -93 then
		hudvars.timebonus = talcalc.Y_GetTimeBonus(max(p.realtime + (p.style_additionaltime or 0) - (p.styles_cutscenetime_prize or 0), 0))
		hudvars.ringbonus = talcalc.Y_GetRingsBonus(p.rings)
		hudvars.nightsbonus = p.totalmarescore
		hudvars.perfect = talcalc.Y_GetPreCalcPerfectBonus(p.rings)
		hudvars.totalbonus = hudvars.timebonus+hudvars.ringbonus+hudvars.perfect
		if p.mo then
			cached_tallyskincolor = v.getColormap(p.mo.skin, p.mo.color)
		else
			cached_tallyskincolor = v.getColormap(TC_DEFAULT, p.skincolor)
		end
	end

	if p.styles_tallytimer and p.styles_tallytimer > 0 then
		if (maptol & TOL_NIGHTS) then
			if hudvars.nightsbonus then
				hudvars.nightsbonus = $-222
				if hudvars.nightsbonus < 0 then
					hudvars.nightsbonus = 0
				end

				if not (p.styles_tallytimer % 3) then
					S_StartSound(nil, sfx_ptally, p)
				end
			end
		elseif G_IsSpecialStage(gamemap) then
			if hudvars.ringbonus then
				hudvars.ringbonus = $-222
				if hudvars.ringbonus < 0 then
					hudvars.ringbonus = 0
				end

				if not (p.styles_tallytimer % 3) then
					S_StartSound(nil, sfx_ptally, p)
				end
			end
		else
			if hudvars.timebonus then
				hudvars.timebonus = $-222
				if hudvars.timebonus < 0 then
					hudvars.timebonus = 0
				end

				if not (p.styles_tallytimer % 3) then
					S_StartSound(nil, sfx_ptally, p)
				end
			end

			if hudvars.ringbonus and not hudvars.timebonus then
				hudvars.ringbonus = $-222
				if hudvars.ringbonus < 0 then
					hudvars.ringbonus = 0
				end

				if not (p.styles_tallytimer % 3) then
					S_StartSound(nil, sfx_ptally, p)
				end
			end

			if hudvars.perfect > 0 and not hudvars.ringbonus then
				hudvars.perfect = $-222
				if hudvars.perfect < 0 then
					hudvars.perfect = 0
				end

				if not (p.styles_tallytimer % 3) then
					S_StartSound(nil, sfx_ptally, p)
				end
			end
		end

		if p.styles_tallytimer == p.styles_tallyfakecounttimer+1 then
			hudvars.timebonus = 0
			hudvars.ringbonus = 0
			hudvars.nightsbonus = 0

			if hudvars.perfect > 0 then
				hudvars.perfect = 0
			end

			S_StartSound(nil, sfx_chchng, p)
		end
	end

	-- Display
	if p.styles_tallytimer ~= nil then
		local specialstage_togg = G_IsSpecialStage(gamemap)

		local timed = p.styles_tallytimer+specialstage_delay
		local timerwentpast = 24*min(max(p.styles_tallytimer - (p.styles_tallyendtime + TICRATE/8), 0), 80)

		tally_totalcalculation = hudvars.totalbonus-hudvars.timebonus-hudvars.ringbonus-hudvars.perfect
		local tally_title  = min((timed+89)*24, 0) 		- timerwentpast
		local tally_x_row1 = 80-min((timed+64)*24, 0) 	- timerwentpast
		local tally_x_row2 = 80-min((timed+69)*24, 0) 	- timerwentpast
		local tally_x_row3 = 80-min((timed+74)*24, 0) 	- timerwentpast
		local tally_x_row4 = 80-min((timed+79)*24, 0) 	- timerwentpast
		local tally_x_row5 = 80-min((timed+84)*24, 0) 	- timerwentpast

		if specialstage_togg then
			local color = v.getColormap(TC_DEFAULT, SKINCOLOR_YELLOW)
			local color2 = hudcfg.tallycolor and v.getColormap(TC_DEFAULT, 0, hudcfg.tallycolor) or v.getColormap(TC_DEFAULT, 1, color_profile.score)

			if hudcfg.titletype and hudspecifics[hudcfg.titletype].tallyspecialbg then
				hudspecifics[hudcfg.titletype].tallyspecialbg(v, p, tally_title, color, color2, 15+min(p.styles_tallytimer+80, 0))
			else
				hudspecifics[1].tallyspecialbg(v, p, tally_title, color, color2, timerfade)
			end

			if hudcfg.titletype and hudspecifics[hudcfg.titletype].tallyspecial then
				hudspecifics[hudcfg.titletype].tallyspecial(v, p, tally_title, color, color2)
			else
				hudspecifics[1].tallyspecial(v, p, tally_title, color, color2)
			end

			if (timed % 2) then
				for i = 1, 7 do
					if emeralds & emeralds_set[i] then
						v.draw(50+i*30, 120, v.getSpritePatch(Options:getvalue("emeralds")[2], i-1, 0, 0), 0)
					end
				end
			end

			v.draw(tally_x_row2+160, 140, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
			v.draw(tally_x_row2+29, 139, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, color)
			v.draw(tally_x_row2, 140, v.cachePatch(fonts.font..'TTSCORE'), V_PERPLAYER, color2)

			write(v, fonts.font..'TNUM', (tally_x_row2+160)*FU, 140*FU, FU, p.score, V_PERPLAYER, color2, "right", fonts.padding)

			if (maptol & TOL_NIGHTS) then
				v.draw(tally_x_row3+160, 156, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)

				v.draw(tally_x_row3+86, 155, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, color)
				v.draw(tally_x_row3, 156, v.cachePatch(fonts.font..'TNIGHTS'), V_PERPLAYER, color2)
				v.draw(tally_x_row3+56, 156, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, color2)

				write(v, fonts.font..'TNUM', (tally_x_row3+160)*FU, 156*FU, FU, hudvars.nightsbonus, V_PERPLAYER, color2, "right", fonts.padding)
			else
				local RINGS = mariomode and 'TCOIN' or 'TRING'

				v.draw(tally_x_row3+160, 156, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)

				v.draw(tally_x_row3+70, 155, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, color)
				v.draw(tally_x_row3, 156, v.cachePatch(fonts.font..RINGS), V_PERPLAYER, color2)
				v.draw(tally_x_row3+40, 156, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, color2)

				write(v, fonts.font..'TNUM', (tally_x_row3+160)*FU, 156*FU, FU, hudvars.ringbonus, V_PERPLAYER, color2, "right", fonts.padding)
			end
		else
			if hudcfg.titletype and hudspecifics[hudcfg.titletype].tallybg then
				hudspecifics[hudcfg.titletype].tallybg(v, p, tally_title, color, color2, 15+min(p.styles_tallytimer+80, 0))
			else
				hudspecifics[1].tallybg(v, p, tally_title, color, color2, timerfade)
			end

			if hudcfg.titletype and hudspecifics[hudcfg.titletype].tallytitle then
				hudspecifics[hudcfg.titletype].tallytitle(v, p, tally_title, cached_tallyskincolor, hudcfg.forceusername_cv.value and p.name or nil)
			else
				hudspecifics[1].tallytitle(v, p, tally_title, cached_tallyskincolor, hudcfg.forceusername_cv.value and p.name or nil)
			end

			local RINGS = mariomode and 'TCOIN' or 'TRING'

			v.draw(tally_x_row4+70, 107, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, cached_tallyskincolor)
			v.draw(tally_x_row3+70, 123, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, cached_tallyskincolor)

			v.draw(tally_x_row4, 108, v.cachePatch(fonts.font..'TTTIME'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.time))
			v.draw(tally_x_row3, 124, v.cachePatch(fonts.font..RINGS), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.rings))

			v.draw(tally_x_row4+40, 108, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
			v.draw(tally_x_row3+40, 124, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))

			v.draw(tally_x_row4+160, 108, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
			v.draw(tally_x_row3+160, 124, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)

			write(v, fonts.font..'TNUM', (tally_x_row4+160)*FU, 108*FU, FU, hudvars.timebonus, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)
			write(v, fonts.font..'TNUM', (tally_x_row3+160)*FU, 124*FU, FU, hudvars.ringbonus, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)

			-- Perfect Bleh
			if hudvars.perfect > -1 then
				v.draw(tally_x_row2+82, 139, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, cached_tallyskincolor)
				v.draw(tally_x_row2-12, 140, v.cachePatch(fonts.font..'TPERFC'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
				v.draw(tally_x_row2+52, 140, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
				v.draw(tally_x_row2+160, 140, v.cachePatch(fonts.font..'TBICONNUM'))

				write(v, fonts.font..'TNUM', (tally_x_row2+160)*FU, 140*FU, FU, hudvars.perfect, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)
			end

			local mania_move = hudcfg.hudselect == 6 and 22 or 0

			-- Total vs Score nonsense
			if hudcfg.hudselect > 1 and not hudcfg.hudselect ~= 3 then
				v.draw(tally_x_row1+50, 155, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, cached_tallyskincolor)
				v.draw(tally_x_row1+21, 156, v.cachePatch(fonts.font..'TTOTAL'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
				v.draw(tally_x_row1+160-mania_move, 156, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
				write(v, fonts.font..'TNUM', (tally_x_row1+160-mania_move)*FU, 156*FU, FU, tally_totalcalculation, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)
			else
				v.draw(tally_x_row5+29, 91, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, cached_tallyskincolor)
				v.draw(tally_x_row5, 92, v.cachePatch(fonts.font..'TTSCORE'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
				v.draw(tally_x_row5+160, 92, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
				write(v, fonts.font..'TNUM', (tally_x_row5+160)*FU, 92*FU, FU, p.score, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)
			end
		end
	end

	if p.styles_tallytimer and (p.styles_tallytimer < 0) then
		tally_totalcalculation = 0
	end

	return true
end, "ingameintermission", 1, 3)