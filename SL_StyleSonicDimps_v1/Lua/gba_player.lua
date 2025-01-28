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

local thok_cv = CV_RegisterVar{
	name = "gba_thok",
	defaultvalue = "enabled",
	flags = CV_NETVAR,
	PossibleValue = {enabled=0, disabled=1}
}

local angle_triggerfall = ANG1*6
local angle_wholerange = angle_triggerfall*2

addHook("PlayerThink", function(p)
	if not p.mo then return end

	if thok_cv.value then
		p.thokitem = MT_RAY
		p.spinitem = MT_RAY
		p.revitem = MT_RAY

		p.styles_swappedthok = true
	elseif p.styles_swappedthok then
		p.thokitem = skins[p.mo.skin].thokitem
		p.spinitem = skins[p.mo.skin].spinitem
		p.revitem = skins[p.mo.skin].revitem

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
