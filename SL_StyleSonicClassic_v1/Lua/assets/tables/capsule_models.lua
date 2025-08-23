local TRPPF_CHANGE 	= 1
local TRPPF_POOF 	= 2
local TRPPF_HEADLOW = 4
local TRPPF_HEADTOP = 8
local TRPPF_DISOLVE = 16
local TRPPF_NOSOLID = 32

local TRAP_LENGHTEXPL = 2*TICRATE

freeslot("SPR_CAPSULE_S2", "SPR_CAPSULE_CD")

local S3K_SPR = freeslot("SPR_CAPSULE_S3K")

local function P_RegisterMultiPart(
	source,
	dist,
	angle,
	frame,
	trflags,
	trchange,
	iterations,
	angleincrement,
	frameincrement,
	framemodulo,
    changeoffsetbool
)
	local framincrm = frameincrement == nil and 1 or frameincrement
	local frammodul = framemodulo == nil and 512 or framemodulo

	local anglincrm = angleincrement == nil and FixedAngle(360*FU/iterations) or angleincrement

	local _dist = dist or 0
	local _angle = angle or 0
	local _frame = frame or 0
	local _trflags = trflags or 0
	local _trchange = trchange or 0

	for i = 1, iterations do
		local _i = (i - 1)
		local iangle = _angle + anglincrm * _i
		local papers = iangle + ANGLE_90
        local offset = (framincrm * _i)

        if frammodul then
            offset = $ % frammodul
        end

		table.insert(source, {
			x = _dist * cos(iangle),
			y = _dist * sin(iangle),
			z = 0,
			dist = dist,
			angle = papers,
			frame = _frame + offset,
			trflags = _trflags,
			trchange = _trchange + (changeoffsetbool and offset or 0)
		})
	end
end

local function P_RegisterMultiPartT(table)
	P_RegisterMultiPart(
		table.source,
		table.dist,
		table.angle,
		table.frame,
		table.trflags,
		table.trchange,
		table.iterations,
		table.angleincrement,
		table.frameincrement,
		table.framemodulo,
        table.changeoffsetbool
	)
end

--
-- SONIC 2 CAPSULE
--

local SONIC2_MODEL = {
	sprite = SPR_CAPSULE_S2,
	destroytics = 3*TRAP_LENGHTEXPL/2,

	-- Body
	{
		frame = 7,
		trflags = TRPPF_CHANGE,
		trchange = 16
	},

	-- Button Stem
	{
		frame = 12,
		trflags = TRPPF_HEADLOW,
		trigger = 2,
		z = 112*FU,
		revz = 128*FU
	},

	-- Button Plate - Paper Sprite Floor
	{
		z = 121*FU,
		frame = 24|FF_FLOORSPRITE,
		trflags = TRPPF_HEADTOP,
	},

	-- Body Plate - Paper Sprite Floor
	{
		z = 73*FU,
		frame = 15|FF_FLOORSPRITE,
	},
}

-- Outside
P_RegisterMultiPartT{
	source           = SONIC2_MODEL,
	dist             = 46,
	angle            = 0,
	frame            = 0|FF_PAPERSPRITE,
	trflags          = TRPPF_CHANGE,
	trchange         = 17|FF_PAPERSPRITE,
	iterations       = 8,
	angleincrement   = nil,
	frameincrement   = 1,
	framemodulo      = 7,
    changeoffsetbool = true,
}

-- Supports
P_RegisterMultiPartT{
	source           = SONIC2_MODEL,
	dist             = 30,
	angle            = 0,
	frame            = 8,
	trflags          = 0,
	trchange         = nil,
	iterations       = 4,
	angleincrement   = ANGLE_90,
	frameincrement   = 0,
	framemodulo      = 1,
    changeoffsetbool = nil,
}

-- Button
P_RegisterMultiPartT{
	source           = SONIC2_MODEL,
	dist             = 26,
	angle            = 0,
	frame            = 13|FF_PAPERSPRITE,
	trflags          = TRPPF_HEADTOP,
	trchange         = nil,
	iterations       = 8,
	angleincrement   = nil,
	frameincrement   = 1,
	framemodulo      = 2,
    changeoffsetbool = nil,
}

