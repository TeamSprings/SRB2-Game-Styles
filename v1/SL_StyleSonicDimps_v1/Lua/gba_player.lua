--[[

		Player-object related additions

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local slope_handler = tbsrequire 'helpers/mo_slope'

local springtroll_cv = CV_RegisterVar{
	name = "gba_springroll",
	defaultvalue = "disabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, enabled=1}
}

local boostvisuals_cv = CV_RegisterVar{
	name = "gba_advance2boostvisuals",
	defaultvalue = "enabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, enabled=1}
}


local afterimage_cv = CV_RegisterVar{
	name = "gba_supereffects",
	defaultvalue = "enabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, enabled=1}
}

local thok_cv = CV_RegisterVar{
	name = "gba_thok",
	defaultvalue = "enabled",
	flags = CV_NETVAR,
	PossibleValue = {enabled=0, disabled=1}
}

local supersparkles = freeslot("S_STYLES_SUPERSPARKLES")
local supersparklesspr = freeslot("SPR_STYLES_SUPERSONICSPARKLES")

states[supersparkles] = {
	sprite = supersparklesspr,
	frame = A|FF_ADD|FF_ANIMATE,
	var1 = 11,
	var2 = 1,
}

local angle_triggerfall = ANG1*6
local angle_wholerange = angle_triggerfall*2
local speed_threshold = 5*FU

addHook("PlayerThink", function(p)
	if not p.mo then return end

	if p.powers[pw_super] > 0
	and afterimage_cv.value then
		-- Super Sonic Effects

		if p.speed > 8*p.mo.scale then
			if not (leveltime % 5) then
				P_SpawnGhostMobj(p.mo)
			end
		else
			if not (leveltime % 8) then
				local radius = p.mo.radius/FU
				local height = p.mo.height/FU

				local sparkle = P_SpawnMobjFromMobj(p.mo,
					P_RandomRange(-radius, radius) * FU,
					P_RandomRange(-radius, radius) * FU,
					P_RandomRange(-height/4, height) * FU,
				MT_PARTICLE)

				sparkle.fuse = TICRATE*2
				sparkle.scale = (sparkle.scale*3)/2

				if not P_IsObjectOnGround(p.mo) then
					sparkle.momz = -9 * FU * P_MobjFlip(p.mo)
				end

				sparkle.state = supersparkles
			end
		end
	else
		if boostvisuals_cv.value
		and ((p.speed > skins[p.mo.skin].normalspeed + speed_threshold)
		or (p.styles_advanceboost and p.speed > skins[p.mo.skin].normalspeed - speed_threshold/2)) then
			if p.styles_advanceboosttimer and p.styles_advanceboosttimer > TICRATE then
				if not (leveltime % 5) then
					P_SpawnGhostMobj(p.mo)
				end

				if not (leveltime % 3) then
					p.mo.colorized = true
				else
					p.mo.colorized = false
				end

				if not p.styles_advanceboost then
					S_StartSound(p.mo, sfx_zoom)
					p.styles_advanceboost = true
				end
			else
				if P_IsObjectOnGround(p.mo) then
					p.styles_advanceboosttimer = p.styles_advanceboosttimer ~= nil and $ + 1 or 0
				end
			end
		else
			if p.styles_advanceboost then
				p.mo.colorized = false
				p.styles_advanceboost = false
			end

			p.styles_advanceboosttimer = 0
		end


		if p.powers[pw_invulnerability] then
			if not (leveltime % 12) then
				local radius = p.mo.radius/FU
				local height = p.mo.height/FU

				local sparkle = P_SpawnMobjFromMobj(p.mo,
					P_RandomRange(-radius, radius) * FU,
					P_RandomRange(-radius, radius) * FU,
					P_RandomRange(-height/4, height) * FU,
				MT_PARTICLE)

				sparkle.fuse = TICRATE/2
				sparkle.state = supersparkles
			end
		end
	end

	if thok_cv.value then
		--p.thokitem = MT_RAY
		p.spinitem = MT_RAY
		p.revitem = MT_RAY

		p.styles_swappedthok = true
	elseif p.styles_swappedthok then
		--p.thokitem = skins[p.mo.skin].thokitem == -1 and MT_THOK or skins[p.mo.skin].thokitem
		p.spinitem = skins[p.mo.skin].spinitem == -1 and MT_THOK or skins[p.mo.skin].spinitem
		p.revitem = skins[p.mo.skin].revitem -1 and MT_THOK or skins[p.mo.skin].revitem

		p.styles_swappedthok = nil
	end

	if p.mo.style_spring_type == nil then return end

	if ((springtroll_cv.value == 1 and p.mo.style_spring_type == 1)
	and p.mo.state == S_PLAY_SPRING or (p.style_springroll and not P_IsObjectOnGround(p.mo))) then

		if p.mo.state ~= S_PLAY_WALK then
			p.mo.state = S_PLAY_WALK
		end
		p.mo.rollangle = $+ANG1*10
		p.style_springroll = true

		local offseted = p.mo.rollangle + angle_triggerfall

		if (p.mo.momz * P_MobjFlip(p.mo)) < 0 and offseted < angle_wholerange and 0 < offseted then
			p.mo.state = S_PLAY_FALL
			p.mo.rollangle = 0
			p.style_springroll = nil
		end

	elseif p.style_springroll and (p.mo.state ~= S_PLAY_WALK or P_IsObjectOnGround(p.mo)) then
		p.mo.rollangle = 0
		p.style_springroll = nil
	end

	if (p.mo.eflags & MFE_JUSTHITFLOOR) then
		if p.style_springroll then
			p.mo.rollangle = 0
			p.style_springroll = nil
		end

		p.style_falling = nil
		p.mo.style_spring_type = nil
	end
end)

addHook("MobjSpawn", function(mo)
	if afterimage_cv.value then
		P_RemoveMobj(mo)
	end
end, MT_SUPERSPARK)

--
--	HOOKS
--

local function Spring_Check(a, sp)
	if not (a.player and a.valid) then return end
	if not (sp.flags & MF_SPRING) then return end

	if 	sp.z+sp.height > a.z
	and a.z+a.height > sp.z then
		a.style_spring_type = sp.info.damage and 1 or 2
	end
end

addHook("MobjCollide", 		Spring_Check, MT_PLAYER)
addHook("MobjMoveCollide", 	Spring_Check, MT_PLAYER)
