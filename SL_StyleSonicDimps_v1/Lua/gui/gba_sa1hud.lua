--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw

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
		local mint = G_TicsToMinutes(p.realtime, true)
		local sect = G_TicsToSeconds(p.realtime)
		local cent = G_TicsToCentiseconds(p.realtime)
		sect = (sect < 10 and '0'..sect or sect)
		cent = (cent < 10 and '0'..cent or cent)

		drawf(v, font_type, (hudinfo[HUD_SECONDS].x-72)*FRACUNIT, (hudinfo[HUD_SECONDS].y-11)*FRACUNIT, FRACUNIT, mint..':'..sect..':'..cent, hudinfo[HUD_RINGS].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
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

		if icon_style and bot_existance and bot_existance.valid then
			v.draw(hudinfo[HUD_LIVES].x+3, hudinfo[HUD_LIVES].y+19, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), v.getColormap(TC_DEFAULT, p.mo.color))
			v.draw(hudinfo[HUD_LIVES].x-6, hudinfo[HUD_LIVES].y+19, v.getSprite2Patch(bot_skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), v.getColormap(TC_DEFAULT, bot_color))
			drawf(v, font_type, (hudinfo[HUD_LIVES].x+14)*FRACUNIT, (hudinfo[HUD_LIVES].y+10)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
		else
			if bot_existance and not bot_existance.valid then
				bot_existance = nil
			end

			v.draw(hudinfo[HUD_LIVES].x-6, hudinfo[HUD_LIVES].y+19, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|(icon_style ~= nil and V_FLIP or 0), v.getColormap(TC_DEFAULT, p.mo.color))
			drawf(v, font_type, (hudinfo[HUD_LIVES].x+5)*FRACUNIT, (hudinfo[HUD_LIVES].y+10)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
		end
	end,

	key = function(v, p, t, e, font_type)
		return true
	end,
}