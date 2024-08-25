local objtyperings = {MT_RING, MT_COIN, MT_NIGHTSSTAR, MT_RING_BOX}
local mapnumrings = 0

addHook("MapLoad", function()
	mapnumrings = 0
	for rings in mobjs.iterate() do
		mapnumrings = $+1
	end
end)

local debugmode_coordinates = CV_RegisterVar({
	name = "S3_CordinatesDebug",
	defaultvalue = "0",
	flags = 0,
	PossibleValue = {Full = 2, Plane = 1, Off = 0},
})

local IT_STRING = 32
local IT_PATCH = 16
local IT_CVAR = 8
local IT_HEADER = (1+48+128)

local function P_ScrollXHudLayer(v, x, y, patch, flags, colormap, slowdown)
	v.draw(x+((leveltime/slowdown) % patch.width), y, patch, flags, colormap)
	v.draw(x+patch.width+((leveltime/slowdown) % patch.width), y, patch, flags, colormap)
	v.draw(x-patch.width+((leveltime/slowdown) % patch.width), y, patch, flags, colormap)
end



local function P_S3KSphereHud(v, p, c)
	v.draw(232, 28, v.cachePatch('S3KSSHU1'), V_SNAPTOTOP)
	v.draw(29, 28, v.cachePatch('S3KSSHU2'), V_SNAPTOTOP)
	TBSlib.fontdrawer(v, 'S3KSSNU', 34*FRACUNIT, 32*FRACUNIT, FRACUNIT, sphereplayer.spheres, V_SNAPTOTOP, v.getColormap(TC_DEFAULT, 1), 0, 2, 3)
	TBSlib.fontdrawer(v, 'S3KSSNU', 258*FRACUNIT, 32*FRACUNIT, FRACUNIT, sphereplayer.rings, V_SNAPTOTOP, v.getColormap(TC_DEFAULT, 1), 0, 2, 3)
end

