local function P_ScrollXHudLayer(v, x, y, patch, flags, colormap, slowdown)
	v.draw(x+((leveltime/slowdown) % patch.width), y, patch, flags, colormap)
	v.draw(x+patch.width+((leveltime/slowdown) % patch.width), y, patch, flags, colormap)
	v.draw(x-patch.width+((leveltime/slowdown) % patch.width), y, patch, flags, colormap)
end

table.insert(TBS_Menu.styles, {
	limitz = {0, 200, 200}
})

-- HEX $AD
-- print(string.format("%x", 0xAD))

local function style_drawer(v)
		local Menu = TBS_Menu.menutypes[TBS_Menu.menu]
		local Menuval = Menu[TBS_Menu.submenu]
		local selection = TBS_Menu.selection
		local limitz = TBS_Menu.styles[TBS_Menu.menu].limitz
	
		P_ScrollXHudLayer(v, 0, -40, v.cachePatch('S3KBACKGROUND'), V_50TRANS, nil, 2)		

		local lazyZ = ((Menuval[#Menuval].z > (limitz[2]+15)) and 
		(Menuval[#Menuval].z <= Menuval[selection].z+limitz[3] and Menuval[#Menuval].z-limitz[2] or (Menuval[selection].z - limitz[1])) or 0)
	
		--for k,c in ipairs(TBS_Menu.menutypes[TBS_Menu.menu][TBS_Menu.submenu]) do
		--	TBSlib.fontdrawer(v, 'S3KTT', 300*FRACUNIT, (c.z-lazyZ)*FRACUNIT, FRACUNIT, c.name, 0, v.getColormap(TC_DEFAULT, 1), "right")		
		--end
end

table.insert(TBS_Menu.menutypes, {
	name = "SONIC 3 Style",
	[1] = { -- Main Menu
		style = function(v) style_drawer(v) end,
		
		{name = "EXIT", z = 50, flags = 0,
		func = function(menut)
			TBS_Menu.enabled_Menu = 0
		end};
		
		{name = "EXIT", z = 100, flags = 0,
		func = function(menut)
			TBS_Menu.enabled_Menu = 0
		end};	

		
		{name = "EXIT", z = 150, flags = 0,
		func = function(menut)
			TBS_Menu.enabled_Menu = 0
		end};
	
	};
})

M_RegisterModSettingsMenu({
	{IT_HEADER, 0, string.upper("gameplay"), 0, 0},
	{IT_STRING|IT_CVAR, 0, string.upper("Debug Mode Coordinates"), "S3_CordinatesDebug", 10},
	{IT_STRING|IT_CALL, 0, string.upper("Open Custom Menu"), function()
			M_MenuClose(1)
			TBS_Menu.enabled_Menu = 1
	end, 15},
}, "Sonic 3 Styles")
