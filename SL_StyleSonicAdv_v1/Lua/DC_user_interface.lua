/* 
		User Interfaces inspired by Sonic Adventure 2.

Contributors: Ace Lite, Demnyx
@Team Blue Spring 2022-2023

*/

local function spfontdw(d, font, x, y, scale, value, flags, color, alligment, padding, leftadd)
	local patch, val
	local str = ''..value
	local fontoffset, allig, actlinelenght = 0, 0, 0
	local trans = V_TRANSLUCENT

	if leftadd ~= nil and leftadd ~= 0 then
		local strlefttofill = leftadd-#str
		if strlefttofill > 0 then
			for i = 1,strlefttofill do
				str = ";"..str
			end
		end
	end

	for i = 1,#str do
		val = string.sub(str, i,i)
		patch = d.cachePatch(font..''..val)
		if not d.patchExists(font..''..val) then
			if d.patchExists(font..''..string.byte(val)) then
				patch = d.cachePatch(font..''..string.byte(val))
			else
				patch = d.cachePatch('SA2NUMNONE')
			end
		end		
		actlinelenght = $+patch.width+(padding or 0)
	end
	
	if alligment == "center" then
		allig = FixedMul(-actlinelenght/2*FRACUNIT, scale)
	elseif alligment == "right" then
		allig = FixedMul(-actlinelenght*FRACUNIT, scale)	
	end
	
	for i = 1,#str do
		val = string.sub(str, i,i)
		if val ~= nil then
			patch = d.cachePatch(font..''..val)
			if not d.patchExists(font..''..val) then
				if d.patchExists(font..''..string.byte(val)) then
					patch = d.cachePatch(font..''..string.byte(val))
				else
					patch = d.cachePatch('SA2NUMNONE')
				end
			end
 		else
			return
		end
		d.drawScaled(FixedMul(x+allig+(fontoffset)*FRACUNIT, scale), FixedMul(y, scale), scale, patch, (val == ";" and flags|trans or flags), color)
		fontoffset = $+patch.width+(padding or 0)
	end

	
end

//
//	GAMEPLAY
//



local Bosses = {}

addHook("MapChange", function()
	Bosses = {}
end)

addHook("MapThingSpawn", function(a, mt)
	if a.info.flags & MF_BOSS then
		table.insert(Bosses, a)
	end
end)


// function for monitor display

