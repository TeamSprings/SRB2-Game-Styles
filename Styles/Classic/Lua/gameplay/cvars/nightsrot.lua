local LIMITRANGE = 360 / 8

local function LIMITED_ROT(a, stop)
	if stop then return end

	local horizontal = R_PointToDist2(0, 0, a.momx, a.momy)
	local jaw = R_PointToAngle2(0, 0, horizontal, a.momz)

	local limitedjaw = FixedAngle((AngleFixed(jaw) / FU / LIMITRANGE) * FU * LIMITRANGE)

	a.rollangle = limitedjaw

	local view_angle = R_PointToAngle(a.x, a.y) - a.angle
	local side = AngleFixed(view_angle) / (180*FU)

	if side > 0 then
		a.rollangle = InvAngle($)
	end

	a.style_rollangle_was_enabled = true
end

local function NONE_ROT(a, stop)
	if stop then return end

	a.rollangle = 0
	a.style_rollangle_was_enabled = true
end

local function MIXED_ROT(a, stop)
	if stop then return end

	local jaw = 0

	local horizontal = R_PointToDist2(0, 0, a.momx, a.momy)
	local jawcalc = R_PointToAngle2(0, 0, horizontal, a.momz)
	local jawint = jawcalc/ANG1

	if jawint > 41 or jawint < -41 then
		jaw = jawint * 8
	end

	a.rollangle = ease.linear(FU/11, 0, jaw) * ANG1

	local view_angle = R_PointToAngle(a.x, a.y) - a.angle
	local side = AngleFixed(view_angle) / (180*FU)

	if side > 0 then
		a.rollangle = InvAngle($)
	end
	
	a.style_rollangle_was_enabled = true
end


return {
	[0] = {nil, 	"vanilla", 		"Vanilla / Full"},
	{LIMITED_ROT, 	"limited", 		"Limited"},
	{MIXED_ROT, 	"mixed", 		"Mixed"},
	{NONE_ROT,	 	"none", 		"None"},
}