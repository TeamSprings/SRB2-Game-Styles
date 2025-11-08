
local HOOK = customhud.SetupItem
local Manager = tbsrequire('gameplay/intermissions/inter_manager')
local hudcfg = 	tbsrequire('gui/hud_conf')
local hudvars = tbsrequire('gui/hud_vars')

local fade_cv = hudcfg.bluefade_cv
local hudspecifics = hudcfg.hudspecifics
local hud_hide_cv = hudcfg.hidehud_cv

HOOK("stagetitle", "classichud", function(v, p, t, e)
	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	if p.styles_entercut or (p.teamsprings_scenethread and p.teamsprings_scenethread.valid)
	or p.styles_entercut_timer ~= nil or p.styles_entercut_etimer ~= nil then
		v.fadeScreen(31, max(5 - leveltime, 0) * 2)

		return
	end

	local exists = min(hudcfg.titletype, 4)

	if hudspecifics[hudcfg.titletype].titlecard then
		exists = hudcfg.titletype
	end

	if hud_hide_cv.value > 1 then
		local check = hudspecifics[exists].titlecard(v, p, t, e, fade_cv.value > 0)

		if check then
			hudvars.hide = true
			hudvars.hidefull = true
		end
	else
		hudspecifics[exists].titlecard(v, p, t, e, fade_cv.value > 0)
	end

	return true
end, "titlecard", 1, 3)

---@param v videolib
HOOK("stylesingame_stagetitle", "classichud", function(v, p)
	if p.styles_entercut_timer == nil or p.styles_entercut_etimer == nil then
		return
	end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local exists = min(hudcfg.titletype, 4)

	if hudspecifics[hudcfg.titletype].titlecard then
		exists = hudcfg.titletype
	end

	if hud_hide_cv.value > 1 then
		local check = hudspecifics[exists].titlecard(v, p, p.styles_entercut_timer, p.styles_entercut_etimer, fade_cv.value > 0)

		if check then
			hudvars.hide = true
			hudvars.hidefull = true
		end
	else
		hudspecifics[exists].titlecard(v, p, p.styles_entercut_timer, p.styles_entercut_etimer, fade_cv.value > 0)
	end

	return true
end, "ingameintermission", 4, 3)

local tally_totalcalculation = 0

HOOK("styles_levelendtally", "classichud", function(v, p, t, e)
	if not p.exiting then return end

	if hud_hide_cv.value == 1
	or hud_hide_cv.value == 3 then
		hudvars.hide = true
	end

	-- Display
	if p.styles_tallytimer ~= nil then
		Manager:draw(v, p, t, e)
	end

	if p.styles_tallytimer and (p.styles_tallytimer < 0) then
		tally_totalcalculation = 0
	end

	return true
end, "ingameintermission", 1, 3)