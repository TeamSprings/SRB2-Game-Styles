freeslot("S_S3KBSPHERES", "SPR_S3KS", "S_PLAY_S3KWALK")
-- Notes : 9x

-- Game info
local inbdistance = FRACUNIT/64

-- spheres and rings from player
-- will be used even in bonus stages
local S3K_player_class = {
	-- general info
	plane = 1,
	finished = 0, -- 0 - not, 1 - red sphereSB, 2 - emerald

	-- spacial info
	x = 3*inbdistance,
	y = 3*inbdistance,
	angle = ANGLE_90,
	height = 0,
	
	-- save info
	save_info = {
		x = 0,
		y = 0,
		z = 0,
		angle = 0,

		leveltime = 0,
		powerup = 0,
		rings = 0,
		
		starpost = 0,
		starpostx = 0,
		starposty = 0,
		starpostz = 0,
	}
}

states[S_S3KBSPHERES] = {
	sprite = SPR_S3KS,
	frame = A,
}

rawset(_G, "S3K_BLUESPHERE", {})

-- no need for duplicates
S3K_BLUESPHERE.non_special_last_map = 0

local BS_EMPTY = 0
local BS_RED_SPHERE = 1
local BS_BLU_SPHERE = 2
local BS_BUMPER = 3
local BS_RING = 4
local BS_SPRING = 5

S3K_BLUESPHERE.items = {
	[BS_EMPTY] = {S_INVISIBLE, 			G}, 			-- Empty
	[BS_RED_SPHERE] = {S_S3KBSPHERES, 	C}, 			-- Red Sphere
	[BS_BLU_SPHERE] = {S_S3KBSPHERES, 	A}, 			-- Blue Sphere
	[BS_BUMPER] = {S_S3KBSPHERES, 		H}, 			-- Bumper
	[BS_RING] = {S_RING, 				A|FF_ANIMATE}, 	-- Ring
	[BS_SPRING] = {S_S3KBSPHERES, 		B}, 			-- Spring
}

local scrollysec = {}
S3K_BLUESPHERE.map_data = {}

--402 player.x
--404 player.y
--400 player.angle -- front 0x00: -- left: 0x40 -- back: 0x80 -- right: 0xC0
S3K_BLUESPHERE.load_map = function(mapnum)
	local map_file = io.openlocal("tbs/S3K/"..mapnum..".dat", "rb")
	if map_file then
		local data = map_file:read('*all')
		local buffer = {}
		
		for i = 1, 32 do
			buffer[i] = {}
		end
		
		-- Data Transfer
		for bin = 0,1023 do
			local loc = (bin % 32)
			local y = (bin / 32)
			buffer[y+1][loc+1] = data:byte((bin), (bin))
		end		
		
		-- Position
		buffer.player_spawn_x = (data:byte(1026, 1026))+1
		buffer.player_spawn_y = (data:byte(1028, 1028))+1
		buffer.player_spawn_a = ((data:byte(1024, 1024))/64)*90
		
		print(buffer.player_spawn_x..'', 
			  buffer.player_spawn_y..'', 
			  buffer.player_spawn_a..'')
		
		S3K_BLUESPHERE.mapdata = buffer
		io.close(mapx)	
	else
		S3K_BLUESPHERE.mapdata = S3KSS_Map[sphereplayer.map]
	end
end

S3K_BLUESPHERE.iterate_maps = function()

end


S3K_BLUESPHERE.get_previous_mapinfo = function()

end

S3K_BLUESPHERE.lastSphereMap = 0
S3K_BLUESPHERE.collectedRings = {}
S3K_BLUESPHERE.map = 0

