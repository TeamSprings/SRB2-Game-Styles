local CDTimeTravel = {
	EnumTimeline = {["Past"] = 3, ["Present"] = 0, ["Future"] = {1, 2} },
	timeline = 0,
	robogenexists = false,
}

local Origin_Textures = {
		-- Bad Future, Good Future, Past
	top = {},
	mid = {},
	but = {},
	fla = {},
	cel = {},
}

CDTimeTravel.sky = {
	[1] = {12, 159, 13}
}

CDTimeTravel.mobjsvisual = {
	[MT_GFZFLOWER3] = {S_THZFLOWERB, S_BSZTULIP_RED, S_BSZTULIP_RED},
	[MT_GFZTREE] = {S_PINETREE, S_GFZCHERRYTREE, S_BUSHTREE},
	[MT_GFZBERRYTREE] = {S_PINETREE, S_GFZBERRYTREE, S_BUSHTREE},
	[MT_BERRYBUSH] = {S_BRAMBLES, S_BLUEBERRYBUSH, S_BUSHTREE},
	[MT_BUSH] = {S_THZFLOWERA, S_BERRYBUSH, S_BSZSHRUB},		
	[MT_GFZFLOWER1] = {S_BRAMBLES, S_GFZBERRYTREE, S_BSZSHRUB}, 
	[MT_GFZFLOWER2] = {S_BRAMBLES, S_GFZBERRYTREE, S_BSZSHRUB},
}

CDTimeTravel.mobjsfunctional = {}

local KeyTXset = {}

CDTimeTravel.TTTX_Table = {
		-- Bad Future, Good Future, Past
		-- GFZ
		['GFZFLR02'] = {'CEZFLR12', 'GFZFLR02', 'JNGGRW1'},
		['GFZFLR10'] = {'CEZFLR12', 'GFZFLR10', 'GFZFLR10'},	
		['GFZFLR21'] = {'CEZFLR12', 'GFZFLR21', 'GFZFLR21'},
		['GFZFLR22'] = {'CEZFLR12', 'GFZFLR22', 'GFZFLR22'},
		['GFZGRSW'] = {'CEZGRSW', 'GFZGRSW', 'JNGGRW1'},
		['GFZGRASS'] = {'CEZGRASS', 'GFZGRASS', 'GRSEDG1'},
		['GFZRAIL4'] = {'CASTLEP', 'GFZRAIL4', 'GFZRAIL4'},		
		['GFZWALL02'] = {'CEZWALL2', 'GFZWALL02', 'GFZWALL02'},
		['GFZWALL'] = {'CEZWALL2', 'GFZWALL', 'OLDROCKW'},
		['GFZWALL2'] = {'CEZROCKA', 'GFZWALL2', 'OLDROCKW'},
		['GFZWALLB'] = {'CEZWALL2', 'GFZWALLB', 'GFZROCK2'},		
		['GFZRAIL'] = {'CASTLES', 'GFZRAIL', 'GFZRAIL'},		
		['GFZRAIL2'] = {'CASTLES', 'GFZRAIL2', 'GFZRAIL2'},		
		['GFZRAIL3'] = {'CASTLES', 'GFZRAIL3', 'GFZRAIL3'},
		['GFZRAIL4'] = {'CASTLES', 'GFZRAIL4', 'GFZRAIL4'},
		['GFZBRIDG'] = {'STLFLR01', 'GFZBRIDG', 'GFZBRIDG'},
		['GFZFLR05'] = {'STLFLR01', 'GFZFLR05', 'GFZFLR05'},
		['GFZFLR06'] = {'STLFLR01', 'GFZFLR06', 'GFZFLR06'},
		['GFZFLR18'] = {'STLFLR01', 'GFZFLR18', 'GFZFLR18'},
		['GFZFLR19'] = {'STLFLR01', 'GFZFLR19', 'GFZFLR19'},
		['GFZFLR09'] = {'STLBLKF2', 'GFZFLR09', 'GFZFLR09'},
		['GFZBLOCK'] = {'STLBLKF2', 'GFZBLOCK', 'GFZBLOCK'},		
		['GFZFLR13'] = {'STLBLKF1', 'GFZFLR13', 'GFZFLR13'},
		['GFZBLOKS'] = {'STLBLKF1', 'GFZBLOKS', 'GFZBLOKS'},		
		['GFS_CLD1'] = {'SKY12', 'F_SKY1', 'F_SKY1'},
		['GFS_CLD2'] = {'SKY12', 'F_SKY1', 'F_SKY1'},
		['GFS_CLD3'] = {'SKY12', 'F_SKY1', 'F_SKY1'},
		['GFS_CLD4'] = {'SKY12', 'F_SKY1', 'F_SKY1'},		
		-- THZ
		
		-- DSZ
		
		-- CEZ
		
		-- AGZ
		
		-- ERZ
}

