local slope_handler = tbsrequire 'helpers/mo_slope'

local GENESIS_ROT_DECS = 45*FRACUNIT
local GENESIS_ROT_THR = tofixed('15.7')
local MAXANGLE = 360*FRACUNIT

local function GENESIS_ROT(a, stop)
	if P_IsObjectOnGround(a) then
		local aim = slope_handler.slopeRotBaseReturnSplice(a, a.standingslope, GENESIS_ROT_THR)

		a.rollangle = aim
	else
		a.rollangle = 0
	end

	a.style_rollangle_was_enabled = true
end

local function MANIA_ROT(a, stop)
	if (a.state > S_PLAY_STND-1
	and a.state < S_PLAY_PAIN)
	or a.state == S_PLAY_SPINDASH then
		if P_IsObjectOnGround(a) and a.standingslope then
			local aim = slope_handler.slopeRotBaseReturn(a, a.standingslope)

			local roll = AngleFixed(a.standingslope.zangle)

			if a.eflags & MFE_JUSTHITFLOOR then
				a.rollangle = aim
			end

			if roll < GENESIS_ROT_THR
			or roll > MAXANGLE-GENESIS_ROT_THR then
				a.rollangle = ease.linear(FRACUNIT/3, a.rollangle, 0)
			else
				a.rollangle = ease.linear(FRACUNIT/3, a.rollangle, aim)
			end
		elseif not stop then
			a.rollangle = ease.linear(FRACUNIT/8, a.rollangle, 0)
		end
	elseif not stop then
		a.rollangle = 0
	end

	a.style_rollangle_was_enabled = true
end

local function FULL_ROT(a, stop)
	slope_handler.slopeRotation(a)
end

return {
	[0] = {nil, 	"disabled", 	"Disabled / Vanilla"},
	{GENESIS_ROT, 	"genesis", 		"Genesis-Like"},
	{MANIA_ROT, 	"mania", 		"Mania"},
	{FULL_ROT, 		"full", 		"Full"},
}