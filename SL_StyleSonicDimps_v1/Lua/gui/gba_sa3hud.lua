local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local colorcmp = tbsrequire 'helpers/color_compress'
local drawf = drawlib.draw

local list_pw = {
	[CA_NONE] 			= "RINGMADV3",
	[CA_THOK] 			= "RINGSADV3",
	[CA_JUMPTHOK] 		= "RINGSADV3",
	[CA_FLY] 			= "RINGTADV3",
	[CA_GLIDEANDCLIMB] 	= "RINGPADV3",
	[CA_HOMINGTHOK] 	= "RINGSADV3",
	[CA_FLOAT] 			= "RINGRADV3",
	[CA_BOUNCE] 		= "RINGNADV3",
	[CA_TWINSPIN] 		= "RINGAADV3",
}

local life_xyz = {{2,0},{0,2},{-2,0},{0,-2},{1,-2},{-1,2},{1,0},{0,1},{-1,0},{0,-1}}

local function draw_lifeicon(v, x, y, patch, flags, colormap)
	if not (colormap) then return end

	for i = 1,10 do
		v.draw(x+life_xyz[i][1], y+life_xyz[i][2], patch, flags, i < 7 and v.getColormap(TC_ALLWHITE, SKINCOLOR_WHITE) or v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
	end

	v.draw(x, y, patch, flags, v.getColormap(TC_DEFAULT, colormap, colorcmp.advance3(colormap)))
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

		drawf(v, font_type, 160*FRACUNIT, (hudinfo[HUD_SECONDS].y-22)*FRACUNIT, FRACUNIT, "T"..mint.."'"..sect..'"'..cent, hudinfo[HUD_RINGS].f|V_PERPLAYER &~ V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
	end,

	rings = function(v, p, t, e, font_type)
		v.draw(8, 1, v.cachePatch(list_pw[p.charability] and list_pw[p.charability] or "RINGMADV3"), hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
		drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-61)*FRACUNIT, (hudinfo[HUD_SECONDS].y-21)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "left", 0, 3, '0')
		if p.rings < 1 and (leveltime % 10) / 5 then
			drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-61)*FRACUNIT, (hudinfo[HUD_SECONDS].y-21)*FRACUNIT, FRACUNIT, "RRR", hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "left", 0, 0)
		end
	end,

	lives = function(v, p, t, e, font_type, icon_style, bot_existance, bot_skin, bot_color)
		if icon_style and bot_existance then
			if bot_existance.valid then
				draw_lifeicon(v, hudinfo[HUD_LIVES].x+13, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(bot_skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), bot_color)
				draw_lifeicon(v, hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color)
				drawf(v, font_type, (hudinfo[HUD_LIVES].x+25)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
			else
				draw_lifeicon(v, hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color)
				drawf(v, font_type, (hudinfo[HUD_LIVES].x+25)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
				bot_existance = nil
			end
		else
			draw_lifeicon(v, hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p.mo.color)
			drawf(v, font_type, (hudinfo[HUD_LIVES].x+17)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
		end
	end,

	key = function(v, p, t, e, font_type)
		if token then
			v.draw(10, 25, v.cachePatch("KEYADV3"), hudinfo[HUD_RINGS].f|V_PERPLAYER)
			drawf(v, font_type, 35*FRACUNIT, 27*FRACUNIT, FRACUNIT, token, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
		end
	end,
}