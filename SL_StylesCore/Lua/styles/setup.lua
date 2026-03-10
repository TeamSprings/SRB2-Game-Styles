local __devMode = true

--[[
	Styles for SRB2
	@ Contributors: Skydusk, Clonefighter
]]

local gameString = "styles"

local packVersion = '4.0x0.1'
rawset(_G, "Style_Version", 4000)
rawset(_G, "Style_VersionString", packVersion)
rawset(_G, "Style_Pack_Active", false)

local packType = '[Styles Core '..packVersion..'] '
local version = '2.2.16'

rawset(_G, "Style_GamePrefix", gameString)
rawset(_G, "Style_PrintPrefix", packType)
rawset(_G, "Style_IOLocation", "client/teamsprings/gamestyles/")

rawset(_G, "Style_DebugMode", __devMode)
rawset(_G, "Style_DebugScriptsLoaded", 0)
rawset(_G, "Style_DebugScriptsTotal", 0)
rawset(_G, "Style_DebugErrorPrinter", "")

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")

dofile(stylesCoreLocation.."tools/globals.lua")

if not Style_DataPack then -- initiaze sequencer
	rawset(_G, "Style_DataPack", {})
end

if VERSION == 202 and SUBVERSION > 15 and not Style_ClassicVersion and not Style_DimpsVersion and not Style_AdventureVersion then
	local start_metric = getTimeMicros()

	-- SETUP LOAD ORDER

	local modio = tbsrequire(stylesCoreLocation..'tools/states/io')
	modio.file = Style_IOLocation.."config.cfg"

    styleslogging.print(modio.embedded and "Loading embedded configuration" or "Loading "..modio.file)
	modio:load()

    styleslogging.print("Starting up core modules")
	stylesdofile(stylesCoreLocation.."load.lua")

	Style_Pack_Active = true
	styleslogging.printNote(packType .. "Mod loaded in " .. ( getTimeMicros() - start_metric ) .. " ms")

	if __devMode then
		if styleslogging.actual_log then
			print(packType.."DEBUG PRINT START")

			for _,logline in ipairs(styleslogging.actual_log) do
				print(logline)
			end

			print(packType.."DEBUG PRINT END")
		end
	end
elseif Style_ClassicVersion and not Style_DimpsVersion and not Style_AdventureVersion then
	-- Notify 'em
	local function ErrorPack_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "OUTDATED STYLES MOD DETECTED.", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE RESET THE GAME WITH JUST STYLES CORE.", 0, "thin-center")
	end

	hud.add(ErrorPack_Notification, "title")
	hud.add(ErrorPack_Notification, "game")
else
	-- Notify 'em
	local function MisVersion_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "STYLES CORE WON'T BE LOADED IN THIS VERSION OF SRB2", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE DOWNLOAD \""..version.."\" OR NEWER VERSION", 0, "thin-center")
	end

	hud.add(MisVersion_Notification, "title")
	hud.add(MisVersion_Notification, "game")
end
