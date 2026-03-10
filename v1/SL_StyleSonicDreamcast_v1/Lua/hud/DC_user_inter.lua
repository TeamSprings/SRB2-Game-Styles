--[[

		User Interfaces inspired by Sonic Adventure 2.

Contributors: Skydusk
@Team Blue Spring 2022-2025

	TODO: Think better algorithm for getting bosses (perhaps blockmap search)
]]

local drawlib = tbslibrary 'lib_emb_tbsdrawers'
local helper = 	tbsrequire 'helpers/c_inter'
local helper2 = tbsrequire 'helpers/lua_hud'
local api = tbsrequire 'styles_api'

local convertPlayerTime = helper2.convertPlayerTime

local font_drawer = drawlib.draw
local font_draweru = drawlib.drawUdj
local rank_calculator = helper.RankCounter
local Y_GetTimeBonus = helper.Y_GetTimeBonus
local Y_GetRingsBonus = helper.Y_GetRingsBonus
local Y_GetGuardBonus = helper.Y_GetGuardBonus
local Y_GetPerfectBonus = helper.Y_GetPerfectBonus

local HOOK = customhud.SetupItem

local rankhook = api:addHook("RankSetup")

--
-- End Level Tally...
--

sfxinfo[freeslot("sfx_rank")].caption = "rank drop!"
sfxinfo[freeslot("sfx_advchi")].caption = "cha-ching!"
sfxinfo[freeslot("sfx_advtal")].caption = "tally"

local emeralds_set = {EMERALD1, EMERALD2, EMERALD3, EMERALD4, EMERALD5, EMERALD6, EMERALD7}

local interm_size = FU-3*FU/8

local music = "_ADVLCEAR"