-- Lights
P_RegisterMultiPartT{
	source           = SONIC2_MODEL,
	dist             = 40,
	angle            = 0,
	frame            = 9|FF_PAPERSPRITE,
	trflags          = 0,
	trchange         = nil,
	iterations       = 8,
	angleincrement   = nil,
	frameincrement   = 0,
	framemodulo      = 1,
    changeoffsetbool = nil,
}

--
-- SONIC CD CAPSULE
--

local SONICCD_MODEL = {
	sprite = SPR_CAPSULE_CD,
	destroytics = 4*TRAP_LENGHTEXPL/3,

	-- Stem
	{
		trflags = TRPPF_NOSOLID,
		frame   = A|FF_TRANS20,

		width   = 24*FU,
		height  = 49*FU,
	},

	-- Head
	{
		frame   = B,
		trflags = TRPPF_DISOLVE,
		trigger = 3,

		z       = 57*FU,
		radius  = 70*FU,
		height  = 85*FU,
	}
}

--
-- SONIC 3 CAPSULE
--

local SONIC3_MODEL = {
	sprite = S3K_SPR,
	destroytics = TRAP_LENGHTEXPL,

	-- Body
	{
		frame = 4,
		trflags = TRPPF_CHANGE,
		trchange = 13
	},

	-- Button Stem
	{
		frame = 9,
		trflags = TRPPF_HEADLOW,
		trigger = 2,
		z = 112*FU,
		revz = 128*FU
	},

	-- Button Plate - Paper Sprite Floor
	{
		z = 121*FU,
		frame = 15|FF_FLOORSPRITE,
		trflags = TRPPF_HEADTOP,
	},
}

-- Outside
P_RegisterMultiPartT{
	source           = SONIC3_MODEL,
	dist             = 46,
	angle            = 0,
	frame            = 0|FF_PAPERSPRITE,
	trflags          = TRPPF_POOF,
	trchange         = nil,
	iterations       = 8,
	angleincrement   = nil,
	frameincrement   = 1,
	framemodulo      = 4,
    changeoffsetbool = nil,
}

-- Supports
P_RegisterMultiPartT{
	source           = SONIC3_MODEL,
	dist             = 30,
	angle            = 0,
	frame            = 5,
	trflags          = 0,
	trchange         = nil,
	iterations       = 4,
	angleincrement   = ANGLE_90,
	frameincrement   = 0,
	framemodulo      = 0,
    changeoffsetbool = nil,
}

-- Button
P_RegisterMultiPartT{
	source           = SONIC3_MODEL,
	dist             = 26,
	angle            = 0,
	frame            = 10|FF_PAPERSPRITE,
	trflags          = TRPPF_HEADTOP,
	trchange         = nil,
	iterations       = 8,
	angleincrement   = nil,
	frameincrement   = 1,
	framemodulo      = 2,
    changeoffsetbool = nil,
}

-- Metal Balls
P_RegisterMultiPartT{
	source           = SONIC3_MODEL,
	dist             = 48,
	angle            = 0,
	frame            = 6,
	trflags          = TRPPF_POOF,
	trchange         = nil,
	iterations       = 12,
	angleincrement   = nil,
	frameincrement   = 0,
	framemodulo      = 0,
    changeoffsetbool = nil,
}

-- Contraptions
P_RegisterMultiPartT{
	source           = SONIC3_MODEL,
	dist             = 48,
	angle            = -ANGLE_45,
	frame            = 7,
	trflags          = TRPPF_CHANGE,
	trchange         = 14,
	iterations       = 2,
	angleincrement   = nil,
	frameincrement   = 0,
	framemodulo      = 0,
    changeoffsetbool = nil,
}

-- Contraptions
P_RegisterMultiPartT{
	source           = SONIC3_MODEL,
	dist             = 52,
	angle            = -ANGLE_45,
	frame            = 8,
	trflags          = 0,
	trchange         = 0,
	iterations       = 2,
	angleincrement   = nil,
	frameincrement   = 0,
	framemodulo      = 0,
    changeoffsetbool = nil,
}

return {
    SONIC2_MODEL,
    SONICCD_MODEL,
    SONIC3_MODEL
}
