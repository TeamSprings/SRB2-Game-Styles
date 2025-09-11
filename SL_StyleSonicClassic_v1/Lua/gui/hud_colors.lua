local Options = tbsrequire 'helpers/create_cvar'

local color_profile = {}
local color_profilefield = {}

local color_changer

local function HUD_ADDCOLORSPACE(hudtype)
	color_profile[hudtype] = nil

	local opt = Options:new("hudcolor"..hudtype, "gui/cvars/hudcolor", function()
		if color_changer then
			color_changer(hudtype)
		end
	end, 0, 7)

	color_profilefield[hudtype] = opt

	return opt
end

local scorecolor_opt   = HUD_ADDCOLORSPACE('score')
local timecolor_opt    = HUD_ADDCOLORSPACE('time')
local ringscolor_opt   = HUD_ADDCOLORSPACE('rings')
local livescolor_opt   = HUD_ADDCOLORSPACE('lives')
local nightscolor_opt  = HUD_ADDCOLORSPACE('nights')
local numberscolor_opt = HUD_ADDCOLORSPACE('numbers')

local color_opt = Options:new("hudcolor", "gui/cvars/hudcolor", function(var)
	if color_changer then
		for _, opt in pairs(color_profilefield) do
			CV_Set(opt.cv, 	var.value)
		end
	end
end, 0, 8)

color_changer = function(setting)
	color_profile[setting] = Options:getPureValue("hudcolor"..setting)
end

return color_profile