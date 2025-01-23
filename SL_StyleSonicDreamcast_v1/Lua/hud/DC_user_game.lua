--[[

		User Interfaces inspired by Sonic Adventure 2.

Contributors: Skydusk, Demnyx
@Team Blue Spring 2022-2025

]]


local worldlib = 	tbslibrary 'lib_sparkeditedw2h'
local drawlib = 	tbslibrary 'lib_emb_tbsdrawers'
local helper = 		tbsrequire 'helpers/lua_hud'
local gettime = 	tbsrequire 'helpers/game_ingametime'

local convertPlayerTime = helper.convertPlayerTime
local translate = worldlib.translate
local font_drawer = drawlib.draw
local font_string = 'SA2NUM'
local font_redstring = 'SA2NUMR'
local font_scale = FRACUNIT/4*3

local HOOK = customhud.SetupItem


local modern_sonic_hud_cvar = CV_FindVar("hudstyle")

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
HOOK("score", "dchud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	V_ScoreDrawer(v, font_string, (hudinfo[HUD_SCORENUM].x-80)*FRACUNIT, (hudinfo[HUD_SECONDS].y-8)*FRACUNIT, font_scale, p.score, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "left", 1, 8)

	return true
end, "game")

-- TIME
HOOK("time", "dchud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	local time_string = ""
	local mint, sect, cent

	if p.gammaTimerRan ~= nil then
		mint, sect, cent = convertPlayerTime(p.gammaTime)
		time_string = mint..':'..sect..':'..cent
	else
		time_string = gettime(p)
	end

	font_drawer(v, font_string, (hudinfo[HUD_SCORENUM].x-80)*FRACUNIT, (hudinfo[HUD_SECONDS].y+4)*FRACUNIT, font_scale, time_string, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "left", 1, 0)

	return true
end, "game")

-- RINGS
HOOK("rings", "dchud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

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
		if token > 1 or not p.styles_keytouch then
			v.drawScaled((hudinfo[HUD_RINGS].x+72)*FRACUNIT, (hudinfo[HUD_RINGS].y-10)*FRACUNIT, font_scale, v.cachePatch('SA2CHAO'), hudinfo[HUD_RINGS].f|V_PERPLAYER)
		end

		if p.styles_keytouch and p.styles_keytouch.dur > 0 then
			local ox, oy, oscale, visible = translate({
					x = p.styles_keytouch.cam_x,
					y = p.styles_keytouch.cam_y,
					z = p.styles_keytouch.cam_z,
					angle = p.styles_keytouch.cam_angle,
					aiming = p.styles_keytouch.cam_aiming,
				},
				{
					x = p.styles_keytouch.x,
					y = p.styles_keytouch.y,
					z = p.styles_keytouch.z,
				}
			)

			local winwidth = v.width()
			local winheight = v.height()
			local winscale = v.dupy()

			local widthgreenextra = (winwidth/winscale - 320)/2
			local heightgreenextra = (winheight/winscale - 200)/2

			local dur = p.styles_keytouch.dur
			local key_sprite = v.getSpritePatch(SPR_SA2K, p.styles_keytouch.frame)

			local scale = 	ease.linear	(dur, font_scale/5, oscale)
			local x = 		ease.outsine(dur, hudinfo[HUD_RINGS].x-widthgreenextra+78+FixedInt(FixedMul(key_sprite.leftoffset, scale)), ox/FRACUNIT)
			local y = 		ease.outsine(dur, hudinfo[HUD_RINGS].y-heightgreenextra+9+FixedInt(FixedMul(key_sprite.topoffset, scale)), oy/FRACUNIT+FixedInt(FixedMul(key_sprite.topoffset, scale)))

			v.drawScaled(x*FRACUNIT, y*FRACUNIT, scale, key_sprite, V_PERPLAYER)
		end
	end

	return true
end, "game")

addHook("PlayerThink", function(p)
	if p.styles_keytouch and p.styles_keytouch.dur > 920 then
		p.styles_keytouch.dur = p.styles_keytouch.dur-FRACUNIT/18
		p.styles_keytouch.frame = ((p.styles_keytouch.frame & FF_FRAMEMASK)+2) % 69
	else
		p.styles_keytouch = nil
	end
end)

-- LIVES
HOOK("lives", "dchud", function(v, p, t, e)
	if G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy
	if p.lives == INFLIVES or p.spectator then return end

	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	if not G_GametypeUsesLives() then return false end
	if not p.mo then return end

	local skin_name = string.upper(skins[p.mo.skin].name)
	local patch_name = "STYLES_ADVLIFE_"..skin_name
	local patch_s_name = "STYLES_SADVLIFE_"..skin_name

	if v.patchExists(patch_s_name) and p.powers[pw_super] then
		v.draw(hudinfo[HUD_LIVES].x+20, hudinfo[HUD_LIVES].y+6, v.cachePatch(patch_s_name), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
	elseif v.patchExists(patch_name) then
		v.draw(hudinfo[HUD_LIVES].x+20, hudinfo[HUD_LIVES].y+6, v.cachePatch(patch_name), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
	else
		local pos = {{-2,0}, {2,0}, {0,2}, {0,-2}}
		if p.mo.skin == "adventuresonic" then
			pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}
		end

		-- white outline
		for i = 1, 4 do
			v.draw((hudinfo[HUD_LIVES].x+20+pos[i][1]), (hudinfo[HUD_LIVES].y+6+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0, "GrayoutWhite"))
		end

		-- icon
		v.draw(hudinfo[HUD_LIVES].x+20, hudinfo[HUD_LIVES].y+6, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
	end

	-- number
	local numlives = (p.lives < 10 and '0'..p.lives or p.lives)
	font_drawer(v, font_string, (hudinfo[HUD_LIVES].x+54)*FRACUNIT, (hudinfo[HUD_LIVES].y+64)*FRACUNIT, font_scale, numlives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 1, 0)

	return true
end, "game")