--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local timeget = tbsrequire 'helpers/game_ingametime'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local colorcmp = tbsrequire 'helpers/color_compress'
local drawf = drawlib.draw

local life_xyz = {{1,0},{0,1},{-1,0},{0,-1}}
local ring_rot = 0

local function draw_lifeicon(v, x, y, patch, flags, colormap, p)
	if not (colormap and colormap[1] and colormap[2]) then return end

	local skin_name = string.upper(skins[p.mo and p.mo.skin or p.skin].name)
	local patch_name = "STYLES_ADV2LIFE_"..skin_name
	local patch_s_name = "STYLES_SADV2LIFE_"..skin_name

	if v.patchExists(patch_s_name) and p.powers[pw_super] then
		v.draw(x, y, v.cachePatch(patch_s_name), flags, color)
	elseif v.patchExists(patch_name) then
		v.draw(x, y, v.cachePatch(patch_name), flags, color)
	else
		for i = 1,4 do
			v.draw(x+life_xyz[i][1], y+life_xyz[i][2], patch, flags, v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
		end

		v.draw(x, y, patch, flags, v.getColormap(TC_DEFAULT, colorcmp.advance2(colormap[1], colormap[2], p), "Advance2ColorCompress"))
	end
end

return {
	score = function(v, p, t, e, font_type)
		drawf(v, font_type,
			(hudinfo[HUD_RINGSNUM].x-64 + (font_type == "RUSNUM" and 4 or font_type == "RUANUM" and 4 or 0))*FRACUNIT,
			(hudinfo[HUD_SECONDS].y-10)*FRACUNIT,
			FRACUNIT,
			p.score,
			hudinfo[HUD_RINGS].f|V_PERPLAYER,
			v.getColormap(TC_DEFAULT, 0),
			"left",
			0, 6, '0')
	end,

	time = function(v, p, t, e, font_type)
		local timestr = timeget(p)
		drawf(v, font_type, 160*FRACUNIT, (hudinfo[HUD_SECONDS].y-24)*FRACUNIT, FRACUNIT, timestr, hudinfo[HUD_RINGS].f|V_PERPLAYER &~ V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
	end,

	rings = function(v, p, t, e, font_type)
		v.draw(5, 2, v.cachePatch('RINGADV2'), hudinfo[HUD_RINGS].f|V_PERPLAYER)

		local speed = p.speed/18/FRACUNIT
		ring_rot = (ring_rot + speed) % 36

		v.draw(11, 6, v.cachePatch('ADV2RIN'..(((leveltime/3+ring_rot/2) % 18) + 1)), hudinfo[HUD_RINGS].f|V_PERPLAYER)

		drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-40)*FRACUNIT, (hudinfo[HUD_SECONDS].y-24)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", 0, 3, '0')
		if p.rings < 1 and (leveltime % 10) / 5 then
			drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-40)*FRACUNIT, (hudinfo[HUD_SECONDS].y-24)*FRACUNIT, FRACUNIT, "RRR", hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "right", 0, 0)
		end
	end,

	lives = function(v, p, t, e, font_type, icon_style, bot_existance, bot_skin, bot_color)
		if p.lives == INFLIVES or p.spectator then return end
		if not (p.mo and p.mo.valid) then return end

		if icon_style and bot_existance and bot_existance.valid then
			draw_lifeicon(v, hudinfo[HUD_LIVES].x+9, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), {1, p.mo.color}, p)
			draw_lifeicon(v, hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(bot_skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), {2, bot_color}, p)

			if G_GametypeUsesLives() then
				drawf(v, font_type, (hudinfo[HUD_LIVES].x+25)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
			end
		else
			if bot_existance and not bot_existance.valid then
				bot_existance = nil
			end

			draw_lifeicon(v, hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y+16, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), {1, p.mo.color}, p)

			if G_GametypeUsesLives() then
				drawf(v, font_type, (hudinfo[HUD_LIVES].x+15)*FRACUNIT, (hudinfo[HUD_LIVES].y+7)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
			end
		end
	end,

	key = function(v, p, t, e, font_type)
		if token then
			for i = 1, token do
				v.draw(8 + (i - 1) * 8, 30, v.cachePatch("KEYADV2"), hudinfo[HUD_RINGS].f|V_PERPLAYER)
			end
		end
	end,
}