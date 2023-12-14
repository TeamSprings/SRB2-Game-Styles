addHook("MapThingSpawn", function(a, mt)
	a.state = S_INVISIBLE
	a.sprite = SPR_CEMG
	a.frame = H|FF_TRANS20|FF_PAPERSPRITE
	a.scale = $+FRACUNIT
	a.model = {}
	
	local other_side = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_BUSH)
	other_side.state = S_INVISIBLE
	other_side.sprite = a.sprite
	other_side.frame = H|FF_TRANS20|FF_PAPERSPRITE
	other_side.angleoffset = ANGLE_270
	other_side.zoffset = 1
	other_side.dispoffset = 1
	table.insert(a.model, other_side)	
	
	local first_side = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_BUSH)
	first_side.state = S_INVISIBLE
	first_side.sprite = a.sprite
	first_side.frame = H|FF_TRANS20|FF_PAPERSPRITE|FF_HORIZONTALFLIP
	first_side.angleoffset = 0
	first_side.zoffset = 1
	first_side.dispoffset = 1	
	table.insert(a.model, first_side)	
	
	local top_side = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_BUSH)
	top_side.state = S_INVISIBLE
	top_side.sprite = a.sprite
	top_side.frame = J|FF_TRANS30|FF_PAPERSPRITE
	top_side.angleoffset = 0
	top_side.zoffset = 18 << FRACBITS
	top_side.renderflags = $|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
	top_side.dispoffset = -1	
	table.insert(a.model, top_side)
	

	local middle_side = P_SpawnMobjFromMobj(a, 0, 0, 0, MT_BUSH)
	middle_side.state = S_INVISIBLE
	middle_side.sprite = a.sprite
	middle_side.frame = I|FF_TRANS30|FF_PAPERSPRITE
	middle_side.angleoffset = 0
	middle_side.zoffset = 12 << FRACBITS	
	middle_side.renderflags = $|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
	middle_side.dispoffset = -1	
	table.insert(a.model, middle_side)
end, MT_EMERALD1)

addHook("MobjThinker", function(a, mt)
	if not a.model then return end
	
	a.angle = $+ANG2
	P_MoveOrigin(a, a.x, a.y, a.z+FixedMul(a.scale, P_MobjFlip(a)*sin(leveltime*ANG1)/3))
	if (leveltime & 8)/7 then
		local sparkle = P_SpawnMobjFromMobj(a, P_RandomRange(-8, 8) << FRACBITS, P_RandomRange(-8, 8) << FRACBITS, P_RandomRange(-8, 8) << FRACBITS, MT_SUPERSPARK)
		sparkle.colorized = true
		sparkle.color = SKINCOLOR_APPLE
		sparkle.scale = a.scale/8
	end
	
	local sides = a.model 
	for i = 1, #sides do
		local side = sides[i]
		side.angle = a.angle+side.angleoffset 
		P_MoveOrigin(side, a.x, a.y, a.z+FixedMul(side.zoffset, a.scale)*P_MobjFlip(a))
	end
end, MT_EMERALD1)

addHook("MobjDeath", function(a, mt)
	if not a.model then return end

	local sides = a.model 
	for i = 1, #sides do
		local side = sides[i]
		P_RemoveMobj(side)
	end	
end, MT_EMERALD1)