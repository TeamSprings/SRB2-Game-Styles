/*
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
*/

freeslot("MT_BACKERADUMMY", "MT_NONPRIORITYERADUMMY", "MT_FRONTTIERADUMMY", "MT_PRIORITYERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "S_DUMMYMONITOR", "S_DUMMYGMONITOR", "SPR_1MOA", "SPR_CA1D")

mobjinfo[MT_EXTRAERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

mobjinfo[MT_BACKERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = -1
}

mobjinfo[MT_FRONTERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = 1
}

mobjinfo[MT_FRONTTIERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_SCENERY,
	dispoffset = 2
}

states[S_DUMMYMONITOR] = {
	sprite = SPR_1MOA,
	frame = A
}

states[S_DUMMYGMONITOR] = {
	sprite = SPR_1MOA,
	frame = B
}

states[S_BOX_FLICKER].nextstate = S_DUMMYMONITOR
states[S_GOLDBOX_FLICKER].nextstate = S_DUMMYGMONITOR
states[S_GOLDBOX_OFF7].nextstate = S_DUMMYGMONITOR

states[S_XPLD_FLICKY].sprite = SPR_CA1D
states[S_XPLD_FLICKY].frame = A
states[S_XPLD1].sprite = SPR_CA1D
states[S_XPLD1].frame = A
states[S_XPLD1].tics = 3
states[S_XPLD2].sprite = SPR_CA1D
states[S_XPLD2].frame = B
states[S_XPLD2].tics = 3
states[S_XPLD3].sprite = SPR_CA1D
states[S_XPLD3].frame = C
states[S_XPLD3].tics = 3
states[S_XPLD4].sprite = SPR_CA1D
states[S_XPLD4].frame = D
states[S_XPLD4].tics = 3
states[S_XPLD5].sprite = SPR_CA1D
states[S_XPLD5].frame = E
states[S_XPLD5].tics = 3
states[S_XPLD5].nextstate = S_NULL

states[S_IVSP].tics = 15
states[S_IVSP].var1 = 3
states[S_IVSP].var2 = 3


mobjinfo[MT_TOKEN].radius = 89*FRACUNIT
mobjinfo[MT_TOKEN].height = 89*FRACUNIT

addHook("MapThingSpawn", function(a)
	if a.nsides then
		for _,key in ipairs(a.nsides) do
			P_RemoveMobj(key)
		end

		a.nsides = nil
	end
	if a.wsides then
		for _,key in ipairs(a.wsides) do
			P_RemoveMobj(key)
		end

		a.wsides = nil
	end

	P_RemoveMobj(a)
end, MT_TOKEN)

addHook("MapThingSpawn", function(a)
	a.ring = P_SpawnMobjFromMobj(a, -200*cos(a.angle+ANGLE_90), -200*sin(a.angle+ANGLE_90), 64*FRACUNIT, MT_TOKEN)
	a.ring.endleveltoken = true
end, MT_SIGN)

addHook("MobjThinker", function(a)
	for p in players.iterate() do
		a.rings = p.rings
	end
	if emeralds < 7 then
		if a.rings >= 50 then
			a.ring.flags2 = $ &~ MF2_DONTDRAW
		else
			a.ring.flags2 = $|MF2_DONTDRAW
		end
	end
end, MT_SIGN)

addHook("MobjSpawn", function(a)
	a.state = S_INVISIBLE
	a.nsides = {}
	a.wsides = {}
	for i = 1,4 do
		local sideSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BUSH)
		sideSpawn.target = a
		sideSpawn.scale = a.scale
		sideSpawn.id = i
		sideSpawn.state = S_BUSH
		sideSpawn.sprite = SPR_TOKE
		sideSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		if i < 3
			sideSpawn.radius = 89*FRACUNIT
			sideSpawn.height = FRACUNIT
			sideSpawn.frame = A|FF_PAPERSPRITE
			table.insert(a.nsides, sideSpawn)
		else
			sideSpawn.radius = FRACUNIT
			sideSpawn.height = FRACUNIT
			sideSpawn.frame = B|FF_PAPERSPRITE
			table.insert(a.wsides, sideSpawn)
		end
	end
end, MT_TOKEN)

addHook("TouchSpecial", function(a, k)
	if a.flags2 &~ MF2_DONTDRAW then
		for _,key in ipairs(a.nsides) do
			key.flags2 = MF2_DONTDRAW
		end
		for _,key in ipairs(a.wsides) do
			key.flags2 = MF2_DONTDRAW
		end
		G_ExitLevel()
	end
end, MT_TOKEN)

addHook("MobjThinker", function(a)
	if a and a.valid
		a.angle = $ + ANG1*3
		for _,key in ipairs(a.nsides) do
			local ang = a.angle + key.id*ANGLE_180
			key.angle = ang + ANGLE_90
			P_SetOrigin(key, a.x + 12*cos(ang), a.y + 12*sin(ang), a.z-20*FRACUNIT)
			if a.flags2 & MF2_DONTDRAW
				key.flags2 = $|MF2_DONTDRAW
			else
				key.flags2 = $ &~ MF2_DONTDRAW
			end
		end
		for i,key in ipairs(a.wsides) do
			local ang = a.angle - key.id*ANGLE_180 - ANGLE_90
			key.angle = ang + ANGLE_90
			P_SetOrigin(key, a.x + 56*cos(ang), a.y + 56*sin(ang), a.z-20*FRACUNIT)
			if a.flags2 & MF2_DONTDRAW
				key.flags2 = $|MF2_DONTDRAW
			else
				key.flags2 = $ &~ MF2_DONTDRAW
			end
		end
	end
end, MT_TOKEN)