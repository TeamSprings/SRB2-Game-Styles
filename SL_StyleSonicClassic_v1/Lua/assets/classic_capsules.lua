freeslot("SPR_CAPSULE_S2", "SPR_CAPSULE_CD")

local Options = tbsrequire('helpers/create_cvar')

local S3K_SPR = freeslot("SPR_CAPSULE_S3K")
local EGGTRAP = freeslot("MT_STYLES_EGGTR")
local EGGTRAPPART = freeslot("MT_STYLES_EGGTRPART")
local EGGTRAPTRIGGER = freeslot("MT_STYLES_EGGTRIGGER")
local EGGTRAPTRIGGERTOUCH = freeslot("MT_STYLES_EGGTRIGGERTOUCH")

mobjinfo[EGGTRAP] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 32*FRACUNIT,
	height = 64*FRACUNIT,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SOLID,
	dispoffset = -1
}

mobjinfo[EGGTRAPPART] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 32*FRACUNIT,
	height = 64*FRACUNIT,
	mass = 100,
	flags = (mobjinfo[MT_BUSH].flags|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION) &~ MF_NOTHINK,
}

mobjinfo[EGGTRAPTRIGGER] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 24*FRACUNIT,
	height = 16*FRACUNIT,
	mass = 100,
	flags = MF_SOLID|MF_NOGRAVITY,
}

mobjinfo[EGGTRAPTRIGGERTOUCH] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 24*FRACUNIT,
	height = 16*FRACUNIT,
	mass = 100,
	flags = MF_SPECIAL|MF_NOGRAVITY,
}


local change_var = -1
local model_type = 1

Options:new("capsule", {
	{nil, "s2", "Sonic 2"},
	{nil, "cd", "Sonic CD"},
	{nil, "s3", "Sonic 3 & Knuckles"},
}, function(var)
	change_var = var.value
end, CV_NETVAR)

addHook("MapChange", function()
	if change_var > -1 then 
		model_type = change_var
		change_var = -1
	end
end)


local TRAPF_ENDLVL 	= 1
local TRAPF_LIFT 	= 2
local TRAPF_FLIGHT 	= 4
local TRAPF_DROP 	= 8

local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8
local TRPPF_DISOLVE = 16

