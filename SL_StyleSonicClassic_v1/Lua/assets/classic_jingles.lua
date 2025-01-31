--[[

	Music/Jingles Replacer

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local invincibilitytheme_cv = CV_RegisterVar{
	name = "classic_invintheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic2=2, soniccdjp=3, soniccdus=4, sonic3=5, sonicknuckles=6, blast3d=7}
}

local invincibility_select = {
	"_INS1",
	"_INS2",
	"_INJP",
	"_INUS",
	"_INS3",
	"_INSK",
	"_IN3D",
}

local supertheme_cv = CV_RegisterVar{
	name = "classic_supertheme",
	defaultvalue = "sonic2",
	flags = 0,
	PossibleValue = {vanilla=0, sonic2=1, sonic3=2, sonicknuckles=3, sonic3unused=4}
}

local supertheme_select = {
	"_SES2",
	"_INS3",
	"_INSK",
	"_SESU",
}

local lifeuptheme_cv = CV_RegisterVar{
	name = "classic_oneuptheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic3=2, sonicknuckles=3}
}

local lifetheme_select = {
	"_1US1",
	"_1US3",
	"_1USK",
}

local bosstheme_cv = CV_RegisterVar{
	name = "classic_bosstheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic2=2, soniccdjp=3, soniccdus=4, sonic3act1=5, sonicknucklesact1=6, sonic3act2=7, blast3d1=8, blast3d2=9, blast3d3=10}
}

local boss_select = {
	"_BOS1",
	"_BOS2",
	"_BOCJ",
	"_BOCU",
	"_BS31",
	"_BSK1",
	"_BS32",
	"_B3D1",
	"_B3D2",
	"_B3D3",
}

local levelendtheme_cv = CV_RegisterVar{
	name = "classic_levelendtheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, soniccdjp=2, soniccdus=3, sonic3=4, blast3d1=5}
}

local levelend_select = {
	"_LCS1",
	"_LCJP",
	"_LCUS",
	"_LCS3",
	"_LC3D",
}

local drowntheme_cv = CV_RegisterVar{
	name = "classic_drowntheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1}
}

local drown_select = {
	"_DRS1",
}

local shoestheme_cv = CV_RegisterVar{
	name = "classic_shoestheme",
	defaultvalue = "soniccdjp",
	flags = 0,
	PossibleValue = {vanilla=0, soniccdjp=1, soniccdus=2}
}

local shoes_select = {
	"_SHJP",
	"_SHUS",
}

addHook("MusicChange", function(oldname, newname, mflags, looping, position, prefadems, fadeinms)
	local music_change = false

	if newname == "_clear" then
		if levelend_select[levelendtheme_cv.value] then
			music_change = levelend_select[levelendtheme_cv.value]
		end
	end

	if oldname == levelend_select[levelendtheme_cv.value] then
		return music_change, mflags, looping, position, prefadems, fadeinms
	else
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
	end

	return music_change, mflags, looping, position, prefadems, fadeinms
end)