--[[

	Music/Jingles Replacer

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local invincibilitytheme_cv = CV_RegisterVar{
	name = "classic_invintheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, soniccdjp=2, soniccdus=3, sonic3=4, sonicknuckles=5, genesis3d=6, saturn3d=7, mania=8, kchaotix=9}
}

local invincibility_select = {
	"_INS1",
	"_INJP",
	"_INUS",
	"_INS3",
	"_INSK",
	"_IN3G",
	"_IN3S",
	"_INSM",
	"_INKC",
}

local supertheme_cv = CV_RegisterVar{
	name = "classic_supertheme",
	defaultvalue = "sonic2",
	flags = 0,
	PossibleValue = {vanilla=0, sonic2=1, sonic3=2, sonicknuckles=3, sonic3unused=4, mania=5}
}

local supertheme_select = {
	"_SES2",
	"_INS3",
	"_INSK",
	"_SESU",
	"_SESM",
}

local lifeuptheme_cv = CV_RegisterVar{
	name = "classic_oneuptheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic3=2, sonicknuckles=3, mania=4}
}

local lifetheme_select = {
	"_1US1",
	"_1US3",
	"_1USK",
	"_1USM",
}

local bosstheme_cv = CV_RegisterVar{
	name = "classic_bosstheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic2=2, soniccdjp=3, soniccdus=4, sonic3act1=5, sonicknucklesact1=6, sonic3act2=7, genesis3d1=8, genesis3d2=9, saturn3d=10, maniaegg1=11, maniaegg2=12}
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
	"_BOM1",
	"_BOM2",
}

local levelendtheme_cv = CV_RegisterVar{
	name = "classic_levelendtheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, soniccdjp=2, soniccdus=3, sonic3=4, genesis3d=5, saturn3d=6, kchaotix=7, mania=8}
}

local levelend_select = {
	"_LCS1",
	"_LCJP",
	"_LCUS",
	"_LCS3",
	"_LC3G",
	"_LC3S",
	"_LCKC",
	"_LCSM",
}

local drowntheme_cv = CV_RegisterVar{
	name = "classic_drowntheme",
	defaultvalue = "sonic1",
	flags = 0,
	PossibleValue = {vanilla=0, sonic1=1, sonic3=2, mania=3}
}

local drown_select = {
	"_DRS1",
	"_DRS3",
	"_DRSM",
}

local shoestheme_cv = CV_RegisterVar{
	name = "classic_shoestheme",
	defaultvalue = "soniccdjp",
	flags = 0,
	PossibleValue = {vanilla=0, soniccdjp=1, soniccdus=2, mania=3}
}

local shoes_select = {
	"_SHJP",
	"_SHUS",
	"_SHSM",
}


-- Music manager
local current_track = ""
local current_typetrack = ""
local old_typetrack = ""
local our_track = false

local event = false
local lenght = 0

local fadingrate = MUSICRATE/2
local boss_defeated = 0

addHook("MapLoad", function()
	boss_defeated = 0
end)

addHook("BossDeath", function()
	boss_defeated = 2
end)

addHook("PostThinkFrame", do
	if displayplayer and displayplayer == consoleplayer then
		if our_track then
			if event then
				lenght = S_GetMusicLength()
				event = false
			end

			if lenght then
				if current_typetrack == "_inv" then
					if displayplayer.powers[pw_invulnerability] == TICRATE/2 then
						S_FadeMusic(0, fadingrate, displayplayer)
					end
				end

				if current_typetrack == "_shoes" then
					if displayplayer.powers[pw_sneakers] == TICRATE/2 then
						S_FadeMusic(0, fadingrate, displayplayer)
					end
				end

				if current_typetrack == "VSBOSS" and boss_defeated then
					local header = mapheaderinfo[gamemap]

					if header.muspostbossname then
						if boss_defeated == 2 then
							S_FadeOutStopMusic(fadingrate, displayplayer)
							boss_defeated = 1
						end

						if not S_MusicPlaying(displayplayer) then
							S_ChangeMusic(header.muspostbossname, true, displayplayer, 0, header.muspostbosspos, 0, header.muspostbossfadein)
							boss_defeated = 0
						end
					end
				end
			end
		end
	end
end)

addHook("MusicChange", function(oldname, newname, mflags, looping, position, prefadems, fadeinms)
	local music_change = false
	local forced_looping = looping
	local forced_prefadems = prefadems
	local forced_fadeinms = fadeinms

	our_track = false

	if newname == "_clear" then
		if levelend_select[levelendtheme_cv.value] then
			music_change = levelend_select[levelendtheme_cv.value]

			forced_prefadems = 0
			forced_fadeinms = MUSICRATE/16
			current_track = music_change

			our_track = true
		end
	end

	if oldname == levelend_select[levelendtheme_cv.value] then
		our_track = true
		return music_change
	else
		if newname == "_1up" then
			if lifetheme_select[lifeuptheme_cv.value] then
				music_change = lifetheme_select[lifeuptheme_cv.value]

				current_track = music_change

				our_track = true
			end
		end

		if newname == "_inv" then
			if invincibility_select[invincibilitytheme_cv.value] then
				music_change = invincibility_select[invincibilitytheme_cv.value]

				current_track = music_change

				forced_looping = true
				forced_prefadems = 0
				forced_fadeinms = MUSICRATE/4

				our_track = true
			end
		end

		if newname == "_super" then
			if supertheme_select[supertheme_cv.value] then
				music_change = supertheme_select[supertheme_cv.value]

				current_track = music_change

				forced_looping = true
				forced_prefadems = 0
				forced_fadeinms = MUSICRATE/8
				our_track = true
			end
		end

		if newname == "_drown" then
			if drown_select[drowntheme_cv.value] then
				music_change = drown_select[drowntheme_cv.value]

				current_track = music_change

				our_track = true
			end
		end

		if newname == "_shoes" then
			if shoes_select[shoestheme_cv.value] then
				music_change = shoes_select[shoestheme_cv.value]

				current_track = music_change

				forced_looping = true
				forced_prefadems = 0
				forced_fadeinms = MUSICRATE/4
				our_track = true
			end
		end

		if newname == "VSBOSS" then
			if boss_select[bosstheme_cv.value] then
				music_change = boss_select[bosstheme_cv.value]

				current_track = music_change

				forced_looping = true
				forced_prefadems = 0
				forced_fadeinms = MUSICRATE/4
				our_track = true
			end
		end
	end

	old_typetrack = current_typetrack
	current_typetrack = newname
	event = true

	return music_change, mflagsx, forced_looping, position, forced_prefadems, forced_fadeinms
end)