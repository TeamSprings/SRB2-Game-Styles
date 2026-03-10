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

local emeralds_set = {
	EMERALD1,
	EMERALD2,
	EMERALD3,
	EMERALD4,
	EMERALD5,
	EMERALD6,
	EMERALD7,
}

local inter = {
	ID = "special",
	addScoreInGameMethod = true,
	calculationSpeed = 222,
	tallyStart = -99,
	tallyHoldover = 5*TICRATE,
}

common:addCounter(
	"styles_tallyCounterSpecial",
	"styles_tallyCounterTotal"
)

function inter:music()
    return Options:getvalue("levelendtheme")[2]
end

function inter.counterSetup(player)
	if (maptol & TOL_NIGHTS) then
		player.styles_tallyCounterSpecial = player.totalmarescore
	else
		player.styles_tallyCounterSpecial = InterCalc.Y_GetRingsBonus(player.rings)
	end

	player.styles_tallyCounterTotal = 0
end

function inter.calculateALL(player)
	if (maptol & TOL_NIGHTS) then
		return player.totalmarescore
	else
		return InterCalc.Y_GetRingsBonus(player.rings)
	end
end


function inter.counterWipe(player)
	player.styles_tallyCounterSpecial = 0
	player.styles_tallyCounterTotal = inter.calculateALL(player)

	S_StartSound(nil, sfx_chchng, player)
end

function inter.counterThink(player)
	if player.styles_tallytimer and player.styles_tallytimer > 0 then
		if player.styles_tallyCounterSpecial then
			player.styles_tallyCounterSpecial = $-inter.calculationSpeed
			player.styles_tallyCounterTotal = $+inter.calculationSpeed

			if player.styles_tallyCounterSpecial < 0 then
				player.styles_tallyCounterTotal = $+player.styles_tallyCounterSpecial
				player.styles_tallyCounterSpecial = 0
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
    return self.calculateALL(player) / inter.calculationSpeed
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

function inter.draw(v, p, t, e)
	local titlex, row1x, row2x,
	row3x, row4x, row5x = common.rows(p, 0)

	-- Background stuff
	local timerfade = 0

	timerfade = 15+min(p.styles_tallytimer+80, 0)

	if timerfade == 15 then
		v.fadeScreen(0, 10)
	else
		v.fadeScreen(0xFB00, max(min(timerfade*31/15, 31), 0))
	end

	local color = v.getColormap(TC_DEFAULT, SKINCOLOR_YELLOW)
	local color2 = hudcfg.tallycolor and v.getColormap(TC_DEFAULT, 0, hudcfg.tallycolor) or v.getColormap(TC_DEFAULT, 1, color_profile.score)

	if hudcfg.titletype and hudspecifics[hudcfg.titletype].tallyspecialbg then
		hudspecifics[hudcfg.titletype].tallyspecialbg(v, p, titlex, color, color2, 15+min(p.styles_tallytimer+80, 0))
	else
		hudspecifics[1].tallyspecialbg(v, p, titlex, color, color2, timerfade)
	end

	if hudcfg.titletype and hudspecifics[hudcfg.titletype].tallyspecial then
		hudspecifics[hudcfg.titletype].tallyspecial(v, p, titlex, color, color2)
	else
		hudspecifics[1].tallyspecial(v, p, titlex, color, color2)
	end

	if (p.styles_tallytimer % 2) then
		for i = 1, 7 do
			if emeralds & emeralds_set[i] then
				v.draw(50+i*30, 120, v.getSpritePatch(Options:getvalue("emeralds")[2], i-1, 0, 0), 0)
			end
		end
	end

	v.draw(row2x+160, 140, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
	v.draw(row2x+29, 139, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, color)
	v.draw(row2x, 140, v.cachePatch(fonts.font..'TTSCORE'), V_PERPLAYER, color2)

	write(v, fonts.font..'TNUM', (row2x+160)*FU, 140*FU, FU, p.score, V_PERPLAYER, color2, "right", fonts.padding)

	v.draw(row3x+160, 156, v.cachePatch(fonts.font..'TBICONNUM'), V_PERPLAYER)
	if (maptol & TOL_NIGHTS) then
		v.draw(row3x+86, 155, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, color)
		v.draw(row3x, 156, v.cachePatch(fonts.font..'TNIGHTS'), V_PERPLAYER, color2)
		v.draw(row3x+56, 156, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, color2)
	else
		local RINGS = mariomode and 'TCOIN' or 'TRING'
		v.draw(row3x+70, 155, v.cachePatch(fonts.font..'TBICON'), V_PERPLAYER, color)
		v.draw(row3x, 156, v.cachePatch(fonts.font..RINGS), V_PERPLAYER, color2)
		v.draw(row3x+40, 156, v.cachePatch(fonts.font..'TBONUS'), V_PERPLAYER, color2)
	end

	write(v, fonts.font..'TNUM', (row3x+160)*FU, 156*FU, FU, p.styles_tallyCounterSpecial, V_PERPLAYER, color2, "right", fonts.padding)
end

return inter