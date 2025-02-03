--[[

		Adventure Checkpoints

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local MapthingCheckpoints = {thg = {}; dis = {};}

local Disable_Checkpoints = false

addHook("MapChange", function()
	Disable_Checkpoints = false
	if CV_FindVar("dc_checkpoints").value == 0 then
		Disable_Checkpoints = true
	end

	MapthingCheckpoints.thg = {}
	MapthingCheckpoints.dis = {}
end)

local function P_SpawnCheckPoint(a)
		-- Set up of Adventure Checkpoint
		a.state = S_INVISIBLE
		a.sprite = SPR_CHE0
		a.frame = A
		a.flags2 = $|MF2_DONTDRAW

		if a.base == nil then
			a.base = {}
			a.pads = {}
			a.stick = {}
			a.bulb = {}
		end

		-- clean up
		for i = 1, 2 do
			if a.base[i] then
				P_RemoveMobj(a.base[i])
			end

			if a.stick[i] then
				P_RemoveMobj(a.stick[i])
			end

			if a.bulb[i] then
				P_RemoveMobj(a.bulb[i])
			end

			if a.pads[i] then
				P_RemoveMobj(a.pads[i])
			end

			--print("yes, checkpoints are cleaned")
			a.pads[i], a.base[i], a.stick[i], a.bulb[i] = nil,nil,nil,nil
		end

		-- Model build

		table.insert(MapthingCheckpoints.thg, a)
		local thingnum = MapthingCheckpoints.thg
		a.idmt = #thingnum

		if not MapthingCheckpoints.dis[a.idmt] then
			MapthingCheckpoints.dis[a.idmt] = {}
			MapthingCheckpoints.dis[a.idmt].dis = 1280
		end

		for i = 1,2 do
			local ang = a.angle+ANGLE_180*i-ANGLE_90
			local base, pad, stick, bulb

			if not a.base[i] then
				base = P_SpawnMobjFromMobj(a, 73*cos(ang), 73*sin(ang),0, MT_FRONTERADUMMY)
				base.state = S_INVISIBLE
				base.sprite = a.sprite
				base.angle = ang
				base.frame = A
				base.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
				base.flags2 = $|MF2_LINKDRAW
				table.insert(a.base, base)
			end

			if not a.pads[i] then
				pad = P_SpawnMobjFromMobj(a, 56*cos(ang), 56*sin(ang),0, MT_BACKTIERADUMMY)
				pad.state = S_INVISIBLE
				pad.sprite = a.sprite
				pad.angle = ang
				pad.frame = B
				pad.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
				pad.flags2 = $|MF2_LINKDRAW
				table.insert(a.pads, pad)
			end

			if not a.stick[i] then
				stick = P_SpawnMobjFromMobj(base, 0, 0, 44*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1), MT_BACKTIERADUMMY)
				stick.state = S_INVISIBLE
				stick.sprite = a.sprite
				stick.angle = ang
				if i == 1 then
					stick.frame = C|FF_PAPERSPRITE
					stick.rollangle = ANGLE_180
					stick.angle = ang+ANGLE_180
				else
					stick.frame = C|FF_PAPERSPRITE
				end
				stick.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
				stick.flags2 = $|MF2_LINKDRAW
				table.insert(a.stick, stick)
			end

			if not a.bulb[i] then
				bulb = P_SpawnMobjFromMobj(base, -49*cos(ang), -49*sin(ang),36*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1), MT_FRONTERADUMMY)
				bulb.state = S_INVISIBLE
				bulb.sprite = a.sprite
				bulb.angle = ang
				bulb.frame = E
				bulb.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
				bulb.flags2 = $|MF2_LINKDRAW
				bulb.dispoffset = 16
				table.insert(a.bulb, bulb)
			end
		end
end

sfxinfo[freeslot("sfx_advche")].caption = "Checkpoint"
mobjinfo[MT_STARPOST].painsound = sfx_advche

