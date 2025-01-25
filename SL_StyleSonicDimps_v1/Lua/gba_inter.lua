--[[

	Intermission Backend

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local finishSectors = {}
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

	p.styles_tallytimer = nil
end)


--
--	Setpiece functions
--

local skiptally = false
local customexit = nil

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
		if skip then
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
end)

--
--	Search Custom Exits
--

local function Hack_SearchCustomExits()
	finishSectors = {}
	skiptally = false

	for s in sectors.iterate do

		if (s.specialflags & SSF_EXIT) then
			local l_id = P_FindSpecialLineFromTag(2, s.tag)

			if l_id and lines[l_id] then
				local l = lines[l_id]

				finishSectors[s] = {
					s,
					s.tag,
					s.floorheight,
					s.ceilingheight,
					l.flags,
					l.args,
				}
			else
				finishSectors[s] = {
					s,
					s.tag,
					s.floorheight,
					s.ceilingheight,
					nil,
					nil,
				}
			end
		end

	end
end

addHook("MapLoad", Hack_SearchCustomExits)

--
-- Setup functions
--

local function G_InteprateStyleSectors(s)
	if finishSectors[s][5] then
		local finish = finishSectors[s]

		local binary_skip = ((finish[5] & ML_NOCLIMB) and true or skiptally)
		local udmf_skip = ((finish[6][1] & TMEF_SKIPTALLY) and true or skiptally)

		skiptally = udmf_skip and true or binary_skip
	end
end

local function G_InitiateNewExit()
	G_SetCustomExitOriginal(nil, 1)
end

--
--	In-Game Handler (SP only)
--

local function G_StylesTallyBackend(p)
	if multiplayer or not end_tallyenabled then return end
	if not (p.mo and p.mo.valid) then return end
	if marathonmode then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	if G_GametypeUsesCoopStarposts() and G_GametypeUsesLives() then

		-- Handles cases with skiptally, hopefully.
		if not p.urhudon then
			local spacial_sec = P_MobjTouchingSectorSpecialFlag(p.mo, SSF_EXIT)

			if spacial_sec and finishSectors[spacial_sec] then
				G_InteprateStyleSectors(spacial_sec)
			end

			G_InitiateNewExit()
		end


		if G_EnoughPlayersFinished() then
			if not skiptally then
				p.mo.flags = $|MF_NOCLIPTHING

				-- STOP
				if p.yusonictable and p.yusonictable.endlvl then
					p.yusonictable.endlvl = 0
				end

				-- Initial Setup of Tally
				if p.exiting == 6 then
					p.styles_tallytimer = -100
					p.styles_tallyfakecounttimer = calc_help.Y_GetTimingCalculation(p)
					p.styles_tallyendtime = p.styles_tallyfakecounttimer + 5*TICRATE
					p.styles_tallylastscore = p.score
					p.exiting = 5

					if mapheaderinfo[gamemap].bonustype == 1 then
						S_ChangeMusic("_CLEARZO", false, p)
					else
						S_ChangeMusic("_CLEAR", false, p)
					end
					p.styles_lasttrack = S_MusicName(p)

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

					local cur_music = S_MusicName(p)
					if cur_music and cur_music ~= p.styles_lasttrack and string.upper(cur_music) ~= "_1UP" then
						S_StopMusic(p)
					elseif not S_MusicPlaying(p) then
						S_ResumeMusic(p)
					end

					p.styles_tallytimer = $+1

					if p.styles_tallytimer > p.styles_tallyendtime then
						p.exiting = 1
						G_ExitLevel()
						return
					end
				end
			end

			if p.exiting == 1 then
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
end)

addHook("PlayerThink", G_StylesTallyBackend)
