--[[

		Sonic Adventure Style's Game Stuff

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local helper = 	tbsrequire 'helpers/c_inter'

-- Global that should have been exposed! Bruh.
local TMEF_SKIPTALLY = 1

--
--	Console Variable
--

local end_tallyenabled = 1
local change_var = -1

local endtally_cv = CV_RegisterVar{
	name = "dc_endtally",
	defaultvalue = "enabled",
	flags = CV_CALL,
	func = function(var)
		if multiplayer then
			CONS_Printf(consoleplayer, "[Adventure Style] This console variable is disabled in multiplayer.")
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

	p.tallytimer = nil
	p.startscore = p.score
end)

addHook("MapLoad", function()
	for p in players.iterate() do
		-- Anti exploit measure
		if p.styles_tallylastscore then
			p.score = p.styles_tallylastscore

			p.styles_tallylastscore = nil
		end
	end
end)


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

local function G_StylesTallyBackend(p)
	if multiplayer then return end
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

			if p.yusonictable and p.yusonictable.yuendcam then
				P_RemoveMobj(p.yusonictable.yuendcam)
				p.yusonictable.yuendcam = nil
			end

			if not skiptally then
				if p.yusonictable and p.yusonictable.endlvl then
					p.yusonictable.endlvl = 0
					if p.tallytimer then
						if p.tallytimer > 12*TICRATE or (p.yusonictable.bosskiller and p.tallytimer >= 10*TICRATE) then
							p.mo.state = S_PLAY_STND
							A_ForceStop(p.mo)
						elseif (p.tallytimer >= 10*TICRATE and p.tallytimer <= 12*TICRATE) and not (p.yusonictable.bosskiller) then
							p.mo.momx = 2*cos(p.mo.angle)
							p.mo.momy = 2*sin(p.mo.angle)
							p.rmomx = 2*FRACUNIT
							p.rmomy = 2*FRACUNIT
							if p.mo.state ~= S_PLAY_WALK then
								p.mo.state = S_PLAY_WALK
							end
						elseif p.tallytimer < 10*TICRATE then
							if p.yusonictable.bosskiller then
								if p.mo.state ~= S_PLAY_FLY then
									p.mo.state = S_PLAY_FLY
									p.yusonictable.tauntstate = 6
									p.mo.frame = Y
								end
							else
								if p.mo.state ~= S_PLAY_FLY then
									p.mo.state = S_PLAY_FLY
									p.yusonictable.tauntstate = 5
									p.mo.frame = 10
								end
							end
							if p.tallytimer == 10*TICRATE-1 then
								p.yusonictable.tauntcd = 120
							end
						end
					end
				end

				p.mo.flags = $|MF_NOCLIPTHING

				if p.exiting == 2*TICRATE+10 then
					p.tallytimer = 13*TICRATE
					p.exiting = 2*TICRATE+9
					p.styles_teleportToGround = true

					p.powers[pw_invulnerability] = 0
					p.powers[pw_sneakers] = 0
					p.powers[pw_extralife] = 0
					p.powers[pw_super] = 0

					if not p.mo.advposecamera then
						p.mo.advposecamera = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_THOK)
						p.mo.advposecamera.state = S_INVISIBLE
						p.awayviewmobj = p.mo.advposecamera
					end
				elseif p.tallytimer then
					if p.tallytimer == 1 then
						p.exiting = 1
					else
						p.exiting = 2*TICRATE+9
					end

					if p.tallytimer == 8*TICRATE then S_StartSound(p.mo, sfx_advtal, p) end

					if p.tallytimer == 11*TICRATE then
						p.styles_tallytrack = "_ADVCLEAR"

						P_PlayJingleMusic(p, p.styles_tallytrack, 0, false)
						p.styles_tallyposms = 0
						p.styles_tallystoplooping = nil
						p.styles_tallysoundlenght = S_GetMusicLength()
					elseif p.tallytimer < 11*TICRATE then
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
					end

					-- cha-ching! sound
					if p.tallytimer == 5*TICRATE then
						S_StartSound(nil, sfx_advchi, p)
					end

					if p.cmd.buttons & BT_SPIN and p.tallytimer > 4*TICRATE+1 then
						p.tallytimer = 4*TICRATE
						-- I wanted to do it but whatever, Demnyx you have this one
						S_StartSound(p.mo, sfx_advchi)
						S_StopSoundByID(p.mo, sfx_advtal)
					end

					if p.styles_teleportToGround then
						P_SetOrigin(p.mo, p.mo.x, p.mo.y, P_MobjFlip(p.mo) > 0 and p.mo.floorz or p.mo.ceilingz)
						p.styles_teleportToGround = nil
					end

					p.tallytimer = $-1
					local angeasemath = ease.insine(max(min(p.tallytimer-10*TICRATE+TICRATE/5, 3*TICRATE-TICRATE/3), 0)*FRACUNIT/(3*TICRATE-TICRATE/3), InvAngle(p.mo.angle-ANGLE_45), p.mo.angle-ANGLE_45)
					local distance = ease.insine(max(min(p.tallytimer-10*TICRATE+TICRATE/5, 3*TICRATE-TICRATE/3), 0)*FRACUNIT/(3*TICRATE-TICRATE/3), 100*FRACUNIT, 300*FRACUNIT)/FRACUNIT
					local aim = ease.insine(max(min(p.tallytimer-10*TICRATE+TICRATE/5, 3*TICRATE-TICRATE/3), 0)*FRACUNIT/(3*TICRATE-TICRATE/3), 0, -35*ANG1)
					local zdistance = ease.insine(max(min(p.tallytimer-10*TICRATE+TICRATE/5, 3*TICRATE-TICRATE/3), 0)*FRACUNIT/(3*TICRATE-TICRATE/3), p.mo.z+p.mo.height/2, p.mo.z+FixedMul(p.mo.height, 3*FRACUNIT))
					P_MoveOrigin(p.mo.advposecamera, p.mo.x-distance*cos(angeasemath), p.mo.y-distance*sin(angeasemath), zdistance)
					p.mo.advposecamera.angle = angeasemath
					p.awayviewmobj = p.mo.advposecamera
					p.awayviewtics = 14*TICRATE
					p.awayviewaiming = aim
					p.viewrollangle = -aim-15*ANG1
				end
			end

			if p.exiting == 1 then
				if not skiptally then
					p.styles_tallylastscore = p.score + helper.Y_GetAllBonus(p)
				end

				G_ExitLevel()
			end
		end
	end
end

addHook("PlayerThink", G_StylesTallyBackend)


addHook("KeyDown", function(key)
	if hud.tallysa then
		if key.num == input.gameControlToKeyNum(GC_SPIN) then
			hud.skiptallysa = true
		end
		return true
	end
end)

addHook("MapChange", function()
	customexit = nil
	lastspecialsector = nil
end)
