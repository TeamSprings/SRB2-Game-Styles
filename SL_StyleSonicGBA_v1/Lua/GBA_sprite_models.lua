/* 
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
*/

freeslot("MT_BACKERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "S_DUMMYMONITOR", "S_ERASMOKE1", "S_ERASMOKE2", "SPR_CA1D", "SPR_CA2D", "SPR_1CAP", "SPR_CHE0", "SPR_1MOA")

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

states[S_ERASMOKE1] = {
	sprite = SPR_CA2D,
	frame = FF_ANIMATE|A,
	tics = 15,
	var1 = 4,
	var2 = 3
}

states[S_ERASMOKE2] = {
	sprite = SPR_CA1D,
	frame = FF_ANIMATE|A,
	tics = 32,
	var1 = 7,
	var2 = 4
}

states[S_DUMMYMONITOR] = {
	sprite = SPR_1MOA,
	frame = B
}

states[S_GOLDBOX_OFF7].nextstate = S_DUMMYMONITOR

addHook("MapThingSpawn", function(a, mt)
	if a.info.flags & MF_MONITOR then
		a.state = S_DUMMYMONITOR
		
		if a.info.flags & MF_GRENADEBOUNCE then
			a.frame = B
		else
			a.frame = A
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
			if a.state ~= S_DUMMYMONITOR
				if a.state == a.info.spawnstate then
					a.state = S_DUMMYMONITOR
				else			
					a.item.flags2 = $|MF2_DONTDRAW
				end
			else
				if a.item.flags2 & MF2_DONTDRAW then 
					a.item.flags2 = $ &~ MF2_DONTDRAW
				end
				A_SmokeTrailer(a, MT_BOXSPARKLE)
			end			
		else
			P_TeleportMove(a.item, a.x, a.y, a.z+14*FRACUNIT)
		end		
		
	end
end, MT_NULL)

states[S_XPLD_FLICKY].sprite = SPR_CA1D
states[S_XPLD_FLICKY].frame = A
states[S_XPLD1].sprite = SPR_CA1D
states[S_XPLD1].frame = A
states[S_XPLD1].tics = 4
states[S_XPLD2].sprite = SPR_CA1D
states[S_XPLD2].frame = B
states[S_XPLD2].tics = 4
states[S_XPLD3].sprite = SPR_CA1D
states[S_XPLD3].frame = C
states[S_XPLD3].tics = 4
states[S_XPLD4].sprite = SPR_CA1D
states[S_XPLD4].frame = D
states[S_XPLD4].tics = 4
states[S_XPLD4].nextstate = S_NULL
 
addHook("MobjDeath", function(a, mt)
	if a.info.flags & MF_MONITOR and not (a.info.flags & MF_GRENADEBOUNCE) then
		a.item.flags2 = $|MF2_DONTDRAW	
		a.flags2 = $|MF2_DONTDRAW
		a.flags = $ &~ MF_SOLID
					
		local smuk = P_SpawnMobjFromMobj(a, 0,0,0, MT_EXTRAERADUMMY)
		smuk.state = S_XPLD1
		smuk.fuse = 32 
		smuk.scale = a.scale	
		
		local boxicon = P_SpawnMobjFromMobj(a.item, 0,0,0, mobjinfo[a.type].damage)
		boxicon.scale = a.item.scale
		boxicon.target = mt
		return true
	end
end, MT_NULL)

addHook("MobjSpawn", function(a, tm)
	a.state = S_ERASMOKE1
end, MT_SONIC3KBOSSEXPLODE)

addHook("MapThingSpawn", function(a)
	a.state = S_BUSH
	a.sprite = SPR_TOKE
	a.frame = R|FF_PAPERSPRITE
	a.nsides = {} 
	for i = 1,2 do
		local sideSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BUSH)
		sideSpawn.target = a
		sideSpawn.scale = a.scale		
		sideSpawn.id = i
		sideSpawn.state = S_BUSH
		sideSpawn.sprite = SPR_TOKE
		sideSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
		sideSpawn.frame = Q|FF_PAPERSPRITE
		table.insert(a.nsides, sideSpawn)
	end
end, MT_TOKEN)


addHook("MobjDeath", function(a)
	for _,key in ipairs(a.nsides) do 
		P_RemoveMobj(key)
	end
end, MT_TOKEN)

addHook("MobjThinker", function(a)
	if a and a.valid
		a.angle = $ + ANG1*3
		for _,key in ipairs(a.nsides) do
			local ang = a.angle + key.id*ANGLE_180
			key.angle = ang + key.id*ANGLE_180+ANGLE_90
			P_TeleportMove(key, a.x + 2*cos(ang), a.y + 2*sin(ang), a.z)
		end
	end
end, MT_TOKEN)
