/* 
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
*/

freeslot("MT_BACKERADUMMY", "MT_NONPRIORITYERADUMMY", "MT_PRIORITYERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "S_DUMMYMONITOR", "S_DUMMYGMONITOR", "SPR_1MOA", "SPR_CA1D")

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
addHook("MapThingSpawn", function(a, mt)
	if a.info.flags & MF_MONITOR then
		
		if a.info.flags & MF_GRENADEBOUNCE then
			a.state = S_DUMMYGMONITOR
		else
			a.state = S_DUMMYMONITOR
		end
		
		local icon = mobjinfo[a.type].damage
		local icstate = mobjinfo[icon].spawnstate
		local icsprite = states[icstate].sprite
		local icframe = states[icstate].frame	

		a.item = P_SpawnMobjFromMobj(a, 0,0,0, MT_FRONTERADUMMY)
		a.item.state = S_INVISIBLE
		a.item.sprite = icsprite
		a.item.frame = icframe
		a.item.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT	
	end
end, MT_NULL)

addHook("MobjThinker", function(a, mt)
	if a.info.flags & MF_MONITOR then
		if a.info.flags & MF_GRENADEBOUNCE then
			P_TeleportMove(a.item, a.x, a.y, a.z+15*FRACUNIT)
			if a.state ~= S_DUMMYGMONITOR			
				a.item.flags2 = $|MF2_DONTDRAW
			else
				if a.item.flags2 & MF2_DONTDRAW then 
					a.item.flags2 = $ &~ MF2_DONTDRAW
				end
				A_SmokeTrailer(a, MT_BOXSPARKLE)
			end
		else
			P_TeleportMove(a.item, a.x, a.y, a.z+14*FRACUNIT)
			if a.state == S_DUMMYMONITOR and a.health > 0
				if (leveltime % 3) / 2
					a.item.flags2 = $|MF2_DONTDRAW
					a.sprite = SPR_MSTV
					a.frame = A
				else
					a.item.flags2 = $ &~ MF2_DONTDRAW				
					a.sprite = SPR_1MOA
					a.frame = A					
				end
			end
		end		
		
	end
end, MT_NULL)

addHook("MobjDeath", function(a, mt)
	if a.info.flags & MF_MONITOR and not (a.info.flags & MF_GRENADEBOUNCE) then
		a.item.flags2 = $|MF2_DONTDRAW
		a.flags = $ &~ MF_SOLID
		a.sprite = SPR_MSTV
		a.frame = B		
		local boxicon = P_SpawnMobjFromMobj(a.item, 0,0,0, mobjinfo[a.type].damage)
		boxicon.scale = a.item.scale
		boxicon.target = mt
		return true
	end
end, MT_NULL)


mobjinfo[MT_TOKEN].radius = 89*FRACUNIT
mobjinfo[MT_TOKEN].height = 89*FRACUNIT



addHook("MapThingSpawn", function(a)
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
		G_SetCustomExitVars(50, 1)		
		G_ExitLevel()
	end
	return true
end, MT_TOKEN)

addHook("MobjThinker", function(a)
	if a and a.valid
		a.angle = $ + ANG1*3
		for _,key in ipairs(a.nsides) do
			local ang = a.angle + key.id*ANGLE_180
			key.angle = ang + ANGLE_90
			P_TeleportMove(key, a.x + 12*cos(ang), a.y + 12*sin(ang), a.z-20*FRACUNIT)
			if a.flags2 & MF2_DONTDRAW
				key.flags2 = $|MF2_DONTDRAW
			else
				key.flags2 = $ &~ MF2_DONTDRAW
			end
		end
		for i,key in ipairs(a.wsides) do
			local ang = a.angle - key.id*ANGLE_180 - ANGLE_90
			key.angle = ang + ANGLE_90 
			P_TeleportMove(key, a.x + 56*cos(ang), a.y + 56*sin(ang), a.z-20*FRACUNIT)
			if a.flags2 & MF2_DONTDRAW
				key.flags2 = $|MF2_DONTDRAW
			else
				key.flags2 = $ &~ MF2_DONTDRAW
			end
		end
	end
end, MT_TOKEN)