--[[

		Sonic Adventure Style's Game Stuff

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]


local finishSectors = {}

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
			CONS_Printf(consoleplayer, "[Adventure Style] This console variable has no use in multiplayer.")
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

addHook("PlayerSpawn", function(p)
	p.startscore = p.score
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


local function G_StylesTallyBackend(p)
	if multiplayer then return end
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
					if p.cmd.buttons & BT_SPIN and p.tallytimer > 4*TICRATE+1 then
						p.tallytimer = 4*TICRATE
						-- I wanted to do it but whatever, Demnyx you have this one
						S_StopMusic(p)
						S_StartSound(p.mo, sfx_advchi)
					end

					--[[
					if p.tallytimer == 12*TICRATE-TICRATE/2 then
						local signpost
						for mo in p.mo.subsector.sector.thinglist() do
							if mo.type == MT_SIGN or MT_SA2_GOALRING then
								signpost = mo
							end
						end

						if signpost and signpost.valid then
							local ang = singpost.angle-ANGLE_90
							P_SetOrigin(p.mo, signpost.x+50*cos(ang), signpost.y+50*sin(ang), signpost.z)
							p.mo.angle = ang
						end
					end
					]]

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
end)
