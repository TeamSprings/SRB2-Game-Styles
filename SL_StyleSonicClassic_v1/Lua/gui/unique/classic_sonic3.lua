--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local nametrim = tbsrequire 'helpers/string_trimnames'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local textlen = drawlib.text_lenght

local min_lifelen = 6*4
local min_lifexap = 6*5-2
local max_lifelen = 7*9

local clamping = tbsrequire 'helpers/anim_clamp'
local title_dur = TICRATE/5 - TICRATE/16

rawset(_G, "S3K_graphic_lvl_icon", {
	["GREENFLOWER"] = 	"S3KBGGFZ";
	["TECHNO HILL"] = 	"S3KBGTHZ";
	["DEEP SEA"] = 		"S3KBGDSZ";
	["CASTLE EGGMAN"] = "S3KBGCEZ";
	["ARID CANYON"] = 	"S3KBGACZ";
	["RED VOLCANO"] = 	"S3KBGRVZ";
	["EGG ROCK"] 	= 	"S3KBGEGZ";
	["BLACK CORE"] 	= 	"S3KBGEGZ";
})

local function drawS3KTXT(v, x, y, scale, value, flags, color1, color2, alligment, padding, leftadd, symbol)
	drawf(v, "S3KIL1FNT", x, y, scale, value, flags, color1, alligment, padding, leftadd, symbol)
	drawf(v, "S3KIL2FNT", x, y, scale, value, flags, color2, alligment, padding, leftadd, symbol)
end

function S3K_graphic_lvl_icon:assign(name, gfx)
	self[name] = gfx
end

if S3K_graphic_lvl_icon then
	S3K_graphic_lvl_icon:assign("ANGEL ISLAND", "S3KBGAIZ")
	S3K_graphic_lvl_icon:assign("GREEN HILL", "S3KBGGHZ")
end

local tryx, tryy = 0, 0

