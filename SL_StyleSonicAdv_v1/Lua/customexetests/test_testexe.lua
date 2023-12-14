local hahafunny = true

M_RegisterModSettingsMenu({
	{IT_HEADER, 0, string.upper("gameplay"), 0, 0},
	
	{IT_STRING|IT_CALL, 0, string.upper("Function Test 1"), function()
		print("*Fart* you expected me to be mature?! But oh yeah... it works.")
	end, 10},
	{IT_STRING|IT_CVAR, 0, string.upper("Ringbox randomizer"), "dc_ringboxrandomizer", 15},	
	{IT_STRING|IT_CVAR|IT_CV_SLIDER, 0, string.upper("Reward Difficulty"), "dc_rewarddifficulty", 20},

	{IT_STRING|IT_CALL, 0, string.upper("Function Test 2"), function()
		M_StartMessage("You expected it to work... huh, too bad!")
	end, 25},
		
	{IT_HEADER, 0, string.upper("eyecandy"), 0, 30},
	
	{IT_STRING|IT_CVAR, 0, string.upper("Enable SA1/2 Item Box"), "dc_itembox", 40},
	{IT_STRING|IT_CVAR, 0, string.upper("Enable SA2 Game HUD"), "dc_hud_gamehud", 45},	
	{IT_STRING|IT_CVAR, 0, string.upper("Enable SA2 Title Card"), "dc_hud_titlecard", 50},
	{IT_STRING|IT_CVAR, 0, string.upper("Enable SA2 Tally Screen"), "dc_hud_tallyscreen", 55},	
	
	{IT_HEADER, 0, string.upper("chao garden"), 0, 65},
	
	{IT_STRING|IT_CVAR|IT_CV_SLIDER, 0, string.upper("Price Difficulty"), "dc_pricedifficulty", 75},
	{IT_STRING|IT_CVAR, 0, string.upper("Enable Chao Knockback"), "dc_chaoragdoll", 80},	
	{IT_STRING|IT_CVAR, 0, string.upper("Enable Other Player' Chao"), "dc_seeotherplayerchao", 85},
	{IT_STRING|IT_CVAR, 0, string.upper("Enable Chao Emotions"), "dc_chaoemotions", 90},
	{IT_STRING|IT_CVAR, 0, string.upper("Enable Chao Emotions"), "dc_chaoemotions", 100},
	{IT_STRING|IT_CVAR, 0, string.upper("Enable Chao Emotions"), "dc_chaoemotions", 120},
	{IT_STRING|IT_CVAR, 0, string.upper("Enable Chao Emotions"), "dc_chaoemotions", 180},	
}, "SA Styles")

COM_AddCommand("OpenStringMenu", function(player, arg0, arg1)
	if gamestate & GS_LEVEL and not paused then
		M_MenuLoad(tonumber(arg0))
	end
end, COM_LOCAL)

COM_AddCommand("CloseThatFuckingMenu", function(player)
	if gamestate & GS_LEVEL and not paused then
		M_MenuClose(1)
	end
end, COM_LOCAL)
