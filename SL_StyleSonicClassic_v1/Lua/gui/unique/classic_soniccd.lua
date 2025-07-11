--[[

	Sonic CD TItle Card contributed by Clone Fighter

	Sonic CD HUD by Skydusk

Contributors: Clone Fighter, Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local drawBG = tbsrequire 'helpers/draw_background'
local drawf = drawlib.draw
local fontlen = drawlib.lenght

local ttlnum = {}

--
--	Title card by Clone Fighter
--

------------------------------
-- // PREPARATION
-- These are just handy functions

local function interpolate(x, y, per) -- Thank you, Neon
    local d = y - x
    d = FixedMul(d, per)
    return x + d
end

local function V_LevelActNumWidth(num, ttlnum) -- Ported from v_video.c, required for the function below
	local result = 0;

	if num == 0 then
		result = ttlnum[num].width
	end
	while num > 0 and num <= 99 do
		result = result + ttlnum[num%10].width+2
		num = num/10
	end

	return result
end

local function V_DrawLevelActNum(v, x, y, num, ttlnum) -- Also ported from v_video.c
	if num > 99 then
		return -- Numbers > 99 not supported
	end

	while num > 0 do
		if num > 9 then -- If there are two digits, draw second digit first
			v.draw(x + (V_LevelActNumWidth(num, ttlnum) - V_LevelActNumWidth(num%10, ttlnum)), y, ttlnum[num%10])
		else
			v.draw(x, y, ttlnum[num])
		end
		num = num/10;
	end
end

local function V_DrawTitle(v, x, y, str, flags)
	drawf(v, 'LCDFT', x*FU, y*FU, FU, str, flags, v.getColormap(TC_DEFAULT, 1), "left")
end

local function V_GetLenght(v, str)
	local lenght = 0
	for i = 1, #str do
		local patch, val
		lenght = $+fontlen(v, patch, str, 'LCDFT', val, 1, i)
	end
	return lenght
end

------------------------------
-- // ACTUAL TITLECARD CODE

return{

	titlecard = function(v, player, tctime, etime, fade)
		if tctime > etime-1 then return end
		if player == secondarydisplayplayer then return end -- remove this once adjusted

		if #ttlnum == 0 then
			for i = 0, 9 do -- preparing ttllnum
				ttlnum[i] = v.cachePatch("CDTTL"..i)
			end
		end

		local gear = v.cachePatch("LTCDACTBLU")

		---@diagnostic disable-next-line
		if mapheaderinfo[gamemap].levelflags & LF_WARNINGTITLE then
			gear = v.cachePatch("LTCDACTRED")
		end

		local back = v.cachePatch("LTCDBACK")
		local iii = v.cachePatch("LTCDLINE")
		local zonegr = v.cachePatch("LTCDZONE")

		-- Level title thing
		local superstr = ""
		local substr1 = ""
		local substr2 = ""
		if string.find(mapheaderinfo[gamemap].lvlttl, " ") then
			local found = string.find(mapheaderinfo[gamemap].lvlttl, " ")
			superstr = string.sub(mapheaderinfo[gamemap].lvlttl, 1, found)
			substr1 = string.sub(mapheaderinfo[gamemap].lvlttl, found+1, found+1)
			substr2 = string.sub(mapheaderinfo[gamemap].lvlttl, found+2, string.len(mapheaderinfo[gamemap].lvlttl))
		else
			superstr = mapheaderinfo[gamemap].lvlttl
		end
		local totalsubstr = substr1..substr2

		if tctime < 10 then -- Slide in
			local fractime = tctime*FU/10

			v.draw(30, interpolate(-168, 0, fractime), back, V_SNAPTOTOP)

			v.drawFill(-500, interpolate(131, 250, FU-fractime), 9999, 9, 31|V_SNAPTOTOP)
			local subttl = "Sonic Robo Blast CD"

			if mapheaderinfo[gamemap].subttl ~= "" then
				v.drawString(interpolate(-v.stringWidth(mapheaderinfo[gamemap].subttl), 63, fractime), interpolate(132, 251, FU-fractime),
				mapheaderinfo[gamemap].subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
			else
				local gpatch = v.cachePatch("LTCDGAME")

				v.draw(interpolate(-gpatch.width, 63, fractime), interpolate(132, 251, FU-fractime), gpatch, V_SNAPTOTOP)
			end

			if mapheaderinfo[gamemap].subttl ~= "" then subttl = mapheaderinfo[gamemap].subttl end
			v.drawString(interpolate(-v.stringWidth(subttl), 63, fractime), interpolate(132, 251, FU-fractime),
			subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")

			V_DrawTitle(v, interpolate(-V_GetLenght(v, superstr), 40, fractime), 80, superstr, V_SNAPTOTOP)
			V_DrawTitle(v, interpolate(40, 400, FU-fractime), 136, substr1, V_SNAPTOTOP)
			V_DrawTitle(v, interpolate(40, 400, FU-fractime)+V_GetLenght(v, substr1), 104, substr2, V_SNAPTOTOP)

			local iiiW = 142
			if V_GetLenght(v, superstr) > 102 then
				iiiW = 142 + V_GetLenght(v, superstr) - 102
			elseif V_GetLenght(v, totalsubstr) > 102 then
				iiiW = 142 + V_GetLenght(v, totalsubstr) - 102
			end
			v.draw(interpolate(iiiW, iiiW+360, FU-fractime), 80, iii, V_SNAPTOTOP)

			if mapheaderinfo[gamemap].actnum ~= 0 then v.draw(142, interpolate(150, 320, FU-fractime), gear) end
			
			---@diagnostic disable-next-line
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then v.draw(interpolate(-48, 104, fractime), 147, zonegr) end
			
			if mapheaderinfo[gamemap].actnum ~= 0 then
				local actw = 142
				if mapheaderinfo[gamemap].actnum/10 > 0 then
					actw = 134
				end
				V_DrawLevelActNum(v, actw, interpolate(150, 320, FU-fractime), mapheaderinfo[gamemap].actnum, ttlnum)
			end

			return true
		elseif tctime >= etime-1 then
			v.drawString(-999, -999, "Zone") -- Draw nothing to hide it

			return true
		elseif tctime > etime-11 then -- Slide out
			local fractime = (etime-tctime-1)*FU/10

			v.draw(30, interpolate(-168, 0, fractime), back, V_SNAPTOTOP)

			v.drawFill(-500, interpolate(-10, 131, fractime), 9999, 9, 31|V_SNAPTOTOP)

			if mapheaderinfo[gamemap].subttl ~= "" then
				v.drawString(interpolate(63, 184, FU-fractime), interpolate(-10, 131, fractime),
				mapheaderinfo[gamemap].subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
			else
				v.draw(interpolate(63, 184, FU-fractime), interpolate(-10, 131, fractime), v.cachePatch("LTCDGAME"), V_SNAPTOTOP)
			end

			V_DrawTitle(v, interpolate(40, 400, FU-fractime), 80, superstr, V_SNAPTOTOP)
			V_DrawTitle(v, interpolate(-V_GetLenght(v, totalsubstr), 40, fractime), 136, substr1, V_SNAPTOTOP)
			V_DrawTitle(v, interpolate(-V_GetLenght(v, totalsubstr), 40, fractime)+V_GetLenght(v, substr1), 104, substr2, V_SNAPTOTOP)

			local iiiW = 142
			if V_GetLenght(v, superstr) > 102 then
				iiiW = 142 + V_GetLenght(v, superstr) - 102
			elseif V_GetLenght(v, totalsubstr) > 102 then
				iiiW = 142 + V_GetLenght(v, totalsubstr) - 102
			end
			v.draw(interpolate(iiiW, iiiW+360, FU-fractime), 80, iii, V_SNAPTOTOP)

			if mapheaderinfo[gamemap].actnum ~= 0 then v.draw(142, interpolate(150, 320, FU-fractime), gear) end
			
			---@diagnostic disable-next-line
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then v.draw(interpolate(104, 320, FU-fractime), 147, zonegr) end
			
			if mapheaderinfo[gamemap].actnum ~= 0 then
				local actw = 142
				if mapheaderinfo[gamemap].actnum/10 > 0 then
					actw = 134
				end
				V_DrawLevelActNum(v, actw, interpolate(150, 320, FU-fractime), mapheaderinfo[gamemap].actnum, ttlnum)
			end

			return true
		else -- Main loop
			v.draw(30, 0, back, V_SNAPTOTOP)

			v.drawFill(-500, 131, 9999, 9, 31|V_SNAPTOTOP)

			if mapheaderinfo[gamemap].subttl ~= "" then
				v.drawString(63, 132,
				mapheaderinfo[gamemap].subttl, V_SNAPTOTOP|V_ALLOWLOWERCASE, "thin")
			else
				v.draw(63, 132, v.cachePatch("LTCDGAME"), V_SNAPTOTOP)
			end

			V_DrawTitle(v, 40, 80, superstr, V_SNAPTOTOP)
			V_DrawTitle(v, 40, 136, substr1, V_SNAPTOTOP)
			V_DrawTitle(v, 40+V_GetLenght(v, substr1), 104, substr2, V_SNAPTOTOP)

			local iiiW = 142
			if V_GetLenght(v, superstr) > 102 then
				iiiW = 142 + V_GetLenght(v, superstr) - 102
			elseif V_GetLenght(v, totalsubstr) > 102 then
				iiiW = 142 + V_GetLenght(v, totalsubstr) - 102
			end
			v.draw(iiiW, 80, iii, V_SNAPTOTOP)

			if mapheaderinfo[gamemap].actnum ~= 0 then v.draw(142, 150, gear) end

			---@diagnostic disable-next-line
			if not (mapheaderinfo[gamemap].levelflags & LF_NOZONE) then v.draw(104, 147, zonegr) end
			
			if mapheaderinfo[gamemap].actnum ~= 0 then
				local actw = 142
				if mapheaderinfo[gamemap].actnum/10 > 0 then
					actw = 134
				end
				V_DrawLevelActNum(v, actw, 150, mapheaderinfo[gamemap].actnum, ttlnum)
			end

			return true
		end
	end,

	lives = function(v, p, t, e, prefix, mo, hide_offset_x, colorprofile, overwrite, lifepos)
		if p and p.mo then
			local curtm = 0 --StyleCD_Timetravel.timeline
			local pos = {{1,0}, {0,1}, {-1,0}, {0,-1}}

			local skin_name = string.upper(skins[p.mo.skin].name)
			local patch_name = "STYLES_CDLIFE_"..skin_name
			local patch_s_name = "STYLES_SCDLIFE_"..skin_name

			local lives_f = hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER
			local lives_x = hudinfo[HUD_LIVES].x+hide_offset_x
			local lives_y = hudinfo[HUD_LIVES].y

			if lifepos > 1 then
				lives_f = ($|V_SNAPTORIGHT|V_SNAPTOTOP) &~ (V_SNAPTOLEFT|V_SNAPTOBOTTOM)
				lives_x = 281-hudinfo[HUD_LIVES].x-hide_offset_x
				lives_y = 184-hudinfo[HUD_LIVES].y
			end

			if v.patchExists(patch_s_name) and p.powers[pw_super] then
				v.draw(lives_x+8, lives_y+11, v.cachePatch(patch_s_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
			elseif v.patchExists(patch_name) then
				v.draw(lives_x+8, lives_y+11, v.cachePatch(patch_name), lives_f, v.getColormap(TC_DEFAULT, p.mo.color))
			else
				for i = 1, 4 do
					v.draw((lives_x+8+pos[i][1]), (lives_y+11+pos[i][2]), v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|(curtm == 0 and V_FLIP or 0), v.getColormap(TC_ALLWHITE))
				end
				v.draw(lives_x+8, lives_y+11, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), lives_f|(curtm == 0 and V_FLIP or 0), v.getColormap(TC_DEFAULT, p.mo.color))
			end

			if G_GametypeUsesLives() then
				local x_p = v.cachePatch(prefix..'XLIFE')
				local x_py = max(x_p.height - 8, 0)/2

				v.draw(lives_x+17, lives_y + 7 - x_py, x_p, lives_f, colorprofile)
				drawf(v, prefix..'TNUM', (lives_x+25)*FU, (lives_y + 4 - x_py)*FU, FU, p.lives, lives_f, colorprofile, "left")
			elseif G_TagGametype() and (p.pflags & PF_TAGIT) then
				v.draw(lives_x+22, lives_y, v.cachePatch('CLASSICIT'), lives_f)
			end

			--v.drawScaled((lives_x+9)*FU, (hudinfo[HUD_LIVES].y+7)*FU, FU/2, v.cachePatch('TIMEPER'..curtm) or v.cachePatch("TIMEPER0"), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS)
			--v.drawScaled((lives_x+60)*FU, (hudinfo[HUD_LIVES].y)*FU, FU/2, v.cachePatch("TTPER0"..curtm), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS)
		end
	end,

	tallyspecialbg = function(v, p, offsetx, color, color2, fading)
		drawBG(v, v.cachePatch("CDTSPECBG"), 0, nil)
	end,

	-- TODO: CREATE CD TALLY TITLE - Font, graphic etc.
	--[[
	tallytitle = function(v, p, offsetx)
		local mo = p.mo

		local lvlt = string.upper(""..mapheaderinfo[gamemap].lvlttl)
		local act = tostring(mapheaderinfo[gamemap].actnum)

		v.draw(96-offsetx, 54, v.cachePatch("S3KPLACEHTALLY"))

		if mo and mo.valid then
			local skin = skins[p.mo.skin or p.skin]

			local skin_name = nametrim(string.upper(skin.realname), "%d", "")
			local color_2 = v.getColormap(TC_DEFAULT, skin.prefcolor)
			local color_1 = v.getColormap(TC_DEFAULT, skin.prefoppositecolor or skincolors[skin.prefcolor].invcolor)

			--drawf(v, (158-offsetx)*FU, 54*FU, FU, skin_name, 0, color_1, color_2, "right")
		else
			local skin_name = "YOU"
			local color_2 = v.getColormap(TC_DEFAULT, SKINCOLOR_WHITE)
			local color_1 = v.getColormap(TC_DEFAULT, SKINCOLOR_BLACK)

			--drawf(v, (158-offsetx)*FU, 54*FU, FU, skin_name, 0, color_1, color_2, "right")
		end

		if act ~= "0" then
			v.draw(228-offsetx, 51, v.cachePatch(S3K_graphic_lvl_icon[lvlt] or 'S3KBGAIZ'), 0)
			v.draw(214-offsetx, 76, v.cachePatch('S3KTTACTC'), 0)
			drawf(v, 'S3KANUM', (239-offsetx)*FU, 55*FU, FU, act, 0, v.getColormap(TC_DEFAULT, 1))
		end
	end,

	tallyspecial = function(v, p, offsetx, color, color2)
		local mo = p.mo
		local act = tostring(mapheaderinfo[gamemap].actnum)

		local str = "CHAOS EMERALDS"

		if emeralds == All7Emeralds(emeralds) then
			str = " GOT THEM ALL"

			if mo then
				str = string.upper(mo.skin)..str
			else
				str = "YOU"..str
			end
		end

		--drawS3KTXT(v, 160*FU, 48*FU, FU, str, 0, v.getColormap(TC_DEFAULT, SKINCOLOR_GREEN), v.getColormap(TC_DEFAULT, SKINCOLOR_BLUE), "center")
	end,
	--]]
}