CDTimeTravel.ChangeTimeline = function(vartime)
			CDTimeTravel.timeline = vartime
	
			for sector in sectors.iterate do
				local flrnumx = #sector
			
				sector.floorpic = Origin_Textures.fla[flrnumx]
				sector.ceilingpic = Origin_Textures.cel[flrnumx]
				
				if vartime ~= 0
					if CDTimeTravel.TTTX_Table[sector.floorpic] ~= nil and CDTimeTravel.TTTX_Table[sector.floorpic][CDTimeTravel.timeline] ~= nil
						sector.floorpic = CDTimeTravel.TTTX_Table[sector.floorpic][CDTimeTravel.timeline]
					end
					if CDTimeTravel.TTTX_Table[sector.ceilingpic] ~= nil and CDTimeTravel.TTTX_Table[sector.ceilingpic][CDTimeTravel.timeline] ~= nil					
						sector.ceilingpic = CDTimeTravel.TTTX_Table[sector.ceilingpic][CDTimeTravel.timeline]
					end
				end
			end	
			
			if KeyTXset[1] == nil
				for k,v in pairs(CDTimeTravel.TTTX_Table) do
					local trkey = R_TextureNumForName(k)
					KeyTXset[trkey] = k
				end

				for k,v in ipairs(KeyTXset) do
					print(v+" "+k)
				end
			end
				
			for side in sides.iterate do
					local sidenumx = #side
					
						side.toptexture = Origin_Textures.top[sidenumx]
						side.midtexture = Origin_Textures.mid[sidenumx]
						side.bottomtexture = Origin_Textures.but[sidenumx]						
					if vartime ~= 0

						if KeyTXset[side.toptexture] ~= nil and CDTimeTravel.TTTX_Table[KeyTXset[side.toptexture]][CDTimeTravel.timeline] ~= nil then
							side.toptexture = R_TextureNumForName(CDTimeTravel.TTTX_Table[KeyTXset[side.toptexture]][CDTimeTravel.timeline])
						end
				
						if KeyTXset[side.midtexture] ~= nil and CDTimeTravel.TTTX_Table[KeyTXset[side.midtexture]][CDTimeTravel.timeline] ~= nil	then
							side.midtexture = R_TextureNumForName(CDTimeTravel.TTTX_Table[KeyTXset[side.midtexture]][CDTimeTravel.timeline])																
						end
	
						if KeyTXset[side.bottomtexture] ~= nil and CDTimeTravel.TTTX_Table[KeyTXset[side.bottomtexture]][CDTimeTravel.timeline] ~= nil then
							side.bottomtexture = R_TextureNumForName(CDTimeTravel.TTTX_Table[KeyTXset[side.bottomtexture]][CDTimeTravel.timeline])											
						end
				
					end

			end

			for moy in mapthings.iterate do

				if moy.valid and moy.mobj and moy.mobj.valid and CDTimeTravel.mobjsvisual[moy.mobj.type] ~= nil then
					moy.mobj.state = moy.mobj.info.spawnstate				
					if vartime ~= 0 and CDTimeTravel.mobjsvisual[moy.mobj.type][CDTimeTravel.timeline] ~= nil then
						moy.mobj.state = CDTimeTravel.mobjsvisual[moy.mobj.type][CDTimeTravel.timeline]
					end
				end
			end

			local cursky = mapheaderinfo[gamemap].skynum
			P_SetupLevelSky(cursky)			
			if vartime ~= 0 and CDTimeTravel.sky[cursky] ~= nil and CDTimeTravel.sky[cursky][CDTimeTravel.timeline] ~= nil	
				local chang = CDTimeTravel.sky[cursky][CDTimeTravel.timeline]
				P_SetupLevelSky(chang)
			end

