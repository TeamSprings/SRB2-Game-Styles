local gameString = "gba"

local packVersion = '3.102'
rawset(_G, "Style_DimpsVersion", 3102)
rawset(_G, "Style_Pack_Active", true)

local packType = '[Dimps Style '..packVersion..'] '
local version = '2.2.14'

--[[
	Dimps Stylized Pack for SRB2
	@ Contributors: Skydusk
]]

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")
assert((SUBVERSION > 13), packType.."Mod requires features from "..version.."+")

freeslot("SKINCOLOR_COMPRESSORGBA", "SKINCOLOR_COMPRESSORGBA2")
freeslot("SKINCOLOR_COMPRESSORGBAP2", "SKINCOLOR_COMPRESSORGBA2P2")
skincolors[freeslot("SKINCOLOR_PITCHBLACK")] = {
	name = "Pitch Black",
	ramp = {31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31},
	accessible = false,
}

if not tbsrequire then
	local cache_lib = {}

	rawset(_G, "tbsrequire", function(path)
		local path = path .. ".lua"
		if cache_lib[path] then
			return cache_lib[path]
		else
			local func, err = loadfile(path)
			if not func then
				error("error loading module '"..path.."': "..err)
			else
				cache_lib[path] = func()
				return cache_lib[path]
			end
		end
	end)
end

local function iterator_n(array, n) if n < #array then n = $+1 return n, array[n] end end
local function iterator(array) return iterator_n, array, 0 end

local function macro_dofile(prefix, ...)
	local array = {...}
	for _,use in iterator(array) do
		dofile(prefix..'_'..use)
	end
end

if VERSION == 202 and SUBVERSION > 13 and not Style_ClassicVersion and not Style_AdventureVersion then
	local start_metric = getTimeMicros()
	print(packType.."Loading")

	dofile("libs/sal_lib-customhud-v2-1.lua")

	macro_dofile(gameString,
	"assets.lua",
	"misc.lua",
	"inter.lua",
	"jingles.lua",
	"monitor.lua",
	"player.lua",
	"hudmanager.lua",

	"io.lua")

	print(packType.."Mod loaded in "..(getTimeMicros()-start_metric).." ms")
elseif Style_ClassicVersion or Style_AdventureVersion then
	-- Notify 'em
	local function ErrorPack_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "DIFFERENT STYLE MOD DETECTED, DIMPS STYLE WON'T BE LOADED.", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE RESET THE GAME AND LOAD ONLY ONE STYLE PER SESSION.", 0, "thin-center")
	end

	hud.add(ErrorPack_Notification, "title")
	hud.add(ErrorPack_Notification, "game")
else
	-- Notify 'em
	local function MisVersion_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "DIMPS STYLE WON'T BE LOADED IN THIS VERSION OF SRB2", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE DOWNLOAD 2.2.14+ or Nighty Build of SRB2", 0, "thin-center")
	end

	hud.add(MisVersion_Notification, "title")
	hud.add(MisVersion_Notification, "game")
end
