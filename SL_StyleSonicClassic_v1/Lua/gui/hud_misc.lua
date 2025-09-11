
local Options = tbsrequire 'helpers/create_cvar'
local color_profile = tbsrequire 'gui/hud_colors'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local fonts = tbsrequire('gui/hud_fonts')

local HOOK = customhud.SetupItem
local write = drawlib.draw

local emeralds_set = {
	EMERALD1,
	EMERALD2,
	EMERALD3,
	EMERALD4,
	EMERALD5,
	EMERALD6,
	EMERALD7,
}

local emeraldpos_opt = Options:new("emeraldpos",
	{
		{nil, "vanilla",   	"Vanilla"},
		{nil, "finaldemo",  "Final Demo"},
	},
nil, 0, 5)

local emeraldanim_opt = Options:new("emeraldanim",
	{
		{nil, "tally",   	"Classic Tally"},
		{nil, "full",  		"Classic Full"},
		{nil, "retro",  	"Retro Engine"},
	},
nil, 0, 5)

HOOK("powerstones", "classichud", function(v, p, t, e)
    if not p.powers[pw_emeralds] then return end

    for i = 1, 7 do
        local em = emeralds_set[i]
        if (p.powers[pw_emeralds] & em) then
            v.draw(128 + (i-1) * 10, 192, v.cachePatch("TEMER"..i), V_SNAPTOBOTTOM)
        end
    end
end, "game", 1, 3)


HOOK("coopemeralds", "classichud", function(v)
    if mrce then
        return
    end

    if not (G_GametypeUsesCoopStarposts() and G_GametypeUsesCoopLives()) then return end

    if multiplayer then
        for i = 1, 7 do
            local em = emeralds_set[i]
            if (emeralds & em) then
                if i > 4 then
                    v.draw(28 + ((i-3) * 14), 14, v.cachePatch("TEMER"..i), V_SNAPTOLEFT)
                else
                    v.draw(36 + (i * 14), 6, v.cachePatch("TEMER"..i), V_SNAPTOLEFT)
                end
            end
        end
    else

        local sprite = Options:getPureValue("emeralds")

        local cv = emeraldpos_opt.cv
        local num = cv.value

        local animcv = emeraldanim_opt.cv
        local val = animcv.value or 1

        if (val == 2 and ((leveltime % 8)/4)) or val ~= 2 then
            local colormap = v.getColormap(TC_DEFAULT, 0, val > 2
            and ("RETROENGINE_CLASSICEM_ANIM" .. min(abs((leveltime/2 % 7) - 4) + 1, 4)) or nil)

            if num == 2 then -- final demo
                for i = 1, 7 do
                    if emeralds & emeralds_set[i] then
                        v.draw(50+i*30, 115, v.getSpritePatch(sprite, i-1, 0, 0), 0, colormap)
                    end
                end
            else
                local BASEVIDWIDTH = 160
                local BASEVIDHEIGHT = 67
                local firstem = v.getSpritePatch(sprite, 0, 0, 0)

                local x = -firstem.width+firstem.leftoffset
                local y = -firstem.height+firstem.topoffset

                if (emeralds & EMERALD1) then
                    v.draw(BASEVIDWIDTH-8-x, BASEVIDHEIGHT-32-y, firstem, 0, colormap)
                end

                if (emeralds & EMERALD2) then
                    v.draw(BASEVIDWIDTH-8+24-x, BASEVIDHEIGHT-16-y, v.getSpritePatch(sprite, 1, 0, 0), 0, colormap)
                end

                if (emeralds & EMERALD3) then
                    v.draw(BASEVIDWIDTH-8+24-x, BASEVIDHEIGHT+16-y, v.getSpritePatch(sprite, 2, 0, 0), 0, colormap)
                end

                if (emeralds & EMERALD4) then
                    v.draw(BASEVIDWIDTH-8-x, BASEVIDHEIGHT+32-y, v.getSpritePatch(sprite, 3, 0, 0), 0, colormap)
                end

                if (emeralds & EMERALD5) then
                    v.draw(BASEVIDWIDTH-8-24-x, BASEVIDHEIGHT+16-y, v.getSpritePatch(sprite, 4, 0, 0), 0, colormap)
                end

                if (emeralds & EMERALD6) then
                    v.draw(BASEVIDWIDTH-8-24-x, BASEVIDHEIGHT-16-y, v.getSpritePatch(sprite, 5, 0, 0), 0, colormap)
                end

                if (emeralds & EMERALD7) then
                    v.draw(BASEVIDWIDTH-8-x, BASEVIDHEIGHT-y, v.getSpritePatch(sprite, 6, 0, 0), 0, colormap)
                end
            end
        end
    end

    return true
end, "scores", 1, 3)

local em_timer = 0