-- FIX: CAPSULES, (CD CAPSULE AND THE ANIM)
-- TODO: ADD MORE CAPSULES
-- TODO: ADD MORE FEATURES (flight, drop and item drop)
-- TODO: MAKE IT FIRST UDMF CUSTOMIZABLE OBJECT
local models = {
	-- SONIC 2 CAPSULE
	function(a) 
		a.scale = $+FRACUNIT/4
			local topSuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BUSH)
			topSuSpawn.target = a
			topSuSpawn.scale = a.scale
			topSuSpawn.state = S_BUSH
			topSuSpawn.sprite = SPR_CAPSULE_S2
			topSuSpawn.frame = E
		for i = 1,8 do
			local ang = a.angle*ANG1+i*(ANG1*(360/8))
			local sideSpawn = P_SpawnMobjFromMobj(a, 46*cos(ang), 46*sin(ang),0, MT_BUSH)
			sideSpawn.target = a
			sideSpawn.scale = a.scale
			sideSpawn.state = S_BUSH
			sideSpawn.sprite = SPR_CAPSULE_S2
			sideSpawn.frame = (i % 4)|FF_PAPERSPRITE
			sideSpawn.angle = ang+ANGLE_90
		end
		for i = 1,4 do
			local ang = a.angle*ANG1+i*ANGLE_90
			local supportSpawn = P_SpawnMobjFromMobj(a, 30*cos(ang), 30*sin(ang),0, MT_NONPRIORITYERADUMMY)
			supportSpawn.target = a
			supportSpawn.scale = a.scale
			supportSpawn.state = S_BUSH
			supportSpawn.sprite = SPR_CAPSULE_S2
			supportSpawn.frame = F
		end
		for i = 1,8 do
			local ang = a.angle*ANG1+i*(ANG1*(360/8))
			local butSpawn = P_SpawnMobjFromMobj(a, 26*cos(ang), 26*sin(ang),0, MT_BUSH)
			butSpawn.target = a
			butSpawn.scale = a.scale
			butSpawn.state = S_BUSH
			butSpawn.sprite = SPR_CAPSULE_S2
			butSpawn.frame = (i % 2)+10|FF_PAPERSPRITE
			butSpawn.angle = ang+ANGLE_90
		end
		for i = 1,8 do
			local ang = a.angle*ANG1+i*(ANG1*(360/8))
			local butSpawn = P_SpawnMobjFromMobj(a, 40*cos(ang), 40*sin(ang),0, MT_BUSH)
			butSpawn.target = a
			butSpawn.scale = a.scale
			butSpawn.state = S_BUSH
			butSpawn.sprite = SPR_CAPSULE_S2
			butSpawn.frame = G|FF_PAPERSPRITE
			butSpawn.angle = ang+ANGLE_90
		end

			local topSuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BUSH)
			topSuSpawn.target = a
			topSuSpawn.scale = a.scale
			topSuSpawn.state = S_BUSH
			topSuSpawn.sprite = SPR_CAPSULE_S2
			topSuSpawn.frame = J	
	end,

	-- SONIC CD CAPSULE
	function(a)
		a.capsule = {}
		a.scale = $+FRACUNIT/4
		
		local stem = P_SpawnMobjFromMobj(a, 0,0,0, EGGTRAPPART)
		stem.target = a
		stem.scale = a.scale
		stem.sprite = SPR_CAPSULE_CD
		stem.frame = A|FF_TRANS20
		table.insert(a.capsule, stem)

		local head = P_SpawnMobjFromMobj(a, 0,0,0, EGGTRAPTRIGGERTOUCH)
		head.target = a
		head.scale = a.scale
		head.sprite = SPR_CAPSULE_CD
		head.styles_trflags = TRPPF_DISOLVE
		head.frame = B
		table.insert(a.capsule, head)
	end,

	-- SONIC 3 & KNUCKLES CAPSULE
	function(a)
		a.capsule = {}
		a.scale = $+FRACUNIT/4
			local body = P_SpawnMobjFromMobj(a, 0,0,0, EGGTRAPPART)
			body.target = a
			body.scale = a.scale
			body.sprite = S3K_SPR
			body.frame = E
			body.offx = 0
			body.offy = 0
			body.styles_trflags = TRPPF_CHANGE
			body.styles_trchnage = 13
			table.insert(a.capsule, body)
		for i = 1,8 do
			local ang = a.angle*ANG1+i*(ANG1*(360/8))
			local sideSpawn = P_SpawnMobjFromMobj(a, 46*cos(ang), 46*sin(ang),0, EGGTRAPPART)
			sideSpawn.target = a
			sideSpawn.scale = a.scale
			sideSpawn.sprite = S3K_SPR
			sideSpawn.frame = (i % 4)|FF_PAPERSPRITE
			sideSpawn.angle = ang+ANGLE_90
			sideSpawn.offx = 46*cos(ang)
			sideSpawn.offy = 46*sin(ang)
			sideSpawn.styles_trflags = TRPPF_POOF
			sideSpawn.styles_trangle = ang
			table.insert(a.capsule, sideSpawn)
		end
		for i = 1,4 do
			local ang = a.angle*ANG1+i*ANGLE_90
			local supportSpawn = P_SpawnMobjFromMobj(a, 30*cos(ang), 30*sin(ang),0, EGGTRAPPART)
			supportSpawn.target = a
			supportSpawn.scale = a.scale
			supportSpawn.sprite = S3K_SPR
			supportSpawn.frame = F
			supportSpawn.offx = 30*cos(ang)
			supportSpawn.offy = 30*sin(ang)
			table.insert(a.capsule, supportSpawn)
		end
		for i = 1,8 do
			local ang = a.angle*ANG1+i*(ANG1*(360/8))
			local butSpawn = P_SpawnMobjFromMobj(a, 26*cos(ang), 26*sin(ang),0, EGGTRAPPART)
			butSpawn.target = a
			butSpawn.scale = a.scale
			butSpawn.sprite = S3K_SPR
			butSpawn.frame = (i % 2)+10|FF_PAPERSPRITE
			butSpawn.angle = ang+ANGLE_90
			butSpawn.styles_trflags = TRPPF_HEADTOP
			butSpawn.offx = 26*cos(ang)
			butSpawn.offy = 26*sin(ang)
			table.insert(a.capsule, butSpawn)
		end
		for i = 1,16 do
			local ang = a.angle*ANG1+i*(ANG1*(360/8))
			local butSpawn = P_SpawnMobjFromMobj(a, 40*cos(ang), 40*sin(ang),0, EGGTRAPPART)
			butSpawn.target = a
			butSpawn.scale = a.scale
			butSpawn.sprite = S3K_SPR
			butSpawn.frame = G
			butSpawn.angle = ang+ANGLE_90
			butSpawn.offx = 40*cos(ang)
			butSpawn.offy = 40*sin(ang)
			table.insert(a.capsule, butSpawn)
		end
		for i = 1,2 do
			local ang = a.angle*ANG1+ANGLE_180*i-ANGLE_45
			local sideSpawn = P_SpawnMobjFromMobj(a, 48*cos(ang), 48*sin(ang),0, EGGTRAPPART)
			sideSpawn.target = a
			sideSpawn.scale = a.scale
			sideSpawn.sprite = S3K_SPR
			sideSpawn.frame = H
			sideSpawn.offx = 48*cos(ang)
			sideSpawn.offy = 48*sin(ang)
			sideSpawn.styles_trflags = TRPPF_CHANGE
			sideSpawn.styles_trchnage = 14
			table.insert(a.capsule, sideSpawn)
		end
		for i = 1,2 do
			local ang = a.angle*ANG1+ANGLE_180*i-ANGLE_45
			local butSpawn = P_SpawnMobjFromMobj(a, 52*cos(ang), 52*sin(ang),0, EGGTRAPPART)
			butSpawn.target = a
			butSpawn.scale = a.scale
			butSpawn.sprite = S3K_SPR
			butSpawn.frame = I
			butSpawn.offx = 52*cos(ang)
			butSpawn.offy = 52*sin(ang)
			table.insert(a.capsule, butSpawn)
		end

			local topYuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, EGGTRAPTRIGGER)
			topYuSpawn.target = a
			topYuSpawn.scale = a.scale
			topYuSpawn.sprite = S3K_SPR
			topYuSpawn.frame = J
			topYuSpawn.styles_trflags = TRPPF_HEADLOW
			topYuSpawn.offx = 0
			topYuSpawn.offy = 0
			table.insert(a.capsule, topYuSpawn)
	end,
}

