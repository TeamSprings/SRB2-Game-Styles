local __devMode = true

--[[
	Classic Stylized Pack for SRB2
	@ Contributors: Skydusk, Clonefighter
]]

local gameString = "classic"

local packVersion = '3.820'
rawset(_G, "Style_ClassicVersion", 3820)
rawset(_G, "Style_ClassicVersionString", packVersion)
rawset(_G, "Style_Pack_Active", true)

local packType = '[Classic Style '..packVersion..'] '
local version = '2.2.15'

rawset(_G, "Style_GamePrefix", gameString)
rawset(_G, "Style_PrintPrefix", packType)
rawset(_G, "Style_IOLocation", "client/teamsprings/gamestyles/classic/")

rawset(_G, "Style_DebugMode", __devMode)
rawset(_G, "Style_DebugScriptsLoaded", 0)
rawset(_G, "Style_DebugScriptsTotal", 0)
rawset(_G, "Style_DebugErrorPrinter", "")

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")

---@diagnostic disable-next-line
skincolors[freeslot("SKINCOLOR_PITCHBLACK")] = {
	name = "Pitch Black",
	ramp = {31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31},
	accessible = false,
}

---@diagnostic disable-next-line
skincolors[freeslot("SKINCOLOR_PURPLEMANIAHUD")] = {
	name = "Purple Mania",
	ramp = {172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172},
	accessible = false,
}

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

if VERSION == 202 and SUBVERSION > 14 and not Style_DimpsVersion and not Style_AdventureVersion then
	local start_metric = getTimeMicros()

	-- Print "LOADING"
	print(packType.."Loading")

	local modio = tbsrequire 'classic_io'

	modio.file = Style_IOLocation.."config.cfg"
	modio.pointer = CV_RegisterVar

	rawset(_G, "CV_RegisterVar", function(...)
		return modio:register(0, ...)
	end)

	-- RUN ALREADY
	safeDoFile("libs/sal_lib-customhud-v4-4.lua")

	-- Game Assets
	safeDoFile(gameString.."_init.lua")

	safeDoFile(gameString.."_disable.lua")

	safeDoFile("assets/"..gameString.."_jingles.lua")
	safeDoFile("gameplay/"..gameString.."_inter.lua")

	safeDoFile("assets/"..gameString.."_monitor.lua")
	safeDoFile("assets/"..gameString.."_misc.lua")
	safeDoFile("assets/"..gameString.."_capsules.lua")

	safeDoFile("gameplay/"..gameString.."_player.lua")

	safeDoFile("gameplay/"..gameString.."_special.lua")
	safeDoFile("gameplay/"..gameString.."_levels.lua")

	safeDoFile(gameString.."_gui.lua")
	safeDoFile(gameString.."_presets.lua")

	-- Finish

	rawset(_G, "CV_RegisterVar", modio.pointer)

	modio:load()

	if __devMode then
		safeDoFile("libs/lib_emb_debug.lua")
		Debuglib.insertStaticTable(modio.registry, "STYLES_MODIO")
		Debuglib.insertStaticTable(tbsrequire('styles_api'), "STYLES_API")
		Debuglib.insertStaticTable(tbsrequire('libs/lib_emb_levelverification'), "STYLES_LVLVERIF")

		if Style_DebugErrorPrinter then
			print(packType.."DEBUG PRINT START")
			
			for line in string.gmatch(Style_DebugErrorPrinter, "[^\n]+") do
				print(line)
			end

			print(packType.."DEBUG PRINT END")
		end
	end

	styles_errprint(packType .. "Mod loaded in " .. ( getTimeMicros() - start_metric ) .. " ms")
elseif Style_DimpsVersion or Style_AdventureVersion then
	-- Notify 'em
	local function ErrorPack_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "DIFFERENT STYLE MOD DETECTED, CLASSIC STYLE WON'T BE LOADED.", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE RESET THE GAME AND LOAD ONLY ONE STYLE PER SESSION.", 0, "thin-center")
	end

	hud.add(ErrorPack_Notification, "title")
	hud.add(ErrorPack_Notification, "game")
else
	-- Notify 'em
	local function MisVersion_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "CLASSIC STYLE WON'T BE LOADED IN THIS VERSION OF SRB2", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE DOWNLOAD 2.2.15 OR NEWER VERSION", 0, "thin-center")
	end

	hud.add(MisVersion_Notification, "title")
	hud.add(MisVersion_Notification, "game")
end
