--[[

		User Interfaces inspired by Sonic Adventure 2.

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local drawlib = tbslibrary 'lib_emb_tbsdrawers'
local helper = 	tbsrequire 'helpers/c_inter'
local helper2 = tbsrequire 'helpers/lua_hud'

local convertPlayerTime = helper2.convertPlayerTime
local rank_calculator = helper.RankCounter
local font_drawer = drawlib.draw

local HOOK = customhud.SetupItem


--
-- Nulling function in case of things already done elsewhere
--

local function nullhud()
	return
end


--
-- BOSS DISPLAY
--

local Boss_found = false
local Bosses = {}

addHook("MapChange", function()
	Boss_found = false
	Bosses = {}
end)

addHook("MapThingSpawn", function(a, mt)
	if a.info.flags & MF_BOSS then
		table.insert(Bosses, a)
		Boss_found = true
	end
end)

local boss_target_hold = 0

HOOK("bossmeter", "dchud", function(v, p, t, e)
	if mapheaderinfo[gamemap].mrce_emeraldstage and mrce and mrce.emstage_attemptavailable then
		return
	end

	if Bosses and Bosses[1] and Bosses[1].valid then
		local boss = Bosses[1]

		local curhealth = boss and (boss.health and boss.health or 0) or 0
		local maxhealth = boss.info.spawnhealth or 1
		local onehealth = FixedDiv(67*FRACUNIT, maxhealth*FRACUNIT)
		local prchealth = (curhealth == 0 and 0 or (FixedMul(FixedDiv(curhealth*FRACUNIT, maxhealth*FRACUNIT), 67*FRACUNIT)))

		if (not boss.valid or curhealth < 1) and Bosses[2] then
			hud.bosshealthcountersmooth = 0

			table.remove(Bosses, 1)
		else
			if hud.bossbardecrease == nil then
				hud.bossbardecrease = 0
			end

			if not hud.bosshealthcountersmooth and (hud.bosshealth == nil or hud.bosshealth > curhealth) and hud.bossbardecrease == 0 then
				hud.bosshealthcountersmooth = hud.bosshealthcountersmooth and $+35 or 35
				hud.bosshealth = curhealth
			elseif hud.bosshealthcountersmooth ~= nil and hud.bosshealthcountersmooth > 0 then
				hud.bosshealthcountersmooth = $-1
			end

			if hud.bosshealthcountersmooth < 2 and curhealth == 0 and hud.bossbardecrease < 67*FRACUNIT then
				hud.bossbardecrease = $+3*FRACUNIT
			end
		end

		if not Bosses[1].target and not boss_target_hold then
			if Bosses[1] then
				boss_target_hold = TICRATE
			else
				return
			end
		elseif boss_target_hold then
			boss_target_hold = $ - 1

			if not Bosses[1] then
				boss_target_hold = 0
				return
			end
		end

		if hud.bossbardecrease < 67*FRACUNIT then

			v.draw(216, hudinfo[HUD_RINGS].y-28, v.cachePatch("SA2BOSSH1"), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)
			v.draw(216+(hud.bossbardecrease or 0)/FRACUNIT, hudinfo[HUD_RINGS].y-28, v.cachePatch("SA2BOSSHL"), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)
			v.draw(289, hudinfo[HUD_RINGS].y-28, v.cachePatch("SA2BOSSHR"), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)

			v.drawStretched(222*FRACUNIT+(hud.bossbardecrease or 0), (hudinfo[HUD_RINGS].y-28)*FRACUNIT, 67*FRACUNIT-(hud.bossbardecrease or 0), FRACUNIT,
			v.cachePatch("SA2BOSSH2"), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)
			v.drawStretched(222*FRACUNIT, (hudinfo[HUD_RINGS].y-20)*FRACUNIT, prchealth+(hud.bosshealthcountersmooth*onehealth)/35, FRACUNIT,
			v.cachePatch((curhealth > maxhealth/5 and "SA2BOBAR2" or "SA2BOBAR1" )), V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_PERPLAYER)

		end
	elseif Boss_found and #Bosses then
		table.sort(Bosses)
		table.remove(Bosses, 1)

		hud.bosshealthcountersmooth = 0
	end
end, "game")


--
-- MONITOR DISPLAY
--

local cv_itembox_style = CV_FindVar("dc_itemboxstyle")
local style_last_value = -1
local border_img

HOOK("monitordisplay", "dchud", function(v, p, t, e)
	if G_RingSlingerGametype() then return end

	if p.boxdisplay and p.boxdisplay.timer and p.boxdisplay.item then
		local lenght = p.boxdisplay.item
		local tic = min(3*TICRATE-p.boxdisplay.timer, TICRATE/5)*FRACUNIT/(TICRATE/5)
		local tictransparency = max(min(p.boxdisplay.timer, TICRATE/4),0)*FRACUNIT/(TICRATE/4)
		local easesubtit = ease.linear(tic, FRACUNIT/2, 9*FRACUNIT/8)
		local easetratit = ease.linear(tictransparency, 9, 0)
		local offset = 161

		if cv_itembox_style.value ~= style_last_value or border_img == nil then
			local brpic = "SA2ICONPWBORDER"

			if cv_itembox_style.value == 1 then
				brpic = "NXGICONPWBORDER"
			end

			border_img = v.cachePatch(brpic)
			style_last_value = cv_itembox_style.value
		end

		for k,img in ipairs(p.boxdisplay.item) do
			local extra = 0
			if SPR_MMON then
				extra = (img[1] == SPR_MMON and -FRACUNIT*16 or 0)
			end
			local pic = v.getSpritePatch(img[1], img[2], 0)
			local incs = pic.width+6

			local x = FixedDiv((offset-(incs*#lenght)/2+incs/2)*easesubtit, easesubtit)
			local y = FixedDiv(180*easesubtit-extra, easesubtit)
			local flags = V_PERPLAYER|(easetratit << V_ALPHASHIFT)|V_SNAPTOBOTTOM

			v.drawScaled(x, y, easesubtit, pic, flags)
			if img[3] and img[3].type and img[3].type == "ENC" then
				local enc = img[3]

				if enc.skin and enc.color then
					v.drawScaled(x, y-5*FRACUNIT, easesubtit, v.getSprite2Patch(enc.skin, SPR2_LIFE, false, A, 0), flags, v.getColormap(enc.skin, enc.color))
				end
			else
				if img[1] == SPR_TV1P and p.mo then
					v.drawScaled(x, y-5*FRACUNIT, easesubtit, v.getSprite2Patch(p.mo.skin, SPR2_LIFE, false, A, 0), flags, v.getColormap(p.mo.skin, p.mo.color))
				end
			end

			if pic.width == 24 then
				v.drawScaled(x, y, easesubtit, border_img, flags)
			end

			offset = $ + incs
		end
	end
end, "game")

--
-- CHECKPOINT TIMER
--


local poweruporiginaly = hudinfo[HUD_POWERUPS].y

HOOK("checkpointtimer", "dchud", function(v, p, t, e)
	if p.checkpointtime then
		if (leveltime % 4)/2 then
			local mint, sect, cent = convertPlayerTime(p.starposttime)

			local strint_ = mint..':'..sect

			if marathonmode then
				strint_ = $..':'..cent
			end

			font_drawer(v, 'SA2TL', (350)*FRACUNIT, (245)*FRACUNIT, FRACUNIT-FRACUNIT/4, strint_,
			V_PERPLAYER|V_SNAPTORIGHT|V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, 0), "center", 1, 0)
		end
	end

	if not hud.powerupsatic then
		hud.powerupsatic = 0
	end

	if p.checkpointtime and hudinfo[HUD_POWERUPS].y > 154 then
		hud.powerupsatic = $+2
	elseif hudinfo[HUD_POWERUPS].y < 176 and not p.checkpointtime then
		hud.powerupsatic = $-2
	end

	hudinfo[HUD_POWERUPS].y = poweruporiginaly - hud.powerupsatic
end, "game")

--
-- SCORE ADDITIVES
--

local score_add = {}

local score_graphic = {
	"SCOREADDSA21",
	"SCOREADDSA22",
	"SCOREADDSA23",
	"SCOREADDSA24",
	"SCOREADDSA25",
	"SCOREADDSA26",
	"SCOREADDSA27",
	"SCOREADDSA28",
	"SCOREADDSA29",
	"SCOREADDSA2A",
}

local score_add_current = nil
local score_add_timer = nil


rawset(_G, "dc_addscoreprompt", function(score_level)
	table.insert(score_add, {graphic = score_graphic[max(min(score_level, #score_graphic), 1)], x = 160, tics = 5*TICRATE})
end)

COM_AddCommand("dc_addfakescore", function(p, num)
	dc_addscoreprompt(tonumber(num))
end)

--addHook("MobjSpawn", function(mo)
--	if multiplayer then return end
--	mo.flags2 = $|MF2_DONTDRAW
--end, MT_SCORE)

--addHook("MobjRemoved", function(mo)
--	if multiplayer then return end
--
--	local cur = (mo.frame & FF_FRAMEMASK)
--
--	if cur > 0 then
--		score_add_current = score_add_current and $+1 or 1
--		score_add_timer = 2*TICRATE
--	end
--end, MT_SCORE)

local y_offset = 0

HOOK("scoreadditives", "dchud", function(v, p, t, e)

	-- Base Score Combos (Unrelated to SA2:Blast)

	if score_add_timer then
		score_add_timer = $ - 1

		if score_add_timer == 0 then
			dc_addscoreprompt(score_add_current or 1)

			score_add_current = nil
			score_add_timer = nil
		end
	end

	-- Gamma Support

	if p and p.valid and p.mo and p.mo.valid and p.mo.gammaVars then
		local gamma_vars = p.mo.gammaVars
		for k, prompt in ipairs(gamma_vars.bonusHud) do
			if prompt.time == 7*TICRATE/4 then
				dc_addscoreprompt(prompt.i)
			end
		end
	end

	-- Main Structure

	if score_add then
		local y = hudinfo[HUD_RINGS].y + 14 + y_offset

		for k, prompt in ipairs(score_add) do
			v.drawScaled((hudinfo[HUD_RINGS].x+12+prompt.x)*FRACUNIT, y*FRACUNIT, FRACUNIT/2, v.cachePatch(prompt.graphic), V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER)


			if prompt.x then
				prompt.x = $/2
			end

			prompt.tics = $-1
			if prompt.tics == 0 then
				y_offset = $ + 8
				table.remove(score_add, k)
			end

			y = $+8
		end

		if y_offset then
			y_offset = $ - 1
		end
	end

end, "game")

--
-- FLICKIES
--

local flickies_y = 200 - 25
local flicky_flags = V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_PERPLAYER
local flicky_scale = FRACUNIT/2

local color_flickies = {
	["flight"] = SKINCOLOR_BLUE,
	["power"] = SKINCOLOR_RED,
	["speed"] = SKINCOLOR_GREEN,
}

sfxinfo[freeslot("sfx_advaac")].caption = "Flicky Collected!"

HOOK("flickies", "dchud", function(v, p, t, e)
	if p.flickies and p.flickies.tics then
		local scale_in = max(p.flickies.tics - (TICRATE*3 - 25), 0)*FRACUNIT/25
		local move_in = max(p.flickies.tics - (TICRATE*3 - 15), 0)*FRACUNIT/15
		local move_out = min(p.flickies.tics - 10, 0)*FRACUNIT/10

		local incoming_move = min(move_in*2, FRACUNIT)

		local invx = ease.linear(incoming_move, 20, 0)
		local x = ease.linear(incoming_move - move_out, 320, 500)-35
		local base = v.cachePatch("FLICKYBASESA2")
		local movscale = 0

		for k, fl in ipairs(p.flickies) do
			if #p.flickies == k then
				movscale = scale_in
				if p.flickies.tics > (TICRATE*3 - 16) then
					continue
				elseif p.flickies.tics == (TICRATE*3 - 25) and not menuactive then
					S_StartSound(nil, sfx_advaac, p)
				end
			end

			local colorindx = 0


			if fl.data and fl.data.type then
				colorindx = color_flickies[fl.data.type] or 0
			end

			local state = states[mobjinfo[fl.mobjtype].spawnstate]
			local sprite = v.getSpritePatch(state.sprite, state.frame, 0, 0)

			v.drawScaled(x * FRACUNIT - movscale*base.width/2, flickies_y * FRACUNIT - movscale*base.height/2, flicky_scale+movscale, base, flicky_flags, v.getColormap(TC_DEFAULT, colorindx))

			v.drawScaled((x + sprite.width/3) * FRACUNIT - movscale,
			(flickies_y + sprite.height/3 + sprite.height/4) * FRACUNIT - movscale,
			flicky_scale + movscale / sprite.height,
			sprite,
			flicky_flags)

			x = $ - invx
		end

		p.flickies.tics = $-1
	end
end, "game")

--
-- RANK DISPLAY
--

HOOK("sa2forcerankdisplay", "dchud", function(v, p, t, e)
	if CV_FindVar("dc_hud_rankdisplay").value == 0 then return end

	local rank = rank_calculator(p)
	local patch = v.cachePatch("SA2RANK"..rank)

	v.draw(160, 28, patch)
	return true
end, "game")

--
--	EMERALD DISPLAY
--

local emerald = {EMERALD1, EMERALD2, EMERALD3, EMERALD4, EMERALD5, EMERALD6, EMERALD7}

HOOK("powerstones", "classichud", function(v, p, t, e)
	if not p.powers[pw_emeralds] then return end

	for i = 1, 7 do
		local em = emeralds_set[i]
		if (p.powers[pw_emeralds] & em) then
			v.draw(128 + (i-1) * 10, 192, v.cachePatch("TEMER"..i), V_SNAPTOBOTTOM)
		end
	end
end, "game")

-- random rotating rocks + add there damn 8th Peaceful Ruby.
HOOK("coopemeralds", "dchud", function(v)
	if mrce then
		return
	end

	if multiplayer then
		return false
	else
		--Off loading local variables for optimalization purposes
		local circlesplit = (360/#emerald)*ANG1
		local leveltimeang = ANGLE_225+(All7Emeralds(emeralds) and leveltime*ANG1 or 0)

		for id,k in ipairs(emerald) do
			-- IF check compares from table whenever or not emerald is in player's possession
			if emeralds & k then
				local posang = id*circlesplit+leveltimeang

				-- Cache that damn sprite
				local state = states[S_CEMG1+id-1]
				local patch = v.getSpritePatch(state.sprite, state.frame+(leveltime/state.var2 % state.var1), 0)
				v.draw((32*cos(posang)/FRACUNIT)+160, (32*sin(posang)/FRACUNIT)+100, patch, V_20TRANS|V_PERPLAYER)
			end
		end
	end
	return true
end, "scores")


--
-- NUlLING
--

HOOK("gammaBonus", "dchud", nullhud, "game")
