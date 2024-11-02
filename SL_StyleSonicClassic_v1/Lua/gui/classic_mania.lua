--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

return{
	lives = function(v, p, t, e, prefix, mo, hide_offset_x)
		if p and p.mo then
			local pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}

			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x

			v.draw((lives_x+10), (hudinfo[HUD_LIVES].y+13), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
			for i = 1, 4 do
				v.draw((lives_x+8+pos[i][1]), (hudinfo[HUD_LIVES].y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_ALLWHITE))
			end

			v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_DEFAULT, p.mo.color))
			drawf(v, 'MATNUM', (lives_x+21)*FRACUNIT, (hudinfo[HUD_LIVES].y+2)*FRACUNIT, FRACUNIT, 'X'..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1), "left")
		end
	end,
}

