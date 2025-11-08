local InterCalc = tbsrequire('helpers/c_inter')
local Options = tbsrequire('helpers/create_cvar')
local hudcfg = 	tbsrequire('gui/hud_conf')
local hudvars = tbsrequire('gui/hud_vars')
local fonts = 	tbsrequire('gui/hud_fonts')
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local common = tbsrequire('gameplay/intermissions/inter_common')

local color_profile = tbsrequire('gui/hud_colors')
local write = drawlib.draw

local fade_cv = hudcfg.bluefade_cv
local hudspecifics = hudcfg.hudspecifics
local hud_hide_cv = hudcfg.hidehud_cv
local cached_tallyskincolor

local Layout = common.layoutNormal

local inter = {
	ID = "coop",
	addScoreInGameMethod = true,
	calculationSpeed = 222,
	tallyStart = -99,
	tallyHoldover = 5*TICRATE,
}

common:addCounter(
	"styles_tallyCounterRings",
	"styles_tallyCounterTime",
	"styles_tallyCounterPerf",
	"styles_tallyCounterTotal"
)

function inter:music()
    return Options:getvalue("levelendtheme")[2]
end

function inter.counterSetup(player)
	player.styles_tallyCounterRings = InterCalc.Y_GetRingsBonus(player.rings)
	player.styles_tallyCounterTime = InterCalc.Y_GetTimeBonus(max(player.realtime + (player.style_additionaltime or 0) - (player.styles_cutscenetime_prize or 0), 0))
	player.styles_tallyCounterPerf = max(InterCalc.Y_GetPreCalcPerfectBonus(player.rings), 0)
	player.styles_tallyCounterTotal = 0
end

function inter.calculateALL(player)
	return (
		InterCalc.Y_GetRingsBonus(player.rings) +
		InterCalc.Y_GetTimeBonus(max(player.realtime + (player.style_additionaltime or 0) - (player.styles_cutscenetime_prize or 0), 0)) +
		max(InterCalc.Y_GetPreCalcPerfectBonus(player.rings), 0)
	)
end

function inter.counterWipe(player)
	player.styles_tallyCounterRings = 0
	player.styles_tallyCounterTime = 0

	if player.styles_tallyCounterPerf > -1 then
		player.styles_tallyCounterPerf = 0
	end

	player.styles_tallyCounterTotal = inter.calculateALL(player)
	S_StartSound(nil, sfx_chchng, player)
end

function inter.counterThink(player)
	if player.styles_tallytimer and player.styles_tallytimer > 0 then
		if player.styles_tallyCounterTime then
			player.styles_tallyCounterTime = $-inter.calculationSpeed
			player.styles_tallyCounterTotal = $+inter.calculationSpeed

			if player.styles_tallyCounterTime < 0 then
				player.styles_tallyCounterTotal = $+player.styles_tallyCounterTime
				player.styles_tallyCounterTime = 0
			end

			if not (player.styles_tallytimer % 3) then
				S_StartSound(nil, sfx_ptally, player)
			end
		end

		if player.styles_tallyCounterRings and not player.styles_tallyCounterTime then
			player.styles_tallyCounterRings = $-inter.calculationSpeed
			player.styles_tallyCounterTotal = $+inter.calculationSpeed

			if player.styles_tallyCounterRings < 0 then
				player.styles_tallyCounterTotal = $+player.styles_tallyCounterRings
				player.styles_tallyCounterRings = 0
			end

			if not (player.styles_tallytimer % 3) then
				S_StartSound(nil, sfx_ptally, player)
			end
		end

		if player.styles_tallyCounterPerf > 0 and not player.styles_tallyCounterRings then
			player.styles_tallyCounterPerf = $-inter.calculationSpeed
			player.styles_tallyCounterTotal = $+inter.calculationSpeed

			if player.styles_tallyCounterPerf < 0 then
				player.styles_tallyCounterTotal = $+player.styles_tallyCounterPerf
				player.styles_tallyCounterPerf = 0
			end

			if not (player.styles_tallytimer % 3) then
				S_StartSound(nil, sfx_ptally, player)
			end
		end

		if player.styles_tallytimer == player.styles_tallyfakecounttimer+1 then
			inter.counterWipe(player)
		end
	end