S3K_BLUESPHERE.set_up = function()
	if not mapheaderinfo[gamemap].spheremode then
		hud.enable("score")
		hud.enable("time")
		hud.enable("rings")
		return
	end
	
	local number_maps = S3K_BLUESPHERE.iterate_maps()+1
	P_LoadS3KData((max(S3K_BLUESPHERE.lastSphereMap, 0)+1) % (number_maps))
	
	S3K_BLUESPHERE.map = S3K_BLUESPHERE.lastSphereMap+1
	S3K_BLUESPHERE.lastSphereMap = S3K_BLUESPHERE.map
	
	hud.disable("score")
	hud.disable("time")
	hud.disable("rings")
		
	scrollysec = {}
	for sector in sectors.iterate do
		if sector.floorpic == 'GFZFLR01' and sector.floorxoffs ~= nil then
			sector.floorpic = 'S3KSSFL'..S3K_BLUESPHERE.map
			scrollysec:insert(sector)
			
			if sector.floorxoffs then
				sector.floorxoffs = 34*FRACUNIT
				sector.flooryoffs = -86*FRACUNIT
			end
		end
		
		if sector.ceilingpic == 'S3KSPLIT' then
			sector.floorpic = 'S3KSPLT'..S3K_BLUESPHERE.map
			sector.ceilingpic =	'S3KSPLT'..S3K_BLUESPHERE.map		
		end
		
		if sector.ceilingpic == 'S3KSPLIG' then
			sector.floorpic = 'S3KSPLG'..S3K_BLUESPHERE.map
			sector.ceilingpic =	'S3KSPLG'..S3K_BLUESPHERE.map		
		end
	end
				
	for y = 1,32 do	
		for x = 1,32 do
			if S3K_BLUESPHERE.map_data[y][x] == BS_BLU_SPHERE then
				consoleplayer.sphere = $+1
			end
		end	
	end
end

S3K_BLUESPHERE.start_timer = 5*TICRATE

S3K_BLUESPHERE.player_set_up = function(player)	

end

local pos = {
	{-4, -4}, {-3, -4}, {-2, -4}, {-1, -4}, {0, -4}, {1, -4}, {2, -4}, {3, -4}, {4, -4},
	{-4, -3}, {-3, -3}, {-2, -3}, {-1, -3}, {0, -3}, {1, -3}, {2, -3}, {3, -3}, {4, -3},
	{-4, -2}, {-3, -2}, {-2, -2}, {-1, -2}, {0, -2}, {1, -2}, {2, -2}, {3, -2}, {4, -2},
	{-4, -1}, {-3, -1}, {-2, -1}, {-1, -1}, {0, -1}, {1, -1}, {2, -1}, {3, -1}, {4, -1},
	{-4, 0}, {-3, 0}, {-2, 0}, {-1, 0}, {0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0},
	{-4, 1}, {-3, 1}, {-2, 1}, {-1, 1}, {0, 1}, {1, 1}, {2, 1}, {3, 1}, {4, 1},
	{-4, 2}, {-3, 2}, {-2, 2}, {-1, 2}, {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2},
	{-4, 3}, {-3, 3}, {-2, 3}, {-1, 3}, {0, 3}, {1, 3}, {2, 3}, {3, 3}, {4, 3},
	{-4, 4}, {-3, 4}, {-2, 4}, {-1, 4}, {0, 4}, {1, 4}, {2, 4}, {3, 4}, {4, 4},
}


//
//
//	CONTINUE FROM THERE
//
//





--41 is middle one

addHook("MapThingSpawn", function(a, mt)
	if not sphereplayer.active then return end
		a.sprite = SPR_S3KS
		a.flags = $ &~ MF_NOGRAVITY
		a.scale = FRACUNIT+FRACUNIT/4
		a.posx = pos[mt.angle][1]
		a.posy = pos[mt.angle][2]
		a.shadowscale = 0
end, MT_BLUESPHERE)

