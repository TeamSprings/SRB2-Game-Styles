local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

rawset(_G, "S3K_graphic_lvl_icon", {
	assign = function(self, zone_name, gfx)
		self[zone_name] = gfx
	end,
	["GREENFLOWER"] = 	"S3KBGGFZ";
	["TECHNO HILL"] = 	"S3KBGTHZ";
	["DEEP SEA"] = 		"S3KBGDSZ";
	["CASTLE EGGMAN"] = "S3KBGCEZ";
	["ARID CANYON"] = 	"S3KBGACZ";
	["RED VOLCANO"] = 	"S3KBGRVZ";
	["EGG ROCK"] 	= 	"S3KBGEGZ";
	["BLACK CORE"] 	= 	"S3KBGEGZ";
})

if S3K_graphic_lvl_icon then
	S3K_graphic_lvl_icon:assign("ANGEL ISLAND", "S3KBGAIZ")
	S3K_graphic_lvl_icon:assign("GREEN HILL", "S3KBGGHZ")
end

local tryx, tryy = 0, 0

return{

	titlecard = function(v, p, t, e)
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
		if t and t <= 3*TICRATE/2 then
			v.fadeScreen(0xFF00, 31)
		elseif t <= 3*TICRATE/2+31 and t > 3*TICRATE/2 then
			v.fadeScreen(0xFF00, 31-(t-3*TICRATE/2))
		end
		if t and t <= 3*TICRATE then
			if t <= TICRATE/5 then
				tryx = $-27*FRACUNIT
				tryy = $+27*FRACUNIT
			end
			if t >= (3*TICRATE - TICRATE/5) then
				tryx = $+27*FRACUNIT
				tryy = $-27*FRACUNIT
			end

			v.draw(69-(offset/FRACUNIT)/2, tryy/FRACUNIT-10, v.cachePatch('S3KTTCARD'), 0)
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then
				drawf(v, 'S3KTT', 288*FRACUNIT+tryx-offset*3, 104*FRACUNIT, FRACUNIT, "ZONE", 0, v.getColormap(TC_DEFAULT, 1), "right")
			end

			if act ~= "0" then
				v.draw(247+(tryx-offset*3)/FRACUNIT, 131, v.cachePatch(S3K_graphic_lvl_icon[lvlt] or 'S3KBGAIZ'), 0)
				v.draw(233+(tryx-offset*3)/FRACUNIT, 156, v.cachePatch('S3KTTACTC'), 0)
				drawf(v, 'S3KANUM', 258*FRACUNIT+tryx-offset*3, 135*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1))
			end

			v.drawString(175, 158, mapheaderinfo[gamemap].subttl, 0|V_ALLOWLOWERCASE, "center")
			drawf(v, 'S3KTT', (288-tryx)*FRACUNIT+tryx-offset*3, 72*FRACUNIT, FRACUNIT, lvlt, 0, v.getColormap(TC_DEFAULT, 1), "right")

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

			v.draw(lives_x, hudinfo[HUD_LIVES].y, v.cachePatch('S3LIVBLANK1'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
			v.draw(lives_x+22, hudinfo[HUD_LIVES].y+10, v.cachePatch('S3CROSS'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
			v.draw(lives_x+8, hudinfo[HUD_LIVES].y+12, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
			v.draw(lives_x, hudinfo[HUD_LIVES].y, v.cachePatch('S3LIVBLANK2'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)

			drawf(v, 'HUS3NAM', (lives_x+17)*FRACUNIT, (hudinfo[HUD_LIVES].y+1)*FRACUNIT, FRACUNIT, string.upper(''..skins[p.mo.skin].hudname), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), 0, 1)
			drawf(v, 'LIF3NUM', (lives_x+17+lifenamelenght)*FRACUNIT, (hudinfo[HUD_LIVES].y+9)*FRACUNIT, FRACUNIT, (p.lives == 127 and string.char(30) or p.lives), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", 1)
		end
	end,

	tallytitle = function(v, p, offsetx)
		local mo = p.mo

		local lvlt = string.upper(""..mapheaderinfo[gamemap].lvlttl)
		local act = tostring(mapheaderinfo[gamemap].actnum)

		v.draw(96-offsetx, 54, v.cachePatch("S3KPLACEHTALLY"))

		if act ~= "0" then
			v.draw(228-offsetx, 52, v.cachePatch(S3K_graphic_lvl_icon[lvlt] or 'S3KBGAIZ'), 0)
			v.draw(214-offsetx, 77, v.cachePatch('S3KTTACTC'), 0)
			drawf(v, 'S3KANUM', (239-offsetx)*FRACUNIT, 56*FRACUNIT, FRACUNIT, act, 0, v.getColormap(TC_DEFAULT, 1))
		end
	end,
}