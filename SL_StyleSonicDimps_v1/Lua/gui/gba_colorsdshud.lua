local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local colorcmp = tbsrequire 'helpers/color_compress'
local drawf = drawlib.draw

local life_xyz = {{2,0},{0,2},{-2,0},{0,-2},{1,-2},{-1,2},{1,0},{0,1},{-1,0},{0,-1}}

local function draw_lifeicon(v, x, y, patch, flags, colormap, p)
	if not (colormap and colormap[1] and colormap[2]) then return end

	for i = 1,10 do
		v.draw(x+life_xyz[i][1], y+life_xyz[i][2], patch, flags, i < 7 and v.getColormap(TC_ALLWHITE, SKINCOLOR_WHITE) or v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
	end

	v.draw(x, y, patch, flags, v.getColormap(TC_DEFAULT, colorcmp.advance2(colormap[1], colormap[2], p), "Advance2ColorCompress"))
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

		drawf(v, font_type, 313*FRACUNIT, (hudinfo[HUD_SECONDS].y-21)*FRACUNIT, FRACUNIT, "T"..mint.."'"..sect..'"'..cent, (hudinfo[HUD_RINGS].f|V_PERPLAYER|V_SNAPTORIGHT) &~ V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 0), "right", -1, 0)
	end,

	rings = function(v, p, t, e, font_type)
		v.draw(2, 1, v.cachePatch("RINGCOLR"), hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
		drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-59)*FRACUNIT, (hudinfo[HUD_SECONDS].y-20)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", -1, 3, '0')
		if p.rings < 1 and (leveltime % 8) / 4 then
			drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-59)*FRACUNIT, (hudinfo[HUD_SECONDS].y-20)*FRACUNIT, FRACUNIT, "RRR", hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", -1, 0)
		end
	end,

	lives = function(v, p, t, e, font_type, icon_style, bot_existance, bot_skin, bot_color)
		local lives = p.lives > 9 and p.lives or "0"..p.lives

		if icon_style and bot_existance then
			if bot_existance.valid then
				draw_lifeicon(v, hudinfo[HUD_LIVES].x+11, hudinfo[HUD_LIVES].y+13, v.getSprite2Patch(bot_skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and 0 or V_FLIP), {2, bot_color}, p)
				draw_lifeicon(v, hudinfo[HUD_LIVES].x-4, hudinfo[HUD_LIVES].y+13, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style == nil and 0 or V_FLIP), {1, p.mo.color}, p)
				drawf(v, 'COLCNT', (hudinfo[HUD_LIVES].x+7)*FRACUNIT, (hudinfo[HUD_LIVES].y+10)*FRACUNIT, FRACUNIT, "X"..lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, -1, 0)
			else
				draw_lifeicon(v, hudinfo[HUD_LIVES].x-2, hudinfo[HUD_LIVES].y+13, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style == nil and 0 or V_FLIP), {1, p.mo.color}, p)
				drawf(v, 'COLCNT', (hudinfo[HUD_LIVES].x+3)*FRACUNIT, (hudinfo[HUD_LIVES].y+10)*FRACUNIT, FRACUNIT, "X"..lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, -1, 0)
				bot_existance = nil
			end
		else
			draw_lifeicon(v, hudinfo[HUD_LIVES].x-2, hudinfo[HUD_LIVES].y+13, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style == nil and 0 or V_FLIP), {1, p.mo.color}, p)
			drawf(v, 'COLCNT', (hudinfo[HUD_LIVES].x+3)*FRACUNIT, (hudinfo[HUD_LIVES].y+10)*FRACUNIT, FRACUNIT, "X"..lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, -1, 0)
		end
	end,

	key = function(v, p, t, e, font_type)
		return true
	end,
}