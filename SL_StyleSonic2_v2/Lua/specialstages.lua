--[[
/*
local function spfontdw(d, font, x, y, scale, value, flags, color)
	local patch, val, str
	for i = 1,24 do
		val = string.sub(''..value, i,i)
		if val ~= nil and val ~= ' ' and val ~= '' then
			patch = d.cachePatch(font..''..val)
			if not d.patchExists(font..''..val) then
				patch = d.cachePatch('S2SSNONE')
			end
 		else
			return
		end
		d.drawScaled(x+((patch.width)*(i-1))*FRACUNIT, y, scale, patch, flags, color)
	end
end
*/

local function spfontdw(d, font, x, y, scale, value, flags, color, alligment, padding)
	local patch, val
	local str = ''..value
	local fontoffset, pad, allig, actlinelenght = 0, 0, 0, 0

	for i = 1,#str do
		val = string.sub(str, i,i)
		patch = d.cachePatch(font..''..val)
		actlinelenght = $+patch.width
	end

	if alligment == "center" then
		allig = -actlinelenght/2*FRACUNIT
	elseif alligment == "right" then
		allig = -actlinelenght*FRACUNIT
	end

	for i = 1,#str do
		val = string.sub(str, i,i)
		if val ~= nil and val ~= ' ' and val ~= '' then
			patch = d.cachePatch(font..''..val)
			if not d.patchExists(font..''..val) then
				patch = d.cachePatch('S2SSNONE')
			end
 		else
			return
		end
		d.drawScaled(x+allig+(fontoffset+(padding or 0)*pad)*FRACUNIT, y, scale, patch, flags, color)
		fontoffset = $+patch.width
		pad = $+1
	end


end

local function onspnumfont(d, font, x, y, scale, value, flags)
	local patch, val, str

	if value < 10 then
		str = '0'..value
	else
		str = ''..value
	end


	for i = 1,2 do
		val = string.sub(str, i,i)
		if val ~= nil and val ~= ' ' and val ~= '' then
			patch = d.cachePatch(font..''..val)
 		else
			patch = d.cachePatch(font..''..0)
		end
		d.drawScaled(x+((patch.width)*(i-1))*FRACUNIT, y, scale, patch, flags)
	end
end

local function twspnumfont(d, font, x, y, scale, value, flags)
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
		d.drawScaled(x+((patch.width)*(i-1))*FRACUNIT, y, scale, patch, flags)
	end
end

local S2bots = {}

addHook("MapLoad", function()
	S2bots = {}
end)

addHook("BotRespawn", function(p, b)
	S2bots[p] = b
end)

addHook("TouchSpecial", function(a, mt)
	if mt.player then
		if mt.ss2rings == nil then
			mt.ss2rings = 0
		end
		mt.ss2rings = $+1
	end
end, MT_RING)

hud.add(function(v, p, c)
	if not G_IsSpecialStage(gamemap) then return end
		hud.disable("nightslink")
		hud.disable("nightsdrill")
		hud.disable("nightsrings")
		hud.disable("nightsscore")
		hud.disable("nightstime")
		hud.disable("multisphereget")
	local pname, mp, firplrg
	firplrg = p.mo.ss2rings or 0

	-- Bot-addition
	if S2bots[p.mo] ~= nil and S2bots[p.mo].valid then
		local bot = S2bots[p.mo]
		local bname
		mp = 0
		if bot.skin == "tails" then bname = "1TAILS2" else bname = nil end

		v.draw(208, 25, v.cachePatch('S2SSRINGS'))
		spfontdw(v, 'S2SSNAMF', 236*FRACUNIT, 16*FRACUNIT, FRACUNIT, (bname or skins[bot.skin].hudname), 0, v.getColormap(bot.skin, bot.color), "center")
		spfontdw(v, 'S2SSNUM', 252*FRACUNIT, 25*FRACUNIT, FRACUNIT, p.rings-firplrg)

		v.draw(140, 17, v.cachePatch('S2SSTOTAL'))
		spfontdw(v, 'S2SSNUM', 160*FRACUNIT, 25*FRACUNIT, FRACUNIT, p.rings, 0, v.getColormap(TC_DEFAULT, 1), "center")
	else
		mp = 78*FRACUNIT
	end

	-- Single player
	if p.mo.skin == "tails" then pname = "1TAILS2" else pname = nil end
	v.draw(56+mp/FRACUNIT, 25, v.cachePatch('S2SSRINGS'))
	spfontdw(v, 'S2SSNUM', 100*FRACUNIT+mp, 25*FRACUNIT, FRACUNIT, firplrg)
	spfontdw(v, 'S2SSNAMF', 81*FRACUNIT+mp, 16*FRACUNIT, FRACUNIT, (pname or skins[p.mo.skin].hudname), 0, v.getColormap(p.mo.skin, p.mo.color), "center")
end)

/*
	Gameplay

*/


addHook("PlayerSpawn", function(p)
	// local
	local a = p.mo

	// forcedangle
	p.forcessangle = a.angle
	p.momentum = 0
end)


local function maxmin(minv, curv, maxv)
	return min(maxv, max(minv, curv))
end

local function numpro(num)
	return num/num
end

local function gradreturnto(gradv, targetv, speed)
	if targetv > gradv then
		gradv = $ + speed
	elseif targetv < gradv then
		gradv = $ - speed
	end

	return gradv
end

local function anglemid(alpha, beta)
	return FixedAngle((AngleFixed(alpha) + AngleFixed(beta))/2)
end

local function atan(x)
    return asin(FixedDiv(x,(1 + FixedMul(x,x)))^(1/2))
end

local function atan2(x, y)
    return atan(FixedDiv(y, x))
end

/*
addHook("PlayerThink", function(p)
	// local
	local a = p.mo

	// putting player into stasis
	input.setMouseGrab(false)
	p.powers[pw_nocontrol] = 34000

	// camera object
	--P_TeleportCameraMove(camera, .x, a.cybercambase.y, a.)


	// playermovement

	-- fixedangle
	a.angle = p.forcessangle
	local xstrafe, ystrafe = 0, 0
	local slopedirmid = a.standingslope and anglemid(a.standingslope.xydirection*numpro(-a.standingslope.zdelta), a.angle) or 0
	local difzangle = a.standingslope and FixedMul(cos(slopedirmid), -sin(a.standingslope.zangle)) or 0
	local mompower = a.standingslope and abs(a.standingslope.zdelta)/4 or 0

	-- slopemomentum
	p.momentum = $ + (difzangle*4) or 0
	p.momentum = maxmin(-30*FRACUNIT, gradreturnto(p.momentum, 0, FRACUNIT/2), 100*FRACUNIT)
	print(p.momentum)

	-- strafing
	if input.gameControlDown(GC_STRAFELEFT) or input.gameControlDown(GC_TURNLEFT) then
		xstrafe = 16*cos(a.angle+ANGLE_90)
		ystrafe = 16*sin(a.angle+ANGLE_90)
	end

	if input.gameControlDown(GC_STRAFERIGHT) or input.gameControlDown(GC_TURNRIGHT) then
		xstrafe = 16*cos(a.angle-ANGLE_90)
		ystrafe = 16*sin(a.angle-ANGLE_90)
	end

	if input.gameControlDown(GC_BACKWARD) then
		p.forcessangle = $+ANGLE_45
	end

	-- acceleration
	a.momx = (20*cos(a.angle) + xstrafe) * (p.powers[pw_sneakers] and 2 or 1) + FixedMul(p.momentum, cos(slopedirmid))
	a.momy = (20*sin(a.angle) + ystrafe) * (p.powers[pw_sneakers] and 2 or 1) + FixedMul(p.momentum, sin(slopedirmid))


	-- animations
	if p.playerstate == PST_DEAD then
		a.state = S_PLAY_DEAD
		a.rollangle = $ + ANG1*5
	else
		if a.momz ~= 0
			if a.state ~= S_PLAY_JUMP then a.state = S_PLAY_JUMP end
		else
			if a.state ~= S_PLAY_WALK and not p.powers[pw_sneakers] then
				a.state = S_PLAY_WALK
			elseif a.state ~= S_PLAY_RUN and p.powers[pw_sneakers] then
				a.state = S_PLAY_RUN
			end
		end
	end




	-- trick for anims
	p.rmomx = 2*FRACUNIT * (speedshoes and 2 or 1)
end)
*/

addHook("MobjSpawn", function(a)
	a.halfpipedummy = P_SpawnMobjFromMobj(a, 0,0,0, MT_THOK)
	a.halfpipedummy.state = S_INVISIBLE
	a.halfpipedummy.flags = $ &~ MF_NOGRAVITY
	a.halfpipeangle = ANG1
	a.anglehp = a.angle
end, MT_PLAYER)

addHook("PlayerThink", function(p)
	// local
	local a = p.mo

	if a.halfpipedummy then

		// putting player into stasis
		input.setMouseGrab(false)
		p.powers[pw_nocontrol] = 34000
		a.flags = $|MF_NOGRAVITY

		// playermovement

		-- strafing
		if input.gameControlDown(GC_STRAFELEFT) or input.gameControlDown(GC_TURNLEFT) then
			a.halfpipeangle = $ - ANG1*5
		end

		if input.gameControlDown(GC_STRAFERIGHT) or input.gameControlDown(GC_TURNRIGHT) then
			a.halfpipeangle = $ + ANG1*5
		end

		-- acceleration
		a.angle = a.anglehp
		a.halfpipedummy.momx = 10*cos(a.angle)
		a.halfpipedummy.momy = 10*sin(a.angle)
		local spacialxtrans = 512*FRACUNIT-1024*cos(a.halfpipeangle)
		P_TeleportMove(a, a.halfpipedummy.x+FixedMul(spacialxtrans, cos(a.angle+ANGLE_90)), a.halfpipedummy.y+FixedMul(spacialxtrans, sin(a.angle+ANGLE_90)), a.halfpipedummy.z+1024*FRACUNIT+1024*cos(a.halfpipeangle+ANGLE_180))
		P_TeleportCameraMove(camera, a.halfpipedummy.x-cos(a.angle)*1024, a.halfpipedummy.y-sin(a.angle)*1024, a.halfpipedummy.z+512*FRACUNIT)

		-- animations
		if p.playerstate == PST_DEAD then
			a.state = S_PLAY_DEAD
			a.rollangle = $ + ANG1*5
		else
			if a.state ~= S_PLAY_WALK then
				a.state = S_PLAY_WALK
				a.rollangle = a.halfpipeangle
			end
		end

		-- trick for anims
		p.rmomx = 2*FRACUNIT
	end
end)


local function turnSSPlayer(line,mobj,sector)
	mobj.player.forcessangle = (line.args[0]*ANG1) or line.frontside.textureoffset
end

addHook("LinedefExecute", turnSSPlayer, "TURNPLR")

local function lineCameraSwitch(line,mobj,sector)
	if mobj.linecamera == false then
		local distance = P_AproxDistance(line.dx, line.dy)
		mobj.camclosedisx = FixedMul(distance, cos(mobj.angle))
		mobj.camclosedisy = FixedMul(distance, sin(mobj.angle))
		mobj.linecamera = true
	else
		mobj.linecamera = false
	end
end

addHook("LinedefExecute", lineCameraSwitch, "CAMSWIC")

]]