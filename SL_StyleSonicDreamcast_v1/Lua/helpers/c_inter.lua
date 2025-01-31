--[[

		Conversion and Adjusting of SRB2's Tally Calculation

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]


local helper = {}

-- Helper Variables

helper.totalcoinnum = 0
helper.totalcoinnumrandm = 0

-- Helper functions

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

function helper.Y_GetPerfectBonus(rings, perfectb, totrings)
	if (totrings == 0 or perfectb == -1 or rings < totrings) then
		return 0
	end

	if rings >= totrings then
		return 5000
	end
end

function helper.Y_ResetCounters()
	helper.totalcoinnum = 0
	helper.totalcoinnumrandm = 0
	hud.smooth = nil
	hud.bosshealth = nil
	hud.bossbardecrease = nil
end

addHook("MapChange", helper.Y_ResetCounters)

function helper.Y_GetTotalCoins(a)
	local totalrings, perfectbonus

	if (a.type == MT_RING or a.type == MT_COIN or a.type == MT_NIGHTSSTAR) then
		helper.totalcoinnum = $ + 1
		helper.totalcoinnumrandm = $ + 1
	end

	if (a.type == MT_RING_BOX) then
		helper.totalcoinnum = $ + 10
		helper.totalcoinnumrandm = $ + 1
	end

	if (a.type == MT_NIGHTSDRONE) then
		perfectbonus = -1
	end

end

function helper.RankCounter(p)

	-- Current Score

	local stagegainedscore = p.score - p.startscore

	local timescore = helper.Y_GetTimeBonus(p.realtime)

	local ringscore = helper.Y_GetRingsBonus(p.rings)

	local totalscore = stagegainedscore + timescore + ringscore

	-- Requirement

	local requirementscore = 0

	if helper.totalcoinnum == 0 or mapheaderinfo[gamemap].bonustype > 0 then
		requirementscore = 5000 + helper.Y_GetRingsBonus(mapheaderinfo[gamemap].startrings)
	else
		requirementscore = 10000 + helper.Y_GetRingsBonus(helper.totalcoinnum) + helper.Y_GetRingsBonus(mapheaderinfo[gamemap].startrings)
	end

	local A_rank = tonumber(mapheaderinfo[gamemap].styles_ranks_a) or requirementscore/4
	local B_rank = tonumber(mapheaderinfo[gamemap].styles_ranks_b) or requirementscore/7
	local C_rank = tonumber(mapheaderinfo[gamemap].styles_ranks_c) or requirementscore/10
	local D_rank = tonumber(mapheaderinfo[gamemap].styles_ranks_d) or requirementscore/12

	-- Compare score and requirement to result

	if totalscore >= A_rank then
		return "A"
	elseif totalscore >= B_rank then
		return "B"
	elseif totalscore >= C_rank then
		return "C"
	elseif totalscore >= D_rank then
		return "D"
	else
		return "E"
	end

end

addHook("MapLoad", function()
	helper.Y_ResetCounters()

	for mobj in mobjs.iterate() do
		helper.Y_GetTotalCoins(mobj)
	end
end)

function helper.Y_GetAllBonus(p)
	-- Current Score
	local secondscore = 0

	if mapheaderinfo[gamemap].bonustype > 0 then
		secondscore = helper.Y_GetGuardBonus(p.timeshit)
	else
		secondscore = helper.Y_GetTimeBonus(p.realtime)
	end

	return secondscore + helper.Y_GetRingsBonus(p.rings)
end

return helper