--[[

		Team Blue Spring's Series of Libaries.
		Lite version of Common Library - LIB_TBS_lite.lua

Contributors: Skydusk
@Team Blue Spring 2025

]]

local fontregistry = {}

local FU = FU
local FRACBITS = FRACBITS

local FixedSqrt = FixedSqrt
local FixedMul = FixedMul
local FixedDiv = FixedDiv

local function atan(x)
    return asin(FixedDiv(x,(1 + FixedMul(x,x)))^(1/2))
end

local function FixedPower(x, n)
	for i = 1, (n-1) do
		x = FixedMul(x, x)
	end
	return x
end

-- sTBS's Fixedpoint interpretation of Roblox's lua doc interpretation's of Bezier's curves.

local function Math_QuadBezier(t, p0, p1, p2)
	return FixedMul(FixedMul(FU - t, FU - t), p0) + 2 * FixedMul(FixedMul(FU - t, t), p1) + FixedMul(FixedMul(t, t), p2)
end

return {atan = atan, power = FixedPower, quadBezier = Math_QuadBezier}