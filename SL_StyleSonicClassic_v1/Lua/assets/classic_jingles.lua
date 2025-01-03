--[[

	Music/Jingles Replacer

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local invincibilitytheme_cv = CV_RegisterVar{
	name = "classic_invintheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic2=2, soniccdjp=3, soniccdus=4, sonic3=5}
}

local invincibility_select = {
	"_INVIS1",
	"_INVIS2",
	"_INVCDJP",
	"_INVCDUS",
	"_SUPS3",
}

local supertheme_cv = CV_RegisterVar{
	name = "classic_supertheme",
	defaultvalue = "sonic2",
	flags = 0,
	PossibleValue = {vanilla=0, sonic2=1, sonic3=2, sonic3unused=3}
}

local supertheme_select = {
	"_SUPS2",
	"_SUPS3",
	"_SUPSU",
}

local lifeuptheme_cv = CV_RegisterVar{
	name = "classic_oneuptheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic3=2}
}

local lifetheme_select = {
	"_1UPS1",
	"_1UPS3",
}

local bosstheme_cv = CV_RegisterVar{
	name = "classic_bosstheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic2=2, soniccdjp=3, soniccdus=4, sonic3act1=5, sonic3act2=6}
}

local boss_select = {
	"_BOSSS1",
	"_BOSSS2",
	"_BOSCDJP",
	"_BOSCDUS",
	"_BOSS3A1",
	"_BOSS3A2",
}

local levelendtheme_cv = CV_RegisterVar{
	name = "classic_levelendtheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, soniccdjp=2, soniccdus=3, sonic3=4}
}

local levelend_select = {
	"_CLES1",
	"_CLECDJP",
	"_CLECDUS",
	"_CLES3",
}

local drowntheme_cv = CV_RegisterVar{
	name = "classic_drowntheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1}
}

local drown_select = {
	"_DROS1",
}

local shoestheme_cv = CV_RegisterVar{
	name = "classic_shoestheme",
	defaultvalue = "soniccdjp",
	flags = 0,
	PossibleValue = {vanilla=0, soniccdjp=1, soniccdus=2}
}

local shoes_select = {
	"_SHOCDJP",
	"_SHOCDUS",
}

addHook("MusicChange", function(oldname, newname, mflags, looping, position, prefadems, fadeinms)
	local music_change = false

	if newname == "_1up" then
		if lifetheme_select[lifeuptheme_cv.value] then
			music_change = lifetheme_select[lifeuptheme_cv.value]
		end
	end

	if newname == "_inv" then
		if invincibility_select[invincibilitytheme_cv.value] then
			music_change = invincibility_select[invincibilitytheme_cv.value]
		end
	end

	if newname == "_super" then
		if supertheme_select[supertheme_cv.value] then
			music_change = supertheme_select[supertheme_cv.value]
		end
	end

	if newname == "_drown" then
		if drown_select[drowntheme_cv.value] then
			music_change = drown_select[drowntheme_cv.value]
		end
	end

	if newname == "_clear" then
		if levelend_select[levelendtheme_cv.value] then
			music_change = levelend_select[levelendtheme_cv.value]
		end
	end

	if newname == "_shoes" then
		if shoes_select[shoestheme_cv.value] then
			music_change = shoes_select[shoestheme_cv.value]
		end
	end

	if newname == "VSBOSS" then
		if boss_select[bosstheme_cv.value] then
			music_change = boss_select[bosstheme_cv.value]
		end
	end

	return music_change, mflags, looping, position, prefadems, fadeinms
end)