local em = tbsrequire('assets/tables/sprites/emeralds')
local em_value = #em
em = nil

return {
	{name = "STYLE PRESET", 	opt = "presets"},
	"HUD",
	{name = "HUD PRESET", 		opt = "hud", --preview = function(v, x, y, flags)
		--v.draw(x+24, 16+y, v.cachePatch(prefix..'TTIME'), flags)
		--drawf(v, prefix..'TNUM', (x+24)*FRACUNIT, (32+y)*FRACUNIT, FRACUNIT, 8420, flags, v.getColormap(TC_DEFAULT, 1), "left")
	--end
	},
	{name = "HUD FONT", 		opt = "hudfont"},
	{name = "HUD ICON STYLE",	opt = "lifeicon"},
	{name = "HUD LAYOUT", 		opt = "hudlayout"},
	{name = "STAGECARD", 		opt = "hudtitle"},
	{minv = 0, maxv = 2, 		name = "DEBUG MODE", cv = CV_FindVar("classic_debug")},
	{minv = 0, maxv = 3, 		name = "HIDEABLE HUD", cv = CV_FindVar("classic_hidehudop")},
	{minv = 0, maxv = 1, 		name = "BLUE FADE", cv = CV_FindVar("classic_bluefade")},
	"GAMEPLAY",
	{name = "TOKEN", 			opt = "specialentrance"},
	{name = "SIGN ACTION", 		opt = "sign_movement"},
	{name = "MONITOR SETS", 	opt = "monitordistribution"},
	{minv = 0, maxv = 1, 		name = "MONITOR HOP", cv = CV_FindVar("classic_monitormaniajump")},
	{minv = 0, maxv = 1, 		name = "SCORE TALLY", cv = CV_FindVar("classic_endtally")},
	"PLAYER",
	{name = "SPIN TRAIL", 		opt = "thok"},
	{name = "SPINDASH", 		opt = "spindash"},
	{name = "SPRING TWIRL", 	opt = "springtwirl"},
	{name = "SPRING ROLL", 		opt = "springroll"},
	{name = "FALL AIRWALK", 	opt = "springairwalk"},
	"EYECANDY",
	{name = "MONITORS", 		opt = "monitor"},
	{name = "STARPOSTS", 		opt = "checkpoints"},
	{name = "EMERALDS", 		opt = "emeralds"},
	{name = "EXPLOSIONS", 		opt = "explosions"},
	{name = "POOF DUST", 		opt = "dust"},
	{name = "PITY SHIELD", 		opt = "pity"},
	{name = "INVINCIBILITY", 	opt = "invincibility"},
	{name = "TOKEN SPRITE",		opt = "tokensprite"},
	{name = "EMBLEMS",			opt = "emblems"},
	{name = "SCORE", 			opt = "score"},
	{name = "SIGN", 			opt = "sign"},
	"MUSIC",
	{name = "1UP THEME", 		opt = "oneuptheme"},
	{name = "SPSHOES THEME", 	opt = "shoestheme"},
	{name = "INVIN THEME", 		opt = "invintheme"},
	{name = "SUPER THEME", 		opt = "supertheme"},
	{name = "BOSS THEME", 		opt = "bosstheme"},
	{name = "CLEAR THEME", 		opt = "levelendtheme"},
	{name = "DROWN THEME", 		opt = "drowntheme"},
}