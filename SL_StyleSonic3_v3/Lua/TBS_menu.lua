//
// Team Blue Spring's Series of Libaries. 
// Menu Framework
//


//
//	MENU VARIABLES
//

rawset(_G, "TBS_Menu", {
	//	global table for menus in TBS framework

	-- version control
	major_iteration = 1, -- versions with extensive changes. 	
	iteration = 1, -- additions, fixes. No variable changes.
	version = "DEV", -- just a string...
	
	-- toggle for menu
	enabled_Menu = 0,

	-- menuitems (containers for menu info)
	menutypes = {},

	-- style variables per menu, includes: 
	-- limiters of space display in Y for each menu object
	-- limitz = {start of menu contains - y1, end of menu contains - y2, space between y1-y2} >> eachitem
	-- optional usage, but required for smooth scrolling within default keydown hook behavior
	styles = {},
	
	-- smoothing between scrolling.
	smoothing = 0,

	// selection
	-- to move these please, refer to pre-built functions
	menu = 1, -- menu object
	submenu = 1, -- submenu within menu object
	selection = 1, -- selection of menu item in submenu structure
	prev_sel = 1,  -- previous selection of menu item
		
	-- input detector
	-- whenever you wanted that kind of thing ig.
	pressbt = 0,

	-- simple boolean to skip checking.
	edgescr = false,
	
	
	-- in combination with confirmed variable, pop-ups are for extra menus appearing in for example: 	
	-- uhhh inputs? can be text or literal kind
	
	
	
	-- in combination with confirmed variable, pop-ups are for extra menus appearing in for example: 
	-- confirmation whenever or not you want delete your entire progress of hard earned coins?
	popup_type = "none",
	popup_message = {},
	
	-- stops menu control. Makes you click double to either confirm your choice or not.
	-- should really be used with popup or input.
	confirmed = 0,
})

rawset(_G, "TBS_MENUCONFIG", {
	-- MENU TRIGGER
	open_key1 = "h",
	open_key2 = "h",
	
	close_key1 = "escape",
	close_key2 = "escape",
	-- >> REST
})

//
//	FLAGS
//

rawset(_G, "TBS_MENUTRG", {
	-- CONTROLLER / KEYBOARD
	LEFT_BUMPER = 1,
	RIGHT_BUMPER = 2,
	CONFIRM = 4,
	ESCAPE = 8,
	UP = 16,
	DOWN = 32,
	LEFT = 64,
	RIGHT = 128,
})

--TBS_MFLAG
rawset(_G, "TBS_MFLAG", {
	-- SKIP OVER MENU ITEM FLAG
	NOTOUCH = 1;
	
	-- DEFAULT MENU FLAGS
	TEXTONLY = 2;
	HEADER = 4;
	SPLIT = 8;
	
	-- CVARS (off-on and slider require cvar flag)
	CVAR = 16;	
	OFFON = 32;
	SLIDER = 64;
	
	-- INPUT
	INPUT = 128;
	INPUTTEXT = 256;	
	
	-- MISC.
	SPECIALDRAW = 512;
})


//
//	MENU FUNCTIONS
//


TBS_Menu.check_Condition = function(menutx)
	if menutx and menutx.condition then 
		if menutx.condition() == false then
			return false
		else
			return true
		end
	else
		return nil
	end
end


local function P_IsMenuUntouchable(flags, condition)
	if (flags & TBS_MFLAG.HEADER or flags & TBS_MFLAG.NOTOUCH or flags & TBS_MFLAG.SPLIT) or (condition ~= nil and condition == false) then
		return true
	else
		return false
	end
end

