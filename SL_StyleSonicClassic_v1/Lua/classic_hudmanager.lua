local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawf = drawlib.draw
local fontlen = drawlib.lenght
local HOOK = customhud.SetupItem

local hud_select = 1
local lifeicon = 1
local prefix = "S1"

--
--	External HUDs
--

local hud_data = {
	[1] = tbsrequire('gui/classic_sonic1'),
	[2] = tbsrequire('gui/classic_sonic2'),
	[3] = tbsrequire('gui/classic_soniccd'),
	[4] = tbsrequire('gui/classic_sonic3'),
}

--
--	CVARs
--

local lif_cv = CV_RegisterVar{
	name = "classic_lifeicon",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		local set = {1, 3, 4}
		lifeicon = set[var.value]
	end,
	PossibleValue = {sonic1=1, soniccd=2, sonic3=3}
}

local font_cv = CV_RegisterVar{
	name = "classic_hudfont",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		local prefixes = {"S1", "ST", "S3"}
		prefix = prefixes[var.value]
	end,
	PossibleValue = {sonic1=1, sonic2=2, sonic3=3}
}

local hud_cv = CV_RegisterVar{
	name = "classic_hud",
	defaultvalue = "sonic1",
	flags = CV_CALL,
	func = function(var)
		local prefixes = {1, 2, 1, 3}
		CV_Set(font_cv, prefixes[var.value])

		local lives = {1, 1, 2, 3}
		CV_Set(lif_cv, lives[var.value])

		hud_select = var.value
	end,
	PossibleValue = {sonic1=1, sonic2=2, soniccd=3, sonic3=4}
}

local debugmode_coordinates = CV_RegisterVar({
	name = "classic_debug",
	defaultvalue = "0",
	flags = 0,
	PossibleValue = {Full = 2, Plane = 1, Off = 0},
})

--
--	HUD Elements
--

HOOK("lives", "classichud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	hud_data[lifeicon].lives(v, p, t, e)
	return true
end, "game")

HOOK("score", "classichud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	v.draw(hudinfo[HUD_SCORE].x, hudinfo[HUD_SCORE].y, v.cachePatch(prefix..'TSCORE'), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER)

	if debugmode_coordinates.value then
		-- Debug Mode
		local bitf = FRACUNIT
		local pvx, pvy = abs(p.mo.x/bitf)/4, abs(p.mo.y/bitf)/4
		local cvx, cvy = abs(t.x/bitf)/4, abs(t.y/bitf)/4

		local xval = hudinfo[HUD_SCORE].x+32

		if debugmode_coordinates.value == 2 then
			local pvz, cvz = abs(p.mo.z/bitf)/4, abs(t.z/bitf)/4

			drawf(v, 'S3DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y-1)*FRACUNIT, FRACUNIT,
			string.upper(string.format("%04x%04x%04x", pvx, pvy, pvz)), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "left")
			drawf(v, 'S3DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y+7)*FRACUNIT, FRACUNIT,
			string.upper(string.format("%04x%04x%04x", cvx, cvy, cvz)), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "left")
		else
			drawf(v, 'S3DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y-1)*FRACUNIT, FRACUNIT,
			string.upper(string.format("%04x%04x", pvx, pvy)), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "left")
			drawf(v, 'S3DBM', xval*FRACUNIT, (hudinfo[HUD_SCORE].y+7)*FRACUNIT, FRACUNIT,
			string.upper(string.format("%04x%04x", cvx, cvy)), hudinfo[HUD_SCORE].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "left")
		end
	else
		drawf(v, prefix..'TNUM', hudinfo[HUD_SCORENUM].x*FRACUNIT, hudinfo[HUD_SCORENUM].y*FRACUNIT, FRACUNIT, p.score, hudinfo[HUD_SCORENUM].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right")
	end

	return true
end, "game")

HOOK("time", "classichud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy
	local mint = G_TicsToMinutes(p.realtime, true)
	local sect = G_TicsToSeconds(p.realtime)
	local cent = G_TicsToCentiseconds(p.realtime)
	sect = (sect < 10 and '0'..sect or sect)
	cent = (cent < 10 and '0'..cent or cent)


	v.draw(hudinfo[HUD_TIME].x, hudinfo[HUD_TIME].y, v.cachePatch(prefix..'TTIME'), hudinfo[HUD_TIME].f|V_HUDTRANS|V_PERPLAYER)
	drawf(v, prefix..'TNUM', hudinfo[HUD_SECONDS].x*FRACUNIT, hudinfo[HUD_SECONDS].y*FRACUNIT, FRACUNIT, mint..":"..sect, hudinfo[HUD_SECONDS].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right")
	return true
end, "game")

HOOK("rings", "classichud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	v.draw(hudinfo[HUD_RINGS].x, hudinfo[HUD_RINGS].y, v.cachePatch(prefix..'TRINGS'), hudinfo[HUD_RINGS].f|V_HUDTRANS|V_PERPLAYER)
	drawf(v, prefix..'TNUM', hudinfo[HUD_RINGSNUM].x*FRACUNIT, hudinfo[HUD_RINGSNUM].y*FRACUNIT, FRACUNIT, p.rings, hudinfo[HUD_RINGSNUM].f|V_HUDTRANS|V_PERPLAYER, v.getColormap(TC_DEFAULT, 1), "right")
	return true
end, "game")

HOOK("stagetitle", "classichud", function(v, p, t, e)
	if (maptol & TOL_NIGHTS) then return end
	if skins["modernsonic"] then return end	-- whyyyy

	hud_data[hud_select].titlecard(v, p, t, e)
	return true
end, "titlecard")