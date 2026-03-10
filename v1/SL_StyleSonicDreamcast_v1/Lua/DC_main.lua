--[[

		Sonic Adventure Style's Globals

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

--
--	Helpers
--

local disabled_monitors = false

local function disable_assets(cvar)
	if not consoleplayer then return end
	if not disabled_assets then return end
	CONS_Printf(consoleplayer, "[Adventure Style] Assets were disabled by another mod. We apologize for inconvenience.")
	CV_Set(cvar, 0)
end

local function disable_assets_as_well_cvar(cvar)
	if not consoleplayer then return end
	CONS_Printf(consoleplayer, "[Adventure Style] This console command is yet to be functional. We apologize for inconvenience.")
	CV_Set(cvar, 0)
end


--
--	Global Cvars
--

CV_RegisterVar({
	name = "dc_replaceshields",
	defaultvalue = "No",
	flags = CV_NETVAR,
	PossibleValue = CV_YesNo,
	category = "Adventure Style - Gameplay",
	displayname = "Item Boxes - Replace Shields"
})

CV_RegisterVar({
	name = "dc_ringboxrandomizer",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Gameplay",
	displayname = "Item Boxes - Ringbox Randomizer"
})

CV_RegisterVar({
	name = "dc_itembox",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Item Boxes",
})

CV_RegisterVar({
	name = "dc_keystyle",
	defaultvalue = "heroes",
	PossibleValue = {heroes = 0, chao = 1},
	category = "Adventure Style - Eyecandy",
	displayname = "Key Style",
})

CV_RegisterVar({
	name = "dc_checkpoints",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Checkpoints",
	--func = disable_assets_as_well_cvar,
})

CV_RegisterVar({
	name = "dc_shields",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Gameplay",
	displayname = "Adventure Shields"
})

CV_RegisterVar({
	name = "dc_miscassets",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Misc Assets",
	--func = disable_assets,
})

CV_RegisterVar({
	name = "dc_playereffects",
	defaultvalue = "off",
	flags = CV_NETVAR,
	PossibleValue = {off=0, sa1=1, sa2=2, heroes=3},
	category = "Adventure Style - Eyecandy",
	displayname = "Player Effects",
	--func = disable_assets,
})

CV_RegisterVar({
	name = "dc_hud",
	defaultvalue = "sa2",
	flags = 0,
	PossibleValue = {sa1=1, sa2=2, heroes=3, nextgen=4},
	category = "Adventure Style - Eyecandy",
	displayname = "HUD Style"
})

CV_RegisterVar({
	name = "dc_hud_rankdisplay",
	defaultvalue = "No",
	flags = 0,
	PossibleValue = CV_YesNo,
	category = "Adventure Style - Eyecandy",
	displayname = "Force Ranking Tracker"
})

--
-- Global table
--

rawset(_G, "Adventure_Style", setmetatable({
	string_version = "0.75",
	version = 1,

	renderer = "none",

	-- hud
	-- monitors
	disable = function(item)
		if type(item) ~= "string" then
			error("[Adventure Style "..rawget(Adventure_Style, "string_version").."] Input key is not a string.")
		end

		if item == "monitors" then
			if disabled_assets then return end

			CV_Set(CV_FindVar("dc_itembox"), 0)
			CV_Set(CV_FindVar("dc_capsule"), 0)
			CV_Set(CV_FindVar("dc_miscassets"), 0)
			CV_Set(CV_FindVar("dc_checkpoints"), 0)
			disabled_assets = true
		else
			error("[Adventure Style "..rawget(Adventure_Style, "string_version").."] Input key is invalid. Either use \"monitors\" or \"hud\".")
		end
	end,
}, {
	-- No sneaking!
	__metatable = false,

	__index = function(array, key)
		local value = rawget(Adventure_Style, key)
		if type(value) == "function" then
			return value
		end
	end,

	__newindex = function(array, key)
		error("[Adventure Style "..rawget(Adventure_Style, "string_version").."] Permission to write into Adventure Style global table denied")
	end,

	__call = function()
		return rawget(Adventure_Style, "version"), rawget(Adventure_Style, "string_version")
	end,
}))