addHook("MobjThinker", function(a)
	if loadingorder == 2 and a.posx ~= nil and a.posy ~= nil and S3KSS_Current ~= nil then 
		a.xpos = (a.posx+sphereplayer.x/inbdistance)
		a.ypos = (a.posy+sphereplayer.y/inbdistance)
		if a.xpos > 32 then
			a.xpos = $-32
		elseif a.xpos < 1 then
			a.xpos = $+32
		end
		if a.ypos > 32 then
			a.ypos = $-32
		elseif a.ypos < 1
			a.ypos = $+32
		end		

		local mapin = S3KSS_Current[a.ypos][a.xpos]
	
		a.state = frames[(mapin or 0)][1]
		a.frame = frames[(mapin or 0)][2]
		
		if a and a.valid then
			P_TryMove(a, a.spawnpoint.x*FRACUNIT-(((sphereplayer.x*64) % FRACUNIT)*96), a.spawnpoint.y*FRACUNIT+(((sphereplayer.y*64) % FRACUNIT)*96), true)
		end
	end
end, MT_BLUESPHERE)

addHook("TouchSpecial", function(a)
	if not sphereplayer.active then return false end
	if loadingorder == 2 and sphereplayer.x ~= nil and a.xpos ~= nil and a.ypos ~= nil then

		if a.xpos == sphereplayer.x/inbdistance and a.ypos == sphereplayer.y/inbdistance and
		S3KSS_Current[a.ypos][a.xpos] == 2 then
			S3KSS_Current[a.ypos][a.xpos] = 1
			sphereplayer.spheres = $-1
			if sphereplayer.spheres <= 0 then
				G_SetCustomExitVars(sphereplayer.lastpos.map, 1)
				G_ExitLevel()
			end			
		end
	end
	return true 	
end, MT_BLUESPHERE)

local dir = {{1,0}, {1,1}, {0,1}, {1, -1}, {1, -1}, {-1, -1}, {-1,0}, {0,-1}}

-- S3K Air's assembly addresser was kinda inspiration for this thing. You could call it translation from lemon but not really, as my set up just doesn't allow me straight up 'copy it'. 
-- so only thing I am taking is logic behind it. -- Sonic 3 Air by Eukaryot

local function P_CheckS3KBalls(x, y)
	local balls = P_CheckS3KBallsStack(x, y)
	if balls == nil then return end
	
	for k,v in ipairs(balls) do
		if S3KSS_Current[v[2]][v[1]] == SB or S3KSS_Current[v[2]][v[1]] == RS then
			S3KSS_Current[v[2]][v[1]] = CS
			if S3KSS_Current[v[2]][v[1]] == SB then
				sphereplayer.spheres = $-1
			end
		end
	end
end


//local 4dir = {{1,0}, {0,1}, {-1,0}, {0,-1}}
//local dax = {-0x01, -0x20, 0x01, 0x20, -0x01, -0x20}

local function P_stackBalls(q, x, y)
	return {x = x; y = y; next = q;}
end


