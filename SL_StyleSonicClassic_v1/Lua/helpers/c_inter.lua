--[[

		Conversion and Adjusting of SRB2's Tally Calculation

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local helper = {}

-- Helper Variables

helper.perfectbonus = -1
helper.totalcoinnum = 0

-- Helper functions

function helper.Y_GetPerfectBonus(rings, perfectb, totrings)
	if (totrings == 0 or perfectb == -1 or rings < totrings) then
		return -1
	end

	if rings >= totrings then
		return 5000
	end
end

function helper.Y_GetTimeBonus(time)
	local secs = time/TICRATE
	local result

	if (secs <  30) then     --[[   :30 ]] result = 50000
	elseif (secs <  60) then --[[  1:00 ]] result = 10000
	elseif (secs <  90) then --[[  1:30 ]] result = 5000
	elseif (secs < 120) then --[[  2:00 ]] result = 4000
	elseif (secs < 180) then --[[  3:00 ]] result = 3000
	elseif (secs < 240) then --[[  4:00 ]] result = 2000
	elseif (secs < 300) then --[[  5:00 ]] result = 1000
	elseif (secs < 360) then --[[  6:00 ]] result = 500
	elseif (secs < 420) then --[[  7:00 ]] result = 400
	elseif (secs < 480) then --[[  8:00 ]] result = 300
	elseif (secs < 540) then --[[  9:00 ]] result = 200
	elseif (secs < 600) then --[[ 10:00 ]] result = 100
	else  --[[ TIME TAKEN: TOO LONG ]] result = 0
	end

	return result
end

function helper.Y_GetGuardBonus(guardtime)
	local guardscoretype = {[0] = 10000, [1] = 5000, [2] = 1000, [3] = 500, [4] = 100}
	return (guardscoretype[guardtime] and guardscoretype[guardtime] or 0)
end

function helper.Y_GetRingsBonus(rings)
	return (max(0, (rings)*100))
end

function helper.Y_GetPreCalcPerfectBonus(rings)
	return helper.Y_GetPerfectBonus(rings, helper.perfectbonus, helper.totalcoinnum)
end

function helper.Y_CalculateAllScore(p)
	if (maptol & TOL_NIGHTS) then
		return p.totalmarescore
	elseif G_IsSpecialStage(gamemap) then
		return helper.Y_GetRingsBonus(p.rings)
	else
		local ring_bonus = helper.Y_GetRingsBonus(p.rings)
		local time_bonus = helper.Y_GetTimeBonus(p.realtime + (p.style_additionaltime or 0))
		local perfct_bonus = max(helper.Y_GetPreCalcPerfectBonus(p.rings), 0)

		return ring_bonus + time_bonus + perfct_bonus
	end
end

function helper.Y_GetDuration(score)
	return score/222
end

function helper.Y_GetTimingCalculation(p)
	return helper.Y_GetDuration(helper.Y_CalculateAllScore(p))
end

function helper.addScore(p, score)
	if (maptol & TOL_NIGHTS) then
		p.score = min(p.score + score, 999999999)
	else
		P_AddPlayerScore(p, score)
	end
end

function helper.Y_ResetCounters()
	helper.totalcoinnum = 0
	helper.perfectbonus = 0
	hud.smooth = nil
	hud.bosshealth = nil
	hud.bossbardecrease = nil
end

addHook("MapChange", helper.Y_ResetCounters)

function helper.Y_GetTotalCoins(a)
	if (a.type == MT_RING or a.type == MT_COIN or a.type == MT_NIGHTSSTAR) then
		helper.totalcoinnum = $ + 1
	end

	if (a.type == MT_RING_BOX) then
		helper.totalcoinnum = $ + 10
	end

	if (a.type == MT_NIGHTSDRONE) then
		helper.perfectbonus = -1
	end
end

addHook("MapLoad", function()
	helper.Y_ResetCounters()

	for mobj in mobjs.iterate() do
		helper.Y_GetTotalCoins(mobj)
	end
end)

return helper