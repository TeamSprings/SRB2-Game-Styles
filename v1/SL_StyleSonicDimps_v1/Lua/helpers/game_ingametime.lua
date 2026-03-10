local time_display_settings = CV_FindVar("timerres")

return function(p)
	local tics = p.realtime + (p.style_additionaltime or 0)
	local countdown = false
	local show_tic = false

	-- tics recalculation
	if (gametyperules & GTR_TIMELIMIT) and timelimit then
		tics = max(60*timelimit*TICRATE - p.realtime, 0)
		countdown = true
	elseif mapheaderinfo[gamemap].countdown then
		tics = tonumber(mapheaderinfo[gamemap].countdown) - p.realtime
		countdown = true
	end

	-- time string formatting
	local time_string = ""

	if time_display_settings.value == 3 then
		time_string = tostring(tics)
		show_tic = true
	elseif time_display_settings.value == 2 or time_display_settings.value == 1 then
		local mint = G_TicsToMinutes(tics, true)
		local sect = G_TicsToSeconds(tics)
		local cent = G_TicsToCentiseconds(tics)
		sect = (sect < 10 and '0'..sect or sect)
		cent = (cent < 10 and '0'..cent or cent)

		time_string = mint..":"..sect..":"..cent

		show_tic = true
	else
		local mint = G_TicsToMinutes(tics, true)
		local sect = G_TicsToSeconds(tics)
		sect = (sect < 10 and '0'..sect or sect)

		time_string = mint..":"..sect
	end

	return time_string, countdown, show_tic
end