HOOK("ingameintermission", "dchud", function(v, p, t, e)
	if not (p.exiting and p.styles_tallytimer) then return true end
	-- Ease and timing

	local specialstage_togg = G_IsSpecialStage(gamemap)

	local textscaling = {}
	local transparency = {}
	local xcnt = {}

	for i = 1,5 do
		textscaling[i] = ease.linear(max(min(p.styles_tallytimer-7*TICRATE-8*i, TICRATE/5), 0)*FU/(TICRATE/5), interm_size, 3*FU/2)
		transparency[i] = ease.linear(max(min(p.styles_tallytimer-7*TICRATE-8*i, TICRATE/5), 0)*FU/(TICRATE/5), 1, 9) << V_ALPHASHIFT
	end

	local fade = ease.linear(max(min(p.styles_tallytimer-8*TICRATE-5, TICRATE/3), 0)*FU/(TICRATE/3), 16, 0)
	local fadewhite = 0

	if not specialstage_togg then
		fadewhite = abs(abs(ease.linear(max(min(p.styles_tallytimer-11*TICRATE, 3*TICRATE), 0)*FU/(3*TICRATE), 10, -10))-10)
	end

	local rankamp = ease.linear(max(min(p.styles_tallytimer-2*TICRATE, TICRATE/5), 0)*FU/(TICRATE/5), FU, 3*FU/2)
	local ranktrp = ease.linear(max(min(p.styles_tallytimer-2*TICRATE, TICRATE/5), 0)*FU/(TICRATE/5), 1, 9) << V_ALPHASHIFT

	local calculationtime = ease.linear(max(min(p.styles_tallytimer-5*TICRATE, 3*TICRATE-TICRATE/2), 0)*FU/(3*TICRATE-TICRATE/2), helper:Y_GetStageBonus(p), 0)

	-- stop music
	if p.styles_tallytimer == 13*TICRATE-1 then
		S_FadeOutStopMusic(MUSICRATE, p)
	end

	--
	--	SET-UP
	--

	v.fadeScreen(0, fadewhite)

	v.fadeScreen(0xFF00, fade)

	local z1, z2 = 56, 125
	local scale = ease.linear(max(min(p.styles_tallytimer-8*TICRATE, TICRATE/4), 0)*FU/(TICRATE/4), FU-FU/4, 1)
	local x1 = FixedDiv(162*scale, scale)
	local index = 5

	v.drawScaled(x1, FixedDiv(z1*scale, scale), scale, v.cachePatch("SA2TLPNA1"), V_PERPLAYER)
	v.drawScaled(x1, FixedDiv(z2*scale, scale), scale, v.cachePatch("SA2TLPNB1"), V_PERPLAYER)
	v.drawScaled(x1, FixedDiv(z1*scale, scale), scale, v.cachePatch("SA2TLPNA2"), V_50TRANS|V_PERPLAYER)
	v.drawScaled(x1, FixedDiv(z2*scale, scale), scale, v.cachePatch("SA2TLPNB2"), V_50TRANS|V_PERPLAYER)

	-- Guard or Score

	if transparency[index] ~= V_90TRANS then

		local zscore = FixedDiv((z1+13)*textscaling[index], textscaling[index])

		local currentscore = ''..(p.score-p.startscore)
		local scorelen = (string.len(""..currentscore))

		local patch = v.cachePatch(mapheaderinfo[gamemap].bonustype > 0 and "SA2TLGRD" or "SA2TLSCR")
		v.drawScaled(FixedDiv((72+patch.leftoffset)*textscaling[index], textscaling[index]), 5*zscore/8,
		textscaling[index], patch, V_PERPLAYER|transparency[index])

		font_draweru(v, 'SA2TL', FixedDiv(246*textscaling[index], textscaling[index]) + (scorelen * 9 * (textscaling[index] - interm_size)),
		5*zscore/8, textscaling[index], currentscore,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)

	end

	-- Time
	index = 4

	if transparency[index] ~= V_90TRANS then

		local ztime = FixedDiv((z1+34)*textscaling[index], textscaling[index])

		local mint, sect, cent = convertPlayerTime(p.realtime)
		local tallytime = ''..(mint..':'..sect..':'..cent)
		local len = (string.len(""..tallytime))

		local patch = v.cachePatch("SA2TLTIME")
		v.drawScaled(FixedDiv((76+patch.leftoffset)*textscaling[index], textscaling[index]), 5*ztime/8,
		textscaling[index], patch, V_PERPLAYER|transparency[index])

		font_draweru(v, 'SA2TL', FixedDiv(246*textscaling[index], textscaling[index]) + (len * 9 * (textscaling[index] - interm_size)),
		5*ztime/8, textscaling[index], tallytime,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)

	end

	-- Rings
	index = 3

	if transparency[index] ~= V_90TRANS then

		local zrings = FixedDiv((z1+55)*textscaling[index], textscaling[index])
		local tallyrings = "/"..(helper.totalcoinnum + mapheaderinfo[gamemap].startrings or 0)

		if (maptol & TOL_NIGHTS) then
			tallyrings = "???"..$
		else
			tallyrings = (p.rings)..$
		end

		local ringslen = (string.len(""..tallyrings))

		local patch = v.cachePatch("SA2TLRNG")
		v.drawScaled(FixedDiv((74+patch.leftoffset)*textscaling[index], textscaling[index]), 5*zrings/8,
		textscaling[index], patch, V_PERPLAYER|transparency[index])

		font_draweru(v, 'SA2TL', FixedDiv(246*textscaling[index], textscaling[index]) + (ringslen * 9 * (textscaling[index] - interm_size)),
		5*zrings/8, textscaling[index], tallyrings,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)

	end

	-- Time Bonus
	index = 2

	if transparency[index] ~= V_90TRANS then

		local timebonz = FixedDiv((z2+55)*textscaling[index], textscaling[index])
		local timebonus = ''..(helper:Y_GetStageBonus(p) - calculationtime)
		local timelen = (string.len(""..timebonus))

		local patch = v.cachePatch("SA2TLTB")

		if (maptol & TOL_NIGHTS) then
			patch = v.cachePatch("SA2TLSB")
		end

		v.drawScaled(FixedDiv((63+patch.leftoffset)*textscaling[index], textscaling[index]), 5*timebonz/8,
		textscaling[index], patch, V_PERPLAYER|transparency[index])

		font_draweru(v, 'SA2TL', FixedDiv(246*textscaling[index], textscaling[index]) + (timelen * 9 * (textscaling[index] - interm_size)),
		5*timebonz/8, textscaling[index], timebonus,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)

	end

	-- Total Score
	index = 1

	if transparency[index] ~= V_90TRANS then

		local totalz = FixedDiv((z2+77)*textscaling[index], textscaling[index])
		local totalScore = ''..(Y_GetRingsBonus(p.rings)+(p.score-p.startscore)+calculationtime)
		local len = (string.len(""..totalScore))

		local patch = v.cachePatch("SA2TLTS")
		v.drawScaled(FixedDiv((61+patch.leftoffset)*textscaling[index], textscaling[index]), 5*totalz/8,
		textscaling[index], patch, V_PERPLAYER|transparency[index])

		font_draweru(v, 'SA2TL', FixedDiv(246*textscaling[index], textscaling[index]) + (len * 9 * (textscaling[index] - interm_size)),
		5*totalz/8, textscaling[index], totalScore,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)

	end

	-- Rank

	if specialstage_togg then
		if transparency[index] ~= V_90TRANS then
			for id = 1, 7 do
				--v.draw(x-3, 93, v.cachePatch("CHAOSEMPTY"), 0)
				if emeralds & emeralds_set[id] then
					local x = 69+id*23
					local state = states[S_CEMG1+id-1]
					local patch = v.getSpritePatch(state.sprite, state.frame+(leveltime/state.var2 % state.var1), 0)

					v.drawScaled(x*FU, 158*FU, FU/2, patch, transparency[index])
				end
			end
		end
	else
		local rank = rank_calculator(p)

		if rankamp ~= 3*FU/2 then
			local patch = v.cachePatch("SA2RANK"..rank)
			v.drawScaled(FixedDiv(144*rankamp, rankamp)+FixedDiv((patch.width/2)*rankamp, rankamp),
			FixedDiv(158*rankamp, rankamp)+FixedDiv((patch.height/2)*rankamp, rankamp), rankamp, patch, V_PERPLAYER|ranktrp)
		end

		-- rank sound
		if p.styles_tallytimer == 2*TICRATE then
			S_StartSound(nil, sfx_rank, p)
			rankhook(p.realmo and p.realmo.skin or p.skin, p, rank)
		end
	end

	return true
end, "game", 8)

