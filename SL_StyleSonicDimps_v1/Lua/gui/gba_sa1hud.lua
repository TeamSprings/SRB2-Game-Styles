--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local timeget = tbsrequire 'helpers/game_ingametime'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw

local function drawLifeIcon(v, x, y, patch, flags, p, color, skin)
	local skin_name = string.upper(skins[skin].name)
	local patch_name = "STYLES_ADV1LIFE_"..skin_name
	local patch_s_name = "STYLES_SADV1LIFE_"..skin_name

	if v.patchExists(patch_s_name) and p.powers[pw_super] then
		v.draw(x, y, v.cachePatch(patch_s_name), flags, color)
	elseif v.patchExists(patch_name) then
		v.draw(x, y, v.cachePatch(patch_name), flags, color)
	else
		v.draw(x, y, patch, flags, color)
	end
end


return {
	score = function(v, p, t, e, font_type)
		drawf(v, font_type,
			(hudinfo[HUD_SCORENUM].x-40 + (font_type == "RUSNUM" and 10 or font_type == "RUANUM" and 10 or 0))*FRACUNIT,
			(hudinfo[HUD_SECONDS].y-25)*FRACUNIT,
			FRACUNIT,
			p.score,
			hudinfo[HUD_RINGS].f|V_PERPLAYER,
			v.getColormap(TC_DEFAULT, 0),
			"right",
			0, 0)
	end,

	time = function(v, p, t, e, font_type)
		local timestr = timeget(p)
		drawf(v, font_type, (hudinfo[HUD_SECONDS].x-72)*FRACUNIT, (hudinfo[HUD_SECONDS].y-11)*FRACUNIT, FRACUNIT, timestr, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
	end,

	rings = function(v, p, t, e, font_type)
		v.draw(5, 2, v.cachePatch('RINGADV'), hudinfo[HUD_RINGS].f|V_PERPLAYER)
		if p.rings > 999 or (font_type == "RUSNUM" and p.rings > 99) then
			drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-79)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y-29)*FRACUNIT, 3*FRACUNIT/4, p.rings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
			if p.rings < 1 and (leveltime % 10) / 5 then
				drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-79)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y-29)*FRACUNIT, 3*FRACUNIT/4, "RRR", hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
			end
		else
			drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-84)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y-34)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
			if p.rings < 1 and (leveltime % 10) / 5 then
				drawf(v, font_type, (hudinfo[HUD_RINGSNUM].x-84)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y-34)*FRACUNIT, FRACUNIT, "R", hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
			end
		end
	end,

	lives = function(v, p, t, e, font_type, icon_style, bot_existance, bot_skin, bot_color)
		if p.lives == INFLIVES or p.spectator then return end
		if not (p.mo or p.mo.valid) then return end

		if icon_style and bot_existance and bot_existance.valid then
			drawLifeIcon(v, hudinfo[HUD_LIVES].x+3, hudinfo[HUD_LIVES].y+19, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p, v.getColormap(TC_DEFAULT, p.mo.color), p.mo.skin)
			drawLifeIcon(hudinfo[HUD_LIVES].x-6, hudinfo[HUD_LIVES].y+19, v.getSprite2Patch(bot_skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), bot_existance.player or p, v.getColormap(TC_DEFAULT, bot_color), bot_skin)

			if G_GametypeUsesLives() then
				drawf(v, font_type, (hudinfo[HUD_LIVES].x+14)*FRACUNIT, (hudinfo[HUD_LIVES].y+10)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
			end
		else
			if bot_existance and not bot_existance.valid then
				bot_existance = nil
			end

			drawLifeIcon(v, hudinfo[HUD_LIVES].x-6, hudinfo[HUD_LIVES].y+19, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), p, v.getColormap(TC_DEFAULT, p.mo.color), p.mo.skin)

			if G_GametypeUsesLives() then
				drawf(v, font_type, (hudinfo[HUD_LIVES].x+5)*FRACUNIT, (hudinfo[HUD_LIVES].y+10)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
			end
		end
	end,

	key = function(v, p, t, e, font_type)
		return true
	end,
}