CV_RegisterVar{
	name = "classic_presets",
	defaultvalue = "disabled",
	flags = CV_CALL,
	func = function(var)
		return
	end,
	PossibleValue = {disabled=0}
}


addHook("GameQuit", function(quit)
	if not quit then return end
	local finalpos = 0
	local forced_variables = {
		index = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
		"classic_presets",
		-- HUD
		"classic_lifeicon",
		"classic_hudfont",
		"classic_hud",
		"classic_debug",
		--Assets
		"classic_monitor",
		"classic_checkpoints",
		"classic_emeralds",
		"classic_explosions",
		"classic_dust",
		"classic_pity",
		"classic_invincibility",
		"classic_score",
		"classic_sign",
	}

	local check = io.openlocal("bluespring/styles/classic_config.dat", "r+")
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

    local file = io.openlocal("bluespring/styles/classic_config.dat", "w")
	if file then
		for k,v in ipairs(forced_variables) do
			file:seek("set", forced_variables.index[k] == 1 and finalpos or forced_variables.index[k]-2)
			file:write(v+" "+CV_FindVar(v).value+"\n")
		end
		file:close()
	end
end)

local function LoadConfig()
	local loadfile = io.openlocal("bluespring/styles/classic_config.dat", "r+")

	if loadfile then
		loadfile:seek("set", 0)
		for line in loadfile:lines() do
			local tab = {}

			for w in string.gmatch(line, "%S+") do
				table.insert(tab, w)
			end

			if tab and tab[1] and tab[2] then
				local cvar = CV_FindVar(tab[1])
				if cvar then
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