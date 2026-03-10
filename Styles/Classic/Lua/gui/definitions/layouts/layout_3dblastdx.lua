return {
    score = true,
    time = true,
    rings = true,

    scoregraphic = false,
    timegraphic = false,
    ringsgraphic = true,

    debugalligment = "right",
    scorenumalligment = "right",
    timenumalligment = "left",
    ringsnumalligment = "right",

    scoreflags = hudinfo[HUD_SCORE].f|V_SNAPTORIGHT &~ V_SNAPTOLEFT,
    timeflags = hudinfo[HUD_TIME].f,
    ringsflags = hudinfo[HUD_RINGS].f,

    xoffset_score = 0,
    xoffset_time = 0,
    xoffset_rings = 0,

    yoffset_score = -1,
    yoffset_time = 3,
    yoffset_rings = -33,

    xoffset_debugnum = 256,
    xoffset_scorenum = 186,
    xoffset_timenum = -104,
    xoffset_ringsnum = -17,

    yoffset_scorenum = 0,
    yoffset_timenum = 0,
    yoffset_ringsnum = 0,

    score_move_dir = -1,
    time_move_dir = 1,
    rings_move_dir = 1,

    rings_padds_symb = nil,
    rings_padds_numb = nil,

    force_ticspos = true,

    score_relative_leftbound = 0,
    time_relative_leftbound = 0,
    rings_relative_leftbound = 0,
}