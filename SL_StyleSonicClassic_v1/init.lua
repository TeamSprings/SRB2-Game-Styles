local gameString = "classic"
local packType = '[Classic Styles] '
local version = '2.2.14' -- Currently 2.2.10. UDMF support comes with 2.2.12

--[[
	Classic Stylized Pack for SRB2
	@ Contributors: Skydusk, Clonefighter
]]

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")

skincolors[freeslot("SKINCOLOR_PITCHBLACK")] = {
	name = "Pitch Black",
	ramp = {31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31},
	accessible = false,
}

skincolors[freeslot("SKINCOLOR_PURPLEMANIAHUD")] = {
	name = "Purple Mania",
	ramp = {172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172, 172},
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

if VERSION == 202 and SUBVERSION > 13 then
	local start_metric = getTimeMicros()
	print(packType.."Loading")

	dofile("libs/sal_lib-customhud-v2-1.lua")

	-- Game Assets
	dofile(gameString.."_init.lua")

	dofile("gameplay/"..gameString.."_inter.lua")

	dofile("assets/"..gameString.."_monitor.lua")
	dofile("assets/"..gameString.."_misc.lua")
	dofile("gameplay/"..gameString.."_player.lua")

	dofile("assets/"..gameString.."_jingles.lua")
	dofile("gameplay/"..gameString.."_special.lua")

	dofile(gameString.."_presets.lua")
	dofile(gameString.."_gui.lua")
	dofile(gameString.."_io.lua")

	print(packType.."Mod loaded in "..(getTimeMicros()-start_metric).." ms")
else
	-- Notify 'em
	local function MisVersion_Notification(v)
		v.drawFill(0, 95, 320, 30, 38)
		v.drawString(160, 100, "CLASSIC STYLE WON'T BE LOADED IN THIS VERSION OF SRB2", V_ORANGEMAP, "thin-center")
		v.drawString(160, 110, "PLEASE DOWNLOAD 2.2.14+ or Nighty Build of SRB2", 0, "thin-center")
	end

	hud.add(MisVersion_Notification, "title")
	hud.add(MisVersion_Notification, "game")
end