return {
	[1] = {
		score = true,
		time = true,
		rings = true,

		scoregraphic = true,
		timegraphic = true,
		ringsgraphic = true,

		debugalligment = "left",
		scorenumalligment = "right",
		timenumalligment = "right",
		ringsnumalligment = "right",

		scoreflags = hudinfo[HUD_SCORE].f,
		timeflags = hudinfo[HUD_TIME].f,
		ringsflags = hudinfo[HUD_RINGS].f,

		xoffset_score = 0,
		xoffset_time = 0,
		xoffset_rings = 0,

		yoffset_score = 0,
		yoffset_time = 0,
		yoffset_rings = 0,

		xoffset_debugnum = 0,
		xoffset_scorenum = 0,
		xoffset_timenum = 0,
		xoffset_ringsnum = 0,

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
	},

	[2] = {
		score = true,
		time = true,
		rings = true,

		scoregraphic = true,
		timegraphic = true,
		ringsgraphic = true,

		debugalligment = "left",
		scorenumalligment = "right",
		timenumalligment = "right",
		ringsnumalligment = "right",

		scoreflags = hudinfo[HUD_SCORE].f,
		timeflags = hudinfo[HUD_TIME].f,
		ringsflags = hudinfo[HUD_RINGS].f,

		xoffset_score = 0,
		xoffset_time = 0,
		xoffset_rings = 0,

		yoffset_score = 0,
		yoffset_time = 0,
		yoffset_rings = 0,

		xoffset_debugnum = 0,
		xoffset_scorenum = -8,
		xoffset_timenum = -8,
		xoffset_ringsnum = -8,

		yoffset_scorenum = 0,
		yoffset_timenum = 0,
		yoffset_ringsnum = 0,

		score_move_dir = 1,
		time_move_dir = 1,
		rings_move_dir = 1,

		rings_padds_symb = nil,
		rings_padds_numb = nil,

		score_relative_leftbound = 8,
		time_relative_leftbound = 1,
		rings_relative_leftbound = 8,
	},	

	[3] = {
		score = false,
		time = false,
		rings = true,

		scoregraphic = true,
		timegraphic = true,
		ringsgraphic = true,

		debugalligment = "left",
		scorenumalligment = "right",
		timenumalligment = "right",
		ringsnumalligment = "right",

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
		xoffset_ringsnum = 0,

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
	},

	[4] = {
		score = false,
		time = false,
		rings = true,

		scoregraphic = true,
		timegraphic = true,
		ringsgraphic = true,

		debugalligment = "left",
		scorenumalligment = "right",
		timenumalligment = "right",
		ringsnumalligment = "right",

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
		xoffset_ringsnum = -17,	

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
	},

	[5] = {
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
	},

	[6] = {
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
	},

	[7] = {
		score = false,
		time = true,
		rings = true,

		scoregraphic = false,
		timegraphic = false,
		ringsgraphic = true,

		ringsgraphiccustom = "MSGGHUDRING",
		redringsgraphiccustom = "MSGGHUDRING",

		debugalligment = "left",
		scorenumalligment = "left",
		timenumalligment = "left",
		ringsnumalligment = "left",

		scoreflags = hudinfo[HUD_SCORE].f,
		timeflags = hudinfo[HUD_TIME].f,
		ringsflags = hudinfo[HUD_RINGS].f,

		xoffset_score = 0,
		xoffset_time = 0,
		xoffset_rings = -2,

		yoffset_score = -8,
		yoffset_time = -8,
		yoffset_rings = -40,

		xoffset_debugnum = 0,
		xoffset_scorenum = -80,
		xoffset_timenum = -80,
		xoffset_ringsnum = -62,	

		yoffset_scorenum = 0,
		yoffset_timenum = 0,
		yoffset_ringsnum = 2,

		score_move_dir = 1,
		time_move_dir = 1,
		rings_move_dir = 1,

		rings_padds_symb = "0",
		rings_padds_numb = 2,

		force_ticspos = false,

		score_relative_leftbound = 0,
		time_relative_leftbound = 0,
		rings_relative_leftbound = 0,	
	},

	[8] = {
		score = false,
		time = false,
		rings = true,

		scoregraphic = false,
		timegraphic = false,
		ringsgraphic = true,

		ringsgraphiccustom = "MSGGHUDRING",
		redringsgraphiccustom = "MSGGHUDRING",

		debugalligment = "left",
		scorenumalligment = "left",
		timenumalligment = "left",
		ringsnumalligment = "left",

		scoreflags = hudinfo[HUD_SCORE].f,
		timeflags = hudinfo[HUD_TIME].f,
		ringsflags = hudinfo[HUD_RINGS].f,

		xoffset_score = 0,
		xoffset_time = 0,
		xoffset_rings = -2,

		yoffset_score = -8,
		yoffset_time = -8,
		yoffset_rings = -40,

		xoffset_debugnum = 0,
		xoffset_scorenum = -80,
		xoffset_timenum = -80,
		xoffset_ringsnum = -62,	

		yoffset_scorenum = 0,
		yoffset_timenum = 0,
		yoffset_ringsnum = 2,

		score_move_dir = 1,
		time_move_dir = 1,
		rings_move_dir = 1,

		rings_padds_symb = "0",
		rings_padds_numb = 2,

		score_relative_leftbound = 0,
		time_relative_leftbound = 0,
		rings_relative_leftbound = 0,	
	},

	[9] = {
		score = true,
		time = true,
		rings = true,

		scoregraphic = false,
		timegraphic = false,
		ringsgraphic = false,

		debugalligment = "left",
		scorenumalligment = "left",
		timenumalligment = "left",
		ringsnumalligment = "left",

		scoreflags = hudinfo[HUD_SCORE].f,
		timeflags = hudinfo[HUD_TIME].f,
		ringsflags = hudinfo[HUD_RINGS].f,

		xoffset_score = 0,
		xoffset_time = 0,
		xoffset_rings = 0,

		yoffset_score = 0,
		yoffset_time = 0,
		yoffset_rings = 0,

		xoffset_debugnum = 0,
		xoffset_scorenum = -104,
		xoffset_timenum =  -104,
		xoffset_ringsnum = -80,	

		yoffset_scorenum = 0,
		yoffset_timenum = 0,
		yoffset_ringsnum = 0,

		score_move_dir = 1,
		time_move_dir = 1,
		rings_move_dir = 1,

		rings_padds_symb = nil,
		rings_padds_numb = nil,

		force_ticspos = true,

		score_relative_leftbound = 0,
		time_relative_leftbound = 0,
		rings_relative_leftbound = 0,	
	},

	[10] = {
		score = false,
		time = true,
		rings = true,

		scoregraphic = false,
		timegraphic = false,
		ringsgraphic = false,

		debugalligment = "left",
		scorenumalligment = "left",
		timenumalligment = "left",
		ringsnumalligment = "left",

		scoreflags = hudinfo[HUD_SCORE].f,
		timeflags = hudinfo[HUD_TIME].f,
		ringsflags = hudinfo[HUD_RINGS].f,

		xoffset_score = 0,
		xoffset_time = 0,
		xoffset_rings = 0,

		yoffset_score = 0,
		yoffset_time = -16,
		yoffset_rings = -16,

		xoffset_debugnum = 0,
		xoffset_scorenum = -80,
		xoffset_timenum = -104,
		xoffset_ringsnum = -80,

		yoffset_scorenum = 0,
		yoffset_timenum = 0,
		yoffset_ringsnum = 0,

		score_move_dir = 1,
		time_move_dir = 1,
		rings_move_dir = 1,

		rings_padds_symb = nil,
		rings_padds_numb = nil,
		
		force_ticspos = true,

		score_relative_leftbound = 0,
		time_relative_leftbound = 0,
		rings_relative_leftbound = 0,	
	},
}