--
--	TITLE CARD
--

sfxinfo[freeslot("sfx_advtts")].caption = "titlecard"

local SubToTagLUT = {
	["SPECIAL STAGE 1"] = "Special Stage: 01",
	["SPECIAL STAGE 2"] = "Special Stage: 02",
	["SPECIAL STAGE 3"] = "Special Stage: 03",
	["SPECIAL STAGE 4"] = "Special Stage: 04",
	["SPECIAL STAGE 5"] = "Special Stage: 05",
	["SPECIAL STAGE 6"] = "Special Stage: 06",
	["SPECIAL STAGE 7"] = "Special Stage: 07",
}

local SubToColor = {
	["SPECIAL STAGE 1"] = {SKINCOLOR_EMERALD, true},
	["SPECIAL STAGE 2"] = {SKINCOLOR_PURPLE, true},
	["SPECIAL STAGE 3"] = {SKINCOLOR_SAPPHIRE, true},
	["SPECIAL STAGE 4"] = {SKINCOLOR_SKY, true},
	["SPECIAL STAGE 5"] = {SKINCOLOR_SANDY, true},
	["SPECIAL STAGE 6"] = {SKINCOLOR_PEPPER, true},
	["SPECIAL STAGE 7"] = {SKINCOLOR_AZURE, true},
}


local mission = {
	[1] = "st ",
	[2] = "nd ",
	[3] = "rd ",
}

local function THTHTHfunc(num)
	if type(num) ~= "number" then
		return num
	end

	if num == 0 then
		return ""
	end

	local ord = num
	local str = "th "

	if num > 20 then
		num = (num % 10) + 1
	end

	if mission[num] then
		str = mission[num]
	end

	return ord..str
end

local ac = 1

