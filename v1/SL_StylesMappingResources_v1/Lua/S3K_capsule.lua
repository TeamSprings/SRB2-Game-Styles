freeslot("SPR_S3KC")

addHook("MapThingSpawn", function(a, tm)
	a.radius = 46*FU
	a.height = 84*FU
	a.spaz = a.z
	P_TeleportMove(a, tm.x*FU, tm.y*FU, tm.z*FU-a.scale*200)
	a.disty = -a.scale*200
	
	for sector in sectors.iterate do
		if sector.tag == 680 or sector.tag == 681 or sector.tag == 682 then
			sector.tag = 0
		end
	end
	
	a.capsule = {}
	a.scale = $+FU/4
		local topSuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BUSH)
		topSuSpawn.target = a
		topSuSpawn.scale = a.scale
		topSuSpawn.state = S_BUSH
		topSuSpawn.sprite = SPR_S3KC
		topSuSpawn.frame = E
		topSuSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		topSuSpawn.offx = 0
		topSuSpawn.offy = 0
		table.insert(a.capsule, topSuSpawn)
	for i = 1,8 do
		local ang = tm.angle*ANG1+i*(ANG1*(360/8))
		local sideSpawn = P_SpawnMobjFromMobj(a, 46*cos(ang), 46*sin(ang),0, MT_BUSH)
		sideSpawn.target = a
		sideSpawn.scale = a.scale
		sideSpawn.state = S_BUSH
		sideSpawn.sprite = SPR_S3KC
		sideSpawn.frame = (i % 4)|FF_PAPERSPRITE
		sideSpawn.angle = ang+ANGLE_90
		sideSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		sideSpawn.offx = 46*cos(ang)
		sideSpawn.offy = 46*sin(ang)
		table.insert(a.capsule, sideSpawn)		
	end
	for i = 1,4 do
		local ang = tm.angle*ANG1+i*ANGLE_90
		local supportSpawn = P_SpawnMobjFromMobj(a, 30*cos(ang), 30*sin(ang),0, MT_NONPRIORITYERADUMMY)
		supportSpawn.target = a
		supportSpawn.scale = a.scale		
		supportSpawn.state = S_BUSH
		supportSpawn.sprite = SPR_S3KC
		supportSpawn.frame = F
		supportSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		supportSpawn.offx = 30*cos(ang)
		supportSpawn.offy = 30*sin(ang)
		table.insert(a.capsule, supportSpawn)		
	end	
	for i = 1,8 do
		local ang = tm.angle*ANG1+i*(ANG1*(360/8))
		local butSpawn = P_SpawnMobjFromMobj(a, 26*cos(ang), 26*sin(ang),0, MT_BUSH)
		butSpawn.target = a
		butSpawn.scale = a.scale
		butSpawn.state = S_BUSH
		butSpawn.sprite = SPR_S3KC
		butSpawn.frame = (i % 2)+10|FF_PAPERSPRITE
		butSpawn.angle = ang+ANGLE_90
		butSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		butSpawn.offx = 26*cos(ang)
		butSpawn.offy = 26*sin(ang)
		table.insert(a.capsule, butSpawn)		
	end
	for i = 1,16 do
		local ang = tm.angle*ANG1+i*(ANG1*(360/8))
		local butSpawn = P_SpawnMobjFromMobj(a, 40*cos(ang), 40*sin(ang),0, MT_BUSH)
		butSpawn.target = a
		butSpawn.scale = a.scale
		butSpawn.state = S_BUSH
		butSpawn.sprite = SPR_S3KC
		butSpawn.frame = G
		butSpawn.angle = ang+ANGLE_90
		butSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		butSpawn.offx = 40*cos(ang)
		butSpawn.offy = 40*sin(ang)
		table.insert(a.capsule, butSpawn)		
	end
	for i = 1,2 do
		local ang = tm.angle*ANG1+ANGLE_180*i-ANGLE_45
		local sideSpawn = P_SpawnMobjFromMobj(a, 48*cos(ang), 48*sin(ang),0, MT_BUSH)
		sideSpawn.target = a
		sideSpawn.scale = a.scale
		sideSpawn.state = S_BUSH
		sideSpawn.sprite = SPR_S3KC
		sideSpawn.frame = H
		sideSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		sideSpawn.offx = 48*cos(ang)
		sideSpawn.offy = 48*sin(ang)
		table.insert(a.capsule, sideSpawn)		
	end	
	for i = 1,2 do
		local ang = tm.angle*ANG1+ANGLE_180*i-ANGLE_45
		local butSpawn = P_SpawnMobjFromMobj(a, 48*cos(ang), 48*sin(ang),0, MT_BUSH)
		butSpawn.target = a
		butSpawn.scale = a.scale
		butSpawn.state = S_BUSH
		butSpawn.sprite = SPR_S3KC
		butSpawn.frame = I
		butSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		butSpawn.offx = 48*cos(ang)
		butSpawn.offy = 48*sin(ang)
		table.insert(a.capsule, butSpawn)		
	end		

		local topYuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BUSH)
		topYuSpawn.target = a
		topYuSpawn.scale = a.scale
		topYuSpawn.state = S_BUSH
		topYuSpawn.sprite = SPR_S3KC
		topYuSpawn.frame = J
		topYuSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		topYuSpawn.offx = 0
		topYuSpawn.offy = 0
		table.insert(a.capsule, topYuSpawn)		
