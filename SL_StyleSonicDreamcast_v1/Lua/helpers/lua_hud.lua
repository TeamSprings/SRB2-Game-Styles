--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local helper = {}

function helper.convertPlayerTime(ttime)
	local mint = G_TicsToMinutes(ttime)
	local sect = G_TicsToSeconds(ttime)
	local cent = G_TicsToCentiseconds(ttime)
	mint = (mint < 10 and '0'..mint or mint)
	sect = (sect < 10 and '0'..sect or sect)
	cent = (cent < 10 and '0'..cent or cent)

	return mint, sect, cent
end

return helper