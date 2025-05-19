--[[

	Presets

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local Options = tbsrequire 'helpers/create_cvar'

local sets = tbsrequire 'helpers/cvar_presets'
local modio = tbsrequire 'classic_io'

local CMD_name = Style_GamePrefix.."_presets"

local presets = {
	-- SONIC 1
	[1] = {
		classic_hud = 1,
		classic_checkpoints = 1,
		classic_emeralds = 1,
		classic_invincibility = 1,
		classic_explosions = 1,
		classic_dust = 1,
		classic_pity = 1,
		classic_score = 1,
		classic_sign = 1,
		classic_monitor = 1,
		classic_specialentrance = 1,
		classic_sign_movement = 1,
		classic_monitormaniajump = 0,

		-- Player
		classic_spindash = 0,
		classic_springtwirk = 0,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 1,
		classic_supertheme = 1,
		classic_oneuptheme = 1,
		classic_bosstheme = 1,
		classic_levelendtheme = 1,
		classic_drowntheme = 1,
		classic_shoestheme = 1,
	},

	-- SONIC 2
	[2] = {
		classic_hud = 2,
		classic_checkpoints = 3,
		classic_emeralds = 2,
		classic_invincibility = 2,
		classic_explosions = 2,
		classic_dust = 2,
		classic_pity = 2,
		classic_score = 2,
		classic_sign = 1,
		classic_monitor = 2,
		classic_specialentrance = 2,
		classic_sign_movement = 1,
		classic_monitormaniajump = 0,

		-- Player
		classic_spindash = 0,
		classic_springtwirk = 0,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 2,
		classic_supertheme = 1,
		classic_oneuptheme = 1,
		classic_bosstheme = 2,
		classic_levelendtheme = 1,
		classic_drowntheme = 1,
		classic_shoestheme = 1,
	},

	-- SONIC CD
	[3] = {
		classic_hud = 3,
		classic_checkpoints = 4,
		classic_emeralds = 3,
		classic_invincibility = 1,
		classic_explosions = 1,
		classic_dust = 1,
		classic_pity = 1,
		classic_score = 3,
		classic_sign = 1,
		classic_monitor = 1,
		classic_specialentrance = 1,
		classic_sign_movement = 1,
		classic_monitormaniajump = 0,

		-- Player
		classic_spindash = 1,
		classic_springtwirk = 1,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 3,
		classic_supertheme = 1,
		classic_oneuptheme = 1,
		classic_bosstheme = 3,
		classic_levelendtheme = 2,
		classic_drowntheme = 1,
		classic_shoestheme = 1,
	},

	-- SONIC 3
	[4] = {
		classic_hud = 4,
		classic_checkpoints = 5,
		classic_emeralds = 4,
		classic_invincibility = 2,
		classic_explosions = 3,
		classic_dust = 2,
		classic_pity = 2,
		classic_score = 4,
		classic_sign = 1,
		classic_monitor = 3,
		classic_specialentrance = 3,
		classic_sign_movement = 1,
		classic_monitormaniajump = 0,

		-- Player
		classic_spindash = 0,
		classic_springtwirk = 0,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 4,
		classic_supertheme = 4,
		classic_oneuptheme = 2,
		classic_bosstheme = 5,
		classic_levelendtheme = 4,
		classic_drowntheme = 2,
		classic_shoestheme = 3,
	},

	-- SONIC MANIA
	[5] = {
		classic_hud = 6,
		classic_checkpoints = 6,
		classic_emeralds = 7,
		classic_invincibility = 2,
		classic_explosions = 3,
		classic_dust = 1,
		classic_pity = 1,
		classic_score = 2,
		classic_sign = 1,
		classic_monitor = 5,
		classic_specialentrance = 3,
		classic_sign_movement = 0,
		classic_monitormaniajump = 1,

		-- Player
		classic_spindash = 0,
		classic_springtwirk = 1,
		classic_springairwalk = 1,

		-- Music
		classic_invintheme = 8,
		classic_supertheme = 5,
		classic_oneuptheme = 4,
		classic_bosstheme = 12,
		classic_levelendtheme = 8,
		classic_drowntheme = 3,
		classic_shoestheme = 3,
	},
}
-- TODO: MAKE SURE THIS WORKS
local function parse_presets(text)
	local new_preset = nil
	local current_index = #presets

	local lines = {}

	-- Split the text into lines, handling different line endings
    for line in string.gmatch(text, "[^\r\n]+") do
        table.insert(lines, line)
    end

    for _, line in ipairs(lines) do
        line = line:match("^%s*(.-)%s*$") -- Trim whitespace

		if not line or line == "" then
			continue
        end

		-- Start of a new preset
        if line:sub(1, 2) == "- " then

            local name = line:match("- name:%s*(.*)")
            if name then
				current_index = $ + 1
				new_preset = true

				presets[current_index] = {}
				sets[current_index] = {nil, "preset"..current_index, name}

				Style_DebugPrint(Style_PrintPrefix.."New Preset: " .. name)
			else
                Style_DebugPrint(Style_PrintPrefix.."Invalid preset format: " .. line)
            end

        elseif new_preset then

			-- cvar value
            local cvar_name = line:match("^(%a[_%w]+)%s+(.+)$")

			if cvar_name then

                if modio.registry[cvar_name] then
                    presets[current_index][cvar_name] = line:match("^"..cvar_name.."%s+(.+)$")
                else
                    Style_DebugPrint(Style_PrintPrefix.."Unknown Console Variable: " .. cvar_name)
                end
            else
                Style_DebugPrint(Style_PrintPrefix.."Invalid preset value format: " .. line)
            end
        else
            Style_DebugPrint(Style_PrintPrefix.."Invalid preset format: " .. line)
        end
    end

    return presets
end

-- Custom Presets Parser
local custom_presets_txt = io.openlocal(Style_IOLocation.."presets.txt", "r+");

if custom_presets_txt then
	parse_presets(custom_presets_txt:read("*a"));

	custom_presets_txt:close();
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

	local report_name = "report" .. os.date("%d%m%Y%H")
	local report_location = Style_IOLocation .. report_name .. ".txt"

	local report = io.openlocal(report_location, "w");

	report:write(txt);
	report:close();

	Style_DebugPrint(Style_PrintPrefix..report_name.." created in < SRB2 Root Folder >/luafiles/"..report_location)
	Style_DebugPrint("NOTE: Please send the report to developer channels. Be it Game Styles GitHub, Game Styles Message Board or Team Springs Discord")
end)

COM_AddCommand(Style_GamePrefix.."_savepreset", function(_, name)
	local preset_name = name and name or os.date("%d%m%Y%H")
	local txt = "\n- name: " .. tostring(preset_name).. "\n"

	--local index = #presets + 1

	--presets[index] = {}
	--sets[index] = {nil, "preset"..index, preset_name}

	for cvar, struct in pairs(modio.registry) do
		if cvar == CMD_name then continue end

		txt = $ .. cvar .. " " .. tostring(struct.cvar.value) .. "\n"
		--presets[index][cvar] = struct.cvar.value
	end

	local presets_location = Style_IOLocation .. "presets.txt"

	local txt_presets = io.openlocal(presets_location, "w");

	local endv = txt_presets:seek("end") .. "\n\n";
	txt_presets:write(endv .. txt);
	txt_presets:close();

	--Options:update("presets", sets);
	Style_DebugPrint(Style_PrintPrefix..preset_name.." created in < SRB2 Root Folder >/luafiles/"..presets_location)
	Style_DebugPrint("NOTE: New preset will only appear at mod load.")
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