local helper = {}

function helper.convertPlayerTime(time)
	local mint = G_TicsToMinutes(time, true)
	local sect = G_TicsToSeconds(time)
	local cent = G_TicsToCentiseconds(time)
	mint = (mint < 10 and '0'..mint or mint)
	sect = (sect < 10 and '0'..sect or sect)
	cent = (cent < 10 and '0'..cent or cent)

	return mint, sect, cent
end

return helper