end, MT_EGGTRAP)

addHook("MobjThinker", function(a)
	if not a.boss and a.disty < 0 then
		for mo in mobjs.iterate() do
			if mo.flags & MF_BOSS then
				a.boss = mo
			end
		end
	end

	if a.boss and a.boss.valid and a.boss.health <= 0 then
		a.activate = true
		a.flags = $|MF_SOLID & ~(MF_NOSECTOR|MF_NOBLOCKMAP)		
	end
		
	if a.activate == true and a.disty < 0 then
		a.disty = $+a.scale*2
		P_TeleportMove(a, a.x, a.y, a.spaz+a.disty)
		for k,v in ipairs(a.capsule) do
			P_TeleportMove(v, a.x+FixedMul(v.offx, a.scale), a.y+FixedMul(v.offy, a.scale), a.z)
		end
	end
	
	if a.disty == 0 then
		a.activatable = true
	end
	
	if a.activated == true and not a.fuse then
		a.fuse = 6*TICRATE
	end
	
	if a.fuse > 3*TICRATE then
				local z = a.subsector.sector.floorheight + FU + (P_RandomKey(a.height/FU) << FRACBITS)		
				local fa = P_RandomRange(1,360) *ANG1
				local ns = a.radius
				local x = a.x + FixedMul(sin(fa), ns)
				local y = a.y + FixedMul(cos(fa), ns)

				local mo2 = P_SpawnMobj(x, y, z, MT_EXPLODE)
				mo2.state = S_XPLD_EGGTRAP -- so the flickies don't lose their target if they spawn
				ns = 2*FU
				mo2.momx = FixedMul(sin(fa), ns)
				mo2.momy = FixedMul(cos(fa), ns)
				mo2.angle = fa
				S_StartSound(mo2, a.info.deathsound)
				
				local flicky = P_SpawnMobjFromMobj(a, FixedMul(sin(fa), ns)/2, FixedMul(cos(fa), ns)/2, z/2, MT_RAY)
				A_FlickySpawn(flicky)
	end
	
	
end, MT_EGGTRAP)

addHook("MobjCollide", function(a,mt)
	if mt.player and a.activatable == true then
		local discenter = P_AproxDistance(a.x - mt.x, a.y - mt.y)
		if discenter < 26*a.scale and a.z+a.height+10*FU > mt.z then
			a.activated = true
		end
	end
end, MT_EGGTRAP)

addHook("MobjFuse", function(a)
	G_ExitLevel()
end, MT_EGGTRAP)

