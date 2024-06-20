states[S_PITY1] = {
	sprite = SPR_PITY,
	frame = FF_ANIMATE|FF_ADD|FF_SEMIBRIGHT|B,
	tics = 136,
	var1 = 67,
	var2 = 2,
	nextstate = S_PITY1,
}

states[S_MAGN1] = {
	sprite = SPR_MAGN,
	frame = FF_ANIMATE|FF_ADD|FF_SEMIBRIGHT|A,
	tics = 182,
	var1 = 91,
	var2 = 2,
	nextstate = S_MAGN1,
}

states[S_MAGN1] = {
	sprite = SPR_MAGN,
	frame = FF_ANIMATE|FF_ADD|FF_SEMIBRIGHT|A,
	tics = 182,
	var1 = 91,
	var2 = 2,
	nextstate = S_MAGN1,
}

states[S_MAGN13] = {
	sprite = SPR_MAGN,
	frame = FF_TRANS20|FF_SEMIBRIGHT|92,
	tics = 2,
	nextstate = S_MAGN1,
}

freeslot("S_MAGN14")

-- Shocks
states[S_MAGN14] = {
	sprite = SPR_MAGN,
	frame = FF_TRANS40|FF_ANIMATE|FF_ADD|FF_PAPERSPRITE|FF_SEMIBRIGHT|93,
	tics = 16,
	var1 = 8,
	var2 = 2,
	nextstate = S_NULL,
}


addHook("MobjThinker", function(mo)
	if not mo.target.track then
		mo.target.track = {}
	end

	if not (leveltime % 3) then
		local shock = P_SpawnMobjFromMobj(mo, -4069*FRACUNIT, -4069*FRACUNIT, -4069*FRACUNIT, MT_METALJETFUME)
		shock.state = S_MAGN14
		shock.scale = mo.scale/2
		shock.angle = P_RandomRange(1, 360) * ANG1
		shock.rollangle = P_RandomRange(1, 360) * ANG1
		shock.target = mo
		shock.dispoffset = P_RandomRange(-1, 1) * 2
		table.insert(mo.target.track, shock)
	end
end, MT_ATTRACT_ORB)


addHook("PlayerThink", function(p)
	if p.shieldscale == skins[p.mo.skin].shieldscale then
		p.shieldscale = tofixed('1.15')
	end

	if p.mo.track then
		for k, v in ipairs(p.mo.track) do
			if v and v.valid then
				if v.target then
					P_MoveOrigin(v, p.mo.x, p.mo.y, p.mo.z + FixedMul(v.target.height/3, v.target.scale))
					v.momx = p.mo.momx
					v.momy = p.mo.momy
					v.momz = p.mo.momz
				else
					P_RemoveMobj(v)
				end
			else
				table.remove(p.mo.track, k)
			end
		end
	end
end)