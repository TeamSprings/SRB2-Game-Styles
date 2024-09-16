local finishSectors = {}
local exitmap, superexit, skiptally, checkemerald

addHook("PlayerSpawn", function(p)
	p.startscore = p.score
end)

local function hacksForCustomCustomExit()
	finishSectors = {}
	exitmap, superexit, skiptally, checkemerald = nil, nil, nil, nil

	for s in sectors.iterate do
		for i = 1, 4 do
			local special = GetSecSpecial(s.special, i)
			if special == 8192 then
				finishSectors[#s] = {s, s.tag}
			end
		end
	end

	local customsettings = {}

	for l in lines.iterate do
		if l.special == 2 then
			table.insert(customsettings, l)
		end
	end

	for lid,l in ipairs(customsettings) do
		for sid,sec in ipairs(finishSectors) do
			if sec[2] == l.tag then
				local seclng = sec[1]
				finishSectors[#seclng] = {sec[1], sec[1].tag, l.frontsector.floorheight, l.frontsector.ceilingheight, l.flags}
			end
		end
	end
end

addHook("MapLoad", hacksForCustomCustomExit)

local function P_InterpretingStandingExitSector(s)
	if finishSectors[#s] then
		exitmap, superexit = (finishSectors[#s][3] and finishSectors[#s][3] or mapheaderinfo[gamemap].nextlevel), (finishSectors[#s][4] and finishSectors[#s][4] or mapheaderinfo[gamemap].nextlevel)

		if finishSectors[#s][5] then
			skiptally = (finishSectors[#s][5] & ML_NOCLIMB and true or false)
			checkemerald = (finishSectors[#s][5] & ML_BLOCKMONSTERS and true or false)
		else
			skiptally = false
			checkemerald = false
		end

		return exitmap, superexit, skiptally, checkemerald
	else
		return nil
	end
end

local function P_NewSA2Exit(exitmap, superexit, checkemerald)
	if checkemerald and All7Emeralds(emeralds) then
		G_SetCustomExitVars(superexit, 1)
	else
		G_SetCustomExitVars(exitmap, 1)
	end
end

local function P_BackEndOfTally(p)
	if p.mrce and p.mrce.hud then
		p.mrce.hud = 2
	end

	if not p.sa2 then
		p.sa2 = {}
	end

	if G_GametypeUsesCoopStarposts() and G_GametypeUsesLives() and not p.urhudon then
		local exitmap, superexit, skiptally, checkemerald = P_InterpretingStandingExitSector(p.mo.subsector.sector)
		if (p.sa2.currentmap and p.sa2.currentmap ~= gamemap) or not p.sa2.currentmap then
			P_NewSA2Exit(exitmap, superexit, checkemerald)
			p.sa2.currentmap = exitmap
		end
	end

	if G_EnoughPlayersFinished() and G_GametypeUsesCoopStarposts() and G_GametypeUsesLives() then

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

			if p.exiting == 6 then
				p.tallytimer = 13*TICRATE
				p.exiting = 5

				if not p.mo.advposecamera then
					p.mo.advposecamera = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_THOK)
					p.mo.advposecamera.state = S_INVISIBLE
					p.awayviewmobj = p.mo.advposecamera
				end
			elseif p.tallytimer then
				if p.tallytimer == 1 then
					p.exiting = 1
				else
					p.exiting = 5
				end
				if hud.skiptallysa and p.tallytimer > 4*TICRATE then
					p.tallytimer = 4*TICRATE
					-- I wanted to do it but whatever, Demnyx you have this one
					S_StopMusic(p)
					S_StartSound(p.mo, sfx_advchi)
					hud.skiptallysa = nil
				end

				--[[
				if p.tallytimer == 12*TICRATE-TICRATE/2 then
					local signpost
					for mo in p.mo.subsector.sector.thinglist() do
						if mo.type == MT_SIGN then
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

addHook("PlayerThink", P_BackEndOfTally)


addHook("KeyDown", function(key)
	if hud.tallysa then
		if key.num == input.gameControlToKeyNum(GC_SPIN) then
			hud.skiptallysa = true
		end
		return true
	end
end)
