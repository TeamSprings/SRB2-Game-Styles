--[[

	Presets

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local Options = tbsrequire 'helpers/create_cvar' ---@type CvarModule
local json = tbsrequire 'libs/lib_emb_json'

local sets = tbsrequire 'helpers/cvar_presets'
local modio = tbsrequire 'classic_io'


local CMD_name 	= Style_GamePrefix.."_presets"
local EXTJSON 	= ".json"
local EXTLOG 	= ".log"

if SUBVERSION < 16 then
	EXTJSON 	= ".txt"
	EXTLOG 		= ".txt"
end

local presets = {
	[0] = {},

	-- SONIC 1
	[1] = json.decode([[{"classic_tokensprite":0,"classic_emeralds":1,"classic_hudtitle":1,"classic_drowntheme":1,"classic_levelendtheme":1,"classic_bosstheme":1,"classic_explosions":1,"classic_disablelevel":0,"classic_springroll":0,"classic_monitordistribution":1,"classic_hud":1,"classic_checkpoints":1,"classic_invincibility":1,"classic_monitoriconrot":0,"classic_supertheme":1,"classic_lifeicon":1,"classic_hudcolor":0,"classic_endtally":1,"classic_momentum":2,"classic_jumpsfx":1,"classic_sign_movement":1,"classic_score":1,"classic_monitor":1,"classic_monitormaniajump":0,"classic_shoestheme":3,"classic_runonwater":1,"classic_preserveshield":1,"classic_specialentrance":1,"classic_invintheme":1,"classic_disablegui":0,"classic_spinsfx":1,"classic_oneuptheme":1,"classic_emblems":1,"classic_sign":1,"classic_hudfont":1,"classic_capsule":1,"classic_springairwalk":1,"classic_lifepos":1,"classic_pity":1,"classic_debug":0,"classic_ringcounter":0,"classic_springtwirl":0,"classic_spindash":0,"classic_username":0,"classic_thok":1,"classic_groundrot":1,"classic_emeraldanim":1,"classic_dust":1,"classic_dashsfx":1,"classic_bluefade":0,"classic_polish":0,"classic_emeraldpos":1,"classic_disablecutscenes":0,"classic_timeformat":1,"classic_hudlayout":2,"classic_hidehudop":0,"classic_easingtonum":0,"classic_monitorstaticanim":1}]]),

	-- SONIC 2
	[2] = json.decode([[{"classic_tokensprite":0,"classic_emeralds":3,"classic_hudtitle":2,"classic_drowntheme":1,"classic_levelendtheme":1,"classic_bosstheme":2,"classic_explosions":2,"classic_disablelevel":0,"classic_springroll":0,"classic_monitordistribution":1,"classic_hud":2,"classic_checkpoints":3,"classic_invincibility":2,"classic_monitoriconrot":0,"classic_supertheme":1,"classic_lifeicon":1,"classic_hudcolor":0,"classic_endtally":1,"classic_momentum":2,"classic_jumpsfx":1,"classic_sign_movement":1,"classic_score":2,"classic_monitor":2,"classic_monitormaniajump":0,"classic_shoestheme":3,"classic_runonwater":1,"classic_preserveshield":1,"classic_specialentrance":2,"classic_invintheme":1,"classic_disablegui":0,"classic_spinsfx":1,"classic_oneuptheme":1,"classic_emblems":1,"classic_sign":1,"classic_hudfont":2,"classic_capsule":1,"classic_springairwalk":1,"classic_lifepos":1,"classic_pity":2,"classic_debug":0,"classic_ringcounter":0,"classic_springtwirl":0,"classic_spindash":0,"classic_username":0,"classic_thok":1,"classic_groundrot":1,"classic_emeraldanim":1,"classic_dust":2,"classic_dashsfx":1,"classic_bluefade":0,"classic_polish":0,"classic_emeraldpos":1,"classic_disablecutscenes":0,"classic_timeformat":1,"classic_hudlayout":2,"classic_hidehudop":0,"classic_easingtonum":0,"classic_monitorstaticanim":1}]]),

	-- SONIC CD
	[3] = json.decode([[{"classic_tokensprite":0,"classic_emeralds":4,"classic_hudtitle":3,"classic_drowntheme":1,"classic_levelendtheme":2,"classic_bosstheme":3,"classic_explosions":1,"classic_disablelevel":0,"classic_springroll":0,"classic_monitordistribution":1,"classic_hud":3,"classic_checkpoints":4,"classic_invincibility":1,"classic_monitoriconrot":0,"classic_supertheme":1,"classic_lifeicon":2,"classic_hudcolor":0,"classic_endtally":1,"classic_momentum":2,"classic_jumpsfx":2,"classic_sign_movement":1,"classic_score":3,"classic_monitor":1,"classic_monitormaniajump":0,"classic_shoestheme":1,"classic_runonwater":1,"classic_preserveshield":1,"classic_specialentrance":1,"classic_invintheme":2,"classic_disablegui":0,"classic_spinsfx":2,"classic_oneuptheme":1,"classic_emblems":1,"classic_sign":1,"classic_hudfont":3,"classic_capsule":1,"classic_springairwalk":1,"classic_lifepos":1,"classic_pity":1,"classic_debug":0,"classic_ringcounter":0,"classic_springtwirl":1,"classic_spindash":1,"classic_username":0,"classic_thok":1,"classic_groundrot":1,"classic_emeraldanim":1,"classic_dust":1,"classic_dashsfx":2,"classic_bluefade":0,"classic_polish":0,"classic_emeraldpos":1,"classic_disablecutscenes":0,"classic_timeformat":2,"classic_hudlayout":2,"classic_hidehudop":0,"classic_easingtonum":0,"classic_monitorstaticanim":1}]]),

	-- SONIC 3
	[4] = json.decode([[{"classic_tokensprite":0,"classic_emeralds":1,"classic_hudtitle":4,"classic_drowntheme":2,"classic_levelendtheme":4,"classic_bosstheme":7,"classic_explosions":3,"classic_disablelevel":0,"classic_springroll":2,"classic_monitordistribution":2,"classic_hud":4,"classic_checkpoints":5,"classic_invincibility":2,"classic_monitoriconrot":0,"classic_supertheme":2,"classic_lifeicon":3,"classic_hudcolor":0,"classic_endtally":1,"classic_momentum":2,"classic_jumpsfx":1,"classic_sign_movement":0,"classic_score":4,"classic_monitor":3,"classic_monitormaniajump":0,"classic_shoestheme":1,"classic_runonwater":1,"classic_preserveshield":2,"classic_specialentrance":3,"classic_invintheme":2,"classic_disablegui":0,"classic_spinsfx":1,"classic_oneuptheme":2,"classic_emblems":1,"classic_sign":1,"classic_hudfont":4,"classic_capsule":1,"classic_springairwalk":1,"classic_lifepos":1,"classic_pity":1,"classic_debug":0,"classic_ringcounter":0,"classic_springtwirl":0,"classic_spindash":0,"classic_username":0,"classic_thok":1,"classic_groundrot":1,"classic_emeraldanim":1,"classic_dust":2,"classic_dashsfx":1,"classic_bluefade":0,"classic_polish":0,"classic_emeraldpos":1,"classic_disablecutscenes":0,"classic_timeformat":1,"classic_hudlayout":2,"classic_hidehudop":0,"classic_easingtonum":0,"classic_monitorstaticanim":1}]]),

	-- SONIC 3D BLAST
	[5] = json.decode([[{"classic_tokensprite":1,"classic_emeralds":5,"classic_hudtitle":6,"classic_drowntheme":1,"classic_levelendtheme":5,"classic_bosstheme":8,"classic_explosions":4,"classic_disablelevel":0,"classic_springroll":2,"classic_monitordistribution":1,"classic_hud":5,"classic_checkpoints":1,"classic_invincibility":2,"classic_monitoriconrot":0,"classic_supertheme":2,"classic_lifeicon":4,"classic_hudcolor":0,"classic_endtally":1,"classic_momentum":2,"classic_jumpsfx":1,"classic_sign_movement":1,"classic_score":5,"classic_monitor":4,"classic_monitormaniajump":0,"classic_shoestheme":1,"classic_runonwater":1,"classic_preserveshield":1,"classic_specialentrance":3,"classic_invintheme":6,"classic_disablegui":0,"classic_spinsfx":1,"classic_oneuptheme":2,"classic_emblems":0,"classic_sign":1,"classic_hudfont":5,"classic_capsule":1,"classic_springairwalk":1,"classic_lifepos":1,"classic_pity":3,"classic_debug":0,"classic_ringcounter":0,"classic_springtwirl":0,"classic_spindash":0,"classic_username":0,"classic_thok":1,"classic_groundrot":0,"classic_emeraldanim":1,"classic_dust":3,"classic_dashsfx":1,"classic_bluefade":1,"classic_polish":0,"classic_emeraldpos":1,"classic_disablecutscenes":0,"classic_timeformat":1,"classic_hudlayout":4,"classic_hidehudop":0,"classic_easingtonum":0,"classic_monitorstaticanim":1}]]),

	-- SONIC MANIA
	[6] = json.decode([[{"classic_tokensprite":3,"classic_emeralds":8,"classic_hudtitle":5,"classic_drowntheme":3,"classic_levelendtheme":8,"classic_bosstheme":11,"classic_explosions":5,"classic_disablelevel":0,"classic_springroll":1,"classic_monitordistribution":3,"classic_hud":6,"classic_checkpoints":6,"classic_invincibility":2,"classic_monitoriconrot":0,"classic_supertheme":5,"classic_lifeicon":5,"classic_hudcolor":0,"classic_endtally":1,"classic_momentum":2,"classic_jumpsfx":1,"classic_sign_movement":1,"classic_score":4,"classic_monitor":5,"classic_monitormaniajump":1,"classic_shoestheme":3,"classic_runonwater":2,"classic_preserveshield":2,"classic_specialentrance":3,"classic_invintheme":8,"classic_disablegui":0,"classic_spinsfx":1,"classic_oneuptheme":4,"classic_emblems":2,"classic_sign":1,"classic_hudfont":6,"classic_capsule":1,"classic_springairwalk":1,"classic_lifepos":1,"classic_pity":1,"classic_debug":0,"classic_ringcounter":0,"classic_springtwirl":1,"classic_spindash":0,"classic_username":0,"classic_thok":1,"classic_groundrot":2,"classic_emeraldanim":1,"classic_dust":4,"classic_dashsfx":1,"classic_bluefade":1,"classic_polish":1,"classic_emeraldpos":1,"classic_disablecutscenes":0,"classic_timeformat":3,"classic_hudlayout":1,"classic_hidehudop":0,"classic_easingtonum":0,"classic_monitorstaticanim":1}]]),
}

---@param text file*
local function parse_presets(text)
	local current_index = #presets
	
	if text then
		local lines = {}

		for line in text:lines() do
			table.insert(lines, line)
		end

		text:close()

		if lines then
			for _, name in ipairs(lines) do
				local location = Style_IOLocation .. "/presets/" .. name .. EXTJSON;
				local preset_text = io.openlocal(location, "r");
				
				if preset_text then
					local array = json.decode(preset_text:read("*a"))
					preset_text:close()

					if array and type(array) == "table" then
						current_index = $ + 1
						presets[current_index] = array.data
						sets[current_index] = {nil, "preset"..current_index, array.name}

						Style_DebugPrint(Style_PrintPrefix.."New Preset: " .. array.name)
					else
						Style_DebugPrint(Style_PrintPrefix.."Invalid preset format")
					end
				end
			end
		end
	end

    return presets
end

-- Custom Presets Parser
local custom_presets_txt = io.openlocal(Style_IOLocation.."presets.txt", "r+");

if custom_presets_txt then
	parse_presets(custom_presets_txt);
end

-- Command for reporting.
-- Port Styles Report
COM_AddCommand("styles_report", function()
	local txt = Style_PrintPrefix .. os.date("%c") .. "\n"
	txt = $ .. "Game Version: " .. VERSIONSTRING .. "\n"
	txt = $ .. "Scripts Loaded: " .. Style_DebugScriptsLoaded .. "/" .. Style_DebugScriptsTotal .. "\n\n"

	if Style_DebugErrorPrinter then
		txt = $ .. "DEBUG Warning/Error List: " .. "\n"
		txt = $ .. Style_DebugErrorPrinter .. "\n\n"
	end

	txt = $ .. "Preset: " .. "\n"

	for cvar, struct in pairs(modio.registry) do
		txt = $ .. cvar .. " " .. tostring(struct.cvar.value) .. "\n"
	end

	local name = "STYLES" .. os.date("%d%m%Y%H")
	local location = Style_IOLocation .. "reports/" .. name .. EXTLOG

	local report = io.openlocal(location, "w");

	if report then
		report:write(txt);
		report:close();
	end

	Style_DebugPrint(Style_PrintPrefix..name.." created in < SRB2 Root Folder >/luafiles/"..location)
	Style_DebugPrint("\x83NOTE: \x80Please send the report to developer channels. Be it Game Styles GitHub, Game Styles Message Board or Team Springs Discord")
end)

COM_AddCommand("styles_presetsave", function(_, name, author)
	local currentdate = os.date("%d%m%Y%H")
	local preset_name = name and name or currentdate
	local maker = author or "none"

	local location = Style_IOLocation .. "presets/" .. preset_name .. EXTJSON
	local file = io.openlocal(location, "w");

	if file then
		local _save = {}

		for cvar, struct in pairs(modio.registry) do
			if cvar == CMD_name then continue end
			_save[cvar] = struct.cvar.value
		end

		file:write(json.encode({name = name, currentdate = currentdate, author = maker, data = _save}))
		file:close()

		local location = Style_IOLocation .. "presets.txt"
		local list = io.openlocal(location, "a+");

		if list then
			local unique = true

			for line in list:lines() do
				if string.find(line, preset_name) then
					unique = false
					break
				end
			end

			if unique then
				list:write('\n'..preset_name);
			end

			list:close();
		end
	end

	Style_DebugPrint(Style_PrintPrefix..preset_name.." created in < SRB2 Root Folder >/luafiles/"..location)
	Style_DebugPrint("\x83NOTE: \x80New preset will only appear at mod load.")
end)

local presets_opt = Options:new("presets", sets, function(var)
	if presets[var.value] then
		local preset = presets[var.value]
		local cache = {}

		for strcvar, change in pairs(preset) do
			local cvar = CV_FindVar(strcvar)
			if cvar and (not ((cvar.flags & CV_NETVAR) and multiplayer) or isserver) then
				table.insert(cache, {value = change, cvar = cvar, priority = modio.registry[strcvar].priority})
			end
		end

		if cache then
			table.sort(cache, modio.cvar_descpriotity);

			for _, struct in ipairs(cache) do
				CV_Set(struct.cvar, struct.value);
			end
		end
	end
end, 0, 10)