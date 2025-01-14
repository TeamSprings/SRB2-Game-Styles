freeslot("S_S3KBSPHERES", "SPR_S3KS", "S_PLAY_S3KWALK")
-- Notes : 9x


--

-- Game info
local inbdistance = FRACUNIT/64
local sphereplayer = {
	active = nil,
	map = 1,
	timer = 300*TICRATE,
	finish = 0, -- 0 - not, 1 - red sphereSB, 2 - emerald
	rings = 0,
	spheres = 0,
	continues = 0,
	angle = ANGLE_90,
	x = 3*inbdistance,
	y = 3*inbdistance,
	momb = 0,
	red_delay = 0,
	height = 0,
	lastpos = {
		map = 0,
		x = 0,
		y = 0,
		z = 0,
		angle = 0,
		starpost = 0,
		leveltime = 0,
		powerup = 0
	}
}

-- This whole thing gives me errors if I don't give it some order.
-- 1) mapload done. 2) playerset 3)item spawn done 4) done
local loadingorder = 0

states[S_S3KBSPHERES] = {
	sprite = SPR_S3KS,
	frame = A,
}

rawset(_G, "sphereplayer", sphereplayer)
local frames = {
	[0] = {S_INVISIBLE, G}, -- Empty
	[1] = {S_S3KBSPHERES, C}, -- Red Sphere
	[2] = {S_S3KBSPHERES, A}, -- Blue Sphere
	[3] = {S_S3KBSPHERES, H}, -- Bumper
	[4] = {S_RING, A|FF_ANIMATE}, -- Ring
	[5] = {S_S3KBSPHERES, B}, -- Spring
}

local scrollysec = {}
local mapdata = {}
local S3KSS_Current = {}

-- from Stackoverflow.com's user Renshaw
local function P_SplitArray(table, x)
	local result = {}
	for i=#mapdata,x do
		local item = {}
		for j=i,i+x-1 do
			if table[j] then
				table.insert(item, table[j])
			end
		end
		table.insert(result, item)
	end
	return result
end

--402 player.x
--404 player.y
--400 player.angle -- front 0x00: -- left: 0x40 -- back: 0x80 -- right: 0xC0
local function P_LoadS3KData(mapnum)
	local mapx = io.openlocal("tbs/S3K/"..mapnum..".dat", "rb")
	if mapx then
		local data = mapx:read('*all')
			for i = 1, 32 do
				mapdata[i] = {}
			end
			for bin = 0,1023 do
				local loc = (bin % 32)
				local y = (bin / 32)
				mapdata[y+1][loc+1] = string.byte(data, (bin), (bin))
				--print(""..mapdata[bin])
			end
			--S3KSS_Current = P_SplitArray(mapdata, 32)
			S3KSS_Current = mapdata
			S3KSS_Current.playerspawnx = (string.byte(data, 1026, 1026))+1
			S3KSS_Current.playerspawny = (string.byte(data, 1028, 1028))+1
			S3KSS_Current.playerspawna = (string.byte(data, 1024, 1024))*90
			print(S3KSS_Current.playerspawnx..'', ''..S3KSS_Current.playerspawny, ''..S3KSS_Current.playerspawna)
			io.close(mapx)
	else
		S3KSS_Current = S3KSS_Map[sphereplayer.map]
	end
end

addHook("MapChange", function()
	loadingorder = 0
	P_LoadS3KData(sphereplayer.map)
end)

