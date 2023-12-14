/* 
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
*/
freeslot("SPR_SSS0")

addHook("TouchSpecial", function(a, mt)
	if mt.player and mt.player.rings >= 25 and a.state == a.info.spawnstate and a.stars == nil then
		a.stars = {}
		a.stfuse = 350
		a.countdownst = 50
		
		for i = 1,16 do
			local ang = a.angle + i*ANG1*((360*FRACUNIT/16)/FRACUNIT)
			local stars = P_SpawnMobjFromMobj(a, 4*cos(ang), 4*sin(ang), a.height, MT_BUSH)
			stars.state = S_INVISIBLE
			stars.sprite = SPR_SSS0
			stars.frame = ((i % 2)*3)|FF_TRANS10|FF_FULLBRIGHT
			stars.renderflags = $|AST_ADD
			stars.angle = ang
			stars.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
			table.insert(a.stars, stars)
		end
	end
end,  MT_STARPOST)

addHook("MobjCollide", function(a, mt)
	if mt.player and (mt.z < a.z+a.height+12*FRACUNIT) and (mt.z > a.z+a.height-32*FRACUNIT) and a.stars ~= nil and a.stars[1].valid then
		G_SetCustomExitVars(50, 1)
		G_ExitLevel()
	end	
end,  MT_STARPOST)	

addHook("MobjThinker", function(a, mt)
		if a.vangle == nil
			a.vangle = 0
		end
		
		a.vangle = $+ANG1*5
		if a.stars ~= nil then
			if a.countdownst > 0 and a.stfuse > 50 then
				a.countdownst = $-1
			end
			if a.stfuse > 0 then
				a.stfuse = $-1
			end			
			
			if a.stfuse <= 50 then
				a.countdownst = $+1
			end			
			
			
			for i,star in ipairs(a.stars) do
				star.angle = $+4*ANG1
				star.frame = (((i % 2)*3+a.stfuse/4) % 6)|FF_TRANS10|FF_FULLBRIGHT
				P_TeleportMove(star, a.x+(55-a.countdownst)*cos(star.angle), a.y+(55-a.countdownst)*sin(star.angle), a.z+a.height+(12-a.countdownst/4)*sin(a.vangle+star.angle))
				if a.stfuse == 0
					a.stars = nil
					P_RemoveMobj(star)
				end
			end
		end
end,  MT_STARPOST)

freeslot("MT_PRIORITYERADUMMY", "MT_NONPRIORITYERADUMMY", "MT_BACKERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY", "S_DUMMYMONITOR", "S_DUMMYGMONITOR", "S_ERASMOKE1", "SPR_1MOA", "SPR_CA1D", "SPR_CA2D")

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

mobjinfo[MT_PRIORITYERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = 256	
}

mobjinfo[MT_NONPRIORITYERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = -256	
}

states[S_DUMMYMONITOR] = {
	sprite = SPR_1MOA,
	frame = A
}

states[S_DUMMYGMONITOR] = {
	sprite = SPR_1MOA,
	frame = B
}

states[S_ERASMOKE1] = {
	sprite = SPR_CA2D,
	frame = FF_ANIMATE|A,
	tics = 21,
	var1 = 6,
	var2 = 3
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