end

addHook("PlayerSpawn", function(p)
		Origin_Textures.top = {}			
		Origin_Textures.mid = {}
		Origin_Textures.but = {}
		Origin_Textures.fla = {}
		Origin_Textures.cel = {}
			
		CDTimeTravel.robogenexists = false
		
		for ac in mobjs.iterate() do	
			if ac.type == MT_ROBOGENERATOR then
				CDTimeTravel.robogenexists = true		
			end
		end
		if CDTimeTravel.robogenexists == false then
			local rogen = P_SpawnMobjFromMobj(p.mo, 0,0,0, MT_ROBOGENERATOR)
			rogen.scale = 3*FRACUNIT/2 
		end
		
		
		CDTimeTravel.timeline = 0
		
		for side in sides.iterate do
			local sidenumx = #side
					
			Origin_Textures.top[sidenumx] = side.toptexture					
			Origin_Textures.mid[sidenumx] = side.midtexture
			Origin_Textures.but[sidenumx] = side.bottomtexture					
		end
		for sector in sectors.iterate do
			local flrnumx = #sector
			
			Origin_Textures.fla[flrnumx] = sector.floorpic
			Origin_Textures.cel[flrnumx] = sector.ceilingpic

		end
	
		if mapheaderinfo[gamemap].bonustype == 1 or mapheaderinfo[gamemap].bonustype == 2 then
			if emeralds >= 7 then
				CDTimeTravel.ChangeTimeline(2)				
			else
				CDTimeTravel.ChangeTimeline(1)
			end
		end	
end)


addHook("MapThingSpawn", function(a, mt)
	if mt then

		if not P_IsObjectOnGround(a) then
			P_TeleportMove(a, a.x, a.y, a.subsector.sector.floorheight)
		end

		a.state = S_INVISIBLE
		a.sprite = SPR_TTPT
		a.frame = A

		a.typetr = P_RandomRange(0, 3)

		a.timesign = P_SpawnMobjFromMobj(a, 0,0,0, MT_TTCDSIGNTOP)
		a.timesign.state = S_INVISIBLE
		a.timesign.sprite = a.sprite
		if a.typetr == 3 then
			a.timesign.frame = C|FF_PAPERSPRITE
		else
			a.timesign.frame = B|FF_PAPERSPRITE		
		end
		a.timesign.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
	
	end
end, MT_TOKEN)



addHook("TouchSpecial", function(a, mt)
	if a.timesign then
		if a.activated ~= true then
			a.spin = 99
			a.activated = true
			CDTimeTravel.ChangeTimeline(a.typetr)
			print(a.typetr)
		end
	end
	return true	
end, MT_TOKEN)

addHook("MobjThinker", function(a, mt)
	if a.spin and a.spin > 0 and a.activated then
		a.spin = $-1
		a.timesign.angle = $+(ANG1*a.spin)/4
	end
end, MT_TOKEN)

addHook("TouchSpecial", function(a, mt)
	if CDTimeTravel.timeline ~= 3 then
		return true	
	end
end, MT_ROBOGENERATOR)

addHook("MobjThinker", function(a, mt)
	if CDTimeTravel.timeline == 3 then
		a.sprite = SPR_CDGR
		a.frame = A
		if (leveltime % 16)/8 then
			a.momz = FRACUNIT/4
		else
			a.momz = -FRACUNIT/4		
		end
	else
		if a.sprite == SPR_CDGR then
			a.state = S_INVISIBLE
		end
	end
end, MT_ROBOGENERATOR)

rawset(_G, "StyleCD_Timetravel", CDTimeTravel)