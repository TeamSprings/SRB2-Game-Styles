local gameString = "gba"
local packType = '[Sonic GBA Style]'
local version = '2.2.14'

/*
	Sonic 3 Stylized Pack for SRB2
	@ Contributors: Ace Lite,
*/

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")
assert((SUBVERSION > 9), packType.."Mod requires features from "..version.."+")

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

-- Shut up and load it in.

// Oh yeah, it is quite pointless check in grand scheme of things.
// I just want to minimalize situation, where some genius decides
// to play this on older version of SRB2.

// Man idiot proofing is so so SOO teadious :earless:
if VERSION == 202 and SUBVERSION > 12 then
	print(packType.."As this is WIP version of "..gameString.." pack and UDMF update is not out yet. Game allows to load this pack in "..VERSIONSTRING)

	dofile("libs/sal_lib-customhud-v2-1.lua")

	// Game Assets
	dofile(gameString.."_misc.lua")
	dofile(gameString.."_monitor.lua")
	dofile(gameString.."_hudmanager.lua")

	dofile(gameString.."_io.lua")
end