local function P_checkS3KBallsStack(startx, starty, replace)
	--local target = 
	local typesphere
	
	--local q = 
	
	--while ()
		

		// Current state (in addition to states saved on the stack) consists of these three variables:
		// Offset of a direction in A4, can have values 0x00, 0x02, ..., 0x0a
		// Offset of a different direction in A4, usually in right angle to D3
		// This is still the position of the currently collected blue sphere
		
		// Look at one of the 4 direct neighbor positions to the current position
		//  -> At 0x00a0da, the following s16 values are stored: -0x01, -0x20, 0x01, 0x20, -0x01, -0x20		
		
		// Neighbor is a red sphere that is not yet marked
		// If we got at most one entry on the stack so far, go on without further checks
		// I guess this way, we will ignore circles of 2 * 2 red spheres
		
		// Temporarily mark this position; the mark tells us whether the position is on the stack already
		// Add an entry to the stack
		// Continue at the neighbor, and create a new state to check:
		//  - Starting at the neighbor's position
		//  - Checking all direction except where we just came from	
		
		// Reached the currently collected blue sphere again
		
		// Go through the entire stack (except for the entry at the very bottom, which represents the start position)
		// Find first direction change in the stack
		
		// Step into the start position is either:
		//  - the first turn's direction (e.g. red spheres built something like the edge of an L-shape, and the start position is the inner corner)
		//  - the start direction (red spheres made a loop that enters the start position straight from behind)
		//     -> In these cases, the position in direction of first turn is expected to be a blue sphere
		
		// Step into the start position is neither of the above
		//  -> The position in diagonal direction (namely start direction + first turn) is expected to be a blue sphere		
		
		// Perform an additional sanity check, just to be sure - and to solve an original game bug from S&K
		//  -> This is just a workaround, better fix whatever is wrong with the actual algorithm
		//  -> I suppose the real bug is that D0.u16 is not necessarily the right position to check, it can be on the wrong side;
		//      considering whether the red sphere ring is CW or CCW and using that info to decide on where to put D0.u16 could do the trick
		//  -> In fact, with the following fix that bug is really rare, it only can (but still does) happen when traversing a very large region
		//      of blue spheres in just the right way	
		

		// Reached a position where it's no use to on, because there's neither a (not yet visited) red sphere nor the currently collected blue sphere; proceed by either:
		//  - Rotating current direction by 90° and check this one; i.e. do not enter the next while loop at all
		//  - If all directions got checked for the current position, take the next entry from the stack and continue with it (possibly multiple times if all directions of the top-of-stack already got checked, too)
		//  - In case the stack is empty, we're done with all checks		
		
end



local function P_RotateS3KPlayer(p, amount)
	sphereplayer.x = ((sphereplayer.x+(sphereplayer.x % inbdistance)/2))/(inbdistance)*inbdistance
	sphereplayer.y = ((sphereplayer.y+(sphereplayer.y % inbdistance)/2))/(inbdistance)*inbdistance
	for k,sec in ipairs(scrollysec) do
		if sec.floorxoffs ~= nil
			sec.floorxoffs = 34 * FRACUNIT
			sec.flooryoffs = -86 * FRACUNIT
		end			
	end	
	sphereplayer.angle = $ + amount*ANG1
	p.mo.rotcooldown = 10
end

states[S_PLAY_S3KWALK] = {
	sprite = SPR_PLAY,
	frame = SPR2_WALK|FF_ANIMATE,
	var1 = 0,
	var2 = 4,
}

