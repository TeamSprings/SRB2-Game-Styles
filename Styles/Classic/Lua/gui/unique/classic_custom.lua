local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local textlen = drawlib.text_lenght
local fonts = 	tbsrequire('gui/hud_fonts')

local min_lifelen = 6*4
local min_lifexap = 6*5-2
local max_lifelen = 7*9

local pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}

local function lifeicon(v, lives_x, lives_y, lives_scale, lives_f, p)
	local skin_name = string.upper(skins[p.mo.skin].name)
	local patch_name = "STYLES_CULIFE_"..skin_name
	local patch_s_name = "STYLES_SCULIFE_"..skin_name

	if v.patchExists(patch_s_name) and p.powers[pw_super] then
		v.draw(lives_x+8, lives_y+11, v.cachePatch(patch_s_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
	elseif v.patchExists(patch_name) then
		v.draw(lives_x+8, lives_y+11, v.cachePatch(patch_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
	else
        for i = 1, 4 do
            v.draw((lives_x+7+pos[i][1]*3), (lives_y+11+pos[i][1]*3), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_BLINK, SKINCOLOR_PITCHBLACK))
        end

		for i = 1, 4 do
			v.draw((lives_x+8+pos[i][1]), (lives_y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_ALLWHITE))
		end

		v.draw(lives_x+8, lives_y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|V_FLIP, v.getColormap(TC_DEFAULT, p.mo.color))
	end
end

return {
	playericon = lifeicon,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x, colorprofile, overwrite, lifepos, colorprofile2, icon)
		if p and p.mo then
			local lifename = string.upper(''..(overwrite and overwrite or skins[p.mo.skin].hudname))
			local lifenamelenght = textlen(v, 'HUS2NAM', lifename, 1)

			lifenamelenght = min(max($, min_lifelen), max_lifelen)

			local lives_f = hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x
			local lives_y = hudinfo[HUD_LIVES].y

			if lifepos > 1 then
				lives_f = ($|V_SNAPTORIGHT|V_SNAPTOTOP) &~ (V_SNAPTOLEFT|V_SNAPTOBOTTOM)
				lives_x = 281 - hudinfo[HUD_LIVES].x - hide_offset_x - max(lifenamelenght - min_lifexap, 0)
				lives_y = 184 - hudinfo[HUD_LIVES].y
			end

			icon(v, lives_x, lives_y, FU, lives_f, p)

			if G_GametypeUsesLives() then
				drawf(v, fonts.livesfnt..'NAM', (lives_x+17)*FU, (lives_y+1)*FU, FU, lifename, lives_f, colorprofile, 0, 1)

				if lifenamelenght > min_lifexap then
					v.draw(lives_x+22, lives_y+10, v.cachePatch('S2CROSS'), lives_f, colorprofile2)
				end

				local lives = p.lives

				if lives == INFLIVES then
					lives = "I"
				end

				drawf(v, fonts.livesnum..'NUM', (lives_x+17+lifenamelenght)*FU, (lives_y+9)*FU, FU, lives,
				lives_f, colorprofile2, "right", 1)
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(lives_x+22, lives_y, v.cachePatch('CLASSICIT'), lives_f)
			end
		end
	end,
}