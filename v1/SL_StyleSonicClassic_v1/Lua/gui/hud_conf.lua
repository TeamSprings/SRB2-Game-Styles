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
        [9] = tbsrequire('gui/unique/classic_custom'),
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

module.lives_index = {1, 3, 4, 5, 6, 7, 8, 9}

module.livesrenderfunc = module.hudspecifics[1].playericon
module.lifeicon_opt = Options:new("lifeiconrender", "gui/cvars/lifeicon",
function(var)
	module.livesrenderfunc = module.hudspecifics[module.lives_index[var.value]].playericon
end, 0, 4)

module.life_opt = Options:new("lifeicon", "gui/cvars/lifeicon", function(var)
	module.livestype = module.lives_index[var.value]
	CV_Set(module.lifeicon_opt.cv, var.value)
end, 0, 5)

module.titles_index = {1, 2, 3, 4, 6, 5}

module.title_opt = Options:new("hudtitle", "gui/cvars/hudtitle", function(var)
	if gamestate == GS_LEVEL then
		titletypechange = module.titles_index[var.value]
	else
		module.titletype = module.titles_index[var.value]
	end
end, 0, 7)

module.hudfont_index  = {1, 2, 3, 4, 5, 6, 7, 8}
module.hudlives_index = {1, 1, 2, 3, 4, 5, 6, 7}
module.hudtitle_index = {1, 2, 3, 4, 6, 5, 4, 4}

module.tallyrecolors_index = {
	"SPECIALSTAGE_SONIC1_TALLY1",
	"SPECIALSTAGE_SONIC2_TALLY",
	"SPECIALSTAGE_SONICCD_TALLY",
	"SPECIALSTAGE_SONIC3_TALLY",
	"SPECIALSTAGE_SONIC3DB_TALLY",
	nil, -- mania
	"SPECIALSTAGE_SONIC1_TALLY1",
	"SPECIALSTAGE_SONIC1_TALLY1",
}

module.hud_opt = Options:new("hud", "gui/cvars/hudtypes", function(var)
	CV_Set(fonts.opt.cv, module.hudfont_index[var.value])
	CV_Set(module.life_opt.cv, module.hudlives_index[var.value])
	CV_Set(module.title_opt.cv, module.hudtitle_index[var.value])

	module.tallycolor = module.tallyrecolors_index[var.value]

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