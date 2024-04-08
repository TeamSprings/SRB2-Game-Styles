--[[
		Sonic Adventure Style's Cvars

Contributors: Ace Lite
@Team Blue Spring 2022-2023

]]

--
--	Extra Functions
--


CV_RegisterVar({
	name = "dc_replaceshields",
	defaultvalue = "No",
	flags = CV_NETVAR,
	PossibleValue = CV_YesNo
})

CV_RegisterVar({
	name = "dc_ringboxrandomizer",
	defaultvalue = "No",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

CV_RegisterVar({
	name = "dc_rewarddifficulty",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 5}
})

--
--	Disable Functions
--

CV_RegisterVar({
	name = "dc_itembox",
	defaultvalue = "Yes",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff
})

CV_RegisterVar({
	name = "dc_hud_gamehud",
	defaultvalue = "Yes",
	flags = 0,
	PossibleValue = CV_OnOff
})

CV_RegisterVar({
	name = "dc_hud_titlecard",
	defaultvalue = "Yes",
	flags = 0,
	PossibleValue = CV_OnOff
})

CV_RegisterVar({
	name = "dc_hud_tallyscreen",
	defaultvalue = "Yes",
	flags = 0,
	PossibleValue = CV_OnOff
})

--
--	Chao Garden!
--

CV_RegisterVar({
	name = "dc_pricedifficulty",
	defaultvalue = 0,
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 5}
})

CV_RegisterVar({
	name = "dc_chaoragdoll",
	defaultvalue = "Yes",
	flags = 0,
	PossibleValue = CV_OnOff
})

CV_RegisterVar({
	name = "dc_seeotherplayerchao",
	defaultvalue = "Yes",
	flags = 0,
	PossibleValue = CV_OnOff
})

CV_RegisterVar({
	name = "dc_chaoemotions",
	defaultvalue = "Yes",
	flags = 0,
	PossibleValue = CV_OnOff
})