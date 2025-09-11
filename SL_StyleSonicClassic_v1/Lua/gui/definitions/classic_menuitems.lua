local function SUBMENU(def)
	local menu = tbsrequire("gui/definitions/submenus/menu_"..def.source)

	menu.name = def.name
	return menu
end

return {
	SUBMENU{
		name 	= 	"GENERAL",
		source 	= 	'general'
	};

	SUBMENU{
		name 	= 	"HEADS-UP DISPLAY",
		source 	= 	'hud'
	};

	SUBMENU{
		name 	= 	"GAMEPLAY",
		source 	= 	'gameplay'
	};

	SUBMENU{
		name 	= 	"PLAYER",
		source 	= 	'player'
	};

	SUBMENU{
		name 	= 	"EYECANDY",
		source 	=	'eyecandy'
	};

	SUBMENU{
		name 	= 	"AUDIO",
		source 	= 	'audio'
	};
}