addHook("MobjThinker", function(a)
	if Disable_Checkpoints then return end

	if not (a.base and a.base[1]) then
		P_SpawnCheckPoint(a)
		a.ohnomorecheckpoints = nil
	end

	local thglist = MapthingCheckpoints.thg
	if a.checksurrondings == nil and #thglist > 1 then
		for k,rvmt in ipairs(MapthingCheckpoints.thg) do
			if rvmt and rvmt.valid then
				local dist = P_AproxDistance(a.x - rvmt.x, a.y - rvmt.y)/FRACUNIT
				local distz = abs(a.z - rvmt.z)
				--print(distz)

				if distz < 50*FRACUNIT and dist < MapthingCheckpoints.dis[a.idmt].dis and a.health == rvmt.health and k ~= a.idmt then
					MapthingCheckpoints.dis[a.idmt].x = rvmt.x
					MapthingCheckpoints.dis[a.idmt].y = rvmt.y
					MapthingCheckpoints.dis[a.idmt].dis = dist
					--print("yes, checkpoints are triggered")
					a.ohnomorecheckpoints = 1
				end
			end
		end
		--print("yes, checked surrondings")
		a.checksurrondings = 1
	end

	local ang = a.angle-ANGLE_90

	if a.ohnomorecheckpoints ~= nil then
		ang = R_PointToAngle2(a.x, a.y, MapthingCheckpoints.dis[a.idmt].x or 0, MapthingCheckpoints.dis[a.idmt].y or 0)

		if a.pads[2] then
			P_TryMove(a, a.x+25*cos(ang), a.y+25*sin(ang), true)
			P_RemoveMobj(a.base[2])
			P_RemoveMobj(a.stick[2])
			P_RemoveMobj(a.bulb[2])
			P_RemoveMobj(a.pads[2])
			--print("yes, checkpoints are cleaned")
			a.pads[2], a.base[2], a.stick[2], a.bulb[2] = nil,nil,nil,nil
		end
	end

	for id,pad in ipairs(a.pads) do
		pad.angle = ang+ANGLE_180*id
		P_SetOrigin(pad,
		a.x+56*cos(ang+ANGLE_180*id),
		a.y+56*sin(ang+ANGLE_180*id),
		a.z)
	end

	for id,base in ipairs(a.base) do
		base.angle = ang+ANGLE_180*id
		P_SetOrigin(base,
		a.x+73*cos(ang+ANGLE_180*id),
		a.y+73*sin(ang+ANGLE_180*id),
		a.z)
	end

	if a.state == S_STARPOST_SPIN and not a.sprong then

		local decreasespd = ease.linear((a.tics*FRACUNIT)/states[S_STARPOST_SPIN].tics, 47*ANG1, 36*ANG1)

		for id,stick in ipairs(a.stick) do
			stick.angle =  $ + (id == 1 and decreasespd or -decreasespd)
			P_SetOrigin(stick, a.base[id].x, a.base[id].y, a.z+44*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1))
		end

		for id,bulb in ipairs(a.bulb) do
			bulb.frame = F
			bulb.angle =  $ + (id == 1 and decreasespd or -decreasespd)
			P_SetOrigin(bulb, a.base[id].x-49*cos(bulb.angle), a.base[id].y-49*sin(bulb.angle), a.z+36*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1))
		end
	elseif a.state == S_STARPOST_FLASH then
		a.sprong = true

		if a.angv == nil then
			a.angv = 0
		end

		if a.angv <= 105 then
			a.angv = $+5
		end

		local calcangle = ease.outquad((a.angv*FRACUNIT)/110, 0, -90*ANG1-10)
		local decreasespd = ease.outquint((a.angv*FRACUNIT)/110, 27*ANG1, 0)
		local height = ease.outquad((a.angv*FRACUNIT)/110, 0, 58)

		if a.angv < 110 then

			for id,stick in ipairs(a.stick) do
				stick.rollangle = (id == 1 and ANGLE_180-calcangle or calcangle)
				stick.angle =  $ + (id == 1 and decreasespd or -decreasespd)

				P_SetOrigin(stick,
				a.base[id].x,
				a.base[id].y,
				a.z+45*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1))
			end

			for id,bulb in ipairs(a.bulb) do
				bulb.angle =  $ + (id == 1 and decreasespd or -decreasespd)

				P_SetOrigin(bulb,
				a.base[id].x-57*cos(bulb.angle)+height*cos(bulb.angle),
				a.base[id].y-57*sin(bulb.angle)+height*sin(bulb.angle),
				a.z+(36+height)*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1))
			end
		end

		if a.angv == 110 then
			if (a.stick[1].frame & FF_PAPERSPRITE) or (a.stick[2] and a.stick[2].frame & FF_PAPERSPRITE) then
				for id,stick in ipairs(a.stick) do
					stick.frame = I &~ FF_PAPERSPRITE
				end
			end

			for id,bulb in ipairs(a.bulb) do
				bulb.frame = F
				P_SetOrigin(bulb,
				a.base[id].x,
				a.base[id].y,
				a.z+(35+height)*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1))
			end

			for id,stick in ipairs(a.stick) do
				P_SetOrigin(stick,
				a.base[id].x,
				a.base[id].y,
				a.z+35*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1))
			end

		end

	else

		for id,stick in ipairs(a.stick) do
			stick.angle = ang
			P_SetOrigin(stick, a.base[id].x, a.base[id].y, a.z+44*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1))
		end

		for id,bulb in ipairs(a.bulb) do
			bulb.angle = ang+ANGLE_180*id
			P_SetOrigin(bulb, a.base[id].x-49*cos(bulb.angle), a.base[id].y-49*sin(bulb.angle), a.z+36*FRACUNIT*(a.flags2 & MF2_OBJECTFLIP and -1 or 1))
		end

	end

