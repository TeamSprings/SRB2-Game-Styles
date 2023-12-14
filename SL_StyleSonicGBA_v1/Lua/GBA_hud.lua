//
//

local function P_SADV1HudDrawer(v, p)

	local mint = G_TicsToMinutes(leveltime, true)
	local sect = G_TicsToSeconds(leveltime)
	local cent = G_TicsToCentiseconds(leveltime)
	sect = (sect < 10 and '0'..sect or sect)
	cent = (cent < 10 and '0'..cent or cent)
	
	v.draw(5, 2, (not mariomode and v.cachePatch('RINGADV') or v.cachePatch('SA2COINS')), hudinfo[HUD_RINGS].f)
	TBSlib.fontdrawer(v, 'ADVNUM', (hudinfo[HUD_SCORENUM].x-40)*FRACUNIT, (hudinfo[HUD_SECONDS].y-25)*FRACUNIT, FRACUNIT, p.score, hudinfo[HUD_RINGS].f, v.getColormap(TC_DEFAULT, 0), "right", 0, 0)
	TBSlib.fontdrawer(v, 'ADVNUM', (hudinfo[HUD_SECONDS].x-72)*FRACUNIT, (hudinfo[HUD_SECONDS].y-11)*FRACUNIT, FRACUNIT, mint..':'..sect..':'..cent, hudinfo[HUD_RINGS].f, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)
	TBSlib.fontdrawer(v, 'ADVNUM', (hudinfo[HUD_RINGSNUM].x-84)*FRACUNIT, (hudinfo[HUD_RINGSNUM].y-34)*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGS].f, v.getColormap(TC_DEFAULT, 0), "center", 0, 0)
	-- Life counter

	v.draw(hudinfo[HUD_LIVES].x-6, hudinfo[HUD_LIVES].y+19, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f, v.getColormap(TC_DEFAULT, p.mo.color))
	TBSlib.fontdrawer(v, 'ADVNUM', (hudinfo[HUD_LIVES].x+5)*FRACUNIT, (hudinfo[HUD_LIVES].y+10)*FRACUNIT, FRACUNIT, p.lives, hudinfo[HUD_LIVES].f, v.getColormap(TC_DEFAULT, 0), 0, 0, 0)	

end

hud.add(function(v, p, t, e)

	hud.disable("rings")
	hud.disable("time")	
	hud.disable("lives")
	hud.disable("score")
	
	P_SADV1HudDrawer(v, p)
	
end, "game")
