/* 
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
*/

local settings = {
	CD3mtimeover = false;
	CD3rdact = true;
	CDtimelines = true;
	CDspecialstagering = true;
	CDvoiceclips = true;
	CDcapsule = true;
	CDspindash = true;
}

settings.save = function()
	local file = io.openlocal("tbs/styles/cd/configsave.dat", "w+")
	if file
		file:seek("set", 0)
		file:write(settings.CD3mtimeover.."\n")
		file:write(settings.CD3rdact.."\n")
		file:write(settings.CDtimelines.."\n")
		file:write(settings.CDspecialstagering.."\n")
		file:write(settings.CDvoiceclips.."\n")
		file:write(settings.CDcapsule.."\n")
		file:write(settings.CDspindash.."\n")	
		file:close()
	end	
end

settings.load = function()
	local check = io.openlocal("tbs/styles/cd/configsave.dat", "r+")
	if check
		check:seek("set", 0)
		settings.CD3mtimeover = check:read("*n")
		settings.CD3rdact = check:read("*n")
		settings.CDtimelines = check:read("*n")
		settings.CDspecialstagering = check:read("*n")
		settings.CDvoiceclips = check:read("*n")
		settings.CDcapsule = check:read("*n")
		settings.CDspindash = check:read("*n")		
		check:close()
	end
end

COM_AddCommand("StyleCDreset", function()
	settings.CD3mtimeover = false
	settings.CD3rdact = true
	settings.CDtimelines = true
	settings.CDspecialstagering = true
	settings.CDvoiceclips = true
	settings.CDcapsule = true
	settings.CDspindash = true
	settings.save()
end, COM_LOCAL)

COM_AddCommand("StyleCDsave", function()
	settings.save()
end, COM_LOCAL)

COM_AddCommand("StyleCDload", function()
	settings.load()
end, COM_LOCAL)

rawset(_G, "StyleCD_settings", settings)

