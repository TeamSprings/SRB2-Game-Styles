local gameString = "gba"
local packType = '[Dimps Style] '
local version = '2.2.14'

--[[
	Dimps Stylized Pack for SRB2
	@ Contributors: Skydusk
]]

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")
assert((SUBVERSION > 13), packType.."Mod requires features from "..version.."+")

freeslot("SKINCOLOR_COMPRESSORGBA", "SKINCOLOR_COMPRESSORGBA2")
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
			return cache_lib[path]()
		else
			local func, err = loadfile(path)
			if not func then
				error("error loading module '"..path.."': "..err)
			else
				cache_lib[path] = func
				return func()
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

if VERSION == 202 and SUBVERSION > 13 then
	local start_metric = getTimeMicros()
	print(packType.."Loading")

	dofile("libs/sal_lib-customhud-v2-1.lua")

	macro_dofile(gameString,
	"misc.lua",
	"inter.lua",
	"monitor.lua",
	"player.lua",
	"hudmanager.lua",

	"io.lua")

	print(packType.."Mod loaded in "..(getTimeMicros()-start_metric).." ms")
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
