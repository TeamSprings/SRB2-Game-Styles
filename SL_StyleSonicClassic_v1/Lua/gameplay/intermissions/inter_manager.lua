local InterCalc = tbsrequire('helpers/c_inter')
local Options = tbsrequire('helpers/create_cvar')

local common = tbsrequire('gameplay/intermissions/inter_common')

local module = {}

local INTER_COOP = 1
local INTER_BOSS = 2
local INTER_SPEC = 3
local INTER_MATC = 4

module.types = {
    [INTER_COOP] = tbsrequire('gameplay/intermissions/types/inter_coop'),
    [INTER_BOSS] = tbsrequire('gameplay/intermissions/types/inter_boss'),
    [INTER_SPEC] = tbsrequire('gameplay/intermissions/types/inter_spec'),
    [INTER_MATC] = tbsrequire('gameplay/intermissions/types/inter_coop'),
}

function module:type()
    local specialstage = G_IsSpecialStage(gamemap)

    local gametype = gametyperules

    if gametype & GTR_CAMPAIGN or gametype & GTR_SPECIALSTAGES then
        if specialstage then
            return INTER_SPEC
        else
            if mapheaderinfo[gamemap].bonustype > 0 then
                return INTER_BOSS
            else
                return INTER_COOP
            end
        end
    elseif gametype & GTR_RACE or gametype & GTR_TAG then
        return INTER_MATC
    else
        return 0
    end
end

function module:check()
    if self:type() == 0 or modeattacking or marathonmode then
        return false
    end

    return true
end

function module:counterWipe(p)
    if not p.styles_tallytype then
        p.styles_tallytype = self:type()
    end

    local funcs = module.types[p.styles_tallytype] or module.types[INTER_COOP]

    funcs.counterWipe(p)
end

function module:counterThink(p)
    if not p.styles_tallytype then
        p.styles_tallytype = self:type()
    end

    local funcs = module.types[p.styles_tallytype] or module.types[INTER_COOP]

    funcs.counterThink(p)
end

function module:counterSetup(p)
    if not p.styles_tallytype then
        p.styles_tallytype = self:type()
    end

    local funcs = module.types[p.styles_tallytype] or module.types[INTER_COOP]

    common:cleanUp(p)
    funcs.counterSetup(p)
end

function module:think(p)
    if not p.styles_tallytype then
        p.styles_tallytype = self:type()
    end

    local funcs = module.types[p.styles_tallytype] or module.types[INTER_COOP]

    if funcs.think then
        funcs.think(p)
    end
end

function module:draw(v, p, t, e)
    if not p.styles_tallytype then
        p.styles_tallytype = self:type()
    end

    local funcs = module.types[p.styles_tallytype] or module.types[INTER_COOP]

    if funcs.setupDraw and p.styles_tallytimer == -93 then
        funcs.setupDraw(v, p)
    end

    funcs.draw(v, p, t, e)
end

function module:setup(p)
    p.styles_tallytype = self:type()
    local funcs = module.types[p.styles_tallytype] or module.types[INTER_COOP]

    p.styles_tallytimer = funcs.tallyStart
    p.styles_tallylastscore = p.score
    p.styles_tallylastlives = p.lives
    p.exiting = 5

    p.powers[pw_invulnerability] = 0
    p.powers[pw_sneakers] = 0
    p.powers[pw_extralife] = 0
    p.powers[pw_super] = 0

    p.styles_tallyfakecounttimer = funcs:duration(p)
    p.styles_tallyendtime = p.styles_tallyfakecounttimer + funcs.tallyHoldover
    p.styles_tallyspeed = funcs.calculationSpeed
    p.styles_tallyingameadditive = funcs.addScoreInGameMethod

    local getTrack = funcs:music()

    S_StopMusic(p)
    S_ChangeMusic(getTrack, false, p, 0, 0, 0, 0)
    --p.styles_lasttrack = nil
    p.styles_tallytrack = getTrack
    p.styles_tallyposms = 0
    p.styles_tallystoplooping = nil
    p.styles_tallysoundlenght = S_GetMusicLength() or 0

    if p.styles_capsule_exit then
        p.styles_capsule_exit = nil
    else
        p.mo.flags = $|MF_NOCLIPTHING
    end

    self:counterSetup(p)
end

function module:sumScore(p)
    if not p.styles_tallytype then
        p.styles_tallytype = self:type()
    end

    local funcs = module.types[p.styles_tallytype] or module.types[INTER_COOP]

    return funcs.calculateALL(p)
end

function module:restScore(p)
    if not p.styles_tallytype then
        p.styles_tallytype = self:type()
    end

    local funcs = module.types[p.styles_tallytype] or module.types[INTER_COOP]

    return funcs.calculateALL(p) - max(p.score - p.styles_tallylastscore, 0)
end

return module