addHook("MapLoad", function()
	sphereplayer.active = mapheaderinfo[gamemap].spheremode
	if not sphereplayer.active then
		if sphereplayer.lastpos.map ~= 0 then
			for player in players.iterate() do
				P_SetOrigin(player.mo, sphereplayer.lastpos.x, sphereplayer.lastpos.y, sphereplayer.lastpos.z)
				player.mo.angle = sphereplayer.lastpos.angle
				player.starpostnum = sphereplayer.lastpos.powerup
				realtime = sphereplayer.lastpos.leveltime
				if sphereplayer.lastpos.powerup ~= 0 then
					player.powers[pw_shield] = sphereplayer.lastpos.powerup
				end
			end
			sphereplayer.lastpos.map = 0
			sphereplayer.lastpos.x = 0
			sphereplayer.lastpos.y = 0
			sphereplayer.lastpos.z = 0
			sphereplayer.lastpos.angle = 0
			sphereplayer.lastpos.checkpoint = 0
			sphereplayer.lastpos.leveltime = 0
			sphereplayer.lastpos.powerup = 0
		end
		return
	end

	sphereplayer.timer = mapheaderinfo[gamemap].spheretimer
	P_LoadS3KData(sphereplayer.map)
	sphereplayer.spheres = 0

	scrollysec = {}
	for sector in sectors.iterate do
		if sector.floorpic == 'GFZFLR01' then
			sector.floorpic = 'S3KSSFL'..sphereplayer.map
			table.insert(scrollysec, sector)

			sector.floorxoffset = 172*FRACUNIT
			sector.flooryoffset = -172*FRACUNIT
		end

		if sector.ceilingpic == 'S3KSPLIT' then
			sector.floorpic = 'S3KSPLT'..(sphereplayer.map)
			sector.ceilingpic =	'S3KSPLT'..(sphereplayer.map)
		end

		if sector.ceilingpic == 'S3KSPLIG' then
			sector.floorpic = 'S3KSPLG'..(sphereplayer.map)
			sector.ceilingpic =	'S3KSPLG'..(sphereplayer.map)
		end
	end

	if multiplayer then
		print("MULTIPLAYER WARNING: Special stage weren't designed for Multiplayer. Other players are expected to be desynced immediedly and kicked out from server.")
	end

	for y = 1,32 do
		for x = 1,32 do
			if S3KSS_Current[y][x] == 2 then
				sphereplayer.spheres = $+1
			end
		end
	end
	loadingorder = 1
	print(loadingorder)
end)


local pos = {}

for y = -9, 9 do
	for x = -9, 9 do
		table.insert(pos, {x, y})
	end
end

local dist_opaq = {
	[9] = FF_TRANS80,
	[8] = FF_TRANS60,
	[7] = FF_TRANS40,
	[6] = FF_TRANS20,
}

local dist_scale = {
	[9] = FRACUNIT/3,
	[8] = FRACUNIT/4,
	[7] = FRACUNIT/6,
	[6] = FRACUNIT/8,
}


--41 is middle one

addHook("MapThingSpawn", function(a, mt)
	if not mapheaderinfo[gamemap].spheremode then return end
		a.sprite = SPR_S3KS
		a.flags = $ &~ MF_NOGRAVITY
		a.scale = FRACUNIT+FRACUNIT/4
		a.posx = pos[mt.angle][1]
		a.posy = pos[mt.angle][2]

		local dist = max(abs(a.posx), abs(a.posy))
		if dist_opaq[dist] then
			a.frame = $|dist_opaq[dist]
			a.scale = $-dist_scale[dist]
		end

		a.spriteyoffset = -4*FRACUNIT
		a.shadowscale = 0
end, MT_BLUESPHERE)

addHook("MobjThinker", function(a)
	if loadingorder == 2 and a.posx ~= nil and a.posy ~= nil and S3KSS_Current ~= nil then
		a.xpos = (((a.posx+sphereplayer.x/inbdistance)-2) % 32) + 1
		a.ypos = (((a.posy+sphereplayer.y/inbdistance)-1) % 32) + 1

		local mapin = S3KSS_Current[a.ypos][a.xpos]

		a.state = frames[(mapin or 0)][1]
		a.frame = frames[(mapin or 0)][2]

		if a and a.valid then
			P_SetOrigin(a, a.spawnpoint.x*FRACUNIT-(((sphereplayer.x*64) % FRACUNIT)*96), a.spawnpoint.y*FRACUNIT+(((sphereplayer.y*64) % FRACUNIT)*96), a.floorz)
			P_SetOrigin(a, a.x, a.y, a.floorz) -- stupid method of updating a.floorz
		end
	end
end, MT_BLUESPHERE)

