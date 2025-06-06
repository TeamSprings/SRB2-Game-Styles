--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

local pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}

return{
	lives = function(v, p, t, e, prefix, mo, hide_offset_x, colorprofile, overwrite, lifepos)
		if p and p.mo then
			local lives_f = hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x
			local lives_y = hudinfo[HUD_LIVES].y

			if lifepos > 1 then
				lives_f = ($|V_SNAPTORIGHT|V_SNAPTOTOP) &~ (V_SNAPTOLEFT|V_SNAPTOBOTTOM)
				lives_x = 281-hudinfo[HUD_LIVES].x-hide_offset_x
				lives_y = 184-hudinfo[HUD_LIVES].y
			end

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_KCLIFE_"..skin_name
			local patch_s_name = "STYLES_SKCLIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, lives_y+11, v.cachePatch(patch_s_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, lives_y+11, v.cachePatch(patch_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				for i = 1, 4 do
					v.draw((lives_x+8+pos[i][1]), (lives_y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_ALLWHITE))
				end

				v.draw(lives_x+8, lives_y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_DEFAULT, p.mo.color))
			end

			if G_GametypeUsesLives() then
				drawf(v, prefix..'TNUM', (lives_x+18)*FU, (lives_y+1)*FU, FU, 'X'..p.lives, lives_f, colorprofile, "left")
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(lives_x+22, lives_y, v.cachePatch('CLASSICIT'), lives_f)
			end
		end
	end,
}

