--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local timeget = tbsrequire 'helpers/game_ingametime'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local colorcmp = tbsrequire 'helpers/color_compress'
local drawf = drawlib.draw

local life_xyz = {{2,0},{0,2},{0,-2},{-1,2},{1,0},{0,1},{-1,0},{0,-1}}

local function draw_lifeicon(v, x, y, patch, flags, colormap, p, id)
	if not (colormap) then return end

	local skin_name = string.upper(skins[p.mo and p.mo.skin or p.skin].name)
	local patch_name = "STYLES_RUSHLIFE_"..skin_name
	local patch_s_name = "STYLES_SRUSHLIFE_"..skin_name

	if v.patchExists(patch_s_name) and p.powers[pw_super] then
		v.draw(x, y, v.cachePatch(patch_s_name), flags, colormap)
	elseif v.patchExists(patch_name) then
		v.draw(x, y, v.cachePatch(patch_name), flags, colormap)
	else
		for i = 1,8 do
			v.draw(x+life_xyz[i][1], y+life_xyz[i][2], patch, flags, i < 5 and v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK) or v.getColormap(TC_ALLWHITE, SKINCOLOR_WHITE))
		end

		v.draw(x, y, patch, flags, v.getColormap(TC_DEFAULT, colormap, colorcmp.advance3(colormap)))
	end
end

return {
	score = function(v, p, t, e, font_type)
		return
	end,

	time = function(v, p, t, e, font_type)
		local timestr = timeget(p)
		local y_off = -20

		if G_GametypeHasTeams() then
			y_off = 8
		end

		drawf(v, font_type, 160*FU, (hudinfo[HUD_SECONDS].y + y_off)*FU, FU, "T"..timestr, hudinfo[HUD_RINGS].f|V_PERPLAYER &~ V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
	end,

	rings = function(v, p, t, e, font_type)
		v.draw(3, 4, v.cachePatch("RINGRUSH"), hudinfo[HUD_RINGS].f|V_PERPLAYER)
		drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-43)*FU, (hudinfo[HUD_SECONDS].y-19)*FU, FU, p.rings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", 0, 3, '0')
		if p.rings < 1 and (leveltime % 8) / 4 then
			drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-43)*FU, (hudinfo[HUD_SECONDS].y-19)*FU, FU, "RRR", hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", 0, 0)
		end
	end,

	lives = function(v, p, t, e, font_type, icon_style, bot_existance, bot_skin, bot_color)
		if p.lives == INFLIVES or (not p.mo) or p.spectator then return end
		if not (p.mo and p.mo.valid) then return end

		if icon_style and bot_existance then
			if bot_existance.valid then
				if bot_skin then
					draw_lifeicon(v, hudinfo[HUD_LIVES].x+10, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(bot_skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), bot_color, p, 2)
				end

				draw_lifeicon(v, hudinfo[HUD_LIVES].x-3, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color, p, 1)

				if G_GametypeUsesLives() then
					drawf(v, font_type, (hudinfo[HUD_LIVES].x+20)*FU, (hudinfo[HUD_LIVES].y+7)*FU, FU, "X"..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
				elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(hudinfo[HUD_LIVES].x+14, hudinfo[HUD_LIVES].y+4, v.cachePatch('CLASSICIT'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
				end
			else
				draw_lifeicon(v, hudinfo[HUD_LIVES].x-3, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color, p, 1)

				bot_existance = nil

				if G_GametypeUsesLives() then
					drawf(v, font_type, (hudinfo[HUD_LIVES].x+16)*FU, (hudinfo[HUD_LIVES].y+7)*FU, FU, "X"..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
				elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(hudinfo[HUD_LIVES].x+14, hudinfo[HUD_LIVES].y+4, v.cachePatch('CLASSICIT'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
				end
			end
		else
			draw_lifeicon(v, hudinfo[HUD_LIVES].x-3, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color, p, 1)

			if G_GametypeUsesLives() then
				drawf(v, font_type, (hudinfo[HUD_LIVES].x+8)*FU, (hudinfo[HUD_LIVES].y+7)*FU, FU, "X"..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(hudinfo[HUD_LIVES].x+14, hudinfo[HUD_LIVES].y+4, v.cachePatch('CLASSICIT'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
			end
		end
	end,

	key = function(v, p, t, e, font_type)
		return true
	end,
}