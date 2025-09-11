return {
    score = false,
    time = true,
    rings = true,

    debugalligment = "left",
    scorenumalligment = "right",
    timenumalligment = "right",
    ringsnumalligment = "right",

    scoregraphic = true,
    timegraphic = true,
    ringsgraphic = true,

    scoreflags = hudinfo[HUD_SCORE].f,
    timeflags = hudinfo[HUD_TIME].f,
    ringsflags = hudinfo[HUD_RINGS].f,

    xoffset_score = 0,
    xoffset_time = 0,
    xoffset_rings = 0,

    yoffset_score = 0,
    yoffset_time = 0,
    yoffset_rings = -33,

    xoffset_debugnum = 0,
    xoffset_scorenum = 0,
    xoffset_timenum = 0,
    xoffset_ringsnum = 24,

    yoffset_scorenum = 0,
    yoffset_timenum = 0,
    yoffset_ringsnum = 0,

    score_move_dir = 1,
    time_move_dir = 1,
    rings_move_dir = 1,

    rings_padds_symb = nil,
    rings_padds_numb = nil,

    score_relative_leftbound = 0,
    time_relative_leftbound = 0,
    rings_relative_leftbound = 0,
}