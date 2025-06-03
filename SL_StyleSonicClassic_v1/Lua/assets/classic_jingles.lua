--[[

	Music/Jingles Replacer

Contributors: Skydusk
@Team Blue Spring 2022-2025

	TODO: Make sure to copy paste & document Music Swap

]]

local Options = tbsrequire('helpers/create_cvar') ---@type CvarModule

local api = tbsrequire 'styles_api'

-- Hooks for API

local swaphook = 	api:addHook("MusicSwap")

local Music = {
	-- Looping themes

	["_inv"] = {	-- Invulnerability theme
		option = Options:new("invintheme", "assets/tables/jingles/invul"),

		loop = true,

		startfade = 0,
		endfade = MUSICRATE/4,
	},
	["_super"] = {	-- Super Sonic theme
		option = Options:new("supertheme", "assets/tables/jingles/super"),

		loop = true,

		startfade = 0,
		endfade = MUSICRATE/8,
	},
	["VSBOSS"] = {	-- Boss theme
		option = Options:new("bosstheme", "assets/tables/jingles/boss"),

		loop = true,

		startfade = 0,
		endfade = MUSICRATE/4,
	},
	["_drown"] = {	-- Drowning theme
		option = Options:new("drowntheme", "assets/tables/jingles/drown"),

		loop = true,

		startfade = 0,
		endfade = MUSICRATE/4,
	},
	["_shoes"] = {	-- Speed Shoes theme
		option = Options:new("shoestheme", "assets/tables/jingles/shoes"),

		loop = true,

		startfade = 0,
		endfade = MUSICRATE/4,
	},

	-- Simple themes

	["_clear"] = {   -- Clear theme
		option = Options:new("levelendtheme", "assets/tables/jingles/tally"),

		startfade = 0,
		endfade = MUSICRATE/16,
	},


	-- Simple jingles

	["_1up"] = {   -- 1UP theme
		option = Options:new("oneuptheme", "assets/tables/jingles/lives"),
	},
}

-- Music manager
local current_track = ""
local current_typetrack = ""
local old_typetrack = ""
local our_track = false
local speedup = false

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
		if displayplayer.powers[pw_sneakers] == TICRATE/2 then
			if speedup then
				S_SpeedMusic(FRACUNIT, displayplayer)
				speedup = nil
			end
		elseif displayplayer.powers[pw_sneakers] > TICRATE/2 and speedup then
			S_SpeedMusic(FRACUNIT*2, displayplayer)
		end

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

	if Music[newname] then
		local data = Music[newname]
		local option = data.option

		if data.loop then
			forced_looping = true
		end

		if data.startfade then
			forced_prefadems = data.startfade
		end

		if data.endfade then
			forced_fadeinms = data.endfade
		end

		if option.values[option.cv.value] then
			music_change = option.values[option.cv.value]
		elseif option.cv.value < 0 then
			speedup = true
			return S_MusicName(displayplayer)
		end

		our_track = true

		swaphook(oldname, newname, Music[newname], forced_looping, forced_prefadems, forced_fadeinms)
	end

	old_typetrack = current_typetrack
	current_typetrack = newname
	event = true

	return music_change, mflagsx, forced_looping, position, forced_prefadems, forced_fadeinms
end)