
local drawlib = 	tbslibrary 'lib_emb_tbsdrawers'
local helper = 		tbsrequire 'helpers/lua_hud'
local gettime = 	tbsrequire 'helpers/game_ingametime'

local convertPlayerTime = helper.convertPlayerTime
local font_drawer = drawlib.draw
local font_string = 'SA1NUM'
local font_redstring = 'SA1NUMR'
local font_scale = FU/4*3


local tokenstyle_cv = CV_FindVar("dc_keystyle")

--
-- Additional Font Drawer
--

local symbad = string.byte(";")

-- TODO: CHECK EVERY GAMETYPE AND WHATEVER

return {
	score = function(v, p, t, e)
		return
	end,

	time = function(v, p, t, e)
		local time_string = ""
		local mint, sect, cent

		if p.gammaTimerRan ~= nil and p.gammaTimerRan == true and p.gammaTime ~= nil then
			mint, sect, cent = convertPlayerTime(p.gammaTime)
			time_string = mint..':'..sect..':'..cent
		else
			time_string = gettime(p)
		end

		v.drawScaled((hudinfo[HUD_RINGS].x-9)*FU, (hudinfo[HUD_SECONDS].y-10)*FU, font_scale, v.cachePatch('SA1TIME'), hudinfo[HUD_RINGS].f|V_PERPLAYER)

		font_drawer(v, font_string, (hudinfo[HUD_SCORENUM].x-81)*FU+FU, (hudinfo[HUD_SECONDS].y-4)*FU-FU/2, font_scale, time_string, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "left", 0, 0)
	end,

	rings = function(v, p, t, e)
		local numrings = (p.rings > 99  and p.rings or (p.rings < 10 and '00'..p.rings or '0'..p.rings))

		-- main drawer
		v.drawScaled((hudinfo[HUD_RINGS].x-9)*FU, (hudinfo[HUD_SECONDS].y)*FU, font_scale, v.cachePatch('SA1RINGS'), hudinfo[HUD_RINGS].f|V_PERPLAYER)
		font_drawer(v, font_string, (hudinfo[HUD_RINGSNUM].x-67)*FU+FU, (hudinfo[HUD_RINGSNUM].y-7)*FU, font_scale, numrings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)

		-- flashing
		if not p.rings then
			local transparency = ease.outsine(abs(((leveltime*FU/22) % (2*FU))+1-FU), 0, 9) << V_ALPHASHIFT
			font_drawer(v, font_redstring, (hudinfo[HUD_RINGSNUM].x-67)*FU+FU, (hudinfo[HUD_RINGSNUM].y-7)*FU, font_scale, "000", hudinfo[HUD_RINGS].f|transparency|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
		end
	end,

	lives = function(v, p, t, e)
		local skin_name = string.upper(skins[p.mo.skin].name)
		local patch_name = "STYLES_DCLIFE_"..skin_name
		local patch_s_name = "STYLES_SDCLIFE_"..skin_name

		if v.patchExists(patch_s_name) and p.powers[pw_super] then
			v.drawScaled((hudinfo[HUD_LIVES].x-10)*FU, (hudinfo[HUD_LIVES].y-9)*FU, FU/2, v.cachePatch(patch_s_name), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
		elseif v.patchExists(patch_name) then
			v.drawScaled((hudinfo[HUD_LIVES].x-10)*FU, (hudinfo[HUD_LIVES].y-9)*FU, FU/2, v.cachePatch(patch_name), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
		else

			v.drawScaled((hudinfo[HUD_LIVES].x-10)*FU, (hudinfo[HUD_LIVES].y-9)*FU, FU/2, v.cachePatch("SA1LIFEBG"), hudinfo[HUD_LIVES].f|V_PERPLAYER)
			-- icon
			v.drawScaled((hudinfo[HUD_LIVES].x-9)*FU+FU/2, (hudinfo[HUD_LIVES].y-9)*FU+FU/2, FU*14/32, v.getSprite2Patch(p.mo.skin, SPR2_XTRA, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
		
			v.drawScaled((hudinfo[HUD_LIVES].x-10)*FU, (hudinfo[HUD_LIVES].y-9)*FU, FU/2, v.cachePatch("SA1LIFEBG1"), hudinfo[HUD_LIVES].f|V_PERPLAYER)
		end

		if G_GametypeUsesLives() then
			-- number
			local numlives = (p.lives < 10 and '0'..p.lives or p.lives)
			font_drawer(v, font_string, (hudinfo[HUD_LIVES].x+15)*FU, (hudinfo[HUD_LIVES].y+57)*FU, font_scale, numlives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
		elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
			v.draw(hudinfo[HUD_LIVES].x+8, hudinfo[HUD_LIVES].y-8, v.cachePatch('CLASSICIT'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
		end
	end,
}