---@param v videolib
HOOK("intermissionemeralds", "classichud", function(v)
    if not (maptol & TOL_NIGHTS) then return end
    local sprite = Options:getPureValue("emeralds")
    local cv = emeraldanim_opt.cv
    local val = cv.value or 1

    if (val < 3 and em_timer/2) or val > 2 then
        local colormap = v.getColormap(TC_DEFAULT, 0, val > 2
        and ("RETROENGINE_CLASSICEM_ANIM" .. min(abs(em_timer/2 - 4) + 1, 4)) or nil)

        for i = 1, 7 do
            if emeralds & emeralds_set[i] then
                v.draw(50+i*30, 92, v.getSpritePatch(sprite, i-1, 0, 0), 0, colormap)
            end
        end
    end

    em_timer = (em_timer+1) % (val > 2 and 14 or 4)
    return true
end, "intermission", 1, 3)

    
local emblemsprites = {
    [0] = "EMBVANILLA",
    [1] = "EMBCLASSIC",
    [2] = "EMBSONICR"
}

HOOK("tabemblems", "classichud", function(v)
    if not numemblems then return end -- 2.2.16 or no emblems

    if menu_toggle then return end

    if not (G_GametypeUsesCoopStarposts() and G_GametypeUsesCoopLives()) then return end

    local cv = Options:getCV("emblems")[1]
    local value = emblemsprites[cv and cv.value or 0] or "EMBVANILLA"
    local total = (numemblems or 0)+(numextraemblems or 0)

    if total < 1 then return end

    local x = 253
    local y = 29
    local flags = V_SNAPTORIGHT

    if multiplayer then
        x = 167
        y = 6
    else
        flags = $|V_SNAPTOTOP
    end

    v.draw(x, y, v.cachePatch(value), flags)

    x = ($ + 27) * FU
    y = ($ + 1) * FU

    write(v, 'LIFENUM', x, y, FU, emblems, flags, v.getColormap(TC_DEFAULT, 0, color_profile.numbers), "left", 1)

    y = $ + 7 * FU

    write(v, 'LIFENUM', x, y, FU, "/"..total, flags, v.getColormap(TC_DEFAULT, 0, color_profile.numbers), "left", 1)
end, "scores", 1, 3)

local tokensprites = {
    [0] = "TOKVANILLA",
    [1] = "TOK3DBLAST",
    [2] = "TOKSONICR",
    [3] = "TOKORIGINS",
}

HOOK("tokens", "classichud", function(v)
    if menu_toggle then return end
    if not token then return end

    if not (G_GametypeUsesCoopStarposts() and G_GametypeUsesCoopLives()) then return end

    local x = 257
    local y = 48
    local flags = 0

    if multiplayer then
        x = 124
        y = 6
        
        if not numemblems then
            x = 167
        end
    elseif not numemblems then
        y = 29
        flags = $|V_SNAPTOTOP|V_SNAPTORIGHT
    else
        flags = $|V_SNAPTOTOP|V_SNAPTORIGHT
    end

    local cv = Options:getCV("tokensprite")[1]
    local value = tokensprites[cv and cv.value or 0] or "TOKVANILLA"

    v.draw(x, y, v.cachePatch(value), flags)

    x = ($ + 23) * FU
    y = ($ + 5) * FU

    write(v, 'LIFENUM', x, y, FU, token, flags, v.getColormap(TC_DEFAULT, 0, color_profile.numbers), "left", 1)
end, "scores", 1, 3)

HOOK("pause", "classichud", function(v)
    if not paused then return end

    v.draw(160, 100, v.cachePatch(fonts.font..'TPAUSE'), 0)
end, "system", 1, 3)

HOOK("gameover", "classichud", function(v, player)
    if not player.deadtimer then return end

    if not ((G_GametypeUsesLives() or ((gametyperules & (GTR_RACE|GTR_LIVES)) == GTR_RACE)) and player.lives <= 0) then return end

    local countdown = false
    local tics = 0

    -- tics recalculation
    if (gametyperules & GTR_TIMELIMIT) and timelimit then
        tics = max(60*timelimit*TICRATE - player.realtime, 0)
        countdown = true
    elseif mapheaderinfo[gamemap].countdown then
        tics = tonumber(mapheaderinfo[gamemap].countdown) - player.realtime
        countdown = true
    end

    local ease = ease.linear(min(player.deadtimer * FU / (gameovertics/3), FU), 500, 0)

    if countdown and tics < 2 then
        v.draw(160 - ease, 100, v.cachePatch(fonts.font..'TGOTIME'), 0)
    else
        v.draw(160 - ease, 100, v.cachePatch(fonts.font..'TGOGAME'), 0)
    end

    v.draw(160 + ease, 100, v.cachePatch(fonts.font..'TGOOVER'), 0)
end, "game", 1, 3)