local function lifeicon(v, lives_x, lives_y, lives_scale, lives_f, p)
	local skin_name = string.upper(skins[p.mo.skin].name)
	local patch_name = "STYLES_S3LIFE_"..skin_name
	local patch_s_name = "STYLES_SS3LIFE_"..skin_name

	if v.patchExists(patch_s_name) and p.powers[pw_super] then
		v.draw(lives_x+8, lives_y+12, v.cachePatch(patch_s_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
	elseif v.patchExists(patch_name) then
		v.draw(lives_x+8, lives_y+12, v.cachePatch(patch_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
	else
		v.draw(lives_x, lives_y, v.cachePatch('S3LIVBLANK1'), lives_f)
		v.draw(lives_x+8, lives_y+12, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
		v.draw(lives_x, lives_y, v.cachePatch('S3LIVBLANK2'), lives_f)
	end
end

return{

	titlecard = function(v, p, t, e, bfade)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local lvlt = string.upper(nametrim(""..mapheaderinfo[gamemap].lvlttl))
		local act = tostring(mapheaderinfo[gamemap].actnum)
		--local scale = FU
		local offset = (#lvlt)*FU

		local isSpecialStage = G_IsSpecialStage(gamemap)
		local fade = isSpecialStage and 0xFB00 or (bfade and 0xFA00 or 0xFF00)
		local translation = isSpecialStage and "SPECIALSTAGE_SONIC3_TITLE" or nil
		local special_gp = isSpecialStage and 'S3KTTCARDSS' or 'S3KTTCARD'

		if p.styles_entercut_timer == nil then

			if t and t <= 3*TICRATE/2 then
				v.fadeScreen(fade, 31)
			elseif t <= 3*TICRATE/2+31 and t > 3*TICRATE/2 then
				v.fadeScreen(fade, 31-(t-3*TICRATE/2))
			end
		end

		if t and t <= e then
			local easet = clamping(0, t, title_dur) - clamping(e-title_dur, t, e)

			tryx = ease.linear(easet, 200*FU, 0)
			tryy = -tryx

			v.draw(69-(offset/FU)/2, tryy/FU-10, v.cachePatch(special_gp), 0)

			---@diagnostic disable-next-line
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				drawf(v, 'S3KTT', 288*FU+tryx-offset*3, 104*FU, FU, "ZONE", 0, v.getColormap(TC_DEFAULT, 1, translation), "right")
			end

			if act ~= "0" then
				v.draw(247+(tryx-offset*3)/FU, 131, v.cachePatch(S3K_graphic_lvl_icon[lvlt] or 'S3KBGAIZ'), 0)
				v.draw(233+(tryx-offset*3)/FU, 156, v.cachePatch('S3KTTACTC'), 0)
				drawf(v, 'S3KANUM', 258*FU+tryx-offset*3, 135*FU, FU, act, 0, v.getColormap(TC_DEFAULT, 1))
			end

			v.drawString(175, 158, mapheaderinfo[gamemap].subttl, 0|V_ALLOWLOWERCASE, "center")
			drawf(v, 'S3KTT', 288*FU+tryx-offset*3, 72*FU, FU, lvlt, 0, v.getColormap(TC_DEFAULT, 1, translation), "right")

			return true
		end
	end,

	lifedims = 32,

	playericon = lifeicon,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x, colorprofile, overwrite, lifepos, colorprofile2)
		if p and p.mo then
			local lifename = string.upper(''..(overwrite and overwrite or skins[p.mo.skin].hudname))
			local lifenamelenght = textlen(v, 'HUS3NAM', lifename, 1)

			lifenamelenght = min(max($, min_lifelen), max_lifelen)

			local lives_f = hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x
			local lives_y = hudinfo[HUD_LIVES].y

			if lifepos > 1 then
				lives_f = ($|V_SNAPTORIGHT|V_SNAPTOTOP) &~ (V_SNAPTOLEFT|V_SNAPTOBOTTOM)
				lives_x = 281 - hudinfo[HUD_LIVES].x - hide_offset_x - max(lifenamelenght - min_lifexap, 0)
				lives_y = 184 - hudinfo[HUD_LIVES].y
			end

			lifeicon(v, lives_x, lives_y, FU, lives_f, p)

			if G_GametypeUsesLives() then
				drawf(v, 'HUS3NAM', (lives_x+17)*FU, (lives_y+1)*FU, FU,
				string.upper(''..(overwrite and overwrite or skins[p.mo.skin].hudname)), lives_f, colorprofile, 0, 1)

				if lifenamelenght > min_lifexap then
					v.draw(lives_x+22, lives_y+10, v.cachePatch('S3CROSS'), lives_f, colorprofile2)
				end

				local lives = p.lives

				if lives == INFLIVES then
					lives = "I"
				end

				drawf(v, 'LIF3NUM', (lives_x+17+lifenamelenght)*FU, (lives_y+9)*FU, FU,
				lives, lives_f, colorprofile2, "right", 1)
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(lives_x+22, lives_y, v.cachePatch('CLASSICIT'), lives_f)
			end
		end
	end,

	tallytitle = function(v, p, offsetx, color, overwrite)
		local mo = p.mo

		local lvlt = string.upper(""..mapheaderinfo[gamemap].lvlttl)
		local act = tostring(mapheaderinfo[gamemap].actnum)

		v.draw(96-offsetx, 54, v.cachePatch("S3KPLACEHTALLY"), V_PERPLAYER)

		if mo and mo.valid then
			local skin = skins[p.mo.skin or p.skin]

			local skin_name = nametrim(string.upper(overwrite and overwrite or skin.realname))
			local color_2 = v.getColormap(TC_DEFAULT, skin.prefcolor)
			local color_1 = v.getColormap(TC_DEFAULT, skin.prefoppositecolor or skincolors[skin.prefcolor].invcolor)

			drawS3KTXT(v, (158-offsetx)*FU, 54*FU, FU, skin_name, V_PERPLAYER, color_1, color_2, "right")
		else
			local skin_name = "YOU"
			local color_2 = v.getColormap(TC_DEFAULT, SKINCOLOR_WHITE)
			local color_1 = v.getColormap(TC_DEFAULT, SKINCOLOR_BLACK)

			drawS3KTXT(v, (158-offsetx)*FU, 54*FU, FU, skin_name, V_PERPLAYER, color_1, color_2, "right")
		end

		if act ~= "0" then
			v.draw(228-offsetx, 51, v.cachePatch(S3K_graphic_lvl_icon[lvlt] or 'S3KBGAIZ'), V_PERPLAYER)
			v.draw(214-offsetx, 76, v.cachePatch('S3KTTACTC'), V_PERPLAYER)
			drawf(v, 'S3KANUM', (239-offsetx)*FU, 55*FU, FU, act, V_PERPLAYER, v.getColormap(TC_DEFAULT, 1))
		else
			v.draw(214-offsetx, 76, v.cachePatch('S3KZONETAG'), V_PERPLAYER)
		end
	end,

	tallyspecial = function(v, p, offsetx, color, color2)
		local mo = p.mo

		local str = "CHAOS EMERALDS"

		if emeralds == All7Emeralds(emeralds) then
			str = " GOT THEM ALL"

			if mo then
				str = string.upper(mo.skin)..str
			else
				str = "YOU"..str
			end
		end

		drawS3KTXT(v, 160*FU, 48*FU, FU, str, V_PERPLAYER, v.getColormap(TC_DEFAULT, SKINCOLOR_GREEN), v.getColormap(TC_DEFAULT, SKINCOLOR_BLUE), "center")
	end,
}