addHook("PlayerThink", function(p)
	if loadingorder == 1 then
		p.powers[pw_nocontrol] = sphereplayer.timer	
		sphereplayer.x = (S3KSS_Current.playerspawnx*inbdistance or inbdistance*3)
		sphereplayer.y = (S3KSS_Current.playerspawny*inbdistance or inbdistance*3)
		sphereplayer.angle = (S3KSS_Current.playerspawna*ANG1) or ANGLE_MAX		
		sphereplayer.height = 0
		loadingorder = 2
		print(loadingorder)		
	end

	if loadingorder == 2 then
		if p.mo.rotcooldown == nil or p.mo.rotcooldown <= 0 then
			sphereplayer.x = $ + cos(p.mo.angle)/1024
			sphereplayer.y = $ - sin(p.mo.angle)/1024
		end	
	
		for k,sec in ipairs(scrollysec) do
			if sec and sec.valid and sec.floorxoffs ~= nil then
				sec.floorxoffs = $ + cos(p.mo.angle)*4
				sec.flooryoffs = $ - sin(p.mo.angle)*4
			end			
		end
	
		local fakeangle = 0
		
		if P_IsObjectOnGround(p.mo) then
			if p.mo.state ~= S_PLAY_S3KWALK then
				p.mo.state = S_PLAY_S3KWALK
			end
		--elseif P_IsObjectOnGround(p.mo) and p.mo.rotcooldown == nil then
			--p.panim = PA_IDLE	
		else
			if p.mo.state ~= S_PLAY_JUMP
				p.mo.state = S_PLAY_JUMP
				p.mo.anim_duration = 4
			end
		end		
		if p.mo.rotcooldown ~= nil and p.mo.rotcooldown > 0 then
			p.mo.rotcooldown = $-1
		end
		p.mo.angle = sphereplayer.angle
		camera.z = p.mo.z+200*FRACUNIT
		--camera.aiming = -ANGLE_45/5*2
		camera.aiming = -ANGLE_90/2		

		if input.gameControlDown(GC_JUMP) and P_IsObjectOnGround(p.mo) then
			p.mo.z = $+42*FRACUNIT
		end

		input.setMouseGrab(false)
		
		if p.mo.rotcooldown == nil or p.mo.rotcooldown == 0 then
			if input.gameControlDown(GC_TURNRIGHT) then
				P_RotateS3KPlayer(p, -90)	
			end
		
			if input.gameControlDown(GC_TURNLEFT) then
				P_RotateS3KPlayer(p, 90)
			end		
		end
		
		if fakeangle == 90 then
			fakeangle = 0
		end		
		
		if sphereplayer.x >= 32*inbdistance-inbdistance/128
			sphereplayer.x = inbdistance/16
		elseif sphereplayer.x <= inbdistance/128
			sphereplayer.x = 32*inbdistance-inbdistance/16		
		end
		if sphereplayer.y >= 32*inbdistance-inbdistance/128
			sphereplayer.y = inbdistance/16
		elseif sphereplayer.y <= inbdistance/128
			sphereplayer.y = 32*inbdistance-inbdistance/16		
		end	
		--print(sphereplayer.x/inbdistance..":X Y:"..sphereplayer.y/inbdistance.." Angle: "..sphereplayer.angle/ANG1.." Timer: ")
	end
end)



local function numfont(d, font, x, y, scale, value)
	local patch, val, str
	
	if value < 100 and value >= 10 then
		str = '0'..value
	elseif value < 10 then
		str = '00'..value
	else
		str = ''..value
	end
	
	
	for i = 1,3 do
		val = string.sub(str, i,i)
		if val ~= nil and val ~= ' ' and val ~= '' then
			patch = d.cachePatch(font..''..val)			
 		else
			patch = d.cachePatch(font..''..0)
		end
		d.drawScaled(x+((patch.width+2)*(i-1))*FRACUNIT, y, scale, patch)		
	end
end




/*
hud.add(function(v, p, c)
	local xpos, ypos, pspRS, frame
	
	local background = v.cachePatch("SP1")
	v.drawScaled(-background.width/5*FRACUNIT, background.height/7*FRACUNIT, FRACUNIT*3/2, background)
	for y = -sphereplayer.viewdistancey/2,sphereplayer.viewdistancey/2 do
		for x = -sphereplayer.viewdistancex/2,sphereplayer.viewdistancex/2 do
			xpos = abs(((x+sphereplayer.x[#p]/inbdistance) % 63)-31)
			ypos = abs(((y+sphereplayer.y[#p]/inbdistance) % 63)-31)
			v.drawScaled(
			abs((x+7)*40*FRACUNIT)-125*FRACUNIT, 
			-130*FRACUNIT+abs((y+7)*32*FRACUNIT)+abs(((max(sphereplayer.x[#p], sphereplayer.y[#p]))/4 % 64)+1)*FRACUNIT,
			((FRACUNIT-2*FRACUNIT/16-(abs(x)*FRACUNIT/5)+(abs(y+7)*FRACUNIT/7))/3), 
			v.cachePatch("SPOBJ"..S3KSS_Map[spheremap][ypos][xpos]))		
		end	
	end
	pspr = v.getSprite2Patch(p.mo.skin, SPR2_WALK, falseS, A, 5)
	v.draw(160, 50, FRACUNIT, pspr)	
	
end, "game")
*/