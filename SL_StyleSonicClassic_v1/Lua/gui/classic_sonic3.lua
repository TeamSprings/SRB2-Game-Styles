--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

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

return{

	titlecard = function(v, p, t, e, bfade)
		if t > e-1 then return end
		if p == secondarydisplayplayer then return end -- remove this once adjusted

		local lvlt = string.upper(""..mapheaderinfo[gamemap].lvlttl)
		local act = tostring(mapheaderinfo[gamemap].actnum)
		--local scale = FRACUNIT
		local offset = (#lvlt)*FRACUNIT
		if t < 2 then
			tryx = (200*FRACUNIT)
			tryy = -(200*FRACUNIT)
		end

		local isSpecialStage = G_IsSpecialStage(gamemap)
		local fade = isSpecialStage and 0xFB00 or (bfade and 0xFA00 or 0xFF00)
		local translation = isSpecialStage and "SPECIALSTAGE_SONIC3_TITLE" or nil
		local special_gp = isSpecialStage and 'S3KTTCARDSS' or 'S3KTTCARD'

		if t and t <= 3*TICRATE/2 then
			v.fadeScreen(fade, 31)
		elseif t <= 3*TICRATE/2+31 and t > 3*TICRATE/2 then
			v.fadeScreen(fade, 31-(t-3*TICRATE/2))
		end
		if t and t <= 3*TICRATE then
			if t <= TICRATE/5 then
				tryx = max($-27*FRACUNIT, 0)
				tryy = min($+27*FRACUNIT, 0)
			end
			if t >= (3*TICRATE - TICRATE/5) then
				tryx = $+27*FRACUNIT
				tryy = $-27*FRACUNIT
			end

			v.draw(69-(offset/FRACUNIT)/2, tryy/FRACUNIT-10, v.cachePatch(special_gp), 0)
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				drawf(v, 'S3KTT', 288*FRACUNIT+tryx-offset*3, 104*FRACUNIT, FRACUNIT, "ZONE", 0, v.getColormap(TC_DEFAULT, 1, translation), "right")
			end

			if act ~= "0" then
				v.draw(247+(tryx-offset*3)/FRACUNIT, 131, v.cachePatch(S3K_graphic_lvl_icon[lvlt] or 'S3KBGAIZ'), 0)
				v.draw(233+(tryx-offset*3)/FRACUNIT, 156, v.cachePatch('S3KTTACTC'), 0)
				drawf(v, 'S3KANUM', 258*FRACUNIT+tryx-offset*3, 135*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1))
			end

			v.drawString(175, 158, mapheaderinfo[gamemap].subttl, 0|V_ALLOWLOWERCASE, "center")
			drawf(v, 'S3KTT', (288-tryx)*FRACUNIT+tryx-offset*3, 72*FRACUNIT, FRACUNIT, lvlt, 0, v.getColormap(TC_DEFAULT, 1, translation), "right")

			return true
		end
	end,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x)
		if p and p.mo then
			local lifename = string.upper(''..skins[p.mo.skin].hudname)
			local lifenamelenght = 0
			for i = 1, #lifename do
				local patch, val
				lifenamelenght = $+fontlen(v, patch, lifename, 'HUS3NAM', val, 1, i)
			end

			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_S3LIFE_"..skin_name
			local patch_s_name = "STYLES_SS3LIFE_"..skin_name

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+12, v.cachePatch(patch_s_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+12, v.cachePatch(patch_name), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				v.draw(lives_x, hudinfo[HUD_LIVES].y, v.cachePatch('S3LIVBLANK1'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
				v.draw(lives_x+8, hudinfo[HUD_LIVES].y+12, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
				v.draw(lives_x, hudinfo[HUD_LIVES].y, v.cachePatch('S3LIVBLANK2'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
			end

			drawf(v, 'HUS3NAM', (lives_x+17)*FRACUNIT, (hudinfo[HUD_LIVES].y+1)*FRACUNIT, FRACUNIT, string.upper(''..skins[p.mo.skin].hudname), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), 0, 1)

			if G_GametypeUsesLives() then
				v.draw(lives_x+22, hudinfo[HUD_LIVES].y+10, v.cachePatch('S3CROSS'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
				drawf(v, 'LIF3NUM', (lives_x+17+lifenamelenght)*FRACUNIT, (hudinfo[HUD_LIVES].y+9)*FRACUNIT, FRACUNIT, (p.lives == 127 and string.char(30) or p.lives), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", 1)
			end
		end
	end,

	tallytitle = function(v, p, offsetx)
		local mo = p.mo

		local lvlt = string.upper(""..mapheaderinfo[gamemap].lvlttl)
		local act = tostring(mapheaderinfo[gamemap].actnum)

		v.draw(96-offsetx, 54, v.cachePatch("S3KPLACEHTALLY"))

		if mo and mo.valid then
			local skin = skins[p.mo.skin or p.skin]

			local skin_name = string.gsub(string.upper(skin.realname), "%d", "")
			local color_2 = v.getColormap(TC_DEFAULT, skin.prefcolor)
			local color_1 = v.getColormap(TC_DEFAULT, skin.prefoppositecolor or skincolors[skin.prefcolor].invcolor)

			drawS3KTXT(v, (158-offsetx)*FRACUNIT, 54*FRACUNIT, FRACUNIT, skin_name, 0, color_1, color_2, "right")
		else
			local skin_name = "YOU"
			local color_2 = v.getColormap(TC_DEFAULT, SKINCOLOR_WHITE)
			local color_1 = v.getColormap(TC_DEFAULT, SKINCOLOR_BLACK)

			drawS3KTXT(v, (158-offsetx)*FRACUNIT, 54*FRACUNIT, FRACUNIT, skin_name, 0, color_1, color_2, "right")
		end

		if act ~= "0" then
			v.draw(228-offsetx, 51, v.cachePatch(S3K_graphic_lvl_icon[lvlt] or 'S3KBGAIZ'), 0)
			v.draw(214-offsetx, 76, v.cachePatch('S3KTTACTC'), 0)
			drawf(v, 'S3KANUM', (239-offsetx)*FRACUNIT, 55*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1))
		end
	end,
}