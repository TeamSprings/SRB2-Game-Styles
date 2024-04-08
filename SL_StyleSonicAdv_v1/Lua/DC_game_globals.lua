--[[

		Sonic Adventure Style's Globals

Contributors: Ace Lite
@Team Blue Spring 2022-2024

]]

local disabled_monitors = false
local disabled_hud = false

local hud_items = { -- merely what is used here
	"stagetitle",
	"score",
	"time",
	"rings",
	"lives",
	"intermissiontally",
}

--
--	Global Cvars
--

CV_RegisterVar({
	name = "dc_replaceshields",
	defaultvalue = "No",
	flags = CV_NETVAR,
	PossibleValue = CV_YesNo,
	category = "Adventure Style - Gameplay",
	displayname = "Monitors - Replace Shields"
})

CV_RegisterVar({
	name = "dc_ringboxrandomizer",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Gameplay",
	displayname = "Monitors - Ringbox Randomizer"
})

--
--	Toggle Console Cvars
--

local function disable_huds(cvar)
	if not disabled_hud then return end
	CONS_Printf(consoleplayer, "[Adventure Style] Entire hud system was disabled by another mod. Apology for inconvenience.")
	CV_Set(cvar, 0)
end

local function disable_assets(cvar)
	if not disabled_assets then return end
	CONS_Printf(consoleplayer, "[Adventure Style] Assets were disabled by another mod. Apology for inconvenience.")
	CV_Set(cvar, 0)
end


CV_RegisterVar({
	name = "dc_itembox",
	defaultvalue = "On",
	flags = CV_NETVAR|CV_NOINIT|CV_CALL,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Item Capsule",
	func = disable_assets,
})

CV_RegisterVar({
	name = "dc_checkpoints",
	defaultvalue = "On",
	flags = CV_NETVAR|CV_NOINIT|CV_CALL,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Item Capsule",
	func = disable_assets,
})

CV_RegisterVar({
	name = "dc_capsule",
	defaultvalue = "On",
	flags = CV_NETVAR|CV_NOINIT|CV_CALL,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Item Capsule",
	func = disable_assets,
})

CV_RegisterVar({
	name = "dc_miscassets",
	defaultvalue = "On",
	flags = CV_NETVAR|CV_NOINIT|CV_CALL,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Item Capsule",
	func = disable_assets,
})

CV_RegisterVar({
	name = "dc_hud_gamehud",
	defaultvalue = "On",
	flags = CV_CALL|CV_NOINIT,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "In-Game Heads Up Display",
	func = disable_huds,
})

CV_RegisterVar({
	name = "dc_hud_titlecard",
	defaultvalue = "On",
	flags = CV_CALL|CV_NOINIT,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Title Card",
	func = disable_huds,
})

CV_RegisterVar({
	name = "dc_newtallyscreen",
	defaultvalue = "On",
	flags = CV_NETVAR|CV_CALL|CV_NOINIT,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Tally Screen",
	func = disable_huds,
})

CV_RegisterVar({
	name = "dc_hud_rankdisplay",
	defaultvalue = "Off",
	flags = 0,
	PossibleValue = CV_OnOff,
	category = "Adventure Style - Eyecandy",
	displayname = "Rank Display",
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
		elseif item == "hud" then
			if disabled_hud then return end

			for i = 1, #hud_items do
				hud.enable(hud_items[i])
			end

			CV_Set(CV_FindVar("dc_hud_gamehud"), 0)
			CV_Set(CV_FindVar("dc_hud_titlecard"), 0)
			CV_Set(CV_FindVar("dc_hud_tallyscreen"), 0)
			disabled_hud = true
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
		return true, rawget(Adventure_Style, "version"), rawget(Adventure_Style, "string_version")
	end,
}))

-- Hud hooking

for _,hook in pairs({
	"game",
	"intermission",
	"titlecard",
	"scores",
	"title",
}) do
	addHook("HUD",
	function(v)
		rawset(Adventure_Style, "renderer", v.renderer())
	end, hook)
end