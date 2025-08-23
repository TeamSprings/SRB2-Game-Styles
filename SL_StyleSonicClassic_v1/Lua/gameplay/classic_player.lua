--[[

		Player-object related additions

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local Options = tbsrequire('helpers/create_cvar')
local slope_handler = tbsrequire 'helpers/mo_slope'

--
--	Options
--

local spindash_opt = Options:new("spindash", "gameplay/cvars/spindash", nil, CV_NETVAR)

local springtwirl_opt = Options:new("springtwirl", "gameplay/cvars/springtwirl", nil, CV_NETVAR)

local springtwalk_opt = Options:new("springairwalk", "gameplay/cvars/springairwalk", nil, CV_NETVAR)

local springtroll_opt = Options:new("springroll", "gameplay/cvars/springroll", nil, CV_NETVAR)

local thok_opt = Options:new("thok", "gameplay/cvars/thok", nil, CV_NETVAR)

local grounding_opt = Options:new("groundrot", "gameplay/cvars/groundrot", nil, CV_NETVAR)

local nightrot_opt = Options:new("nightsrot", "gameplay/cvars/nightsrot", nil, CV_NETVAR)

local momentum_opt = Options:new("momentum", {{false, "disable", "Disabled"}, {true, "enable", "Enabled"}}, nil, CV_NETVAR)

local runonwater_opt = Options:new("runonwater", {{false, "disable", "Disabled"}, {true, "enable", "Enabled"}}, nil, CV_NETVAR)

local preserveshield_opt = Options:new("preserveshield", {{nil, "disable", "Disabled"}, {1, "managed", "Managed"}, {2, "zone", "Zone only"}, {3, "always", "Always"}}, nil, CV_NETVAR)

local jumpsounds_opt = Options:new("jumpsfx", "gameplay/sfx/jumpsfx", nil, 0)

local spinsounds_opt = Options:new("spinsfx", "gameplay/sfx/spinsfx", nil, 0)

local dashsounds_opt = Options:new("dashsfx", "gameplay/sfx/dashsfx", nil, 0)

--
--	Cvars
--

local spindash_cv = spindash_opt.cv

local springtwirl_cv = springtwirl_opt.cv

local springtwalk_cv = springtwalk_opt.cv

local springtroll_cv = springtroll_opt.cv

local thok_cv = thok_opt.cv

--
--  RUN ON WATER
--

local ronw_state = freeslot('S_STYLES_RUNONWATER')
local ronw_sprite = freeslot('SPR_WATERRUN_S3')
local ronw_angle = ANG1 * 20

states[ronw_state] = {
	sprite = ronw_sprite,
	frame = 0|FF_PAPERSPRITE|FF_ANIMATE|FF_ADD|FF_TRANS20,
	var1 = 4,
	var2 = 2,
}

--
--	Thinker
--

local lastzone

addHook("PlayerSpawn", function(p)
	if not (gametyperules & GTR_FRIENDLY) then return end
	if (G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS)) then return end

	local preservation = preserveshield_opt()
	local currentzone = mapheaderinfo[gamemap].lvlttl
	local newzone = false

	if currentzone ~= lastzone then
		newzone = true
		lastzone = currentzone
	end

	if preservation and p.styles_preserveshield then
		if preservation > 2 or (
			newzone == false and (preservation == 2 or (preservation == 1 and mapheaderinfo[gamemap].bonustype < 1))) then
			p.powers[pw_shield] = p.styles_preserveshield
			P_SpawnShieldOrb(p)
		end
	end

	p.styles_preserveshield = nil
end)

addHook("PlayerThink", function(p)
	if not p.mo then return end

	if spindash_cv.value and p.mo.state == S_PLAY_SPINDASH then
		p.mo.state = S_PLAY_ROLL
	end

	local speedv = FixedDiv(FixedHypot(p.rmomx, p.rmomy), p.mo.scale)
	local onground = P_IsObjectOnGround(p.mo)
	local waterfactor = 1 + (p.mo.eflags & MFE_UNDERWATER) / MFE_UNDERWATER
	local skin = skins[p.mo.skin]

	-- SFX

	local jumpsfx = jumpsounds_opt()
	local spinsfx = spinsounds_opt()
	local dashsfx = dashsounds_opt()


	if jumpsfx and S_SoundPlaying(p.realmo, sfx_jump) then
		S_StopSoundByID(p.realmo, sfx_jump)
		S_StartSound(p.realmo, jumpsfx)
	end

	if spinsfx and S_SoundPlaying(p.realmo, sfx_spin) then
		S_StopSoundByID(p.realmo, sfx_spin)
		S_StartSound(p.realmo, spinsfx)
	end

	if dashsfx and S_SoundPlaying(p.realmo, sfx_zoom) then
		S_StopSoundByID(p.realmo, sfx_zoom)
		S_StartSound(p.realmo, dashsfx)
	end

	-- PRESERVE SHIELDS

	if (gametyperules & GTR_FRIENDLY) and not (G_IsSpecialStage(gamemap) or (maptol & TOL_NIGHTS)) then
		local preservation = preserveshield_opt()

		if preservation then
			if p.exiting then
				p.styles_preserveshield = p.powers[pw_shield]
			end
		else
			p.styles_preserveshield = nil
		end
	end

	-- MOMENTUM
	-- Edited Clairbun's work

	local momentumtog = momentum_opt()

	if momentumtog then
		local nmom = skin.normalspeed
		local pmom = speedv

		local friction = FixedDiv(p.mo.friction, p.mo.movefactor)

		if p.dashmode >= 3*TICRATE then
			nmom = p.normalspeed
		end

		if (p.powers[pw_sneakers] or p.powers[pw_super]) then
			pmom = $*3/5
		end

		if (p.mo.eflags & MFE_JUSTHITFLOOR) then
			p.normalspeed = skin.normalspeed
			p.mo.friction = $-$/10
		elseif onground then
			local sustain = FixedDiv(min(pmom * waterfactor, 3*nmom/2), friction)
			p.normalspeed = max(nmom, ease.linear(FRACUNIT/186, sustain, nmom))
		elseif not(p.dashmode) then
			p.normalspeed = skin.normalspeed
		end
	end

	-- ABILITIES

	local runwater = runonwater_opt()

	if runwater then
		if not (skin.flags & SF_RUNONWATER) then
			if skin.normalspeed <= speedv then
				p.charflags = $|SF_RUNONWATER
			else
				p.charflags = $ &~ SF_RUNONWATER
			end
		else
			p.charflags = $|SF_RUNONWATER
		end

		p.styles_runonwater = true
	elseif p.styles_runonwater then
		if not (skin.flags & SF_RUNONWATER) then
			p.charflags = $ &~ SF_RUNONWATER
		end

		p.styles_runonwater = nil
	end

	if 	(p.charflags & SF_RUNONWATER)
	and (p.mo.eflags & MFE_TOUCHWATER)
	and (p.mo.state == S_PLAY_RUN or p.mo.state == S_PLAY_WALK)
	and skin.normalspeed-FRACUNIT/2 <= speedv then
		if not p.styles_waterrunpart1 then
			p.styles_waterrunpart1 = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_ROTATEOVERLAY)
			p.styles_waterrunpart1.state = ronw_state
			p.styles_waterrunpart1.target = p.mo
			p.styles_waterrunpart1.tracer = p.mo
			p.styles_waterrunpart1.angle = R_PointToAngle2(0, 0, p.mo.momx, p.mo.momy) - ronw_angle
			p.styles_waterrunpart1.scale = 0
			p.styles_waterrunpart1.styles_spla = true
			p.styles_waterrunpart1.styles_offx = FixedMul(cos(p.mo.angle + ANGLE_90), p.mo.scale * 12)
			p.styles_waterrunpart1.styles_offy = FixedMul(sin(p.mo.angle + ANGLE_90), p.mo.scale * 12)
		else
			p.styles_waterrunpart1.angle = R_PointToAngle2(0, 0, p.mo.momx, p.mo.momy) - ronw_angle
			p.styles_waterrunpart1.scale = ease.linear(FRACUNIT/2, $, FixedMul(p.mo.scale, p.speed/32))
			p.styles_waterrunpart1.styles_offx = FixedMul(cos(p.mo.angle + ANGLE_90), p.mo.scale * 12)
			p.styles_waterrunpart1.styles_offy = FixedMul(sin(p.mo.angle + ANGLE_90), p.mo.scale * 12)
		end

		if not p.styles_waterrunpart2 then
			p.styles_waterrunpart2 = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_ROTATEOVERLAY)
			p.styles_waterrunpart2.state = ronw_state
			p.styles_waterrunpart2.target = p.mo
			p.styles_waterrunpart2.tracer = p.mo
			p.styles_waterrunpart2.angle = R_PointToAngle2(0, 0, p.mo.momx, p.mo.momy) + ronw_angle
			p.styles_waterrunpart2.scale = 0
			p.styles_waterrunpart2.styles_spla = true
			p.styles_waterrunpart2.styles_offx = FixedMul(cos(p.mo.angle - ANGLE_90), p.mo.scale * 12)
			p.styles_waterrunpart2.styles_offy = FixedMul(sin(p.mo.angle - ANGLE_90), p.mo.scale * 12)
		else
			p.styles_waterrunpart2.angle = R_PointToAngle2(0, 0, p.mo.momx, p.mo.momy) + ronw_angle
			p.styles_waterrunpart2.scale = ease.linear(FRACUNIT/2, $, FixedMul(p.mo.scale, p.speed/32))
			p.styles_waterrunpart2.styles_offx = FixedMul(cos(p.mo.angle - ANGLE_90), p.mo.scale * 12)
			p.styles_waterrunpart2.styles_offy = FixedMul(sin(p.mo.angle - ANGLE_90), p.mo.scale * 12)
		end

	elseif p.styles_waterrunpart1 or p.styles_waterrunpart2 then
		if p.styles_waterrunpart1 then
			p.styles_waterrunpart1.target = nil
		end

		if p.styles_waterrunpart2 then
			p.styles_waterrunpart2.target = nil
		end

		p.styles_waterrunpart1 = nil
		p.styles_waterrunpart2 = nil
	end

	-- EYE CANDY

	if thok_cv.value then
		p.thokitem = MT_RAY
		p.spinitem = MT_RAY
		p.revitem = MT_RAY

		p.styles_swappedthok = true
	elseif p.styles_swappedthok then
		p.thokitem = skin.thokitem == -1 and MT_THOK or skin.thokitem
		p.spinitem = skin.spinitem == -1 and MT_THOK or skin.spinitem
		p.revitem = skin.revitem -1 and MT_NULL or skin.revitem

		p.styles_swappedthok = nil
	end

	local groundrot = grounding_opt()
	
	if p.powers[pw_carry] == CR_NIGHTSMODE then
		local nightsrot = nightrot_opt()

		if nightsrot 
		and p.mo.state == S_PLAY_NIGHTS_FLY
		or  p.mo.state == S_PLAY_NIGHTS_DRILL then
			nightsrot(p.mo, nil)
		elseif p.mo.state == S_PLAY_NIGHTS_PULL then
			p.mo.rollangle = $ + ANG10
			p.drawangle = $ + ANG10
		elseif p.mo.style_rollangle_was_enabled then
			p.mo.rollangle = 0
			p.mo.style_rollangle_was_enabled = nil
		end
	elseif groundrot then
		groundrot(p.mo, p.style_springroll)
	elseif p.mo.style_rollangle_was_enabled then
		p.mo.rollangle = 0
		p.mo.style_rollangle_was_enabled = nil
	end

	if p.followmobj then
		p.followmobj.rollangle = p.mo.rollangle
	end

	if p.mo.style_spring_type == nil then return end

	if springtwirl_cv.value and p.mo.style_spring_type == 2
	and (p.mo.state == S_PLAY_SPRING or p.cd_springtwirl) and not p.style_springroll then
		p.drawangle = leveltime*ANG1*16
		p.cd_springtwirl = true
	elseif p.mo.state ~= S_PLAY_SPRING and p.cd_springtwirl then
		p.drawangle = p.mo.angle
		p.cd_springtwirl = nil
	end

	if ((springtroll_cv.value == 2 or (springtroll_cv.value == 1 and p.mo.style_spring_type == 1))
	and not p.cd_springtwirl and p.mo.state == S_PLAY_SPRING
	or (p.style_springroll and not onground)) then

		if p.mo.state ~= S_PLAY_WALK then
			p.mo.state = S_PLAY_WALK
		end
		p.mo.rollangle = $+ANG1*10
		p.style_springroll = true
	elseif p.style_springroll and (p.mo.state ~= S_PLAY_WALK or onground) then
		p.mo.rollangle = 0
		p.style_springroll = nil
	end

	if springtwalk_cv.value then
		if (p.mo.state == S_PLAY_SPRING) then
			p.styles_spronk = true
		elseif p.styles_spronk and (p.mo.state == S_PLAY_FALL
		or (p.style_falling and p.mo.state == S_PLAY_WALK)) then
			if p.style_springroll then
				p.mo.rollangle = 0
				p.style_springroll = false
			end
			p.cd_springtwirl = false
			p.style_falling = true

			if p.mo.state ~= S_PLAY_WALK then
				p.mo.state = S_PLAY_WALK
			end
			p.mo.springyscale = 16*FU
		else
			p.style_falling = nil
			if p.styles_spronk then
				p.styles_spronk = false
				p.mo.springyscale = 0
			end
		end
	end

	if (p.mo.eflags & MFE_JUSTHITFLOOR) then
		if p.style_springroll then
			p.mo.rollangle = 0
			p.style_springroll = nil
		end


		if p.styles_spronk then
			p.styles_spronk = false
			p.mo.springyscale = 0
		end

		p.style_falling = nil
		p.mo.style_spring_type = nil
	end
end)

--
--	HOOKS
--

--local function SpecialPusher_Check(a, k)
--	if (k.player) then
--		if a.type == MT_STEAM or a.type == MT_FAN and not k.player.style_springroll then
--			k.z = $ + P_MobjFlip(k)
--			k.player.style_springroll = true
--		else
--			k.style_spring_type = a.info.damage and 1 or 2
--		end
--	end
--end

local function Spring_Check(a, sp)
	if not (a.player and a.valid) then return end
	if not (sp and sp.valid) then return end

	if not (sp.flags & MF_SPRING) then return end

	if 	sp.z+sp.height >= a.z
	and a.z+a.height >= sp.z then
		a.style_spring_type = sp.info.damage and 1 or 2
	end
end

--addHook("TouchSpecial", SpecialPusher_Check, MT_STEAM)
--addHook("TouchSpecial", SpecialPusher_Check, MT_FAN)

addHook("MobjCollide", 		Spring_Check, MT_PLAYER)
addHook("MobjMoveCollide", 	Spring_Check, MT_PLAYER)
