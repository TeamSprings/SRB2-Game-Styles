--[[

	Intermission Backend

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local Options = tbsrequire('helpers/create_cvar')

local list = tbsrequire 'gameplay/compact/specialpacks'
local calc_help = tbsrequire 'helpers/c_inter'

-- Global that should have been exposed! Bruh.
local TMEF_SKIPTALLY = 1

local api = tbsrequire 'styles_api'

-- Hooks for API

local setuphook = 	api:addHook("TallySetup")
local endhook = 	api:addHook("TallyEnd")
local skiphook = 	api:addHook("TallySkip")
local prerankhook = api:addHook("PreRankSetup") -- Unused for other styles
local rankhook = 	api:addHook("RankSetup") -- Unused for other styles

--
--	Console Variable
--

local specialpackdetected = nil
local end_tallyenabled = 1
local change_var = -1

local endtally_cv = CV_RegisterVar{
	name = "classic_endtally",
	defaultvalue = "enabled",
	flags = CV_CALL,
	func = function(var)
		if multiplayer then
			CONS_Printf(consoleplayer, "[Classic Style] This console variable is disabled in multiplayer.")
		end

		change_var = var.value
	end,
	PossibleValue = {disabled=0, enabled=1}
}

addHook("AddonLoaded", function()
	if list and not specialpackdetected then
		for _,v in ipairs(list) do
			if _G[v] then
				specialpackdetected = true
				return
			end
		end
	end
end)

addHook("PlayerSpawn", function(p)
	if change_var > -1 then
		end_tallyenabled = change_var
		change_var = -1
	end
end)

addHook("MapLoad", function()
	for p in players.iterate() do
		p.styles_tallytimer = nil

		-- Anti exploit measure
		if p.styles_tallylastscore then
			p.score = p.styles_tallylastscore

			p.styles_tallylastscore = nil
		end

		if p.styles_tallylastlives then
			p.lives = p.styles_tallylastlives

			p.styles_tallylastlives = nil
		end
	end
end)


--
--	Setpiece functions
--

local skiptally = false
local customexit = nil
local lastspecialsector = nil

--
-- Switch & Updated definition of G_SetCustomExitVars for mod support.
-- Such a horrible unprotected way to do @override
--

local G_SetCustomExitOriginal = G_SetCustomExitVars

rawset(_G, "G_SetCustomExitVars", function(...)
	local args = {...}

	local skip = args[2]

	-- Force skip true
	if end_tallyenabled then
		if skip then
			skiptally = true
		else
			skiptally = false
		end

		skip = 1
	end

	customexit = args[1]
	G_SetCustomExitOriginal(args[1], skip, args[3], args[4], args[5], args[6], args[7])
end)

local G_ExitLevelOriginal = G_ExitLevel

rawset(_G, "G_ExitLevel", function(...)
	local args = {...}

	local skip = args[2]

	-- Force skip true
	if end_tallyenabled then
		if (skip == nil and skiptally) or skip == true then
			skiptally = true
		else
			skiptally = false
		end

		skip = 1
	end

	G_ExitLevelOriginal(args[1] or customexit, skip, args[3], args[4], args[5], args[6], args[7])

	if customexit then
		customexit = nil
	end

	if skiptally then
		skiptally = false
	end

	lastspecialsector = nil
end)

--
-- 	Setup functions
--

local function G_CheckIfSectorIsCustomExit(s)
	local result = nil

	for l in lines.tagged(s.tag) do
		if l.special ~= 2 then continue end

		result = {
			s,
			s.tag,
			s.floorheight,
			s.ceilingheight,
			l.flags,
			l.args,
			l.frontsector,
		}
	end

	return result
end

local function G_InteprateStyleSectors(finish)
	if not finish then return end

	local binary_skip = ((finish[5] & ML_NOCLIMB) and true or skiptally)
	local udmf_skip = ((finish[6][1] & TMEF_SKIPTALLY) and true or skiptally)

	skiptally = udmf_skip and true or binary_skip

	local check = nil

	if finish[7] and finish[7].floorheight then
		check = finish[7].floorheight/FRACUNIT
	end

	customexit = (finish[6][0] > 0 and finish[6][0] or check) or customexit

	lastspecialsector = finish
end

local function G_InitiateNewExit()
	G_SetCustomExitOriginal(nil or customexit, 1)
end

--
--	Grant Emerald
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

local function G_StylesGrantEmerald(p)
	if gamemap >= sstage_start and gamemap < sstage_end then
		local em_selection = gamemap - sstage_start + 1

		if emeralds_set[em_selection] then
			p.styles_granted = emeralds_set[em_selection]
			emeralds = $ | p.styles_granted
		end
	elseif gamemap >= smpstage_start and gamemap <= smpstage_end then
		local em_selection = gamemap - smpstage_start + 1

		if emeralds_set[em_selection] then
			p.styles_granted = emeralds_set[em_selection]
			emeralds = $ | p.styles_granted
		end
	end
end

--
--	In-Game Handler (SP only)
--

local function G_StylesTallyBackend(p)
	if (multiplayer and not splitscreen) or not end_tallyenabled then return end
	if not (p.mo and p.mo.valid) then return end
	if specialpackdetected then return end
	if p.bot then return end

	if marathonmode then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local specialstage = G_IsSpecialStage(gamemap)

	if (G_GametypeUsesCoopStarposts() and G_GametypeUsesLives()) or (specialstage and not modeattacking) then

		if p.exiting and not lastspecialsector then
			-- Handles cases with skiptally, hopefully.
			if not p.urhudon then
				local spacial_sec = P_PlayerTouchingSectorSpecialFlag(p, SSF_EXIT)

				if spacial_sec then
					G_InteprateStyleSectors(G_CheckIfSectorIsCustomExit(spacial_sec))
				end

				if not spacial_sec and p.mo then
					spacial_sec = p.mo.subsector

					if spacial_sec and spacial_sec.sector then
						G_InteprateStyleSectors(G_CheckIfSectorIsCustomExit(spacial_sec.sector))
					end
				end

				G_InitiateNewExit()
			end
		end


		if G_EnoughPlayersFinished() then
			if not skiptally then
				if not stagefailed then
					G_StylesGrantEmerald(p)
				end

				-- STOP
				if p.yusonictable and p.yusonictable.endlvl then
					p.yusonictable.endlvl = 0
				end

				-- Initial Setup of Tally
				if p.exiting == 6 then
					p.styles_tallytimer = -99
					p.styles_tallyfakecounttimer = calc_help.Y_GetTimingCalculation(p)
					p.styles_tallyendtime = p.styles_tallyfakecounttimer + 5*TICRATE
					p.styles_tallylastscore = p.score
					p.styles_tallylastlives = p.lives
					p.exiting = 5

					p.powers[pw_invulnerability] = 0
					p.powers[pw_sneakers] = 0
					p.powers[pw_extralife] = 0
					p.powers[pw_super] = 0

					local getTrack = Options:getvalue("levelendtheme")[2]

					S_StopMusic(p)
					S_ChangeMusic(getTrack, false, p, 0, 0, 0, 0)
					--p.styles_lasttrack = nil
					p.styles_tallytrack = getTrack
					p.styles_tallyposms = 0
					p.styles_tallystoplooping = nil
					p.styles_tallysoundlenght = S_GetMusicLength()

					p.mo.flags = $|MF_NOCLIPTHING

					setuphook(p.realmo and p.realmo.skin or p.skin, p)
				-- Background Process
				elseif p.styles_tallytimer ~= nil then
					p.exiting = 5
					if not p.styles_lasttrack then
						p.styles_lasttrack = S_MusicName(p)
					end

					-- Sending the 222s to score counter. Mainly to grant all lives and everything like that.
					if p.styles_tallytimer > 0 and p.styles_tallytimer < p.styles_tallyfakecounttimer then

						if p.cmd.buttons & BT_SPIN then
							p.styles_tallytimer = p.styles_tallyfakecounttimer
							calc_help.addScore(p, calc_help.Y_CalculateAllScore(p) - max(p.score - p.styles_tallylastscore, 0))

							skiphook(p.realmo and p.realmo.skin or p.skin, p)
						else
							if p.styles_tallytimer < p.styles_tallyfakecounttimer - 1 then
								calc_help.addScore(p, 222)
							else
								calc_help.addScore(p, calc_help.Y_CalculateAllScore(p) - max(p.score - p.styles_tallylastscore, 0))
							end
						end
					end

					p.powers[pw_invulnerability] = 0
					p.powers[pw_sneakers] = 0
					p.powers[pw_extralife] = 0
					p.powers[pw_super] = 0

					local cur_music = S_MusicName(p)

					if p.styles_tallystoplooping then
						S_StopMusic(p)
					elseif cur_music then
						if cur_music ~= p.styles_tallytrack or not (S_MusicPlaying(p)) then
							if not p.styles_tallytrack then
								p.styles_tallytrack = Options:getvalue("levelendtheme")[2]
							end

							S_ChangeMusic(p.styles_tallytrack, false, p, 0, p.styles_tallyposms, 0, 0)

							if p.styles_tallysoundlenght - MUSICRATE <= p.styles_tallyposms then
								S_StopMusic(p)
								p.styles_tallystoplooping = true
							end
						elseif cur_music and cur_music == p.styles_tallytrack then
							if p.styles_tallysoundlenght - MUSICRATE > p.styles_tallyposms then
								p.styles_tallyposms = S_GetMusicPosition()
							end
						end
					end

					p.styles_tallytimer = $+1

					if p.styles_tallytimer > p.styles_tallyendtime then
						p.exiting = 1
						p.styles_tallylastscore = p.score
						p.styles_tallylastlives = p.lives
						G_ExitLevel()

						endhook(p.realmo and p.realmo.skin or p.skin, p)
						return
					end
				end
			end

			if p.exiting == 1 then
				p.styles_tallylastscore = p.score
				p.styles_tallylastlives = p.lives
				G_ExitLevel()
			end
		end
	else
		p.styles_tallytimer = nil
	end
end

addHook("MapChange", function()
	for p in players.iterate do
		p.styles_tallytimer = nil
	end

	customexit = nil
	lastspecialsector = nil
end)


addHook("PlayerThink", G_StylesTallyBackend)
