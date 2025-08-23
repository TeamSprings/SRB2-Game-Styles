--[[

		Conversion and Adjusting of SRB2's Tally Calculation

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local helper = {
	perfectbonus = -1,
	totalcoinnum = 0
}

-- Constants

local SCORETIC 		= 222
local RINGREWARD 	= 100
local TIMETIER		= 30

local GUARDREWARD = {
	[0] 	= 10000,
	[1] 	= 5000,
	[2] 	= 1000,
	[3] 	= 500,
	[4] 	= 100
}

local TIMEREWARD = {
	[0] 	= 50000,
	[1] 	= 10000,
	[2] 	= 5000,
	[3] 	= 4000,
	[4] 	= 3000,
	[5] 	= 2000,
	[6] 	= 1000,
	[7] 	= 500,
	[8] 	= 400,
	[9] 	= 300,
	[10] 	= 200,
	[11] 	= 100,
	[12] 	= 100,
	[13] 	= 0,
}

local RINGCOUNTLUT = {
	[MT_RING] 		= 1,
	[MT_COIN] 		= 1,
	[MT_NIGHTSSTAR] = 1,

	[MT_RING_BOX] 	= 10,
}

-- Helper functions

function helper.Y_GetPerfectBonus(rings, perfectb, totrings)
	if (totrings == 0 or perfectb == -1) then
		return -1
	end

	if rings >= totrings then
		return 5000
	end

	return -1
end

function helper.Y_GetTimeBonus(time)
	local secs = max(0, time / TICRATE)
	
	return (TIMEREWARD[secs / TIMETIER] or 0)
end

function helper.Y_GetGuardBonus(guardtime)
	return (GUARDREWARD[guardtime] or 0)
end

function helper.Y_GetRingsBonus(rings)
	return (max(0, rings * RINGREWARD))
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
		local time_bonus = helper.Y_GetTimeBonus(max(p.realtime + (p.style_additionaltime or 0) - (p.styles_cutscenetime_prize or 0), 0))

		local perfct_bonus = max(helper.Y_GetPreCalcPerfectBonus(p.rings), 0)

		return ring_bonus + time_bonus + perfct_bonus
	end
end

function helper.Y_GetDuration(score)
	return score / SCORETIC
end

function helper.Y_GetTimingCalculation(p)
	return helper.Y_CalculateAllScore(p) / SCORETIC
end

function helper.Y_ResetCounters()
	helper.totalcoinnum = 0
	helper.perfectbonus = 0
end

addHook("MapChange", helper.Y_ResetCounters)

addHook("MapLoad", function()
	helper.Y_ResetCounters()

	---@diagnostic disable-next-line
	for mobj in mobjs.iterate() do
		if RINGCOUNTLUT[mobj.type] then
			helper.totalcoinnum = $ + RINGCOUNTLUT[mobj.type]
			continue
		end

		if (mobj.type == MT_NIGHTSDRONE) then
			helper.perfectbonus = -1
		end
	end
end)

-- Abstraction functions

function helper.addScore(p, score)
	if (maptol & TOL_NIGHTS) then
		p.score = min(p.score + score, 999999999)
	else
		P_AddPlayerScore(p, score)
	end
end

return helper