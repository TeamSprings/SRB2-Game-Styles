/* 
		Sonic Adventure Style's Capsule

Contributors: Ace Lite
@Team Blue Spring 2022-2023

*/


//
// S3K Code currently, model in progress.
//


freeslot("SPR_SA1C")

addHook("MapThingSpawn", function(a, tm)
	a.radius = 46*FRACUNIT
	a.height = 88*FRACUNIT
	a.spaz = a.z
	a.scale = $+FRACUNIT/6
	P_TeleportMove(a, tm.x*FRACUNIT, tm.y*FRACUNIT, tm.z*FRACUNIT-a.scale*200)
	a.disty = -a.scale*200
	
	for sector in sectors.iterate do
		if sector.tag == 680 or sector.tag == 681 or sector.tag == 682 then
			sector.tag = 0
		end
	end
	
	a.capsule = {}
	for i = 1,8 do
		local ang = tm.angle*ANG1+i*(ANG1*(360/8))
		local sideSpawn = P_SpawnMobjFromMobj(a, 51*cos(ang), 51*sin(ang),0, MT_EXTRAERADUMMY)
		sideSpawn.target = a
		sideSpawn.scale = a.scale
		sideSpawn.state = S_BUSH
		sideSpawn.sprite = SPR_SA1C
		sideSpawn.frame = 1+(i % 2)|FF_PAPERSPRITE
		sideSpawn.angle = ang+ANGLE_90
		sideSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		sideSpawn.offx = 51*cos(ang)
		sideSpawn.offy = 51*sin(ang)
		table.insert(a.capsule, sideSpawn)		
	end
	for i = 1,4 do
		local ang = tm.angle*ANG1+i*ANGLE_90+ANGLE_45
		local supportSpawn = P_SpawnMobjFromMobj(a, 60*cos(ang), 60*sin(ang),0, MT_EXTRAERADUMMY)
		supportSpawn.target = a
		supportSpawn.scale = a.scale		
		supportSpawn.state = S_BUSH
		supportSpawn.sprite = SPR_SA1C
		supportSpawn.frame = F
		supportSpawn.angle = ang		
		supportSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		supportSpawn.offx = 60*cos(ang)
		supportSpawn.offy = 60*sin(ang)
		table.insert(a.capsule, supportSpawn)		
	end
	for i = 1,8 do
		local ang = tm.angle*ANG1+i*(ANG1*(360/8))
		local butSpawn = P_SpawnMobjFromMobj(a, 39*cos(ang), 39*sin(ang),0, MT_EXTRAERADUMMY)
		butSpawn.target = a
		butSpawn.scale = a.scale
		butSpawn.state = S_BUSH
		butSpawn.sprite = SPR_SA1C
		butSpawn.frame = G|FF_PAPERSPRITE
		butSpawn.angle = ang+ANGLE_90
		butSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		butSpawn.offx = 39*cos(ang)
		butSpawn.offy = 39*sin(ang)
		table.insert(a.capsule, butSpawn)		
	end
		local topYuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_FRONTERADUMMY)
		topYuSpawn.target = a
		topYuSpawn.scale = a.scale
		topYuSpawn.state = S_BUSH
		topYuSpawn.sprite = SPR_SA1C
		topYuSpawn.frame = A
		topYuSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
		topYuSpawn.offx = 0
		topYuSpawn.offy = 0
		table.insert(a.capsule, topYuSpawn)
		
		local topYuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BACKTIERADUMMY)
		topYuSpawn.target = a
		topYuSpawn.scale = a.scale
		topYuSpawn.state = S_BUSH
		topYuSpawn.sprite = SPR_SA1C
		topYuSpawn.frame = H
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
	
	if a.disty == -a.scale*200 then
		for k,v in ipairs(a.capsule) do
			v.flags2 = $|MF2_DONTDRAW
		end
	elseif a.capsule[1].flags2 & MF2_DONTDRAW then
		for k,v in ipairs(a.capsule) do
			v.flags2 = $ &~ MF2_DONTDRAW
		end		
	end
	
	
	if a.activate == true and a.disty < 0 then
		a.disty = $+a.scale*2
		P_TeleportMove(a, a.x, a.y, a.spaz+a.disty)
		for k,v in ipairs(a.capsule) do
			P_TeleportMove(v, a.x+FixedMul(v.offx, a.scale), a.y+FixedMul(v.offy, a.scale), a.z)
		end
	end
	
	if a.disty == 0
		a.activatable = true
	end
	
	if a.activated == true and a.fusecounter == nil then
		a.fusecounter = 3*TICRATE
	end
	
	if a.fusecounter then
		a.fusecounter = $-1
	end
	
	if a.fusecounter and a.fusecounter > TICRATE then

		for k,v in ipairs(a.capsule) do
			if v and v.valid then
				if v.frame == B|FF_PAPERSPRITE then
					v.frame = D|FF_PAPERSPRITE
				end
				if v.frame == C|FF_PAPERSPRITE then
					v.frame = E|FF_PAPERSPRITE
				end
				if v.frame == A then
					P_RemoveMobj(v)
				end
			end
		end



		local z = a.subsector.sector.floorheight + FRACUNIT + (P_RandomKey((FixedMul(2*a.height/3, a.scale))/FRACUNIT) << FRACBITS)		
		local fa = P_RandomRange(1,360) *ANG1
		local ns = a.radius
		local x = a.x + FixedMul(sin(fa), ns)
		local y = a.y + FixedMul(cos(fa), ns)
		if (leveltime % 3)/2 then
			local mo2 = P_SpawnMobj(x, y, z, MT_EXPLODE)
			mo2.state = S_XPLD_EGGTRAP // so the flickies don't lose their target if they spawn
			ns = 2*FRACUNIT
			mo2.momx = FixedMul(sin(fa), ns)
			mo2.momy = FixedMul(cos(fa), ns)
			mo2.angle = fa
			S_StartSound(mo2, a.info.deathsound)
				
			local flicky = P_SpawnMobj(x, y, z, MT_RAY)
			A_FlickySpawn(flicky)
		end
	end
	
	if a.fusecounter and a.fusecounter == 2 then
		for p in players.iterate() do
			P_DoPlayerExit(p)
		end
	end
end, MT_EGGTRAP)

addHook("MobjCollide", function(a,mt)
	if mt.player and a.activatable == true then
		local discenter = P_AproxDistance(a.x - mt.x, a.y - mt.y)
		if discenter < 26*a.scale and a.z+a.height+10*FRACUNIT > mt.z then
			a.activated = true
			a.flags = $ &~ MF_NOCLIPTHING
		end
	end
end, MT_EGGTRAP)

