local HIDETARGET = -160
local HIDEINCRM = 10

local module = {
    hide = false,
    hidefull = false,
    hide_offsetx = 0,
    hidefull_offsetx = 0,

    -- IN-GAME TALLY
    timebonus = 0,
    ringbonus = 0,
    nightsbonus = 0,
    perfect = 0,

    totalbonus = 0,
}

local hudconfigurations = tbsrequire('gui/hud_conf')

local HOOK = customhud.SetupItem
local hud_hide_cv = hudconfigurations.hidehud_cv

HOOK("styles_hudhide_manager", "classichud", function(v, p, t, e)
	if p.teamsprings_scenethread and p.teamsprings_scenethread.valid then
		Styles_HideHud()
	end

	if hud_hide_cv.value then
		if module.hide then
			if module.hide_offsetx > HIDETARGET then
				module.hide_offsetx = $ - HIDEINCRM
			elseif module.hide_offsetx < HIDETARGET then
				module.hide_offsetx = HIDETARGET
			end

			if module.hidefull then
				module.hidefull_offsetx = module.hide_offsetx
			else
				module.hidefull_offsetx = 0
			end

			module.hide = false
			module.hidefull = false
		else
			if module.hide_offsetx < 0 then
				module.hide_offsetx = $ + HIDEINCRM
			elseif module.hide_offsetx > 0 then
				module.hide_offsetx = 0
			end

			if module.hidefull_offsetx then
				module.hidefull_offsetx = module.hide_offsetx
			else
				module.hidefull_offsetx = 0
			end
		end
	else
		module.hide_offsetx = 0
		module.hidefull_offsetx = 0
	end
	return true
end, "game", 1, 3)

rawset(_G, "Styles_HideHud", function()
	module.hide = true
	module.hidefull = true
end)

return module