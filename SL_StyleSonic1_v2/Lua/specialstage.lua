freeslot("MT_SONIC1SPSTBORDER", "MT_SONIC1SPRITEBLOCKS")

-- Example 

-- Video shit
local videoWidth, videoHeight, origx, origy
local horizontalFOV = 95*ANG1

local function P_Update_Video(d)
	videoWidth = d.width()
	videoHeight = v.height()
	aspectRatio = videoWidth/videoHeight
end

local ids_datasets = {
	-- blocks(1-9)
	1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,
	-- gameplayblocks
	5,1,6,0,7,8,9,10,12,13,14,15,9,5,5,0,0,0,0,0,0,16,17,17,17,17,17,17,11,0,0,0,0,0,0,0,0,18,12,13,14,15,
}	

local ids_mobjtiles = {
	[0] = "ignore"; -- Air
	[1] = {MT_SONIC1SPSTBORDER, "blue"}; -- Blue Blocks
	[2] = {MT_SONIC1SPSTBORDER, "yellow"}; -- Yellow Blocks
	[3] = {MT_SONIC1SPSTBORDER, "purple"}; -- Purple Blocks
	[4] = {MT_SONIC1SPSTBORDER, "lime"};	-- Lime Blocks
	[5] = {MT_SONIC1SPRITEBLOCKS, "bump"};-- Bumper
	[6]	= {MT_SONIC1SPRITEBLOCKS, "goal"};-- Goal Block
	[7] = {MT_SONIC1SPRITEBLOCKS, "up"}; -- UP Tile
	[8] = {MT_SONIC1SPRITEBLOCKS, "down"};-- DOWN Tile
	[9] = {MT_SONIC1SPRITEBLOCKS, "r"};-- R Tile
	[10] = {MT_SONIC1SPRITEBLOCKS, "spin"};-- Spinning Tile
	[11] = {MT_SONIC1SPRITEBLOCKS, "inv"};-- Invisible Tile
	[12] = {MT_SONIC1SPRITEBLOCKS, "blue"};-- Blue Crystal
	[13] = {MT_SONIC1SPRITEBLOCKS, "green"};-- Green Crystal
	[14] = {MT_SONIC1SPRITEBLOCKS, "yellow"};-- Yellow Crystal
	[15] = {MT_SONIC1SPRITEBLOCKS, "purple"};-- Purple Crystal
	[16] = {MT_RING, "ring"};-- Rings
	[17] = {MT_EMERALD, "emerald"};-- Current Emerald
	[18] = {MT_SONIC1SPRITEBLOCKS, "switch"};-- Switch Tile	
}

hud.add(P_Update_Video, "game")

local function atan(x)
    return asin(FixedDiv(x,(1 + FixedMul(x,x)))^(1/2))    
end

local mapdata = {}
local S01SS_Current = {}

local function P_LoadS01Data(mapnum)
	local mapx = io.openlocal("tbs/S01/"..mapnum..".dat", "rb")
	if mapx then
		local data = mapx:read('*all')
			for i = 1, 64 do
				mapdata[i] = {}
			end
			for bin = 0,4095 do
				local loc = (bin % 64)
				local y = (bin / 64)
				mapdata[y+1][loc+1] = string.byte(data, (bin), (bin))
			end
			S01_Current = mapdata
			io.close(mapx)	
	else
		S01SS_Current = S01SS_Map[sphereplayer.map]
	end
end

local verticalFOV = 2*atan(tan(horizontalFOV/2)/aspectRatio)

addHook("PlayerThink", function(p)
	-- Camera object
	local playdis = P_AproxDistance(p.mo.x - camera.x, p.mo.y - camera.y)
	local mindisxcam = playdis*(-cos(horizontalFOV))
	local maxdisxcam = playdis*cos(horizontalFOV)
	local mindiszcam = playdis*(-sin(verticalFOV))
	local maxdiszcam = playdis*sin(verticalFOV)

	origx = mindisxcam+(mindisxcam - maxdisxcam)/2
	origz = mindiszcam+(mindiszcam - maxdiszcam)/2	
end)

addHook("MobjThinker", function(a)
	local pointdis = P_AproxDistance(a.x - origx, a.z - origz)

	if pointdis > mindisxcam and pointdis < maxdisxcam and pointdis < mindiszcam and pointdis > maxdiszcam then
		if a.flags2 & MF2_DONTDRAW then
			a.flags2 = $ &~ MF2_DONTDRAW
		end
	else
		if a.flags2 &~ MF2_DONTDRAW then
			a.flags2 = $|MF2_DONTDRAW
		end
	end
end, MT_SONIC1SPSTBORDER)