local function P_S3KLivesHud(v, p)
	local lifename = string.upper(''..skins[p.mo.skin].hudname)
	local lifenamelenght = 0
	for i = 1, #lifename do
		local patch, val
		lifenamelenght = $+TBSlib.fontlenghtcal(v, patch, lifename, 'HUS3NAM', val, 1, i)
	end


	v.draw(hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y, v.cachePatch('S3LIVBLANK1'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)
	v.draw(hudinfo[HUD_LIVES].x+22, hudinfo[HUD_LIVES].y+10, v.cachePatch('S3CROSS'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)


	--v.drawScaled((hudinfo[HUD_LIVES].x+16)*FRACUNIT, hudinfo[HUD_LIVES].y*FRACUNIT, FRACUNIT/2, v.getSprite2Patch(p.mo.skin, SPR2_XTRA, (p.powers[pw_super] and true or false), A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
	--v.drawCropped((hudinfo[HUD_LIVES].x+8)*FRACUNIT, (hudinfo[HUD_LIVES].y+13)*FRACUNIT, FRACUNIT, FRACUNIT, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color), 0, FRACUNIT, 16*FRACUNIT, 14*FRACUNIT)
	v.draw(hudinfo[HUD_LIVES].x+8, hudinfo[HUD_LIVES].y+12, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), hudinfo[HUD_LIVES].f|V_FLIP|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, p.mo.color))
	v.draw(hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y, v.cachePatch('S3LIVBLANK2'), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER)


	TBSlib.fontdrawer(v, 'HUS3NAM', (hudinfo[HUD_LIVES].x+17)*FRACUNIT, (hudinfo[HUD_LIVES].y+1)*FRACUNIT, FRACUNIT, string.upper(''..skins[p.mo.skin].hudname), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), 0, 1)
	TBSlib.fontdrawer(v, 'LIFENUM', (hudinfo[HUD_LIVES].x+17+lifenamelenght)*FRACUNIT, (hudinfo[HUD_LIVES].y+9)*FRACUNIT, FRACUNIT, (p.lives == 127 and string.char(30) or p.lives), hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right", 1)
end

local function P_TallyS3KHud(v, p, t, e)





end

local originringy =	hudinfo[HUD_RINGS].y
local originringny = hudinfo[HUD_RINGSNUM].y

local function P_DrawDebugScore(v, p, c, zbool)
	local bitf = FRACUNIT
	local pvx, pvy = abs(p.mo.x/bitf)/4, abs(p.mo.y/bitf)/4
	local cvx, cvy = abs(c.x/bitf)/4, abs(c.y/bitf)/4

	local xval = hudinfo[HUD_SCORE].x+32

	if zbool then
		local pvz, cvz = abs(p.mo.z/bitf)/4, abs(c.z/bitf)/4

		TBSlib.fontdrawer(v, 'S3DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y-1)*FRACUNIT, FRACUNIT,
		string.upper(string.format("%04x%04x%04x", pvx, pvy, pvz)), hudinfo[HUD_SCORE].f, v.getColormap(TC_DEFAULT, 1), "left")
		TBSlib.fontdrawer(v, 'S3DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y+7)*FRACUNIT, FRACUNIT,
		string.upper(string.format("%04x%04x%04x", cvx, cvy, cvz)), hudinfo[HUD_SCORE].f, v.getColormap(TC_DEFAULT, 1), "left")
	else
		TBSlib.fontdrawer(v, 'S3DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y-1)*FRACUNIT, FRACUNIT,
		string.upper(string.format("%04x%04x", pvx, pvy)), hudinfo[HUD_SCORE].f, v.getColormap(TC_DEFAULT, 1), "left")
		TBSlib.fontdrawer(v, 'S3DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y+7)*FRACUNIT, FRACUNIT,
		string.upper(string.format("%04x%04x", cvx, cvy)), hudinfo[HUD_SCORE].f, v.getColormap(TC_DEFAULT, 1), "left")
	end

end


hud.add(function(v, p, c)
	if mapheaderinfo[gamemap].s3bonusmode then
		hud.disable("time")
		hud.disable("score")
		hud.disable("lives")

		hudinfo[HUD_RINGS].y = hudinfo[HUD_SCORE].y
		hudinfo[HUD_RINGSNUM].y = hudinfo[HUD_SCORENUM].y
		P_S3KLivesHud(v, p)
	-- global variable about to be changed

	elseif sphereplayer.active then
		hud.disable("score")
		hud.disable("time")
		hud.disable("rings")
		hud.disable("lives")

		P_S3KSphereHud(v, p, c)
	else
		hud.enable("time")
		hud.enable("score")
		hud.disable("lives")

		if debugmode_coordinates.value or (p.mo and p.mo.state == S_OBJPLACE_DUMMY) then
			hud.disable("score")
			v.draw(hudinfo[HUD_SCORE].x, hudinfo[HUD_SCORE].y, v.cachePatch("STTSCORE"), hudinfo[HUD_SCORE].f)
			P_DrawDebugScore(v, p, c, debugmode_coordinates.value > 1 and true or false)
		end

		hudinfo[HUD_RINGS].y = originringy
		hudinfo[HUD_RINGSNUM].y = originringny
		P_S3KLivesHud(v, p)
	end

	if p.pflags & PF_FINISHED then
		P_TallyS3KHud(v, p, l, e)
	end

end, "game")


rawset(_G, "S3K_graphic_lvl_icon", {
	assign = function(self, zone_name, gfx)
		self[zone_name] = gfx
	end,
	["GREENFLOWER"] = 	"S3KBGGFZ";
	["TECHNO HILL"] = 	"S3KBGTHZ";
	["DEEP SEA"] = 		"S3KBGDSZ";
	["CASTLE EGGMAN"] = "S3KBGCEZ";
})

if S3K_graphic_lvl_icon then
	S3K_graphic_lvl_icon:assign("ANGEL ISLAND", "S3KBGAIZ")
	S3K_graphic_lvl_icon:assign("GREEN HILL", "S3KBGGHZ")
end

local tryx, tryy = 0, 0

hud.add(function(v, p, t, e)
	hud.disable("stagetitle")
	local lvlt = string.upper(""..mapheaderinfo[gamemap].lvlttl)
	local act = mapheaderinfo[gamemap].actnum
	--local scale = FRACUNIT
	local offset = (lvlt == "BONUS STAGE" and (#lvlt)*FRACUNIT/2*3 or (#lvlt)*FRACUNIT)
	if t < 3 then
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
		if not mapheaderinfo[gamemap].s3bonusmode then
			v.draw(69-(offset/FRACUNIT)/2, 8+tryy/FRACUNIT, v.cachePatch('S3KTTCARD'))
			if mapheaderinfo[gamemap].levelflags &~ LF_NOZONE and mapheaderinfo[gamemap].subttl == "" then
				TBSlib.fontdrawer(v, 'S3KTT', 288*FRACUNIT+tryx-offset*3, 104*FRACUNIT, FRACUNIT, "ZONE", 0, v.getColormap(TC_DEFAULT, 1), "right")
			elseif mapheaderinfo[gamemap].subttl ~= "" then
				TBSlib.fontdrawer(v, 'S3KTT', 302*FRACUNIT+tryx-offset*3, 104*FRACUNIT, FRACUNIT, string.upper(""..mapheaderinfo[gamemap].subttl), 0, v.getColormap(TC_DEFAULT, 1), "right")
			end
			if act ~= 0 then
				v.draw(247+(tryx-offset*3)/FRACUNIT, 131, v.cachePatch(S3K_graphic_lvl_icon[lvlt] or 'S3KBGAIZ'))
				v.draw(233+(tryx-offset*3)/FRACUNIT, 156, v.cachePatch('S3KTTACTC'))
				TBSlib.fontdrawer(v, 'S3KANUM', 258*FRACUNIT+tryx-offset*3, 135*FRACUNIT, FRACUNIT, ''..act, 0, v.getColormap(TC_DEFAULT, 1))
			end
		end
		TBSlib.fontdrawer(v, 'S3KTT', 288*FRACUNIT+tryx-offset*3, 72*FRACUNIT, FRACUNIT, lvlt, 0, v.getColormap(TC_DEFAULT, 1), "right")
	end



end, "titlecard")

