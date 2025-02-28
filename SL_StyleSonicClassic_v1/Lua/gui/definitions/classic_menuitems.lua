local em = tbsrequire('assets/tables/sprites/classic_emeralds')
local em_value = #em
em = nil

return {
	{minv = 1, maxv = 5, name = "STYLE PRESET", cv = CV_FindVar("classic_presets")},
	"HUD",
	{minv = 1, maxv = 8, name = "HUD PRESET", cv = CV_FindVar("classic_hud"), --preview = function(v, x, y, flags)
		--v.draw(x+24, 16+y, v.cachePatch(prefix..'TTIME'), flags)
		--drawf(v, prefix..'TNUM', (x+24)*FRACUNIT, (32+y)*FRACUNIT, FRACUNIT, 8420, flags, v.getColormap(TC_DEFAULT, 1), "left")
	--end
	},
	{minv = 1, maxv = 8, 		name = "HUD FONT", cv = CV_FindVar("classic_hudfont")},
	{minv = 1, maxv = 6, 		name = "HUD ICON STYLE", cv = CV_FindVar("classic_lifeicon")},
	{minv = 1, maxv = 3, 		name = "HUD LAYOUT", cv = CV_FindVar("classic_hudlayout")},
	{minv = 1, maxv = 5, 		name = "STAGECARD", cv = CV_FindVar("classic_hudtitle")},
	{minv = 0, maxv = 2, 		name = "DEBUG MODE", cv = CV_FindVar("classic_debug")},
	{minv = 0, maxv = 3, 		name = "HIDEABLE HUD", cv = CV_FindVar("classic_hidehudop")},
	{minv = 0, maxv = 1, 		name = "BLUE FADE", cv = CV_FindVar("classic_bluefade")},
	"GAMEPLAY",
	{minv = 0, maxv = 3, 		name = "TOKEN", cv = CV_FindVar("classic_specialentrance")},
	{minv = 0, maxv = 1, 		name = "SCORE TALLY", cv = CV_FindVar("classic_endtally")},
	{minv = 0, maxv = 3, 		name = "MONITOR SETS", cv = CV_FindVar("classic_monitordistribution")},
	{minv = 0, maxv = 1, 		name = "MONITOR HOP", cv = CV_FindVar("classic_monitormaniajump")},
	"PLAYER",
	{minv = 0, maxv = 1, 		name = "SPIN TRAIL", cv = CV_FindVar("classic_thok")},
	{minv = 0, maxv = 1, 		name = "SPINDASH", cv = CV_FindVar("classic_spindash")},
	{minv = 0, maxv = 1, 		name = "SPRING TWIRL", cv = CV_FindVar("classic_springtwirl")},
	{minv = 0, maxv = 2, 		name = "SPRING ROLL", cv = CV_FindVar("classic_springroll")},
	{minv = 0, maxv = 1, 		name = "FALL AIRWALK", cv = CV_FindVar("classic_springairwalk")},
	"EYECANDY",
	{minv = 1, maxv = 5, 		name = "MONITORS", cv = CV_FindVar("classic_monitor")},
	{minv = 1, maxv = 6, 		name = "STARPOSTS", cv = CV_FindVar("classic_checkpoints")},
	{minv = 1, maxv = em_value, name = "EMERALDS", cv = CV_FindVar("classic_emeralds")},
	{minv = 1, maxv = 3, 		name = "EXPLOSIONS", cv = CV_FindVar("classic_explosions")},
	{minv = 1, maxv = 2, 		name = "POOF DUST", cv = CV_FindVar("classic_dust")},
	{minv = 1, maxv = 4, 		name = "PITY SHIELD", cv = CV_FindVar("classic_pity")},
	{minv = 1, maxv = 2, 		name = "INVINCIBILITY", cv = CV_FindVar("classic_invincibility")},
	{minv = 1, maxv = 4, 		name = "SCORE", cv = CV_FindVar("classic_score")},
	{minv = 1, maxv = 2, 		name = "SIGN", cv = CV_FindVar("classic_sign")},
	{minv = 0, maxv = 1, 		name = "SIGN ACTION", cv = CV_FindVar("classic_sign_movement")},
	"MUSIC",
	{minv = 0, maxv = 4, 	name = "1UP THEME", cv = CV_FindVar("classic_oneuptheme")},
	{minv = 0, maxv = 3, 	name = "SPSHOES THEME", cv = CV_FindVar("classic_shoestheme")},
	{minv = 0, maxv = 9, 	name = "INVIN THEME", cv = CV_FindVar("classic_invintheme")},
	{minv = 0, maxv = 5, 	name = "SUPER THEME", cv = CV_FindVar("classic_supertheme")},
	{minv = 0, maxv = 12, 	name = "BOSS THEME", cv = CV_FindVar("classic_bosstheme")},
	{minv = 0, maxv = 8, 	name = "CLEAR THEME", cv = CV_FindVar("classic_levelendtheme")},
	{minv = 0, maxv = 3, 	name = "DROWN THEME", cv = CV_FindVar("classic_drowntheme")},
}