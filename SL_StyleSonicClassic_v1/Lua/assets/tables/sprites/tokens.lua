local token_sonic_r = freeslot("S_TOKEN_SONICR")

local token_sonic_origins = freeslot("S_TOKEN_ORIGINS")

local token_sonic_3dblast = freeslot("S_TOKEN_3DBLAST")

states[token_sonic_r] = {
	sprite = freeslot("SPR_TOKEN_SONICR"),
	frame = A|FF_ANIMATE|FF_SEMIBRIGHT,
	tics = 20,
	var1 = 19,
	var2 = 1,
	nextstate = token_sonic_r,
}

states[token_sonic_origins] = {
	sprite = freeslot("SPR_TOKEN_SONICORIGINS"),
	frame = A|FF_ANIMATE|FF_SEMIBRIGHT,
	tics = 20,
	var1 = 19,
	var2 = 1,
	nextstate = token_sonic_origins,
}

states[token_sonic_3dblast] = {
	sprite = freeslot("SPR_TOKEN_3B"),
	frame = A|FF_ANIMATE|FF_SEMIBRIGHT,
	tics = 40,
	var1 = 39,
	var2 = 1,
	nextstate = token_sonic_3dblast,
}


return {
	[0] = {{S_TOKEN, 		FRACUNIT}, 		"vanilla", 	"Vanilla"},
	{{token_sonic_3dblast, 	FRACUNIT/4},	"b3d",		"Sonic 3D Blast"},
	{{token_sonic_r, 		FRACUNIT/3},	"sonicr", 	"Sonic R"},
	{{token_sonic_origins, 	FRACUNIT/3},	"origins", 	"Sonic Origins"},
}