end

function inter:duration(player)
    return self.calculateALL(player) / self.calculationSpeed
end

local player1_color = nil
local player2_color = nil

function inter.setupDraw(v, player)
	local secondplayer = secondarydisplayplayer

	if player == secondplayer then
		local realmo = secondplayer.realmo

		if realmo then
			player2_color = v.getColormap(TC_DEFAULT, realmo.color, realmo.translation)
		end
	else
		local realmo = player.realmo

		if realmo then
			player1_color = v.getColormap(TC_DEFAULT, realmo.color, realmo.translation)
		end
	end
end

function inter.draw(v, player, t, e)
	local titlex, row1x, row2x,
	row3x, row4x, row5x = common.rows(player, 0)

	local playercolor = player == secondarydisplayplayer and player2_color or player1_color

	if hudcfg.titletype and hudspecifics[hudcfg.titletype].tallybg then
		hudspecifics[hudcfg.titletype].tallybg(v, player, titlex, color, color2, 15+min(player.styles_tallytimer+80, 0))
	else
		hudspecifics[1].tallybg(v, player, titlex, color, color2, timerfade)
	end

	if hudcfg.titletype and hudspecifics[hudcfg.titletype].tallytitle then
		hudspecifics[hudcfg.titletype].tallytitle(v, player, titlex, playercolor, hudcfg.forceusername_cv.value and player.name or nil)
	else
		hudspecifics[1].tallytitle(v, player, titlex, playercolor, hudcfg.forceusername_cv.value and player.name or nil)
	end

	local RINGS = mariomode and 'TCOIN' or 'TRING'

	v.draw(row4x+70, 107, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, playercolor)
	v.draw(row3x+70, 123, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, playercolor)

	v.draw(row4x, 108, v.cachePatch(fonts.font..'TTTIME'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.time))
	v.draw(row3x, 124, v.cachePatch(fonts.font..RINGS), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.rings))

	v.draw(row4x+40, 108, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
	v.draw(row3x+40, 124, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))

	v.draw(row4x+160, 108, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
	v.draw(row3x+160, 124, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)

	write(v, fonts.font..'TNUM', (row4x+160)*FU, 108*FU, FU, player.styles_tallyCounterTime, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)
	write(v, fonts.font..'TNUM', (row3x+160)*FU, 124*FU, FU, player.styles_tallyCounterRings, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)

	-- Perfect Bleh
	if player.styles_tallyCounterPerf > 0 then
		v.draw(row2x+82, 139, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, playercolor)
		v.draw(row2x-12, 140, v.cachePatch(fonts.font..'TPERFC'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
		v.draw(row2x+52, 140, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
		v.draw(row2x+160, 140, v.cachePatch(fonts.font..'TBICONNUM'))

		write(v, fonts.font..'TNUM', (row2x+160)*FU, 140*FU, FU, player.styles_tallyCounterPerf, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)
	end

	local mania_move = hudcfg.hudselect == 6 and 22 or 0

	-- Total vs Score nonsense
	if Layout() then
		v.draw(row1x+50, 155, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, playercolor)
		v.draw(row1x+21, 156, v.cachePatch(fonts.font..'TTOTAL'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
		v.draw(row1x+160-mania_move, 156, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
		write(v, fonts.font..'TNUM', (row1x+160-mania_move)*FU, 156*FU, FU, player.styles_tallyCounterTotal, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)
	else
		v.draw(row5x+29, 91, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, playercolor)
		v.draw(row5x, 92, v.cachePatch(fonts.font..'TTSCORE'), V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.score))
		v.draw(row5x+160, 92, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
		write(v, fonts.font..'TNUM', (row5x+160)*FU, 92*FU, FU, player.score, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "right", fonts.padding)
	end
end

return inter