--[[

	Slope Handler

	Originally contributed for Mystic Realms: Community Edition

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local helper = {}

-- Taken from MRCELibs, still Skydusk's work, merely borrowing my own functions xd
function helper.cameraSpriteRotReturn(mo, yaw, roll, pitch)
	local viewang = R_PointToAngle(mo.x, mo.y)
	if not R_PointToDist(mo.x, mo.y) then
		viewang = mo.angle
	end

	local ang = viewang - yaw
	return FixedMul(cos(ang), roll) + FixedMul(sin(ang), pitch)
end

function helper.cameraSpriteRot(mo, yaw, roll, pitch)
	local viewang = R_PointToAngle(mo.x, mo.y)
	if not R_PointToDist(mo.x, mo.y) then
		viewang = mo.angle
	end

	local ang = viewang - yaw
	mo.rollangle = FixedMul(cos(ang), roll) + FixedMul(sin(ang), pitch)
end

function helper.slopeRotBaseReturn(mo, slope)
	if not slope then return 0 end
	return helper.cameraSpriteRotReturn(mo, slope.xydirection, 0, slope.zangle)
end

function helper.slopeRotBase(mo, slope)
	-- Reset
	if not slope then
		if mo.rollangle then
			mo.rollangle = ease.linear(FRACUNIT/4, mo.rollangle, FixedAngle(0))
		end
		return
	end

	helper.cameraSpriteRot(mo, slope.xydirection, 0, slope.zangle)
end

function helper.slopeRotBaseGenesis(mo, slope)
	-- Reset
	if not slope then
		if mo.rollangle then
			mo.rollangle = ease.linear(FRACUNIT/4, mo.rollangle, FixedAngle(0))
		end
		return
	end

	helper.cameraSpriteRot(mo, slope.xydirection, 0, FixedAngle(AngleFixed(slope.zangle)/(8*FRACUNIT)*FRACUNIT))
end


-- Use this function for automatic groundslope rotation
-- It is right now more so a macro, but it can change...
function helper.slopeRotation(mo)
	helper.slopeRotBase(mo, mo.standingslope)
	mo.style_rollangle_was_enabled = true
end

function helper.slopeRotationGenesis(mo)
	helper.slopeRotBaseGenesis(mo, mo.standingslope)
	mo.style_rollangle_was_enabled = true
end


return helper