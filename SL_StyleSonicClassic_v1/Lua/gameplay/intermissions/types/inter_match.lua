local Options = tbsrequire('helpers/create_cvar')
local Rankings = tbsrequire 'gui/leaderboards/lead_render'
local BGdraw = tbsrequire 'helpers/draw_nonstrechbackground'

local inter = {
	ID = "match",
	addScoreInGameMethod = false,
	calculationSpeed = 0,
	tallyStart = -20,
	tallyHoldover = 2*TICRATE,
}

function inter:music()
    return "_INTER"
end

function inter.counterSetup(player)
	return
end

function inter.calculateALL(player)
	return 0
end

function inter.counterWipe(player)
    return
end

function inter.counterThink(player)
	return
end

function inter:duration(player)
    return 8*TICRATE
end

local player1_color = nil
local player2_color = nil

function inter.setupDraw(v, player)
	return
end

function inter.draw(v, player, t, e)

    local flags = 0

    if player.styles_tallytimer < 0 then
        flags = (-max(min(player.styles_tallytimer, 0), -20)/2) << V_ALPHASHIFT
    end

    BGdraw(v, v.cachePatch("SRB2BACK"), flags)
    Rankings(v, 0, 0, false, flags)
    v.draw(160, 9, v.cachePatch('STYLESMATCHRESULT'), flags|V_SNAPTOTOP)
end

return inter