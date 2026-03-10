--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local abs = abs
local max = max
local min = min
local FU = FU

local function clampTimer(min_, x, max_)
	return abs(max(min(x, max_), min_) - min_) * FU / (max_ - min_)
end

return clampTimer