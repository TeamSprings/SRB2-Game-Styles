local Options = tbsrequire 'helpers/create_cvar'
local fonts = 	tbsrequire('gui/hud_fonts')

local module = {
    numbereasing = false,

    layouts = tbsrequire('gui/definitions/classic_layouts'),
    layoutindex = 1,

    hudselect = 1,
    titletype = 1,
    livesnames = tbsrequire('gui/definitions/classic_nameconvert'),
    livestype = 1,
    livespos = 1,

    tallycolor = "SPECIALSTAGE_SONIC1_TALLY1",

    hudspecifics = {
        [1] = tbsrequire('gui/unique/classic_sonic1'),
        [2] = tbsrequire('gui/unique/classic_sonic2'),
        [3] = tbsrequire('gui/unique/classic_soniccd'),
        [4] = tbsrequire('gui/unique/classic_sonic3'),
        [5] = tbsrequire('gui/unique/classic_blast3d'),
        [6] = tbsrequire('gui/unique/classic_mania'),
        [7] = tbsrequire('gui/unique/classic_xtreme'),
        [8] = tbsrequire('gui/unique/classic_chaotix'),
    },

    forceusername_cv = CV_RegisterVar{
        name = "classic_username",
        defaultvalue = "0",
        flags = 0,
        PossibleValue = {off = 0, on = 1},
    },

    totalringcounter_cv = CV_RegisterVar{
        name = "classic_ringcounter",
        defaultvalue = "0",
        flags = 0,
        PossibleValue = {off = 0, on = 1},
    },

    hidehud_cv = CV_RegisterVar{
        name = "classic_hidehudop",
        defaultvalue = "0",
        flags = 0,
        PossibleValue = {off = 0, tally = 1, title = 2, both = 3},
    },

    bluefade_cv = CV_RegisterVar{
        name = "classic_bluefade",
        defaultvalue = "off",
        flags = 0,
        PossibleValue = {off = 0, tally = 1},
    }
}

local titletypechange = -1

addHook("MapChange", function()
	if titletypechange > 0 then
		module.titletype = titletypechange

		titletypechange = -1
	end
end)

module.currentlayout = module.layouts[1]
module.currenthud = module.hudspecifics[1]

module.easenum_opt = Options:new("easingtonum",
	{
		[0] = {nil, "disabled",    "Disabled"},
		[1] = {nil, "smooth",  		"Smooth"},
	},
function(cvar)
	module.numbereasing = (cvar.value == 1)
end, 0, 5)

module.debug_opt = Options:new("debug",
	{
		[0] = {nil, 	"off",   	"Off"},
		[1] = {1, 		"plane",  	"2D X/Y"},
		[2] = {2, 		"full",  	"3D X/Y/Z"},
	},
nil, 0, 5)

module.lifepos_opt = Options:new("lifepos",
	{
		{nil, "classic",   	"Classic"},
		{nil, "mobile", 	"Mobile"},
	},
function(var)
	module.livepos = var.value
end, 0, 5)

module.life_opt = Options:new("lifeicon", "gui/cvars/lifeicon", function(var)
	local set = {1, 3, 4, 5, 6, 7, 8}
	module.livestype = set[var.value]
end, 0, 5)

module.title_opt = Options:new("hudtitle", "gui/cvars/hudtitle", function(var)
	local titles = {1, 2, 3, 4, 6, 5}

	if gamestate == GS_LEVEL then
		titletypechange = titles[var.value]
	else
		module.titletype = titles[var.value]
	end
end, 0, 7)

module.hud_opt = Options:new("hud", "gui/cvars/hudtypes", function(var)
	local font = {1, 2, 3, 4, 5, 6, 7, 8}
	CV_Set(fonts.opt.cv, font[var.value])

	local lives = {1, 1, 2, 3, 4, 5, 6, 7}
	CV_Set(module.life_opt.cv, lives[var.value])

	local title = {1, 2, 3, 4, 6, 5, 4, 4}
	CV_Set(module.title_opt.cv, title[var.value])

	local recolorersinsp = {
		"SPECIALSTAGE_SONIC1_TALLY1",
		"SPECIALSTAGE_SONIC2_TALLY",
		"SPECIALSTAGE_SONICCD_TALLY",
		"SPECIALSTAGE_SONIC3_TALLY",
		"SPECIALSTAGE_SONIC3DB_TALLY",
		nil, -- mania
		"SPECIALSTAGE_SONIC1_TALLY1",
		"SPECIALSTAGE_SONIC1_TALLY1",
	}
	module.tallycolor = recolorersinsp[var.value]

	if var.value > 4 then
		---@diagnostic disable-next-line
		CV_Set(module.bluefade_cv, 1)
	else
		---@diagnostic disable-next-line
		CV_Set(module.bluefade_cv, 0)
	end

	module.hudselect = var.value
    module.currenthud = module.hudspecifics[var.value]
end, 0, 8)

module.layout_opt = Options:new("hudlayout", "gui/cvars/layouts", function(var)
	module.layoutindex = var.value
    module.currentlayout = module.layouts[var.value]
end, 0, 4)

module.timeformat_opt = Options:new("timeformat", "gui/cvars/hudtime", nil, 0, 7)

return module