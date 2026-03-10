local chaotixblock = true
local SUGOINOTLOADED = true

local OGSUGOIMAINHUD
local OGBLAST3DFUNC
local BLAST3DHUD
local SUGOIMAINHUD
local SUGOIEXITS

local ANG4 = ANG1 * 4

local getUpValue

if debug then
	getUpValue = function(func, name)
		local i = 1

		while true do
			local _name, value = debug.getupvalue(func, i)
			if not _name then return end

			if _name == name then
				return value
			end

			i = i + 1
		end
	end

	---@param v videolib 
	BLAST3DHUD = function(v, player)
		if (OGBLAST3DFUNC) and (mapheaderinfo[gamemap].threedimensionalexplosion) and gametype ~= GT_RACE then
			local area = getUpValue(OGBLAST3DFUNC, "area")

			local num = 0

			if(player.mo and player.mo.valid) then
				while(player.mo.flickies and player.mo.flickies[num] and player.mo.flickies[num].valid) do
					num = $ + 1
				end
			end

			if(gametype == GT_COMPETITION) then
				v.drawString(320-80, 200-16, "Flickies Saved:", V_SNAPTOBOTTOM|V_SNAPTORIGHT|V_YELLOWMAP, "thin")
				v.drawString(320-4, 200-8, num, V_SNAPTOBOTTOM|V_SNAPTORIGHT, "right")
			else
				local freed = (getUpValue(OGBLAST3DFUNC, "numflickiesfreed") or 0)
				local num2 = (mapheaderinfo[gamemap]["area"..area.."flickies"] or 0)
				local flickies_y = hudinfo[HUD_LIVES].y - 1
				local flickies_x = 303-hudinfo[HUD_LIVES].x

				if num2 then
					for i = 1, num2 do
						if i <= freed then
							if i <= num then
								v.draw(flickies_x, flickies_y, v.cachePatch("S3BFLBLUEBIRD"), V_SNAPTOBOTTOM|V_SNAPTORIGHT)
							else
								v.draw(flickies_x, flickies_y - (sin(leveltime * ANG4 + i * ANGLE_90) * 3)/FU, v.cachePatch("S3BFLBLUEBIRD"), V_SNAPTOBOTTOM|V_SNAPTORIGHT)
							end
						else
							v.draw(flickies_x, flickies_y, v.cachePatch("S3BFLCRAWLA"), V_SNAPTOBOTTOM|V_SNAPTORIGHT)
						end

						flickies_x = $-17
					end
				end
			end
		end
	end

	SUGOIMAINHUD = function(v, player)
		sugoi.clientrenderer = v.renderer()

		if (G_PlatformGametype()) then
			if (mapheaderinfo[gamemap].sugoicutscene) then
				v.drawFill()
				return
			end

			local drawCredits = getUpValue(OGSUGOIMAINHUD, "drawCredits")
			local drawVoting = getUpValue(OGSUGOIMAINHUD, "drawVoting")
			local drawShop = getUpValue(OGSUGOIMAINHUD, "drawShop")
			local drawHubSelect = getUpValue(OGSUGOIMAINHUD, "drawHubSelect")

			local p1 = players[0]

			if (mapheaderinfo[gamemap].creditsmap) then
				if (splitscreen) and not (player == p1) then return end
				drawCredits(v, player)
			elseif (sugoi.currentVoteInfo.voting and sugoi.hubSpot) then
				if (sugoi.cv_vote.value == -1) then return end
				if (splitscreen) and not (player == p1) then return end
				drawVoting(v, player)
			elseif (player.ui and player.ui.mode) then
				if (player.ui.mode == 1) then
					drawShop(v, player)
				elseif (player.ui.mode == 2) then
					drawHubSelect(v, player)
				end
			else
				if (sugoi.hubSpot) then
					if (player.shopitem) then
						v.drawScaled(
							16*FRACUNIT, 176*FRACUNIT,
							FRACUNIT/2,
							v.cachePatch(sugoi.shopitems[player.shopitem].livesIcon),
							V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_PERPLAYER
						);
					end

					if not Styles_IsMenuActive() then
						SUGOIEXITS(v, player)
					end
				end

				if (sugoi.currentCecho.timer and sugoi.currentCecho.text) then
					v.drawString(160, 176, sugoi.currentCecho.text, sugoi.currentCecho.flags, "center")
				end
			end
		end

		if (sugoi.clientrenderer == "opengl" and sugoi.daycycle >= 0) then
			drawOpenGLBadDayCycle(v, mapheaderinfo[gamemap].palette)
		end
	end
end

addHook("AddonLoaded", function()
	if chaotixblock and chaotix then
		local _chaotix = chaotix

		local mighty = _chaotix.mighty

		-- Scaffolding because I do not trust anything with chaotix name
		-- Give me unique mod IDs already!
		if mighty and customhud.ToggleRaws("game", "Lua/2_Mighty/mighty_memes.lua", nil, nil, nil, false) then
			chaotixblock = nil
		end
	end

	if sugoi and SUGOINOTLOADED then

		if debug then
			if BLAST3D then
				local item = customhud.ToggleRaws("game", "lua/subarashii/special/greenflowergrove.lua", nil, nil, nil, false)

				if item then
					customhud.SetupItem("Styles_Blast3DFlickies", "classichud", BLAST3DHUD, "game")

					OGBLAST3DFUNC = item[1]
					BLAST3D = nil
				end
			end

			if SUGOIMAINHUD then
				local item = customhud.ToggleRaws("game", "lua/sugoi_hud.lua", nil, nil, nil, false)

				if item then
					customhud.SetupItem("SugoiMainHud", "classichud", SUGOIMAINHUD, "gamemenu")

					OGSUGOIMAINHUD = item[1]
					SUGOIMAINHUD = nil
				end

				SUGOIEXITS = getUpValue(item[1], "drawExits")
			end
		end

		customhud.PromoteRaw("scores", "lua/sugoi_hud.lua", nil, nil, nil, "SugoiScores", "Sugoi", 32)

		SUGOINOTLOADED = nil
	end
end)