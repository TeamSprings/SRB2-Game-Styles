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

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_SMALIFE_"..skin_name
			local patch_s_name = "STYLES_SSMALIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.cachePatch(patch_s_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.cachePatch(patch_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				v.draw((lives_x+10), (hudinfo[HUD_LIVES].y+13), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
				for i = 1, 4 do
					v.draw((lives_x+8+pos[i][1]), (hudinfo[HUD_LIVES].y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_ALLWHITE))
				end

				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS|V_FLIP, v.getColormap(TC_DEFAULT, p.mo.color))
			end

			if G_GametypeUsesLives() then
				drawf(v, 'MATNUM', (lives_x+21)*FRACUNIT, (hudinfo[HUD_LIVES].y+2)*FRACUNIT, FRACUNIT, 'X'..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1), "left")
			end
		end
	end,
}

