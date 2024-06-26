--[[

		User Interfaces inspired by Sonic Adventure 2.

Contributors: Ace Lite, Demnyx
@Team Blue Spring 2022-2024

]]



local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local helper = 	tbsrequire 'helpers/lua_hud'

local convertPlayerTime = helper.convertPlayerTime
local font_drawer = drawlib.draw
local font_string = 'SA2NUM'
local font_redstring = 'SA2NUMR'
local font_scale = FRACUNIT/4*3

local HOOK = customhud.SetupItem

--
-- Additional Font Drawer
--

local symbad = string.byte(";")

local function V_ScoreDrawer(v, font, x, y, scale, value, flags, color, alligment, padding, leftadd, symbol)
	local str = tostring(value)
	local fontoffset = 0

	str = string.rep(";", max(8-#str, 0))..str

	local maxv = #str
	local nx = FixedMul(x, scale)
	local ny = FixedMul(y, scale)

	local drawer = v.drawScaled

	for i = 1,maxv do
		local d = string.sub(str, i, i)
		local f = flags
		local p

		if d == ";" then
			p = v.cachePatch(font..symbad)
			f = $|V_60TRANS
		else
			p = v.cachePatch(font..d)
		end

		drawer(nx+fontoffset*scale, ny, scale, p, f, color)
		fontoffset = $+p.width+padding
	end
end

--
-- In-Game Hook
--

-- SCORE
HOOK("score", "sa2hud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end

	V_ScoreDrawer(v, font_string, (hudinfo[HUD_SCORENUM].x-80)*FRACUNIT, (hudinfo[HUD_SECONDS].y-8)*FRACUNIT, font_scale, p.score, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "left", 1, 8)

	return true
end, "game")

-- TIME
HOOK("time", "sa2hud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end

	local mint, sect, cent = convertPlayerTime(p.realtime)
	font_drawer(v, font_string, (hudinfo[HUD_SCORENUM].x-80)*FRACUNIT, (hudinfo[HUD_SECONDS].y+4)*FRACUNIT, font_scale, mint..':'..sect..':'..cent, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "left", 1, 0)

	return true
end, "game")

-- RINGS
HOOK("rings", "sa2hud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end

	local numrings = (p.rings > 99  and p.rings or (p.rings < 10 and '00'..p.rings or '0'..p.rings))

	-- main drawer
	v.drawScaled((hudinfo[HUD_RINGS].x+12)*FRACUNIT, (hudinfo[HUD_RINGS].y-10)*FRACUNIT, font_scale, (not mariomode and v.cachePatch('SA2RINGS') or v.cachePatch('SA2COINS')), hudinfo[HUD_RINGS].f|V_PERPLAYER)
	font_drawer(v, font_string, (hudinfo[HUD_RINGSNUM].x-32)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y+14)*FRACUNIT, font_scale, numrings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 1, 0)

	-- flashing
	if not p.rings then
		local transparency = ease.outsine(abs(((leveltime*FRACUNIT/22) % (2*FRACUNIT))+1-FRACUNIT), 0, 9) << V_ALPHASHIFT
		font_drawer(v, font_redstring, (hudinfo[HUD_RINGSNUM].x-32)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y+14)*FRACUNIT, font_scale, "000", hudinfo[HUD_RINGS].f|transparency|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 1, 0)
	end

	if token then
		v.drawScaled((hudinfo[HUD_RINGS].x+72)*FRACUNIT, (hudinfo[HUD_RINGS].y-10)*FRACUNIT, font_scale, v.cachePatch('SA2CHAO'), hudinfo[HUD_RINGS].f|V_PERPLAYER)
	end

	return true
end, "game")

-- LIVES
HOOK("lives", "sa2hud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end

	if not G_GametypeUsesLives() then return false end
	local numlives = (p.lives < 10 and '0'..p.lives or p.lives)

	local pos = {{-2,0}, {2,0}, {0,2}, {0,-2}}
	if p.mo.skin == "adventuresonic" then
		pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}
	end

	-- white outline
	for i = 1, 4 do
		v.draw((hudinfo[HUD_LIVES].x+20+pos[i][1]), (hudinfo[HUD_LIVES].y+6+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_ALLWHITE))
	end

	-- icon
	v.draw(hudinfo[HUD_LIVES].x+20, hudinfo[HUD_LIVES].y+6, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))

	-- number
	font_drawer(v, font_string, (hudinfo[HUD_LIVES].x+54)*FRACUNIT, (hudinfo[HUD_LIVES].y+64)*FRACUNIT, font_scale, numlives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 1, 0)

	return true
end, "game")