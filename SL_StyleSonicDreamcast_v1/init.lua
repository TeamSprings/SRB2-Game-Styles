local gameString = "DC"

local packVersion = '3.200'
rawset(_G, "Style_AdventureVersion", 3200)
rawset(_G, "Style_Pack_Active", true)

local packType = '[Adventure Style '..packVersion..'] '
local version = '2.2.14'

--[[
	Sonic Adventure Stylized Pack for SRB2
	@ Contributors: Skydusk, Demnyx
]]

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")
assert((SUBVERSION > 13), packType.."Mod requires features from "..version.."+")

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

	rawset(_G, "tbslibrary", function(path)
		return tbsrequire("libs/"..path)
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

if VERSION == 202 and SUBVERSION > 13 and not Style_DimpsVersion and not Style_ClassicVersion then
	local start_metric = getTimeMicros()
	print(packType.."Loading")

	-- sal's library
	dofile("libs/sal_lib-customhud-v2-1.lua")

	macro_dofile(gameString, "main.lua")

	macro_dofile("entities/"..gameString,
		"objects_custom.lua",

		"models_common.lua",
		"models_itembox.lua",
		"models_checkpoint.lua",
		"models_shields.lua",
		"flickies.lua")

	macro_dofile(gameString, "game.lua")

	macro_dofile("hud/"..gameString,
		"user_game.lua",
		"user_inter.lua",
		"user_mics.lua")

	macro_dofile(gameString, "jingles.lua")

	macro_dofile(gameString, "save.lua")

	print(packType.."Mod loaded in "..(getTimeMicros()-start_metric).." ms")
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
		v.drawString(160, 110, "PLEASE DOWNLOAD 2.2.14+ or Nighty Build of SRB2", 0, "thin-center")
	end

	hud.add(MisVersion_Notification, "title")
	hud.add(MisVersion_Notification, "game")
end