addHook("TouchSpecial", function(a)
	if not mapheaderinfo[gamemap].spheremode then return end
	if loadingorder == 2 and a.xpos ~= nil and a.ypos ~= nil then
		-- red sphere logic
		if not sphereplayer.red_delay then
			if S3KSS_Current[a.ypos][a.xpos] == 1 then
				G_SetCustomExitVars(sphereplayer.lastpos.map, 1)
				G_ExitLevel()
				S_StartSound(nil, sfx_s3kaf)
			end

			-- blue sphere logic
			if S3KSS_Current[a.ypos][a.xpos] == 2 then
				S3KSS_Current[a.ypos][a.xpos] = 1
				sphereplayer.spheres = $-1
				S_StartSound(nil, a.info.deathsound)

				if sphereplayer.spheres <= 0 then
					G_SetCustomExitVars(sphereplayer.lastpos.map, 1)
					G_ExitLevel()

					S_StartSound(nil, sfx_s3kaf)
				end
			end

			-- bumper logic
			if S3KSS_Current[a.ypos][a.xpos] == 3 then
				if sphereplayer.momb < 0 then
					sphereplayer.momb = TICRATE
				else
					sphereplayer.momb = -TICRATE
				end
				S_StartSound(nil, sfx_s3kaa)
			end
		end

		-- ring logic
		if S3KSS_Current[a.ypos][a.xpos] == 4 then
			S3KSS_Current[a.ypos][a.xpos] = 0
			sphereplayer.rings = $+1
			S_StartSound(nil, sfx_itemup)
		end

		sphereplayer.red_delay = 8
	end
	return true
end, MT_BLUESPHERE)

local dir = {{1,0}, {1,1}, {0,1}, {1, -1}, {1, -1}, {-1, -1}, {-1,0}, {0,-1}}

-- S3K Air's assembly addresser was kinda inspiration for this thing. You could call it translation from lemon but not really, as my set up just doesn't allow me straight up 'copy it'.
-- so only thing I am taking is logic behind it. -- Sonic 3 Air by Eukaryot

--local function P_CheckS3KBalls(x, y)
--	local balls = P_CheckS3KBallsStack(x, y)
--	if balls == nil then return end
--
--	for k,v in ipairs(balls) do
--		if S3KSS_Current[v[2]][v[1]] == SB or S3KSS_Current[v[2]][v[1]] == RS then
--			S3KSS_Current[v[2]][v[1]] = CS
--			if S3KSS_Current[v[2]][v[1]] == SB then
--				sphereplayer.spheres = $-1
--			end
--		end
--	end
--end


--local 4dir = {{1,0}, {0,1}, {-1,0}, {0,-1}}
--local dax = {-0x01, -0x20, 0x01, 0x20, -0x01, -0x20}

