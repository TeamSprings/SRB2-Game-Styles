local __devMode = true

local gameString = "DC"

local packVersion = '3.500'
rawset(_G, "Style_AdventureVersion", 3500)
rawset(_G, "Style_AdventureVersionString", packVersion)
rawset(_G, "Style_Pack_Active", true)

local packType = '[Adventure Style '..packVersion..'] '
local version = '2.2.15'

rawset(_G, "Style_GamePrefix", gameString)
rawset(_G, "Style_PrintPrefix", packType)
rawset(_G, "Style_IOLocation", "client/bluespring/styles/adv_")

rawset(_G, "Style_DebugScriptsLoaded", 0)
rawset(_G, "Style_DebugScriptsTotal", 0)
rawset(_G, "Style_DebugErrorPrinter", "")

--[[
	Sonic Adventure Stylized Pack for SRB2
	@ Contributors: Skydusk, Demnyx
]]

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")

local function styles_errerror(str)
	error(str)

	Style_DebugErrorPrinter = $ .. str .. "\n"
end

local function styles_errprint(str)
	print(str)

	Style_DebugErrorPrinter = $ .. str .. "\n"
end

rawset(_G, "Style_DebugPrint", styles_errprint)

if not tbsrequire then
	local cache_lib = {}

	rawset(_G, "tbsrequire", function(path)
		local path = path .. ".lua"
		if cache_lib[path] then
			return cache_lib[path]
		else
			Style_DebugScriptsTotal = $ + 1

			local func, err = loadfile(path)
			if not func then
				styles_errerror("[Game Styles] Error loading module '"..path.."': "..err)
			else
				cache_lib[path] = func()
				Style_DebugScriptsLoaded = $ + 1

				return cache_lib[path]
			end
		end
	end)

	rawset(_G, "tbslibrary", function(path)
		return tbsrequire("libs/"..path)
	end)
end

local function safeDoFile(path)
	local func, err = loadfile(path)

	if func then
		local status, result = pcall(func)

		if not status then
			styles_errprint("[Game Styles] Error loading or executing " .. path .. ": " .. result)
		else
			Style_DebugScriptsLoaded = $ + 1
		end
	else
		styles_errprint("[Game Styles] Error loading " .. path .. ": " .. err)
	end

	Style_DebugScriptsTotal = $ + 1
end

local function iterator_n(array, n) if n < #array then n = $+1 return n, array[n] end end
local function iterator(array) return iterator_n, array, 0 end

local function macro_dofile(prefix, ...)
	local array = {...}
	for _,use in iterator(array) do
		safeDoFile(prefix..'_'..use)
	end
end

if VERSION == 202 and SUBVERSION > 14 and not Style_DimpsVersion and not Style_ClassicVersion then
	local start_metric = getTimeMicros()
	print(packType.."Loading")

	local modio = tbsrequire 'DC_save'

	modio.file = Style_IOLocation.."cvars.dat"
	modio.pointer = CV_RegisterVar

	rawset(_G, "CV_RegisterVar", function(...)
		return modio:register(0, ...)
	end)

	-- sal's library
	safeDoFile("libs/sal_lib-customhud-v4-1.lua")

	macro_dofile(gameString, "main.lua")

	macro_dofile("entities/"..gameString,
		"objects_custom.lua",

		"models_common.lua",
		"models_itembox.lua",
		"models_checkpoint.lua",
		"models_shields.lua",
		"flickies.lua")

	macro_dofile(gameString,
		"game.lua",
		"player.lua"
	)

	macro_dofile("hud/"..gameString,
		"user_game.lua",
		"user_inter.lua",
		"user_mics.lua")

	macro_dofile(gameString,
		"jingles.lua",
		"menu.lua"
	)

	-- Finish

	rawset(_G, "CV_RegisterVar", modio.pointer)

	modio:load()

	styles_errprint(packType .. "Mod loaded in " .. ( getTimeMicros() - start_metric ) .. " ms")
elseif Style_DimpsVersion or Style_ClassicVersion then
	-- Notify 'em
	local function ErrorPack_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "DIFFERENT STYLE MOD DETECTED, ADVENTURE STYLE WON'T BE LOADED.", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE RESET THE GAME AND LOAD ONLY ONE STYLE PER SESSION.", 0, "thin-center")
	end

	hud.add(ErrorPack_Notification, "title")
	hud.add(ErrorPack_Notification, "game")
else
	-- Notify 'em
	local function MisVersion_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "ADVENTURE STYLE WON'T BE LOADED IN THIS VERSION OF SRB2", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE DOWNLOAD 2.2.15 OR NEWER VERSION", 0, "thin-center")
	end

	hud.add(MisVersion_Notification, "title")
	hud.add(MisVersion_Notification, "game")
end
