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