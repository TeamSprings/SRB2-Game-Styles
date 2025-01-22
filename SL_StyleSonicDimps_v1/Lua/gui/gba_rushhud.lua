--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local colorcmp = tbsrequire 'helpers/color_compress'
local drawf = drawlib.draw

local life_xyz = {{2,0},{0,2},{-2,0},{0,-2},{1,-2},{-1,2},{1,0},{0,1},{-1,0},{0,-1}}

local function draw_lifeicon(v, x, y, patch, flags, colormap, p)
	if not (colormap) then return end

	local skin_name = string.upper(skins[p.mo and p.mo.skin or p.skin].name)
	local patch_name = "STYLES_SRUSHLIFE_"..skin_name
	local patch_s_name = "STYLES_SSRUSHLIFE_"..skin_name

	if v.patchExists(patch_s_name) and p.powers[pw_super] then
		v.draw(x, y, v.cachePatch(patch_s_name), flags, colormap)
	elseif v.patchExists(patch_name) then
		v.draw(x, y, v.cachePatch(patch_name), flags, colormap)
	else
		for i = 1,10 do
			v.draw(x+life_xyz[i][1], y+life_xyz[i][2], patch, flags, i < 7 and v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK) or v.getColormap(TC_ALLWHITE, SKINCOLOR_WHITE))
		end

		v.draw(x, y, patch, flags, v.getColormap(TC_DEFAULT, colormap, colorcmp.advance3(colormap)))
	end
end

return {
	score = function(v, p, t, e, font_type)
		return
	end,

	time = function(v, p, t, e, font_type)
		local mint = G_TicsToMinutes(p.realtime, true)
		local sect = G_TicsToSeconds(p.realtime)
		local cent = G_TicsToCentiseconds(p.realtime)
		sect = (sect < 10 and '0'..sect or sect)
		cent = (cent < 10 and '0'..cent or cent)

		drawf(v, font_type, 160*FRACUNIT, (hudinfo[HUD_SECONDS].y-20)*FRACUNIT, FRACUNIT, "T"..mint..':'..sect..':'..cent, hudinfo[HUD_RINGS].f|V_PERPLAYER &~ V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
	end,

	rings = function(v, p, t, e, font_type)
		v.draw(3, 4, v.cachePatch("RINGRUSH"), hudinfo[HUD_RINGS].f|V_PERPLAYER)
		drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-43)*FRACUNIT, (hudinfo[HUD_SECONDS].y-19)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", 0, 3, '0')
		if p.rings < 1 and (leveltime % 8) / 4 then
			drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-43)*FRACUNIT, (hudinfo[HUD_SECONDS].y-19)*FRACUNIT, FRACUNIT, "RRR", hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", 0, 0)
		end
	end,

	lives = function(v, p, t, e, font_type, icon_style, bot_existance, bot_skin, bot_color)
		if p.lives == INFLIVES or (not p.mo) or p.spectator then return end

		if icon_style and bot_existance then
			if bot_existance.valid then
				draw_lifeicon(v, hudinfo[HUD_LIVES].x+10, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(bot_skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), bot_color, p)
				draw_lifeicon(v, hudinfo[HUD_LIVES].x-3, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color, p)

				if G_GametypeUsesLives() then
					drawf(v, font_type, (hudinfo[HUD_LIVES].x+20)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT, "X"..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
				end
			else
				draw_lifeicon(v, hudinfo[HUD_LIVES].x-3, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color, p)

				bot_existance = nil

				if G_GametypeUsesLives() then
					drawf(v, font_type, (hudinfo[HUD_LIVES].x+16)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT, "X"..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
				end
			end
		else
			draw_lifeicon(v, hudinfo[HUD_LIVES].x-3, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color, p)

			if G_GametypeUsesLives() then
				drawf(v, font_type, (hudinfo[HUD_LIVES].x+8)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT, "X"..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
			end
		end
	end,

	key = function(v, p, t, e, font_type)
		return true
	end,
}