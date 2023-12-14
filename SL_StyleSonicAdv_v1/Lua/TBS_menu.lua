//
// Team Blue Spring's Series of Libaries. 
// Menu Framework
//


//
//	MENU VARIABLES
//

if not TBS_Menu then
	rawset(_G, "TBS_Menu", {
		iteration = 1,
		
		enabled_Menu = 0,
		pressdelay = 0,

		menutypes = {},
		styles = {},

		menu = 1,
		submenu = 1,
		selection = 1,
		prev_sel = 1,
		
		pressbt = 0,

		edgescr = false,
		scroll = 0,
	
		popup_message = {},
		confirmed = 0,
	})
end

//
//	FLAGS
//

local MQ_qleft = 1
local MQ_qright = 2

local flags = {
	HEADER = 1;
	SPECIAL = 2;
	JUSTTEXT = 4;
	CVAR = 8;
	SLIDER = 16;
	DRAWSP = 32;
	TEXTSPL = 64;
	OFFON = 128;
}

rawset(_G, "MFLG", flags)


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
	if (flags & MFLG.HEADER or flags & MFLG.SPECIAL or flags & MFLG.TEXTSPL) or (condition ~= nil and condition == false) then
		return true
	else
		return false
	end
end

hud.menutbs = {
	smooth = 0
}

TBS_Menu.select_menu_structure = function(move, struct_menu)	
	if hud.menutbs and abs(hud.menutbs.smooth) then
		hud.menutbs.smooth = 0
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
	
	if hud.menutbs and abs(hud.menutbs.smooth) then
		hud.menutbs.smooth = 0
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
		
		if not TBS_Menu.confirmed then
		
			if key.num == ctrl_inputs.up[1] then
				M_selectionItemMMM(true, #countsub)
				
				-- another in case of header
				while (P_IsMenuUntouchable(countsub[TBS_Menu.selection].flags, TBS_Menu.check_Condition(countsub[TBS_Menu.selection]))) do
					M_selectionItemMMM(true, #countsub, true)					
				end
				
				if not (TBS_Menu.edgescr or countsub[#countsub].z <= countsub[TBS_Menu.selection].z+TBS_Menu.styles[TBS_Menu.menu].limitz[3] or countsub[#countsub].z <= (TBS_Menu.styles[TBS_Menu.menu].limitz[2]+15)) then
					hud.menutbs.smooth = abs(countsub[TBS_Menu.selection].z - countsub[TBS_Menu.prev_sel].z)/3
				end
			end
	
			if key.num == ctrl_inputs.down[1] then
				M_selectionItemMMM(false, #countsub)
				
				-- another in case of header
				while (P_IsMenuUntouchable(countsub[TBS_Menu.selection].flags, TBS_Menu.check_Condition(countsub[TBS_Menu.selection]))) do
					M_selectionItemMMM(false, #countsub, true)		
				end

				if not (TBS_Menu.edgescr or countsub[#countsub].z <= countsub[TBS_Menu.selection].z+TBS_Menu.styles[TBS_Menu.menu].limitz[3] or countsub[#countsub].z <= (TBS_Menu.styles[TBS_Menu.menu].limitz[2]+15)) then
					hud.menutbs.smooth = -abs(countsub[TBS_Menu.selection].z - countsub[TBS_Menu.prev_sel].z)/3
				end
			end

			if (key.num == ctrl_inputs.jmp[1] or key.num == ctrl_inputs.spn[1]) and Menu[TBS_Menu.submenu][TBS_Menu.selection].func and not Menu[TBS_Menu.submenu][TBS_Menu.selection].enum then
				Menu[TBS_Menu.submenu][TBS_Menu.selection].func(TBS_Menu.menutypes[TBS_Menu.menu])
			end
		
			if Menu[TBS_Menu.submenu][TBS_Menu.selection].flags & MFLG.CVAR and Menu[TBS_Menu.submenu][TBS_Menu.selection].cvar then
			
				if (key.num == ctrl_inputs.right[1] or key.num == ctrl_inputs.turr[1]) then
					CV_AddValue(Menu[TBS_Menu.submenu][TBS_Menu.selection].cvar(), 1)
				end
		
				if (key.num == ctrl_inputs.left[1] or key.num == ctrl_inputs.turl[1]) then
					CV_AddValue(Menu[TBS_Menu.submenu][TBS_Menu.selection].cvar(), -1)
				end
				
			end
		
			if key.name == "q" then
				TBS_Menu.select_menu_structure(false, TBS_Menu)
				TBS_Menu.pressbt = $|MQ_qleft
			end
			
			if key.name == "e" then
				TBS_Menu.select_menu_structure(true, TBS_Menu)			
				TBS_Menu.pressbt = $|MQ_qright
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
	end
end)

hud.add(function(v, stplyr)	
	if TBS_Menu.enabled_Menu == 1 then
		TBS_Menu.menutypes[TBS_Menu.menu][TBS_Menu.submenu].style(v)

		local num_menus = TBS_Menu.menutypes
		--if not #num_menus > 1 then return end
		
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
