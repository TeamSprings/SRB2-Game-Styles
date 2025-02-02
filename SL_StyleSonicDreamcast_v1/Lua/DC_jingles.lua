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
		--if levelend_select[levelendtheme_cv.value] then
			music_change = levelend_select[levelendtheme_cv.value]

			forced_prefadems = 0
			forced_fadeinms = MUSICRATE/16
			current_track = music_change

			our_track = true
		--end
	end

	--if oldname == levelend_select[levelendtheme_cv.value] then
		--our_track = true
		--return music_change
	--else
		if newname == "_1up" then
			--if lifetheme_select[lifeuptheme_cv.value] then
				--music_change = lifetheme_select[lifeuptheme_cv.value]

				--current_track = music_change

				our_track = true
			--end
		end

		if newname == "_inv" then
			--if invincibility_select[invincibilitytheme_cv.value] then
				--music_change = invincibility_select[invincibilitytheme_cv.value]

				--current_track = music_change

				forced_looping = true
				forced_prefadems = 0
				forced_fadeinms = MUSICRATE/4

				our_track = true
			--end
		end

		if newname == "_super" then
			--if supertheme_select[supertheme_cv.value] then
				--music_change = supertheme_select[supertheme_cv.value]

				--current_track = music_change

				forced_looping = true
				forced_prefadems = 0
				forced_fadeinms = MUSICRATE/8
				our_track = true
			--end
		end

		if newname == "_drown" then
			--if drown_select[drowntheme_cv.value] then
				--music_change = drown_select[drowntheme_cv.value]

				--current_track = music_change

				our_track = true
			--end
		end

		if newname == "_shoes" then
			--if shoes_select[shoestheme_cv.value] then
				--music_change = shoes_select[shoestheme_cv.value]

				--current_track = music_change

				forced_looping = true
				forced_prefadems = 0
				forced_fadeinms = MUSICRATE/4
				our_track = true
			--end


		end

		if newname == "VSBOSS" then
			--if boss_select[bosstheme_cv.value] then
				--music_change = boss_select[bosstheme_cv.value]

				--current_track = music_change

				forced_looping = true
				forced_prefadems = 0
				forced_fadeinms = MUSICRATE/4
				our_track = true
			--end
		end
	--end

	old_typetrack = current_typetrack
	current_typetrack = newname
	event = true

	return music_change, mflagsx, forced_looping, position, forced_prefadems, forced_fadeinms
end)