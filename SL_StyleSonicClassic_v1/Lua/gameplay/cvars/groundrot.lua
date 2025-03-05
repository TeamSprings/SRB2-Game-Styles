local slope_handler = tbsrequire 'helpers/mo_slope'

local GENESIS_ROT_THR = 8*FRACUNIT
local MAXANGLE = 360*FRACUNIT

local function GENESIS_ROT(a)
	if P_IsObjectOnGround(a) then
		slope_handler.slopeRotation(a)
	else
		a.rollangle = 0
	end

	a.rollangle = FixedAngle((AngleFixed(a.rollangle) / GENESIS_ROT_THR) * GENESIS_ROT_THR)
end

local function MANIA_ROT(a)
	slope_handler.slopeRotation(a)

	local roll = AngleFixed(a.rollangle)

	if roll < GENESIS_ROT_THR or roll-GENESIS_ROT_THR > roll then
		a.rollangle = 0
	end
end

local function FULL_ROT(a)
	slope_handler.slopeRotation(a)
end

return {
	[0] = {nil, 	"disabled", 	"Disabled / Vanilla"},
	{GENESIS_ROT, 	"genesis", 		"Genesis"},
	{MANIA_ROT, 	"mania", 		"Mania"},
	{FULL_ROT, 		"full", 		"Full"},
}