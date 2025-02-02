--[[

	Intermission Backend

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local calc_help = tbsrequire 'helpers/c_inter'

-- Global that should have been exposed! Bruh.
local TMEF_SKIPTALLY = 1

--
--	Console Variable
--

local end_tallyenabled = 1
local change_var = -1

local endtally_cv = CV_RegisterVar{
	name = "gba_endtally",
	defaultvalue = "enabled",
	flags = CV_CALL|CV_NETVAR,
	func = function(var)
		if multiplayer then
			CONS_Printf(consoleplayer, "[Dimps Style] This console variable is disabled in multiplayer.")
		end

		change_var = var.value
	end,
	PossibleValue = {disabled=0, enabled=1}
}

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
-- Setup functions
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
--	In-Game Handler (SP only)
--

local function G_StylesTallyBackend(p)
	if multiplayer or not end_tallyenabled then return end
	if not (p.mo and p.mo.valid) then return end
	if p.bot then return end

	if marathonmode then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	if G_GametypeUsesCoopStarposts() and G_GametypeUsesLives() then

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
				p.mo.flags = $|MF_NOCLIPTHING

				-- STOP
				if p.yusonictable and p.yusonictable.endlvl then
					p.yusonictable.endlvl = 0
				end

				-- Initial Setup of Tally
				if p.exiting == 7 then
					p.styles_tallytimer = -100
					p.styles_tallyfakecounttimer = calc_help.Y_GetTimingCalculation(p)
					p.styles_tallyendtime = p.styles_tallyfakecounttimer + 5*TICRATE
					p.styles_tallylastscore = p.score
					p.styles_tallylastlives = p.lives

					p.powers[pw_invulnerability] = 0
					p.powers[pw_sneakers] = 0
					p.powers[pw_extralife] = 0
					p.powers[pw_super] = 0

					S_StopMusic(p)
					p.styles_tallytrack = "_CLEAR"

					if mapheaderinfo[gamemap].bonustype > 0 then
						p.styles_tallytrack = "_CLEZO"
					end

					S_ChangeMusic(p.styles_tallytrack, false, p, 0, 0, 0, 0)
					p.styles_tallyposms = 0
					p.styles_tallystoplooping = nil
					p.styles_tallysoundlenght = S_GetMusicLength()

					p.exiting = 5
				-- Background Process
				elseif p.styles_tallytimer ~= nil then
					p.exiting = 5

					-- Sending the 222s to score counter. Mainly to grant all lives and everything like that.
					if p.styles_tallytimer > 0 and p.styles_tallytimer < p.styles_tallyfakecounttimer then

						if p.cmd.buttons & BT_SPIN then
							p.styles_tallytimer = p.styles_tallyfakecounttimer
							P_AddPlayerScore(p, calc_help.Y_CalculateAllScore(p) - max(p.score - p.styles_tallylastscore, 0))
						else
							if p.styles_tallytimer < p.styles_tallyfakecounttimer - 1 then
								P_AddPlayerScore(p, 222)
							else
								P_AddPlayerScore(p, calc_help.Y_CalculateAllScore(p) - max(p.score - p.styles_tallylastscore, 0))
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
							S_ChangeMusic(p.styles_tallytrack, false, p, 0, p.styles_tallyposms, 0, 0)

							if p.styles_tallystoplooping or (p.styles_tallysoundlenght - MUSICRATE <= p.styles_tallyposms) then
								S_StopMusic(p)
								p.styles_tallystoplooping = true
							end
						elseif cur_music and cur_music == p.styles_tallytrack then
							if p.styles_tallysoundlenght - MUSICRATE > p.styles_tallyposms then
								p.styles_tallyposms = S_GetMusicPosition()

								if p.styles_tallyposms == p.styles_tallysoundlenght then
									p.styles_tallystoplooping = true
								end
							end
						end
					end

					p.styles_tallytimer = $+1

					if p.styles_tallytimer > p.styles_tallyendtime then
						p.exiting = 1
						p.styles_tallylastscore = p.score
						p.styles_tallylastlives = p.lives
						G_ExitLevel()
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