local function gainMonDisplay(v, p)
	if p.boxdisplay and p.boxdisplay.timer and p.boxdisplay.item then
		local lenght = p.boxdisplay.item
		local tic = min(3*TICRATE-p.boxdisplay.timer, TICRATE/5)*FRACUNIT/(TICRATE/5)
		local tictransparency = max(min(p.boxdisplay.timer, TICRATE/4),0)*FRACUNIT/(TICRATE/4)
		local easesubtit = ease.linear(tic, FRACUNIT/2, 9*FRACUNIT/8)
		local easetratit = ease.linear(tictransparency, 9, 0)
		local offset = 161 
		
		for k,img in ipairs(p.boxdisplay.item) do
			local extra = 0
			if SPR_MMON then
				extra = (img[1] == SPR_MMON and -FRACUNIT*16 or 0)
			end
			local pic = v.getSpritePatch(img[1], img[2], 0)
			local incs = pic.width+6
			v.drawScaled(FixedDiv((offset-(incs*#lenght)/2+incs/2)*easesubtit, easesubtit), FixedDiv(180*easesubtit-extra, easesubtit), easesubtit, pic, V_PERPLAYER|(easetratit << V_ALPHASHIFT)|V_SNAPTOBOTTOM)
			offset = $ + incs
		end
	end
end



local function convertPlayerTime(time)
	local mint = G_TicsToMinutes(time, true)
	local sect = G_TicsToSeconds(time)
	local cent = G_TicsToCentiseconds(time)
	mint = (mint < 10 and '0'..mint or mint)
	sect = (sect < 10 and '0'..sect or sect)
	cent = (cent < 10 and '0'..cent or cent)
	
	return mint, sect, cent
end

local poweruporiginaly = hudinfo[HUD_POWERUPS].y

local function checkpointTimeDisplay(v, p)
	if p.checkpointtime then
		if (leveltime % 4)/2 then
			local mint, sect, cent = convertPlayerTime(p.starposttime)
		
			spfontdw(v, 'SA2TL', (290)*FRACUNIT, (240)*FRACUNIT, FRACUNIT-FRACUNIT/4, mint..':'..sect..':'..cent, 
			V_PERPLAYER|V_SNAPTORIGHT|V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, 0), 0, 1, 0)
		end
	end

	if not hud.powerupsatic then
		hud.powerupsatic = 0
	end

	if p.checkpointtime and hudinfo[HUD_POWERUPS].y > 154 then
		hud.powerupsatic = $+2
	elseif hudinfo[HUD_POWERUPS].y < 176 and not p.checkpointtime then
		hud.powerupsatic = $-2
	end		
	
	hudinfo[HUD_POWERUPS].y = poweruporiginaly - hud.powerupsatic
end


//
//	RANKING
//


local totalcoinnum = 0
local totalcoinnumrandm = 0

local function Y_ResetCounters()
	totalcoinnum = 0
	totalcoinnumrandm = 0	
	hud.smooth = nil
	hud.bosshealth = nil
	hud.bossbardecrease = nil
end

addHook("MapLoad", function(map)
	--local flickylist = mapheaderinfo[map].flickies
	--if flickylist then
		--for i = 0,6 do
			--if flickylist[i] then
				--print("flicky:"..flickylist[i])
			--end
		--end
		--print(#flickylist)
	--end
	
	local grades = mapheaderinfo[map].grades
	if grades then
		for i = 0,(#grades+1) do
			if grades[i] then			
				print("grade:"..grades[i])
			end
		end
		print(#grades)		
	end
end)


addHook("MapChange", Y_ResetCounters)

local function Y_GetTotalCoins(a)
	local totalrings, perfectbonus
	
	if (a.type == MT_RING or a.type == MT_COIN or a.type == MT_NIGHTSSTAR) then
		totalcoinnum = $ + 1
		totalcoinnumrandm = $ + 1
	end
	
	if (a.type == MT_RING_BOX) then
		totalcoinnum = $ + 10
		totalcoinnumrandm = $ + 1
	end	
	
	if (a.type == MT_NIGHTSDRONE) then
		perfectbonus = -1
	end	
		
end

addHook("MobjSpawn", Y_GetTotalCoins)

addHook("PlayerSpawn", function(p)
	p.startscore = p.score
end)

local function Y_GetTimeBonus(time)
	local secs = time/TICRATE
	local result
	
	if (secs <  30) then /*   :30 */ result = 50000
	elseif (secs <  60) then /*  1:00 */ result = 10000
	elseif (secs <  90) then /*  1:30 */ result = 5000
	elseif (secs < 120) then /*  2:00 */ result = 4000
	elseif (secs < 180) then /*  3:00 */ result = 3000
	elseif (secs < 240) then /*  4:00 */ result = 2000
	elseif (secs < 300) then /*  5:00 */ result = 1000
	elseif (secs < 360) then /*  6:00 */ result = 500
	elseif (secs < 420) then /*  7:00 */ result = 400
	elseif (secs < 480) then /*  8:00 */ result = 300
	elseif (secs < 540) then /*  9:00 */ result = 200
	elseif (secs < 600) then /* 10:00 */ result = 100
	else  /* TIME TAKEN: TOO LONG */ result = 0
	end
	
	return result
end

local function Y_GetGuardBonus(guardtime)
	local guardscoretype = {[0] = 10000, [1] = 5000, [2] = 1000, [3] = 500, [4] = 100}
	return (guardscoretype[guardtime] and guardscoretype[guardtime] or 0)
end

local function Y_GetRingsBonus(rings)
	return (max(0, (rings)*100))
end

local function Y_GetPerfectBonus(rings, perfectb, totrings)
	if (totrings == 0 or perfectb == -1 or rings < totrings) then 
		return 0 
	end
	
	if rings >= totrings then
		return 5000
	end
end


local function RankCounter(p)
	
	// Current Score
	
	local stagegainedscore = p.score - p.startscore
	
	local timescore = Y_GetTimeBonus(p.realtime)
	
	local ringscore = Y_GetRingsBonus(p.rings)
	
	local totalscore = stagegainedscore + timescore + ringscore
	
	// Requirement
	
	local requirementscore = 0
	
	if totalcoinnum == 0 or mapheaderinfo[gamemap].bonustype > 0 then 
		requirementscore = 5000 + Y_GetRingsBonus(mapheaderinfo[gamemap].startrings)
	else
		requirementscore = 10000 + Y_GetRingsBonus(totalcoinnum) + Y_GetRingsBonus(mapheaderinfo[gamemap].startrings)
	end
	
	// Compare score and requirement to result
	
	if totalscore > requirementscore/4 then
		return "A"
	elseif totalscore > requirementscore/7 then
		return "B"
	elseif totalscore > requirementscore/10 then
		return "C"
	elseif totalscore > requirementscore/12 then
		return "D"
	else
		return "E"
	end
	
end

//
// End Level Tally
//

local finishSectors = {}
local exitmap, superexit, skiptally, checkemerald

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
	if customhud then return end
	
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
				
				/*
				if p.tallytimer == 12*TICRATE-TICRATE/2 then
					local signpost
					for mo in p.mo.subsector.sector.thinglist() do
						if mo.type == MT_SIGN then
							signpost = mo
						end
					end
					
					if signpost and signpost.valid then
						local ang = singpost.angle-ANGLE_90
						P_TeleportMove(p.mo, signpost.x+50*cos(ang), signpost.y+50*sin(ang), signpost.z)
						p.mo.angle = ang
					end	
				end
				*/
				
				p.tallytimer = $-1
				local angeasemath = ease.insine(max(min(p.tallytimer-10*TICRATE+TICRATE/5, 3*TICRATE-TICRATE/3), 0)*FRACUNIT/(3*TICRATE-TICRATE/3), InvAngle(p.mo.angle-ANGLE_45), p.mo.angle-ANGLE_45)
				local distance = ease.insine(max(min(p.tallytimer-10*TICRATE+TICRATE/5, 3*TICRATE-TICRATE/3), 0)*FRACUNIT/(3*TICRATE-TICRATE/3), 100*FRACUNIT, 300*FRACUNIT)/FRACUNIT
				local aim = ease.insine(max(min(p.tallytimer-10*TICRATE+TICRATE/5, 3*TICRATE-TICRATE/3), 0)*FRACUNIT/(3*TICRATE-TICRATE/3), 0, -35*ANG1)
				local zdistance = ease.insine(max(min(p.tallytimer-10*TICRATE+TICRATE/5, 3*TICRATE-TICRATE/3), 0)*FRACUNIT/(3*TICRATE-TICRATE/3), p.mo.z+p.mo.height/2, p.mo.z+FixedMul(p.mo.height, 3*FRACUNIT))
				P_TeleportMove(p.mo.advposecamera, p.mo.x-distance*cos(angeasemath), p.mo.y-distance*sin(angeasemath), zdistance)
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

sfxinfo[freeslot("sfx_rank")].caption = "rank drop!"
sfxinfo[freeslot("sfx_advchi")].caption = "cha-ching!"
sfxinfo[freeslot("sfx_advtal")].caption = "tally"

local function tallyDrawer(v, p) 
	if customhud then return end
	// Ease and timing

	local textscaling = {}
	local transparency = {}
	local xcnt = {}

	for i = 1,5 do
		textscaling[i] = ease.linear(max(min(p.tallytimer-7*TICRATE-8*i, TICRATE/3), 0)*FRACUNIT/(TICRATE/3), FRACUNIT-3*FRACUNIT/8, 3*FRACUNIT)
		transparency[i] = ease.linear(max(min(p.tallytimer-7*TICRATE-8*i, TICRATE/3), 0)*FRACUNIT/(TICRATE/3), 1, 9) << V_ALPHASHIFT 
	end

	local fade = ease.linear(max(min(p.tallytimer-8*TICRATE-5, TICRATE/3), 0)*FRACUNIT/(TICRATE/3), 16, 0)

	local fadewhite = abs(abs(ease.linear(max(min(p.tallytimer-11*TICRATE, 3*TICRATE), 0)*FRACUNIT/(3*TICRATE), 10, -10))-10)

	local rankamp = ease.linear(max(min(p.tallytimer-2*TICRATE, TICRATE/3), 0)*FRACUNIT/(TICRATE/3), FRACUNIT, 3*FRACUNIT)
	local ranktrp = ease.linear(max(min(p.tallytimer-2*TICRATE, TICRATE/3), 0)*FRACUNIT/(TICRATE/3), 1, 9) << V_ALPHASHIFT

	local calculationtime = ease.linear(max(min(p.tallytimer-5*TICRATE, 3*TICRATE-TICRATE/2), 0)*FRACUNIT/(3*TICRATE-TICRATE/2), Y_GetTimeBonus(p.realtime), 0)


	// Sound effects

	-- stop music
	if p.tallytimer == 13*TICRATE-1 then 
		S_FadeOutStopMusic(MUSICRATE, p)
	end
	
	if p.tallytimer == 11*TICRATE then 
		P_PlayJingleMusic(p, "_ADVCLEAR", 0, false)
	end	

	if p.tallytimer == 8*TICRATE then S_StartSound(p.mo, sfx_advtal, p) end
	-- cha-ching! sound
	if p.tallytimer == 5*TICRATE then
		S_StartSound(nil, sfx_advchi, p) 
	end
	
	if hud.skiptallysa then 
		S_FadeOutStopMusic(MUSICRATE, p)
	end
	
	-- rank sound
	if p.tallytimer == 2*TICRATE then S_StartSound(nil, sfx_rank, p) end

	//
	//	SET-UP
	//
	
	v.fadeScreen(0, fadewhite)
	
	v.fadeScreen(0xFF00, fade)

	local z1, z2 = 56, 125
	local scale = ease.linear(max(min(p.tallytimer-8*TICRATE, TICRATE/4), 0)*FRACUNIT/(TICRATE/4), FRACUNIT-FRACUNIT/4, 1)
	local x1 = FixedDiv(162*scale, scale)
	local index = 5
	
	v.drawScaled(x1, FixedDiv(z1*scale, scale), scale, v.cachePatch("SA2TLPNA1"), V_PERPLAYER)
	v.drawScaled(x1, FixedDiv(z2*scale, scale), scale, v.cachePatch("SA2TLPNB1"), V_PERPLAYER)
	v.drawScaled(x1, FixedDiv(z1*scale, scale), scale, v.cachePatch("SA2TLPNA2"), V_50TRANS|V_PERPLAYER)
	v.drawScaled(x1, FixedDiv(z2*scale, scale), scale, v.cachePatch("SA2TLPNB2"), V_50TRANS|V_PERPLAYER)

	// Guard or Score
	
	if transparency[index] ~= V_90TRANS then
		
		local zscore = FixedDiv((z1+13)*textscaling[index], textscaling[index])
		
		local currentscore = ''..(p.score-p.startscore)
		local scorelen = (string.len(""..currentscore))
	
		local patch = v.cachePatch(mapheaderinfo[gamemap].bonustype > 0 and "SA2TLGRD" or "SA2TLSCR")
		v.drawScaled(FixedDiv((72+patch.leftoffset)*textscaling[index], textscaling[index]), 5*zscore/8, 
		textscaling[index], patch, V_PERPLAYER|transparency[index])

		spfontdw(v, 'SA2TL', FixedDiv((392-scorelen*6)*textscaling[index]-scorelen*textscaling[index]/4, 
		textscaling[index]), zscore-textscaling[index], textscaling[index], currentscore,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)	
	
	end
	
	// Time
	index = 4
	
	if transparency[index] ~= V_90TRANS then

		local ztime = FixedDiv((z1+35)*textscaling[index], textscaling[index])
		
		local mint, sect, cent = convertPlayerTime(p.realtime)
		local tallytime = ''..(mint..':'..sect..':'..cent)
	
	
		local patch = v.cachePatch("SA2TLTIME")
		v.drawScaled(FixedDiv((76+patch.leftoffset)*textscaling[index], textscaling[index]), 5*ztime/8, 
		textscaling[index], patch, V_PERPLAYER|transparency[index])
	
		spfontdw(v, 'SA2TL', FixedDiv(350*textscaling[index], textscaling[index]), ztime-textscaling[index], 
		textscaling[index], tallytime,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)
	
	end
	
	// Rings
	index = 3
	
	if transparency[index] ~= V_90TRANS then

		local zrings = FixedDiv((z1+57)*textscaling[index], textscaling[index])	
		local tallyrings = ''..(p.rings.."/"..(totalcoinnum + mapheaderinfo[gamemap].startrings or 0))
		local ringslen = (string.len(""..tallyrings))
	
		local patch = v.cachePatch("SA2TLRNG")
		v.drawScaled(FixedDiv((74+patch.leftoffset)*textscaling[index], textscaling[index]), 5*zrings/8, 
		textscaling[index], patch, V_PERPLAYER|transparency[index])
	
		spfontdw(v, 'SA2TL', FixedDiv((392-ringslen*6)*textscaling[index]-ringslen*textscaling[index]/4, 
		textscaling[index]), zrings-textscaling[index], textscaling[index], tallyrings,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)
	
	end
	
	// Time Bonus
	index = 2
		
	if transparency[index] ~= V_90TRANS then

		local timebonz = FixedDiv((z2+55)*textscaling[index], textscaling[index])
		local timebonus = ''..(Y_GetTimeBonus(p.realtime) - calculationtime)
		local timelen = (string.len(""..timebonus))
	
		local patch = v.cachePatch("SA2TLTB")
		v.drawScaled(FixedDiv((63+patch.leftoffset)*textscaling[index], textscaling[index]), 5*timebonz/8, 
		textscaling[index], patch, V_PERPLAYER|transparency[index])
	
		spfontdw(v, 'SA2TL', FixedDiv((392-timelen*6)*textscaling[index]-timelen*textscaling[index]/4, 
		textscaling[index]), timebonz, textscaling[index], timebonus,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)
	
	end
	
	// Total Score
	index = 1
		
	if transparency[index] ~= V_90TRANS then	

		local totalz = FixedDiv((z2+77)*textscaling[index], textscaling[index])
		local totalScore = ''..(Y_GetRingsBonus(p.rings)+(p.score-p.startscore)+calculationtime)
		local totallen = (string.len(""..totalScore))	
	
		local patch = v.cachePatch("SA2TLTS")
		v.drawScaled(FixedDiv((61+patch.leftoffset)*textscaling[index], textscaling[index]), 5*totalz/8, 
		textscaling[index], patch, V_PERPLAYER|transparency[index])

		spfontdw(v, 'SA2TL', FixedDiv((392-totallen*6)*textscaling[index]-totallen*textscaling[index]/4, 
		textscaling[index]), totalz, textscaling[index], totalScore,
		V_PERPLAYER|transparency[index], v.getColormap(TC_DEFAULT, 0), "right", 0, 0)
	
	end
	
	// Rank
	
	local rank = RankCounter(p)
	if rankamp ~= 3*FRACUNIT then
		local patch = v.cachePatch("SA2RANK"..rank)
		v.drawScaled(FixedDiv(144*rankamp, rankamp)+FixedDiv((patch.width/2)*rankamp, rankamp), 
		FixedDiv(158*rankamp, rankamp)+FixedDiv((patch.height/2)*rankamp, rankamp), rankamp, patch, V_PERPLAYER|ranktrp)
	end
	
end


/*
hud.add(function(v, p, t, e)
	local rank = RankCounter(p)
	v.draw(144, 10, v.cachePatch("SA2RANK"..rank))
end, "game")
*/

//
// In-Game Hook
//

hud.add(function(v, p, t, e)
	if G_GametypeUsesLives() and not p.urhudon then
		hud.disable("rings")
		hud.disable("time")
		hud.disable("score")
		hud.disable("lives")
		
		if not customhud then //Check of K.S. Custom Hud Framework. I should have use it...
			local mint, sect, cent = convertPlayerTime(p.realtime)
			local numrings = (p.rings > 99  and p.rings or (p.rings < 10 and '00'..p.rings or '0'..p.rings))
			local numlives = (p.lives < 10 and '0'..p.lives or p.lives)
			hud.transparency = ease.outsine(abs(((leveltime*FRACUNIT/22) % (2*FRACUNIT))+1-FRACUNIT), 0, 9) << V_ALPHASHIFT
	
			//
			//	RING/TIME/SCORE
			//
	
	
			v.drawScaled((hudinfo[HUD_RINGS].x+7)*FRACUNIT, (hudinfo[HUD_RINGS].y-10)*FRACUNIT, FRACUNIT/4*3, (not mariomode and v.cachePatch('SA2RINGS') or v.cachePatch('SA2COINS')), hudinfo[HUD_RINGS].f|V_PERPLAYER)
			spfontdw(v, 'SA2NUM', (hudinfo[HUD_SCORENUM].x-18)*FRACUNIT, (hudinfo[HUD_SECONDS].y-8)*FRACUNIT, FRACUNIT/4*3, p.score, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", 1, 8)
			spfontdw(v, 'SA2NUM', (hudinfo[HUD_SECONDS].x+6)*FRACUNIT, (hudinfo[HUD_SECONDS].y+4)*FRACUNIT, FRACUNIT/4*3, mint..':'..sect..':'..cent, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", 1, 0)
			spfontdw(v, 'SA2NUM', (hudinfo[HUD_RINGSNUM].x-37)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y+14)*FRACUNIT, FRACUNIT/4*3, numrings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 1, 0)
			if p.rings == 0 then spfontdw(v, 'SA2NUMR', (hudinfo[HUD_RINGSNUM].x-37)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y+14)*FRACUNIT, FRACUNIT/4*3, "000", hudinfo[HUD_RINGS].f|hud.transparency|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 1, 0) end
	
			if token then
				v.drawScaled((hudinfo[HUD_RINGS].x+65)*FRACUNIT, (hudinfo[HUD_RINGS].y-10)*FRACUNIT, FRACUNIT/4*3, v.cachePatch('SA2CHAO'), hudinfo[HUD_RINGS].f|V_PERPLAYER)
			end
			
			//
			//	LIFE COUNTER
			//
	
	
			local pos 
	
			if p.mo.skin == "adventuresonic" then
				pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}	
			else
				pos = {{-2,0}, {2,0}, {0,2}, {0,-2}}
			end


			for i = 1, 4 do
				v.draw((hudinfo[HUD_LIVES].x+16+pos[i][1]), (hudinfo[HUD_LIVES].y+6+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_ALLWHITE))
			end
			v.draw(hudinfo[HUD_LIVES].x+16, hudinfo[HUD_LIVES].y+6, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			spfontdw(v, 'SA2NUM', (hudinfo[HUD_LIVES].x+46)*FRACUNIT, (hudinfo[HUD_LIVES].y+58)*FRACUNIT, FRACUNIT/4*3, numlives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 1, 0)
	
			//
			//	BOSS HEALTH COUNTER
			//
	
	
			if Bosses and Bosses[1] and P_CheckSight(Bosses[1], p.mo) then
				
		
				local boss = Bosses[1]
		
		
		
				local curhealth = (boss.health and boss.health or 0)
				local maxhealth = boss.info.spawnhealth or 1
				local onehealth = FixedDiv(67*FRACUNIT, maxhealth*FRACUNIT)
				local prchealth = (curhealth == 0 and 0 or (FixedMul(FixedDiv(curhealth*FRACUNIT, maxhealth*FRACUNIT), 67*FRACUNIT)))
				if hud.bossbardecrease == nil then
					hud.bossbardecrease = 0
				end

				if not hud.bosshealthcountersmooth and (hud.bosshealth == nil or hud.bosshealth > curhealth) and hud.bossbardecrease == 0 then
					hud.bosshealthcountersmooth = hud.bosshealthcountersmooth and $+35 or 35
					hud.bosshealth = curhealth
				elseif hud.bosshealthcountersmooth ~= nil and hud.bosshealthcountersmooth > 0 then
					hud.bosshealthcountersmooth = $-1
				end
				
				if hud.bosshealthcountersmooth < 2 and curhealth == 0 and hud.bossbardecrease < 67*FRACUNIT then 
					hud.bossbardecrease = $+3*FRACUNIT
				end
				
				if hud.bossbardecrease < 67*FRACUNIT then

					v.draw(216, hudinfo[HUD_RINGS].y-28, v.cachePatch("SA2BOSSH1"), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)
					v.draw(216+(hud.bossbardecrease or 0)/FRACUNIT, hudinfo[HUD_RINGS].y-28, v.cachePatch("SA2BOSSHL"), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)
					v.draw(289, hudinfo[HUD_RINGS].y-28, v.cachePatch("SA2BOSSHR"), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)
				
					v.drawStretched(222*FRACUNIT+(hud.bossbardecrease or 0), (hudinfo[HUD_RINGS].y-28)*FRACUNIT, 67*FRACUNIT-(hud.bossbardecrease or 0), FRACUNIT, 
					v.cachePatch("SA2BOSSH2"), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)				
					v.drawStretched(222*FRACUNIT, (hudinfo[HUD_RINGS].y-20)*FRACUNIT, prchealth+(hud.bosshealthcountersmooth*onehealth)/35, FRACUNIT, 
					v.cachePatch((curhealth > maxhealth/5 and "SA2BOBAR2" or "SA2BOBAR1" )), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)

				end
			end
		
			//
			// EXTRA FUNCTIONS
			//

		end
		
		if not customhud or (customhud and customhud.CheckType and customhud.CheckType("time") == "sa1hud") then
			checkpointTimeDisplay(v, p)
				
			gainMonDisplay(v, p)
		end
		
		
		if p.exiting and p.tallytimer then
			hud.tallysa = true
			tallyDrawer(v, p)
		else
			hud.tallysa = nil
		end

	elseif not p.urhudon then
		hud.enable("rings")
		hud.enable("time")
		hud.enable("score")
		hud.enable("lives")	
	end
end, "game")

//
//	EMERALD DISPLAY
//

local emerald = {EMERALD1, EMERALD2, EMERALD3, EMERALD4, EMERALD5, EMERALD6, EMERALD7}

-- random rotating rocks + add there damn 8th Peaceful Ruby.
hud.add(function(v)
	-- "SCORES" Hook doesn't have player_t, so without iterating over everysingle... wait why MRCE.Hud isn't a global in first place?
	-- Damn it... you are making it harder than it should be.
	if multiplayer then	
		hud.enable("coopemeralds")
	else
		hud.disable("coopemeralds")
		//Off loading local variables for optimalization purposes
		local circlesplit = (360/#emerald)*ANG1
		local leveltimeang = ANGLE_225+(All7Emeralds(emeralds) and leveltime*ANG1 or 0)
		
		for id,k in ipairs(emerald) do
			// IF check compares from table whenever or not emerald is in player's possession
			if emeralds & k then
				local posang = id*circlesplit+leveltimeang
				
				// Cache that damn sprite
				local state = states[S_CEMG1+id-1]
				local patch = v.getSpritePatch(state.sprite, state.frame+(leveltime/state.var2 % state.var1), 0)
				v.draw((32*cos(posang)/FRACUNIT)+160, (32*sin(posang)/FRACUNIT)+100, patch, V_20TRANS|V_PERPLAYER)
			end
		end
	end
end, "scores")

//
//	TITLE CARD
//

hud.disable("stagetitle")

sfxinfo[freeslot("sfx_advtts")].caption = "titlecard"

hud.add(function(v, p, t, et)
	if customhud then return end
	local namezone = mapheaderinfo[gamemap].lvlttl..""
	local subtitle = mapheaderinfo[gamemap].subttl..""
	local actnum = mapheaderinfo[gamemap].actnum..""
	local stagenum = (gamemap < 9 and "0"..gamemap or ""..gamemap)
		
	// Splitting Level Name into Words
	local split = {}
	
	for w in namezone:gmatch("%S+") do table.insert(split, w) end
	
	if #split > 1 then
		for i = 2,#split do
			if #split[i] < 6 and (not split[i-1] or #split[i-1] < 9) then
				split[i-1] = $+" "..split[i]
				table.remove(split, i)
			end
		end
	end
	
	if (actnum ~= "0") then
		split[#split] = $+" "..actnum
	end
	
	// Sound Effects / Music
	
	if (leveltime <= et) then
		hud.p = p
		hud.sa2musicstop = (t <= (2*TICRATE+9) and 1 or 0)
		if hud.sa2musicstop then
			S_SetInternalMusicVolume(0, p)
		end
		if (t == TICRATE/2) then
			S_StartSound(nil, sfx_advtts, p)
		end
	end
	
	// Timer and easing functions
	local tic = min(t, TICRATE)*FRACUNIT/TICRATE
	local ticq = min(t, TICRATE-17)*FRACUNIT/(TICRATE-17)
	
	local easespin = ease.inquint(tic, 500, 0)
	local easegoout = ease.linear(max(min(t-2*TICRATE-9, TICRATE/2), 0)*FRACUNIT/(TICRATE/2), 0, 93)
	local easescaleout = ease.outsine((max(min(t-2*TICRATE/3-5, 2*TICRATE), 0)*FRACUNIT)/(2*TICRATE), FRACUNIT, 3*FRACUNIT/2)
		
	local easetransparency1 = ease.linear(max(min(t-2*TICRATE+TICRATE/3, TICRATE/3), 0)*FRACUNIT/(TICRATE/3), 5, 9)
		
	local easetransparency2 = ease.linear((max(min(t-2*TICRATE/3, TICRATE/3), 0)*FRACUNIT)/(TICRATE/3), 0, 9)
		
	local easetransparency3 = ease.linear((max(min(t-2*TICRATE-TICRATE/2, TICRATE/3), 0)*FRACUNIT)/(TICRATE/3), 0, 9)
	local easetransparency4 = ease.linear((max(min(t-2*TICRATE-TICRATE/2, TICRATE/3), 0)*FRACUNIT)/(TICRATE/3), 5, 9)
		
	local easespout = ease.inquint((max(min(t-5*TICRATE/2-9, TICRATE/2), 0)*FRACUNIT)/(TICRATE/2), 0, 500)
	
	local easesubtit = ease.linear(ticq, 1, FRACUNIT)
	local easespeen = ease.incubic(ticq, 90, 0)*ANG1
	local easetranp = ease.incubic(tic, 4, 9)
	local easescale = (ease.incubic(ticq, 500, 150)*FRACUNIT)/100
	
	// Actual Title Card Drawer
	if t < et then
	
		if leveltime <= et then
			v.fadeScreen(0xFF00, 31-(easegoout*31/93))
		end
	
		local lenght = split[#split]
	
		local SRB2tagsideline = v.cachePatch("SA2TTNAM")
	
		v.draw(0-easegoout,0, v.cachePatch("SA2TTBAR"), V_SNAPTOLEFT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, p.skincolor))
		
		if easetransparency2 ~= 9 then
			v.drawScaled(FixedDiv(41*easescaleout, easescaleout),FixedDiv(-50*easescaleout, easescaleout), easescaleout, SRB2tagsideline, V_SNAPTOLEFT|V_SNAPTOTOP|V_ADD|V_PERPLAYER|(easetransparency2 << V_ALPHASHIFT), v.getColormap(TC_DEFAULT, p.skincolor))
		end

		if easetransparency1 ~= 9 then
			v.draw(41,-50-(t % SRB2tagsideline.height), SRB2tagsideline, V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER|V_ADD|(easetransparency1 << V_ALPHASHIFT), v.getColormap(TC_DEFAULT, p.skincolor))
		end		
		
		// SPEEEEN
		
		local spinGhost = v.getSpritePatch(SPR_CHE0, H, 0, easespeen)
		
		if easetranp ~= 9 then
			v.drawScaled(FixedDiv((123+#lenght*13)*easescaleout+420, easescale), FixedDiv(75*easescaleout+185*sin(easespeen), easescale), easescale, spinGhost, V_ADD|V_PERPLAYER|(easetranp << V_ALPHASHIFT), v.getColormap(TC_DEFAULT, p.skincolor))
		end
		
		v.draw((96+#lenght*10)-easespin+easespout, 75, v.cachePatch("SA2TTSPIN"), 0, v.getColormap(TC_DEFAULT, p.skincolor))
	
		spfontdw(v, 'SA2TTFONT', (116+easespin-easespout)*FRACUNIT, 82*FRACUNIT, FRACUNIT-FRACUNIT/4, "Stage: "..stagenum, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, SKINCOLOR_SLATE), 0, -1, 0)
		
		// SUBTITLE
		
		if subtitle and subtitle ~= "" then
			for i = 1, 2 do
				v.drawScaled(FixedDiv(84*FRACUNIT, easesubtit), FixedDiv(140*FRACUNIT, easesubtit), easesubtit, v.cachePatch("SA2TTSUB"..i), ((i == 2 and easetransparency4 or easetransparency3) << V_ALPHASHIFT)|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.skincolor))
			end
			
			if t > TICRATE then
				spfontdw(v, 'COMSANSFT', 300*FRACUNIT, 300*FRACUNIT, FRACUNIT/2, subtitle, hudinfo[HUD_LIVES].f|(easetransparency3 << V_ALPHASHIFT)|V_PERPLAYER, v.getColormap(TC_DEFAULT, SKINCOLOR_CARBON), "center", 1, 0)
			end
			
		end
		
		// TITLE
		
		for i = 1, #split do
			local spliteaseout = ease.inquint((max(min(t-5*TICRATE/2-(i-1), TICRATE/2+(i-1)), 0)*FRACUNIT)/(TICRATE/2+(i-1)), 0, 500)
			spfontdw(v, 'SA2TTFONT', FixedDiv((96-(#split[i] > 8 and #split[i]*2 or 0)+easespin-spliteaseout)*FRACUNIT, FRACUNIT+FRACUNIT/2), FixedDiv((88+(i-1)*20)*FRACUNIT, FRACUNIT+FRACUNIT/2), FRACUNIT+FRACUNIT/2, split[i], hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, SKINCOLOR_SLATE), 0, -1, 0)
		end	
	
	end
end, "titlecard")


addHook("PreThinkFrame", do for p in players.iterate() do
		if hud.sa2musicstop then
			S_PauseMusic(p)
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

