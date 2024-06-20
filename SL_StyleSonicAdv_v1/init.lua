local gameString = "DC"
local packType = '[Sonic Adventure Style]'
local version = '2.2.13'

--[[
	Sonic Adventure Stylized Pack for SRB2
	@ Contributors: Ace Lite,
]]

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")
assert((SUBVERSION > 12), packType.."Mod requires features from "..version.."+")

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

-- Pointless really, merely attempt to create iterator, possibly useful for other type of iterations
local function iterator_n(array, n) if n < #array then n = $+1 return n, array[n] end end
local function iterator(array) return iterator_n, array, 0 end

local function macro_dofile(prefix, ...)
	local array = {...}
	for _,use in iterator(array) do
		dofile(prefix..'_'..use)
	end
end

if VERSION == 202 and SUBVERSION > 9 then
	print(packType.."As this is WIP version of "..gameString.." pack and UDMF update is not out yet. Game allows to load this pack in "..VERSIONSTRING)

	-- sal's library
	dofile("libs/sal_lib-customhud-v2-1.lua")

	macro_dofile(gameString, "main.lua")

	macro_dofile("entities/"..gameString,
		"objects_custom.lua",

		"models_common.lua",
		"models_itembox.lua",
		"models_checkpoint.lua",
		"models_capsule.lua",
		"models_shields.lua")

	macro_dofile(gameString, "game.lua")

	macro_dofile("hud/"..gameString,
		"user_game.lua",
		"user_inter.lua",
		"user_mics.lua")
end
