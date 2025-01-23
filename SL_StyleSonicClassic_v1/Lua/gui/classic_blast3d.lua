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
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_B3DLIFE_"..skin_name
			local patch_s_name = "STYLES_SB3DLIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.cachePatch(patch_s_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.cachePatch(patch_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				v.draw(lives_x, hudinfo[HUD_LIVES].y-1, v.cachePatch('3BLIVBLANK1'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
				v.draw(lives_x, hudinfo[HUD_LIVES].y-1, v.cachePatch('3BLIVBLANK2'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
			end

			if G_GametypeUsesLives() then
				drawf(v, prefix..'TNUM', (lives_x+18)*FRACUNIT, (hudinfo[HUD_LIVES].y+1)*FRACUNIT, FRACUNIT, 'X'..p.lives, hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1), "left")
			end
		end
	end,
}