HOOK("stagetitle", "dchud", function(v, p, t, et)
	if t > et-1 then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local namezone = mapheaderinfo[gamemap].lvlttl..""
	local subtitle = mapheaderinfo[gamemap].subttl..""
	local actnum = mapheaderinfo[gamemap].actnum..""
	local stagenum = (gamemap < 9 and "0"..gamemap or ""..gamemap)

	-- Splitting Level Name into Words
	local split = {}

	for w in namezone:gmatch("%S+") do table.insert(split, w) end

	if #split > 1 then
		for i = 2,#split do
			if split[i] and #split[i] < 6 and (not split[i-1] or #split[i-1] < 9) then
				split[i-1] = $+" "..split[i]
				table.remove(split, i)
			end
		end
	end

	if (actnum ~= "0") then
		split[#split] = $+" "..actnum
	end

	-- Sound Effects / Music

	if (leveltime <= et) then
		if t == 4 then
			ac = 1
		end


		if consoleplayer and consoleplayer == p then
			hud.sa2musicstop = (t <= (2*TICRATE+9) and 2 or 0)

			if hud.sa2musicstop then
				S_SetInternalMusicVolume(0, p)
			end
		end

		if ac and (t == TICRATE/2) then
			S_StartSound(nil, sfx_advtts, p)
			ac = nil
		end
	end

	-- Timer and easing functions
	local tic = min(t, TICRATE)*FU/TICRATE
	local ticq = min(t, TICRATE-17)*FU/(TICRATE-17)

	local easespin = ease.inquint(min(2*tic, FU), 500, 0)
	local easespinspin = ease.inquint(min(2*tic, FU), 500, 0)
	local easegoout = ease.linear(max(min(t-2*TICRATE-9, TICRATE/2), 0)*FU/(TICRATE/2), 0, 93)
	local easescaleout = ease.outsine((max(min(t-2*TICRATE/3-5, 2*TICRATE), 0)*FU)/(2*TICRATE), FU, 3*FU/2)

	local easetransparency1 = ease.linear(max(min(t-2*TICRATE+TICRATE/3, TICRATE/3), 0)*FU/(TICRATE/3), 5, 9)

	local easetransparency2 = ease.linear((max(min(t-2*TICRATE/3, TICRATE/3), 0)*FU)/(TICRATE/3), 0, 9)

	local easetransparency3 = ease.linear((max(min(t-2*TICRATE-TICRATE/2, TICRATE/3), 0)*FU)/(TICRATE/3), 0, 9)
	local easetransparency4 = ease.linear((max(min(t-2*TICRATE-TICRATE/2, TICRATE/3), 0)*FU)/(TICRATE/3), 5, 9)

	local easespout = ease.inquint((max(min(t-5*TICRATE/2-9, TICRATE/2), 0)*FU)/(TICRATE/2), 0, 500)

	local easesubtit = ease.linear(ticq, 1, FU)
	local easespeen = ease.incubic(ticq, 90, 0)*ANG1
	local easetranp = ease.incubic(tic, 4, 9)
	local easescale = (ease.incubic(ticq, 700, 150)*FU)/100

	-- Actual Title Card Drawer
	if t < et then

		if not mapheaderinfo[gamemap].styles_titlecard_nofade and leveltime <= et and displayplayer == p then
			v.fadeScreen(0xFF00|V_PERPLAYER, 31-(easegoout*31/93))
		end

		local color = p.skincolor or displayplayer.skincolor

		if mapheaderinfo[gamemap].styles_titlecard_color then
			local ttcl = tostring(mapheaderinfo[gamemap].styles_titlecard_color)

			if _G[ttcl] and skincolors[_G[ttcl]] then
				color = _G[ttcl]
			else
				print("Warning: Wrong color index in Lua.styles_titlecard_color")
			end
		end


		local lenght = split[#split]

		local SRB2tagsideline = v.cachePatch("SA2TTNAM")

		v.draw(0-easegoout,0, v.cachePatch("SA2TTBAR"), V_SNAPTOLEFT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, color))

		if easetransparency2 ~= 9 then
			v.drawScaled(FixedDiv(41*easescaleout, easescaleout),FixedDiv(-50*easescaleout, easescaleout), easescaleout, SRB2tagsideline, V_SNAPTOLEFT|V_SNAPTOTOP|V_ADD|(easetransparency2 << V_ALPHASHIFT), v.getColormap(TC_DEFAULT, color))
		end

		if easetransparency1 ~= 9 then
			v.draw(41,-50-(t % SRB2tagsideline.height), SRB2tagsideline, V_SNAPTOLEFT|V_SNAPTOTOP|V_ADD|(easetransparency1 << V_ALPHASHIFT), v.getColormap(TC_DEFAULT, color))
		end

		local textColor = v.getColormap(TC_DEFAULT, SKINCOLOR_SLATE)

		if SubToColor[string.upper(subtitle)] then
			local data = SubToColor[string.upper(subtitle)]
			textColor = v.getColormap(TC_DEFAULT, data[1])

			if data[2] then
				color = data[1]
			end
		end

		-- SPEEEEN

		local spinGhost = v.getSpritePatch(SPR_CHE0, H, 0, easespeen)
		local spinGraphic = v.cachePatch("SA2TTSPIN")

		if easetranp ~= 9 then
			v.drawScaled((75+#lenght*10+spinGraphic.width/2)*FU, (75+spinGraphic.height/2)*FU, easescale, spinGhost, V_ADD|V_PERPLAYER|(easetranp << V_ALPHASHIFT), v.getColormap(TC_DEFAULT, color))
		end

		v.draw((75+#lenght*10)-easespinspin+easespout, 75, spinGraphic, V_PERPLAYER, v.getColormap(TC_DEFAULT, color))

		if mapheaderinfo[gamemap].styles_dc_stagenum then
			font_drawer(v, 'SA2TTFONT', (80+#lenght*4+easespin-easespout)*FU, 82*FU, FU-FU/4, mapheaderinfo[gamemap].styles_dc_stagenum.."", V_PERPLAYER, textColor, 0, -1, 0)
		elseif SubToTagLUT[string.upper(subtitle)] then
			font_drawer(v, 'SA2TTFONT', (80+#lenght*4+easespin-easespout)*FU, 82*FU, FU-FU/4, SubToTagLUT[string.upper(subtitle)], V_PERPLAYER, textColor, 0, -1, 0)
			subtitle = nil
		elseif not (G_RingSlingerGametype() or G_GametypeHasSpectators()) then
			font_drawer(v, 'SA2TTFONT', (80+#lenght*4+easespin-easespout)*FU, 82*FU, FU-FU/4, "Stage: "..stagenum, V_PERPLAYER, textColor, 0, -1, 0)
		end

		-- SUBTITLE

		if subtitle and string.len(subtitle) > 0 then
			for i = 1, 2 do
				v.drawScaled(FixedDiv(84*FU, easesubtit), FixedDiv(140*FU, easesubtit), easesubtit, v.cachePatch("SA2TTSUB"..i), ((i == 2 and easetransparency4 or easetransparency3) << V_ALPHASHIFT)|V_PERPLAYER, v.getColormap(TC_DEFAULT, color))
			end

			if t > TICRATE then
				if mapheaderinfo[gamemap].styles_mission then
					local tag = mapheaderinfo[gamemap].styles_missiontag or "Mission:"

					font_drawer(v, 'SA2TTFONT', 187*FU, 298*FU, 3*FU/5-FU/9, THTHTHfunc(tonumber(mapheaderinfo[gamemap].styles_mission) or 0)..tag, (easetransparency3 << V_ALPHASHIFT)|V_PERPLAYER, v.getColormap(TC_DEFAULT, SKINCOLOR_SLATE), 0, -1, 0)
					font_drawer(v, 'COMSANSFT', 182*FU, 312*FU, FU/2, tostring(subtitle), (easetransparency3 << V_ALPHASHIFT)|V_PERPLAYER, v.getColormap(TC_DEFAULT, SKINCOLOR_GREY), "left", 1, 0)
				else
					font_drawer(v, 'COMSANSFT', 358*FU, 300*FU, FU/2, tostring(subtitle), (easetransparency3 << V_ALPHASHIFT)|V_PERPLAYER, v.getColormap(TC_DEFAULT, SKINCOLOR_GREY), "center", 1, 0)
				end
			end

		end

		-- TITLE

		for i = 1, #split do
			local spliteaseout = ease.inquint((max(min(t-5*TICRATE/2-(i-1), TICRATE/2+(i-1)), 0)*FU)/(TICRATE/2+(i-1)), 0, 500)
			font_drawer(v, 'SA2LTTFONT', (115-(#split[i] > 8 and #split[i]*2 or 0)+easespin-spliteaseout)*FU, (88+(i-1)*20)*FU, FU, split[i], V_PERPLAYER, textColor, 0, -1, 0)
		end

	end
end, "titlecard")


addHook("PreThinkFrame", function()
	for p in players.iterate() do
		if hud.sa2musicstop then
			S_PauseMusic(p)
			hud.sa2musicstop = $ - 1
		end
	end
end)

addHook("PlayerThink", function(p)
	if hud.sa2musicstop == 0 and S_MusicPaused() then
		S_ResumeMusic(p)
		S_SetMusicPosition(0)
		S_FadeMusic(100, MUSICRATE/2, p)
		hud.sa2musicstop = nil
	end
end)

