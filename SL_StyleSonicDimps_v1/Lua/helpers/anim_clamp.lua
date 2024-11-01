local function clampTimer(min_, x, max_)
	return abs(max(min(x, max_), min_) - min_) * FRACUNIT / (max_ - min_)
end

return clampTimer