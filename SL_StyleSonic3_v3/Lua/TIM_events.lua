hud.add(function(v, p, c)	
	local timey = os.date('*t')		
	v.drawString(320, 40, "CURRENT DATE", V_YELLOWMAP, "right")
	v.drawString(320, 48, string.format("%02d:%02d:%02d", timey.hour, timey.min, timey.sec), 0, "right")
	v.drawString(320, 56, string.format("%02d/%02d/%04d", timey.day, timey.month, timey.year), 0, "right")
	
	v.drawString(320, 72, "winter: "+(timey.month == 12), V_YELLOWMAP, "right")	
	v.drawString(320, 80, "xmas: "+(timey.month == 12 and timey.day == 24), V_YELLOWMAP, "right")	
end, "game")

local KeyTXset = {}

local XmasTextures = {
	// GFZ ROCK
	["GFZROCK"] = "XMAS01",
	["GFZCHEKB"] = "XMAS01A",
	["GFZCHEK1"] = "XMAS01A",	
	["GFZCHEK2"] = "XMAS01A",	
	["GFZWALL"] = "XMASWALL",
	["GFZWALL2"] = "XMASWALL",
	["GFZVINE1"] = "XMAS03",
	["GFZVINE2"] = "XMAS03",
	["GFZVINE3"] = "XMAS04",
	["GFZROCKB"] = "XMASROCKB",
	["GFZCRACK"] = "XMASCRACK",	
	["GFZCRAC1"] = "XMASCRACX",
	["GFZCRAC2"] = "XMASCRACX",
	["GFZINSID"] = "XMAS24",
	["GFZFLR08"] = "XMSFLR04",	

	// GFZ GRASS
	["GFZGRASS"] = "SNOWALL",
	["GFZFLR02"] = "XMSFLR02",	
	["GFZFLR10"] = "XMSFLR02",
	["GFZFLR21"] = "XMSFLR02",	
	["GFZFLR22"] = "XMSFLR02",

	// GFZ MISC
	["GFZBLOCK"] = "XMAS19",
	["GFZFLR09"] = "XMAS19",	
	["GFZBRIDG"] = "XMAS23",
	["GFZFLR05"] = "XMSFLR05",	
	["GFZFLR06"] = "XMSFLR06",
}

local WinterThings = {
	[MT_BUSH] = MT_XMASBUSH,
	[MT_BERRYBUSH] = MT_XMASBERRYBUSH,
	[MT_BLUEBERRYBUSH] = MT_XMASBLUEBERRYBUSH,
	[MT_GFZFLOWER3] = MT_SNOWMANHAT,
	[MT_GFZFLOWER2] = MT_LAMPPOST2,
	[MT_GFZFLOWER1] = MT_XMASPOLE,
	[MT_GFZTREE] = MT_FHZTREE,
}

addHook("MapLoad", function(map)
	local timex = os.date('*t')
	if timex.month == 12 then return end
	
	for sector in sectors.iterate do
		if XmasTextures[sector.floorpic] ~= nil
			sector.floorpic = XmasTextures[sector.floorpic]
		end
		if XmasTextures[sector.ceilingpic] ~= nil					
			sector.ceilingpic = XmasTextures[sector.ceilingpic]
		end
	end	
	print("sectors swapped")

	if KeyTXset[1] == nil
		for k,v in pairs(XmasTextures) do
			local trkey = R_TextureNumForName(k)
			KeyTXset[trkey] = k
		end
	end
				
	for side in sides.iterate do			
		if KeyTXset[side.toptexture] ~= nil and XmasTextures[KeyTXset[side.toptexture]] ~= nil then
			side.toptexture = R_TextureNumForName(XmasTextures[KeyTXset[side.toptexture]])
		end
				
		if KeyTXset[side.midtexture] ~= nil and XmasTextures[KeyTXset[side.midtexture]] ~= nil	then
			side.midtexture = R_TextureNumForName(XmasTextures[KeyTXset[side.midtexture]])																
		end
	
		if KeyTXset[side.bottomtexture] ~= nil and XmasTextures[KeyTXset[side.bottomtexture]] ~= nil then
			side.bottomtexture = R_TextureNumForName(XmasTextures[KeyTXset[side.bottomtexture]])											
		end
	end

	print("lines swapped")
	
	for m in mapthings.iterate do
		if m.mobj and m.mobj.valid and WinterThings[m.mobj.type] then
			P_SpawnMobjFromMobj(m.mobj, 0, 0, 0, WinterThings[m.mobj.type])
			P_RemoveMobj(m.mobj)
		end
	end	
	
	print("mobjs swapped")
end)