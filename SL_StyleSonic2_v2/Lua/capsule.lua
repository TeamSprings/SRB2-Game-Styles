/* 
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
*/

freeslot("SPR_S2CA")

addHook("MapThingSpawn", function(a, tm)
	a.scale = $+FRACUNIT/4
		local topSuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BUSH)
		topSuSpawn.target = a
		topSuSpawn.scale = a.scale
		topSuSpawn.state = S_BUSH
		topSuSpawn.sprite = SPR_S2CA
		topSuSpawn.frame = E
		topSuSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION	
	for i = 1,8 do
		local ang = tm.angle*ANG1+i*(ANG1*(360/8))
		local sideSpawn = P_SpawnMobjFromMobj(a, 46*cos(ang), 46*sin(ang),0, MT_BUSH)
		sideSpawn.target = a
		sideSpawn.scale = a.scale
		sideSpawn.state = S_BUSH
		sideSpawn.sprite = SPR_S2CA
		sideSpawn.frame = (i % 4)|FF_PAPERSPRITE
		sideSpawn.angle = ang+ANGLE_90
		sideSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
	end
	for i = 1,4 do
		local ang = tm.angle*ANG1+i*ANGLE_90
		local supportSpawn = P_SpawnMobjFromMobj(a, 30*cos(ang), 30*sin(ang),0, MT_NONPRIORITYERADUMMY)
		supportSpawn.target = a
		supportSpawn.scale = a.scale		
		supportSpawn.state = S_BUSH
		supportSpawn.sprite = SPR_S2CA
		supportSpawn.frame = F
		supportSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
	end	
	for i = 1,8 do
		local ang = tm.angle*ANG1+i*(ANG1*(360/8))
		local butSpawn = P_SpawnMobjFromMobj(a, 26*cos(ang), 26*sin(ang),0, MT_BUSH)
		butSpawn.target = a
		butSpawn.scale = a.scale
		butSpawn.state = S_BUSH
		butSpawn.sprite = SPR_S2CA
		butSpawn.frame = (i % 2)+10|FF_PAPERSPRITE
		butSpawn.angle = ang+ANGLE_90
		butSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
	end
	for i = 1,8 do
		local ang = tm.angle*ANG1+i*(ANG1*(360/8))
		local butSpawn = P_SpawnMobjFromMobj(a, 40*cos(ang), 40*sin(ang),0, MT_BUSH)
		butSpawn.target = a
		butSpawn.scale = a.scale
		butSpawn.state = S_BUSH
		butSpawn.sprite = SPR_S2CA
		butSpawn.frame = G|FF_PAPERSPRITE
		butSpawn.angle = ang+ANGLE_90
		butSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
	end

		local topSuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BUSH)
		topSuSpawn.target = a
		topSuSpawn.scale = a.scale
		topSuSpawn.state = S_BUSH
		topSuSpawn.sprite = SPR_S2CA
		topSuSpawn.frame = J
		topSuSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
end, MT_EGGTRAP)