end, MT_STARPOST)

local shields = {
	{SH_WHIRLWIND, SPR_TVWW};
	{SH_ARMAGEDDON, SPR_TVAR};
	{SH_ELEMENTAL, SPR_TVEL};
	{SH_ATTRACT, SPR_TVAT};
	{SH_FORCE|1, SPR_TVFO};
}

local function insertPlayerItemToHud(p, sprite, frame)
	if p and not p.boxdisplay then
		p.boxdisplay = {}
	end
	if p and not p.boxdisplay.item then
		p.boxdisplay.item = {}
	end
	p.boxdisplay.timer = TICRATE*3
	table.insert(p.boxdisplay.item, {sprite, frame})
end


local rewards = {
	[1] = function(p)
		P_GivePlayerRings(p, 5)
		insertPlayerItemToHud(p, SPR_TV_SA2RINGMONITORS, E)
	end;
	[2] = function(p)
		P_GivePlayerRings(p, 10)
		insertPlayerItemToHud(p, SPR_TVRI, C)
	end;
	[3] = function(p)
		P_GivePlayerRings(p, 20)
		insertPlayerItemToHud(p, SPR_TV_SA2RINGMONITORS, A)
	end;
	[4] = function(p)
		p.powers[pw_sneakers] = sneakertics + 6 * TICRATE - TICRATE/2 - 1

		if consoleplayer == p and not p.powers[pw_super] then
			if S_SpeedMusic(0) and mapheaderinfo[gamemap].levelflags & LF_SPEEDMUSIC then
				S_SpeedMusic(FRACUNIT + 4*FRACUNIT/10)
			else
				P_PlayJingle(p, JT_SHOES)
			end
		end

		insertPlayerItemToHud(p, SPR_TVSS, C)
	end;
	[5] = function(p)
		if not p.powers[pw_shield] then
			P_SwitchShield(p, SH_PITY)
			insertPlayerItemToHud(p, SPR_TVPI, C)
		elseif p.powers[pw_shield] == SH_PITY then
			if CV_FindVar("dc_replaceshields").value then
				P_SwitchShield(p, SH_ATTRACT)
				insertPlayerItemToHud(p, SPR_TVAT, C)
			else
				local Random = P_RandomRange(1, 5)
				P_SwitchShield(p, shields[Random][1])
				insertPlayerItemToHud(p, shields[Random][2], C)
			end
		end
	end;
}

addHook("TouchSpecial", function(a,t)
	if t.player and t.player.starposttime < leveltime then

		t.player.checkpointtime = TICRATE*3

		if not (Disable_Checkpoints or a.giveaway) then
			if t.player.rings > 19 then
				local rewardsplit = t.player.rings/20
				if rewardsplit < 5 then
					rewards[rewardsplit](t.player)
				else
					rewards[5](t.player)
				end
			end
			a.giveaway = 1
		end
	end
end, MT_STARPOST)

addHook("PlayerThink", function(p)
	if not p.boxdisplay or not p.boxdisplay.timer then
		p.boxdisplay = {}
	end

	if p.boxdisplay.timer then
		p.boxdisplay.timer = $ - 1
	end

	if p.checkpointtime then
		p.checkpointtime = $ - 1
	end
end)