TBS_Menu.select_menu_structure = function(move, struct_menu)	
	if TBS_Menu.smoothing and abs(TBS_Menu.smoothing) then
		TBS_Menu.smoothing = 0
	end

	TBS_Menu.selection = 1
	TBS_Menu.submenu = 1	
	
	local xlen = struct_menu.menutypes
	
	if move then
		TBS_Menu.menu = (1 < TBS_Menu.menu and $-1 or #xlen)
	else
		TBS_Menu.menu = (#xlen > TBS_Menu.menu and $+1 or 1)		
	end
end


TBS_Menu.select_sub_menu_structure = function(submenux, menutab)
	local numsel = 1
	while (true) do
		local menutx = menutab[submenux][numsel]
		local flags = menutx.flags
		if not (P_IsMenuUntouchable(flags, TBS_Menu.check_Condition(menutx))) then
			break
		end
		numsel = $+1
	end
	
	if TBS_Menu.smoothing and abs(TBS_Menu.smoothing) then
		TBS_Menu.smoothing = 0
	end
	
	TBS_Menu.selection = numsel
	TBS_Menu.submenu = submenux
end


local function M_selectionItemMMM(move, itemcount, skip)
	if not skip then
		TBS_Menu.prev_sel = TBS_Menu.selection
	end

	if (move and 1 < TBS_Menu.selection) or (not move and itemcount > TBS_Menu.selection) then
		TBS_Menu.edgescr = false
	else
		TBS_Menu.edgescr = true
	end
	
	if move then
		TBS_Menu.selection = (1 < TBS_Menu.selection and $-1 or itemcount)
	else
		TBS_Menu.selection = (itemcount > TBS_Menu.selection and $+1 or 1)
	end
end


COM_AddCommand("tbs_menu", function(player, arg1)
	if gamestate & GS_LEVEL and not paused then
		CONS_Printf(player, "\x82".."Menu Activated")
		TBS_Menu.select_sub_menu_structure(1, tonumber(arg1) or TBS_Menu.menutypes[TBS_Menu.menu])
		TBS_Menu.enabled_Menu = 1
	else
		CONS_Printf(player, "\x82".."Menu can only be activated in game.")
	end
end, COM_LOCAL)

addHook("KeyDown", function(key)
	if TBS_Menu.enabled_Menu == 1 then
		local Menu = TBS_Menu.menutypes[TBS_Menu.menu]
		local countsub = Menu[TBS_Menu.submenu]
		
		if countsub[TBS_Menu.selection].inputChange then
			countsub[TBS_Menu.selection].inputChange(key)
			return true
		end
		
		if not TBS_Menu.confirmed then
		
			if key.name == TBS_MENUCONFIG.close_key1 or key.name == TBS_MENUCONFIG.close_key2 then
				TBS_Menu.select_sub_menu_structure(1, TBS_Menu.menutypes[TBS_Menu.menu])
				TBS_Menu.enabled_Menu = 0
			end
		
		
			if key.num == ctrl_inputs.up[1] then
				M_selectionItemMMM(true, #countsub)
				
				-- another in case of header
				while (P_IsMenuUntouchable(countsub[TBS_Menu.selection].flags, TBS_Menu.check_Condition(countsub[TBS_Menu.selection]))) do
					M_selectionItemMMM(true, #countsub, true)					
				end
				
				if not (TBS_Menu.edgescr or countsub[#countsub].z <= countsub[TBS_Menu.selection].z+TBS_Menu.styles[TBS_Menu.menu].limitz[3] or countsub[#countsub].z <= (TBS_Menu.styles[TBS_Menu.menu].limitz[2]+15)) then
					TBS_Menu.smoothing = abs(countsub[TBS_Menu.selection].z - countsub[TBS_Menu.prev_sel].z)/3
				end
			end
	
			if key.num == ctrl_inputs.down[1] then
				M_selectionItemMMM(false, #countsub)
				
				-- another in case of header
				while (P_IsMenuUntouchable(countsub[TBS_Menu.selection].flags, TBS_Menu.check_Condition(countsub[TBS_Menu.selection]))) do
					M_selectionItemMMM(false, #countsub, true)		
				end

				if not (TBS_Menu.edgescr or countsub[#countsub].z <= countsub[TBS_Menu.selection].z+TBS_Menu.styles[TBS_Menu.menu].limitz[3] or countsub[#countsub].z <= (TBS_Menu.styles[TBS_Menu.menu].limitz[2]+15)) then
					TBS_Menu.smoothing = -abs(countsub[TBS_Menu.selection].z - countsub[TBS_Menu.prev_sel].z)/3
				end
			end

			if (key.num == ctrl_inputs.jmp[1] or key.num == ctrl_inputs.spn[1]) and Menu[TBS_Menu.submenu][TBS_Menu.selection].func and not Menu[TBS_Menu.submenu][TBS_Menu.selection].enum then
				Menu[TBS_Menu.submenu][TBS_Menu.selection].func(TBS_Menu.menutypes[TBS_Menu.menu])
			end
		
			if Menu[TBS_Menu.submenu][TBS_Menu.selection].flags & TBS_MFLAG.CVAR and Menu[TBS_Menu.submenu][TBS_Menu.selection].cvar then
			
				if (key.num == ctrl_inputs.right[1] or key.num == ctrl_inputs.turr[1]) then
					CV_AddValue(Menu[TBS_Menu.submenu][TBS_Menu.selection].cvar(), 1)
				end
		
				if (key.num == ctrl_inputs.left[1] or key.num == ctrl_inputs.turl[1]) then
					CV_AddValue(Menu[TBS_Menu.submenu][TBS_Menu.selection].cvar(), -1)
				end
				
			end
		
			if key.name == "q" then
				TBS_Menu.select_menu_structure(false, TBS_Menu)
				TBS_Menu.pressbt = $|TBS_MENUTRG.LEFT_BUMPER
			end
			
			if key.name == "e" then
				TBS_Menu.select_menu_structure(true, TBS_Menu)			
				TBS_Menu.pressbt = $|TBS_MENUTRG.RIGHT_BUMPER
			end
		
			if key.num == ctrl_inputs.sys[1] then
				TBS_Menu.submenu = 1
				TBS_Menu.enabled_Menu = 0
			end
		else
			if (key.num == ctrl_inputs.jmp[1]) then
				Menu[TBS_Menu.submenu][TBS_Menu.selection].func()
			elseif (key.num == ctrl_inputs.spn[1]) then
				TBS_Menu.popupmessage = {}
				TBS_Menu.confirmed = 0
			end
		end

		return true
	else
		if key.name == TBS_MENUCONFIG.open_key1 or key.name == TBS_MENUCONFIG.open_key2 then
			TBS_Menu.select_sub_menu_structure(1, TBS_Menu.menutypes[TBS_Menu.menu])
			TBS_Menu.enabled_Menu = 1
		end		
	end
end)

hud.add(function(v, stplyr)	
	if TBS_Menu.enabled_Menu == 1 then
		TBS_Menu.menutypes[TBS_Menu.menu][TBS_Menu.submenu].style(v)

		local num_menus = TBS_Menu.menutypes
		if #num_menus < 1 then return end
		
		local menu_name = TBS_Menu.menutypes[TBS_Menu.menu].name
		local name_len = v.stringWidth(menu_name)/2
		
		local vibes = abs((leveltime/3 % 6)-3)
		local tbs = "_TBS_MENU"
		
		local left_key = v.cachePatch(tbs.."QP"..((TBS_Menu.pressbt & 1) and "R" or "S"))
		local right_key = v.cachePatch(tbs.."EP"..((TBS_Menu.pressbt & 2) and "R" or "S"))
		
		local left_arrow = v.cachePatch(tbs.."LA"..((TBS_Menu.pressbt & 1) and "R" or "S"))
		local right_arrow = v.cachePatch(tbs.."RA"..((TBS_Menu.pressbt & 2) and "R" or "S"))		
		
		TBS_Menu.pressbt = 0
		
		v.draw(160-name_len, 7, left_key, 0)
		v.draw(170+name_len, 7, right_key, 0)

		-- arrow
		v.draw(160-name_len-left_key.width-vibes, 8+left_key.height/2, left_arrow, 0)
		v.draw(170+name_len+right_key.width+vibes, 8+right_key.height/2, right_arrow, 0)
		
		v.drawString(165, 9, menu_name, 0, "center")
	end	
end, "game")

hud.add(function(v, stplyr)	
	if TBS_Menu.enabled_Menu == 1 then
		TBS_Menu.menutypes[TBS_Menu.menu][TBS_Menu.submenu].style(v)

		local num_menus = TBS_Menu.menutypes
		if #num_menus < 1 then return end
		
		local menu_name = TBS_Menu.menutypes[TBS_Menu.menu].name
		local name_len = v.stringWidth(menu_name)/2
		
		local vibes = abs((leveltime/3 % 6)-3)
		local tbs = "_TBS_MENU"
		
		local left_key = v.cachePatch(tbs.."QP"..((TBS_Menu.pressbt & 1) and "R" or "S"))
		local right_key = v.cachePatch(tbs.."EP"..((TBS_Menu.pressbt & 2) and "R" or "S"))
		
		local left_arrow = v.cachePatch(tbs.."LA"..((TBS_Menu.pressbt & 1) and "R" or "S"))
		local right_arrow = v.cachePatch(tbs.."RA"..((TBS_Menu.pressbt & 2) and "R" or "S"))		
		
		TBS_Menu.pressbt = 0
		
		v.draw(160-name_len, 7, left_key, 0)
		v.draw(170+name_len, 7, right_key, 0)

		-- arrow
		v.draw(160-name_len-left_key.width-vibes, 8+left_key.height/2, left_arrow, 0)
		v.draw(170+name_len+right_key.width+vibes, 8+right_key.height/2, right_arrow, 0)
		
		v.drawString(165, 9, menu_name, 0, "center")
	end	
end, "title")

-------------
----------	HUD SYSTEM
-------------

rawset(_G, "TBS_Hud", {
	names = {[0] = "SRB2", },
	registered_huds = {[0] = 1},
	configurations = {[0] = {off = {""}}},
	
	hud_elements = {},
	disabled_elements = {},	
	enabled_elements = {},
	
	selectedhud = 0,
})

local vanilla_hud_items = {
	"stagetitle",
	"textspectator",
	"score",
	"time",
	"rings",
	"lives",
	"teamscores",
	"weaponrings",
	"powerstones",
	"nightslink",
	"nightsdrill",
	"nightsrings",
	"nightsscore",
	"nightstime",
	"nightsrecords",
	"rankings",
	"coopemeralds",
	"tokens",
	"tabemblems",
	"intermissiontally",
	"intermissionmessages"
}

// Slots

-- TBS_Hud.freeslot_hud()
TBS_Hud.freeslot_hud = function(...)

end

-- TBS_Hud.configurate_hud()
TBS_Hud.configurate_hud = function(...)


end

-- TBS_Hud.freeslot_hud_element()
TBS_Hud.freeslot_hud_element = function(...)


end

// Removes hud element -- use in cases when you don't want it appear even after other mods enabled it.
-- TBS_Hud.free_hud_element()
TBS_Hud.free_hud_element = function(...)


end

// Change

-- TBS_Hud.select_hud(select hud)
TBS_Hud.select_hud = function(hud)
	for i,k in ipairs(vanilla_hud_items) do
		hud.enable(k)
	end

	for i,k in ipairs(TBS_Hud[configurations][hud].off) do
		hud.disable(k)
	end
	
	TBS_Hud.selectedhud = hud
end

// Toggles

-- TBS_Hud.disable_all_hud()
TBS_Hud.disable_all_hud = function()
	for i,k in ipairs(vanilla_hud_items) do
		hud.enable(k)
	end
	
	TBS_Hud.selectedhud = 0
end

-- TBS_Hud.reset_hud()
TBS_Hud.reset_hud = function()


end

// Hud Element functions

-- TBS_Hud.enable_hud(select hud)
TBS_Hud.enable_hud = function(hud)


end

-- TBS_Hud.disable_hud(select hud)
TBS_Hud.disable_hud = function(hud)


end