addHook("MobjSpawn", function(a, tm)
	a.styles_flags = 0
	
	a.radius = 46*FRACUNIT
	a.height = 84*FRACUNIT

	models[model_type](a)

	a.disty = 0
	a.activatable = true
end, EGGTRAP)

local list_flickies = {
	MT_FLICKY_01,
	MT_FLICKY_02,
	MT_FLICKY_03,
	MT_FLICKY_04,
	MT_FLICKY_05,
	MT_FLICKY_06,
	MT_FLICKY_07,
	MT_FLICKY_08,
	MT_FLICKY_09,
	MT_FLICKY_10,
	MT_FLICKY_11,
	MT_FLICKY_12,
	MT_FLICKY_13,
	MT_FLICKY_14,
	MT_FLICKY_15,
	MT_FLICKY_16,
	MT_SECRETFLICKY_01,
	MT_SECRETFLICKY_02,
}

addHook("MobjThinker", function(a)
	if a.styles_tagged then
		local count = 0


		if a.styles_list then
			for _,mo in ipairs(a.styles_list) do
				if mo and mo.health > 0 then
					count = $ + 1
				end
			end
		else
			for mo in mapthings.tagged(a.styles_tagged) do
				if mo and mo.health > 0 then
					count = $ + 1
				end
			end
		end

		if count == 0 then
			a.styles_tagged = nil
			for _,v in ipairs(a.capsule) do
				if v then
					v.alpha = FRACUNIT

					if v.info.flags & MF_SOLID then
						v.flags = $ | MF_SOLID
					end
				end
			end

			a.alpha = FRACUNIT
		else
			if not a.styles_movement then
				for _,v in ipairs(a.capsule) do
					if v then
						v.alpha = 0
					end

					if v.flags & MF_SOLID then
						v.flags = $ &~ MF_SOLID
					end
				end

				a.styles_movetarget = a.z
				a.styles_movement = 1
				a.alpha = 0
				a.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT

				if a.styles_flags & TRAPF_LIFT then
					a.styles_movement = TICRATE
					P_SetOrigin(a, a.x, a.y, a.z - 200*FRACUNIT)
				end
			end
		end
	else
		if a.styles_movement then
			if a.styles_flags & TRAPF_LIFT then
				a.flags = $ | (MF_NOGRAVITY|MF_NOCLIPHEIGHT)

				P_SetOrigin(a, a.x, a.y, ease.linear(a.styles_movement * FRACUNIT / TICRATE, a.z, a.styles_movetarget))
				a.styles_movement = $ - 1
				
				if not a.styles_movement then
					a.flags = $ &~ (MF_NOGRAVITY|MF_NOCLIPHEIGHT)
					a.styles_movement = nil
				end
			end
		end
	end

	if a.boss and a.boss.valid and a.boss.health <= 0 then
		a.activate = true
		a.flags = $|MF_SOLID & ~(MF_NOSECTOR|MF_NOBLOCKMAP)
	end

	if a.activated == true and not a.openinganim and not a.openedup then
		a.openinganim = 2*TICRATE
	end

	if a.openinganim and a.openinganim > TICRATE then
				local z = a.subsector.sector.floorheight + FRACUNIT + (P_RandomKey(a.height/FRACUNIT) << FRACBITS)
				local fa = P_RandomRange(1,360) *ANG1
				local ns = a.radius
				local x = a.x + FixedMul(sin(fa), ns)
				local y = a.y + FixedMul(cos(fa), ns)

				local mo2 = P_SpawnMobj(x, y, z, MT_EXPLODE)
				mo2.state = S_XPLD1
				ns = 2*FRACUNIT
				mo2.momx = FixedMul(sin(fa), ns)
				mo2.momy = FixedMul(cos(fa), ns)
				mo2.angle = fa
				S_StartSound(mo2, sfx_pop)

				local list = a.styles_flickylist or list_flickies
				local randm = P_RandomKey(#list)

				if list[randm] and not (leveltime % 4) then
					local flicky = P_SpawnMobjFromMobj(a, FixedMul(sin(fa), ns), FixedMul(cos(fa), ns), (P_RandomKey(a.height/FU) * FU), list[randm])
					flicky = flicky.info.seestate
				end

				a.openedup = true
	elseif a.openinganim == 1
	and a.styles_flags & TRAPF_ENDLVL then
		for p in players.iterate do
			p.exiting = 7
		end
	end

	if a.openinganim then
		a.openinganim  = $ - 1
	end

	if a.press then
		a.press = $ - 1
		if a.press == 0 then
			a.press = nil
		end
	end

end, EGGTRAP)

addHook("MobjThinker", function(a)
	if a.target then
		if not a.styles_deattached then
			P_MoveOrigin(a, a.target.x + FixedMul((a.offx or 0), a.target.scale),
							a.target.y + FixedMul((a.offy or 0), a.target.scale),
							a.target.z)
		end

		if not a.activated and a.target.openedup then
			if a.styles_trflags then
				if (a.styles_trflags & TRPPF_CHANGE) then
					a.frame = a.styles_trchnage
				end

				if (a.styles_trflags & TRPPF_POOF) then
					a.momx = a.offx / 4
					a.momy = a.offy / 4
					a.momz = a.offy / 4 * P_MobjFlip(a)

					a.fuse = 8*TICRATE
					a.flags = ($|MF_NOCLIPHEIGHT|MF_NOCLIP|MF_NOCLIPTHING) &~ MF_NOGRAVITY

					a.styles_deattached = true
				end
			end

			a.activated = true
		end

		if a.styles_trflags then
			if a.target.press then
				if (a.styles_trflags & TRPPF_HEADTOP) then
					a.spriteyoffset = -16*FRACUNIT
				end
			else
				if (a.styles_trflags & TRPPF_HEADTOP) then
					a.spriteyoffset = 0
				end
			end
		end
	else
		P_RemoveMobj(a)
	end
end, EGGTRAPPART)

addHook("MobjThinker", function(a)
	if a.target then
		if not a.styles_deattached then
			P_MoveOrigin(a, a.target.x + FixedMul((a.offx or 0), a.target.scale),
							a.target.y + FixedMul((a.offy or 0), a.target.scale),
							a.target.z)
		end

		if a.styles_trflags then
			if a.target.press then
				if (a.styles_trflags & TRPPF_HEADLOW) then
					a.alpha = 0
				end

				if (a.styles_flags & TRPPF_DISOLVE) then
					P_RemoveMobj(a)
				end
			else
				if (a.styles_trflags & TRPPF_HEADLOW) then
					a.alpha = FRACUNIT
				end
			end
		end
	else
		P_RemoveMobj(a)
	end
end, EGGTRAPTRIGGER)

addHook("MobjThinker", function(a)
	if a.target then
		if not a.styles_deattached then
			P_MoveOrigin(a, a.target.x + FixedMul((a.offx or 0), a.target.scale),
							a.target.y + FixedMul((a.offy or 0), a.target.scale),
							a.target.z)
		end

		if a.styles_trflags then
			if a.target.press then
				if (a.styles_trflags & TRPPF_HEADLOW) then
					a.alpha = 0
				end

				if (a.styles_trflags & TRPPF_DISOLVE) then
					P_RemoveMobj(a)
				end
			else
				if (a.styles_trflags & TRPPF_HEADLOW) then
					a.alpha = FRACUNIT
				end
			end
		end
	else
		P_RemoveMobj(a)
	end
end, EGGTRAPTRIGGERTOUCH)

addHook("MobjCollide", function(a,mt)
	if mt.player then
		if a.target and a.target.activatable == true then
			local discenter = P_AproxDistance(a.x - mt.x, a.y - mt.y)
			
			if discenter < 26*a.scale and a.z+a.height+10*FRACUNIT > mt.z then
				if ((a.target.styles_flags & TRAPF_LIFT) and not a.target.styles_movement) 
				or ((a.target.styles_flags & TRAPF_LIFT) ~= 1) then
					a.target.activated = true
				end

				a.target.press = 4
			end
		end
	elseif not mt.player then
		return false
	end
end, EGGTRAPTRIGGER)

addHook("TouchSpecial", function(a,mt)
	if mt.player then
		if a.target and a.target.activatable == true then	
			if ((a.target.styles_flags & TRAPF_LIFT) and not a.target.styles_movement) 
			or ((a.target.styles_flags & TRAPF_LIFT) ~= 1) then
				a.target.activated = true
			end

			a.target.press = 4
		end
	end

	return true
end, EGGTRAPTRIGGERTOUCH)