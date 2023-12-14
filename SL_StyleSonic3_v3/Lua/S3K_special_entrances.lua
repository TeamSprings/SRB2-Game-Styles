
//
// Bonus Stage Entrance
//

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
		G_SetCustomExitVars(164, 1)
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

//
// Special Stage Ring Token
//

mobjinfo[MT_TOKEN].radius = 89*FRACUNIT
mobjinfo[MT_TOKEN].height = 89*FRACUNIT

addHook("MapThingSpawn", function(a)
	a.state = S_INVISIBLE
	a.nsides = {} 
	a.wsides = {} 	
	for i = 1,4 do
		local sideSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_FRONTERADUMMY)
		sideSpawn.target = a
		sideSpawn.scale = a.scale		
		sideSpawn.id = i
		sideSpawn.state = S_BUSH
		sideSpawn.sprite = SPR_TOKE
		sideSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		if i < 3
			sideSpawn.radius = 89*FRACUNIT
			sideSpawn.height = 171*FRACUNIT				
			sideSpawn.frame = A|FF_PAPERSPRITE
			table.insert(a.nsides, sideSpawn)
		else
			sideSpawn.radius = 10*FRACUNIT	
			sideSpawn.height = 171*FRACUNIT				
			sideSpawn.frame = B|FF_PAPERSPRITE
			table.insert(a.wsides, sideSpawn)		
		end
	end		
end, MT_TOKEN)

addHook("TouchSpecial", function(a, k)
	for _,key in ipairs(a.nsides) do 
		key.flags2 = MF2_DONTDRAW
	end
	for _,key in ipairs(a.wsides) do 
		key.flags2 = MF2_DONTDRAW
	end
	if not multiplayer then
		if not All7Emeralds(emeralds) then
			G_SetCustomExitVars(776, 1)
			sphereplayer.lastpos.map = gamemap
			sphereplayer.lastpos.x = k.x
			sphereplayer.lastpos.y = k.y
			sphereplayer.lastpos.z = k.z		
			sphereplayer.lastpos.angle = k.angle
			sphereplayer.lastpos.checkpoint = k.player.starpostnum
			sphereplayer.lastpos.leveltime = leveltime			
			sphereplayer.lastpos.powerup = k.player.powers[pw_shield]
			local countemr = 0
			local multic = 1	
			for i = 1,6 do
				multic = $*2
				countemr = (emeralds & multic) and $+1 or $
			end
			sphereplayer.map = countemr+1
			G_ExitLevel()
		elseif k.player then
			k.player.rings = $+50
		end
		P_KillMobj(a)
		return true
	end
end, MT_TOKEN)

addHook("MobjThinker", function(a)
	if a and a.valid
		a.angle = $ + ANG1*3
		for _,key in ipairs(a.nsides) do
			local ang = a.angle + key.id*ANGLE_180
			key.angle = ang + ANGLE_90
			P_TeleportMove(key, a.x + 12*cos(ang), a.y + 12*sin(ang), a.z-20*FRACUNIT)
		end
		for i,key in ipairs(a.wsides) do
			local ang = a.angle - key.id*ANGLE_180 - ANGLE_90
			key.angle = ang + ANGLE_90 
			P_TeleportMove(key, a.x + 56*cos(ang), a.y + 56*sin(ang), a.z-20*FRACUNIT)
		end	
	end
end, MT_TOKEN)