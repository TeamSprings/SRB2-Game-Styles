--[[

	I/O Config script

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

addHook("GameQuit", function(quit)
	if not quit then return end
	local finalpos = 0
	local forced_variables = {
		index = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
		"gba_hud",
		"gba_iconstyle",
		"gba_hudfont",
		"gba_borders",
		"gba_itemdisplay",

		"gba_monitorstyle",
		"gba_eggmanvoice",

		"gba_endtally",
		"gba_sign_movement",
		"gba_springroll",
		"gba_thok"
	}

	local check = io.openlocal("client/bluespring/styles/dimps_cvars.dat", "r+")
	if check then
		for line in check:lines() do
			local w = line:match("^([%w]+)")
			for k,v in ipairs(forced_variables) do
				if v == w then
					forced_variables.index[k] = tonumber(check:seek("cur"))+2
				end
			end
		end
		local finalpos = tonumber(check:seek("end"))
		check:close()
	end

    local file = io.openlocal("client/bluespring/styles/dimps_cvars.dat", "w")
	if file then
		for k,v in ipairs(forced_variables) do
			file:seek("set", forced_variables.index[k] == 1 and finalpos or forced_variables.index[k]-2)
			file:write(v+" "+CV_FindVar(v).value+"\n")
		end
		file:close()
	end
end)

local function LoadConfig()
	local loadfile = io.openlocal("client/bluespring/styles/dimps_cvars.dat", "r+")

	if loadfile then
		loadfile:seek("set", 0)
		for line in loadfile:lines() do
			local tab = {}

			for w in string.gmatch(line, "%S+") do
				table.insert(tab, w)
			end

			if tab and tab[1] and tab[2] then
				local cvar = CV_FindVar(tab[1])
				if cvar and (not ((cvar.flags & CV_NETVAR) and multiplayer) or isserver) then
					CV_Set(cvar, tab[2])
				end
			else
				continue
			end
		end
		loadfile:close()
	end
end
LoadConfig()