--[[
local function P_CheckS3KBallsStack(x, y)
	local turned = {}
	local counter, counterx, countery, yl = 0,0,0,0

		for i = 1,8 do
			if S3KSS_Current[((x + dir[i][1]) % 32) + 1)][((y + dir[i][2]) % 32) + 1)] == SB then
				counter = $+1
			end
		end

		if (counter == 0) then return end

		repeat
			yl = $ + 1
			counterx = $+1
		until (S3KSS_Current[(((x + yl) % 32) + 1)][y] == eS)
		yl = 0
		repeat
			y = $ - 1
			counterx = $+1
		until (S3KSS_Current[((x + yl) % 32) + 1)][y] == eS)
		yl = 0
		counterx = $+1

		if (counterx < 3) then return end

		repeat
			yl = $ + 1
			countery = $+1
		until (S3KSS_Current[x][((y + yl) % 32) + 1)] == eS)
		yl = 0
		repeat
			yl = $ - 1
			countery = $+1
		until (S3KSS_Current[x][((y + yl) % 32) + 1)] == eS)
		yl = 0
		countery = $+1

		if (countery < 3) then return end

		local stackbuffer = {}
		stackbuffer[1][1] = x
		stackbuffer[1][2] = y
		stackbuffer.size = 0
		stackbuffer.offset = 0

		*/
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

		/*
		while (true) do

			local posx = 0
			local posy = 0
			local neightbor = {}
			for i = 1, 4 do
				neightbor[i] = S3KSS_Current[(x + 4dir[i][1] + posx) % 32 + 1][(y + 4dir[i][2] + posy) % 32 + 1]
				if neightbor[i] = SB then
					local accepted = true

					if accepted == true





					end

					if stackbuffer.size <= 2 then
						accepted = false
					end

				end

			end

			while ()
				if (stackSize == 0)
					return

		end
end
--]]


local function P_RotateS3KPlayer(p, amount)
	sphereplayer.x = ((sphereplayer.x+(sphereplayer.x % inbdistance)/2))/(inbdistance)*inbdistance
	sphereplayer.y = ((sphereplayer.y+(sphereplayer.y % inbdistance)/2))/(inbdistance)*inbdistance
	p.mo.rotcooldown = abs(amount/8) - 3
	p.mo.rotdir = amount > 0 and ANG2 or -ANG2
	p.mo.rotaim = sphereplayer.angle + amount*ANG1
end

states[S_PLAY_S3KWALK] = {
	sprite = SPR_PLAY,
	frame = SPR2_WALK|FF_ANIMATE,
	var1 = 0,
	var2 = 4,
}

local turn = 0
local function inRange(point, center, range)
	return point < center+range and point > center-range
end


addHook("PlayerThink", function(p)
	if loadingorder == 1 then
		p.powers[pw_nocontrol] = sphereplayer.timer
		sphereplayer.x = (S3KSS_Current.playerspawnx and S3KSS_Current.playerspawnx*inbdistance or inbdistance*3)
		sphereplayer.y = (S3KSS_Current.playerspawny and S3KSS_Current.playerspawny*inbdistance or inbdistance*3)
		sphereplayer.angle = (S3KSS_Current.playerspawna*ANG1) or ANGLE_MAX
		sphereplayer.height = 0
		loadingorder = 2
		p.aiming = $+ANG1*90

		print(loadingorder)
	end

	if loadingorder == 2 then
		if p.mo.rotcooldown == nil or p.mo.rotcooldown <= 0 then
			if sphereplayer.momb then
				sphereplayer.x = $ + sphereplayer.momb*cos(p.mo.angle)/4056
				sphereplayer.y = $ - sphereplayer.momb*sin(p.mo.angle)/4056

				sphereplayer.momb = sphereplayer.momb/2
				if abs(sphereplayer.momb) == 1 then
					sphereplayer.momb = 0
				end
			else
				sphereplayer.x = $ + cos(p.mo.angle)/1024
				sphereplayer.y = $ - sin(p.mo.angle)/1024
			end

			if sphereplayer.red_delay then
				sphereplayer.red_delay = $-1
			end

			if turn then
				if inRange(sphereplayer.x, sphereplayer.x/inbdistance*inbdistance, inbdistance/16)
				or inRange(sphereplayer.y, sphereplayer.y/inbdistance*inbdistance, inbdistance/16) then
					if turn > 0 then
						P_RotateS3KPlayer(p, 90)
					elseif turn < 0 then
						P_RotateS3KPlayer(p, -90)
					end

					turn = 0
				end
			end
		else
			sphereplayer.angle = $ + 8*p.mo.rotdir
			p.mo.rotcooldown = $ - 1
			if p.mo.rotcooldown == 0 then
				sphereplayer.angle = p.mo.rotaim
			end

			--P_TryCameraMove(camera,
			--p.mo.x-FixedMul(cos(p.mo.angle), CV_FindVar("camera_dist").value)*4,
			--p.mo.y-FixedMul(sin(p.mo.angle), CV_FindVar("camera_dist").value)*4)

			--camera.momx = 0
			--camera.momy = 0
		end

		for k,sec in ipairs(scrollysec) do
			if sec and sec.valid then
				sec.floorxoffset = p.mo.x + 6144*sphereplayer.x - FRACUNIT*48 -- offset
				sec.flooryoffset = p.mo.y + 6144*sphereplayer.y - FRACUNIT*96
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
			if p.mo.state ~= S_PLAY_JUMP then
				p.mo.state = S_PLAY_JUMP
				p.mo.anim_duration = 4
			end
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
				turn = -1
			end

			if input.gameControlDown(GC_TURNLEFT) then
				turn = 1
			end
		end

		if fakeangle == 90 then
			fakeangle = 0
		end

		if sphereplayer.x >= 32*inbdistance-inbdistance/128 then
			sphereplayer.x = inbdistance/16
		elseif sphereplayer.x <= inbdistance/128 then
			sphereplayer.x = 32*inbdistance-inbdistance/16
		end
		if sphereplayer.y >= 32*inbdistance-inbdistance/128 then
			sphereplayer.y = inbdistance/16
		elseif sphereplayer.y <= inbdistance/128 then
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

--[[
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
--]]