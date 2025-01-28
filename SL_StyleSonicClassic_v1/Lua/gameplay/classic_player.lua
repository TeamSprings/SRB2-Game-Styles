--[[

		Player-object related additions

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local slope_handler = tbsrequire 'helpers/mo_slope'

--
--	CD Nonsense!
--

local spindash_cv = CV_RegisterVar{
	name = "classic_spindash",
	defaultvalue = "genesis",
	flags = CV_NETVAR,
	PossibleValue = {genesis=0, soniccd=1}
}

local springtwirl_cv = CV_RegisterVar{
	name = "classic_springtwirl",
	defaultvalue = "disabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, soniccd=1}
}

local springtwalk_cv = CV_RegisterVar{
	name = "classic_springairwalk",
	defaultvalue = "disabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, genesis=1}
}

local springtroll_cv = CV_RegisterVar{
	name = "classic_springroll",
	defaultvalue = "disabled",
	flags = CV_NETVAR,
	PossibleValue = {disabled=0, diagonalonly=1, genesis=2}
}

local thok_cv = CV_RegisterVar{
	name = "classic_thok",
	defaultvalue = "enabled",
	flags = CV_NETVAR,
	PossibleValue = {enabled=0, disabled=1}
}

--local grounding_cv = CV_RegisterVar{
--	name = "classic_groundrot",
--	defaultvalue = "disabled",
--	flags = 0,
--	PossibleValue = {disabled=0, chunky=1, full=2}
--}

addHook("PlayerThink", function(p)
	if not p.mo then return end

	if spindash_cv.value and p.mo.state == S_PLAY_SPINDASH then
		p.mo.state = S_PLAY_ROLL
	end

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

	--if P_IsObjectOnGround(p.mo) then
	--	if grounding_cv.value == 1 then
	--		slope_handler.slopeRotationGenesis(p.mo)
	--	elseif grounding_cv.value == 2 then
	--		slope_handler.slopeRotation(p.mo)
	--	end
	--elseif p.mo.style_rollangle_was_enabled then
	--	p.mo.rollangle = 0
	--	p.mo.style_rollangle_was_enabled = nil
	--end

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
	or (p.style_springroll and not P_IsObjectOnGround(p.mo))) then

		if p.mo.state ~= S_PLAY_WALK then
			p.mo.state = S_PLAY_WALK
		end
		p.mo.rollangle = $+ANG1*10
		p.style_springroll = true
	elseif p.style_springroll and (p.mo.state ~= S_PLAY_WALK or P_IsObjectOnGround(p.mo)) then
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
			p.mo.springyscale = 16*FRACUNIT
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
	if not (sp.flags & MF_SPRING) then return end

	if 	sp.z+sp.height > a.z
	and a.z+a.height > sp.z then
		a.style_spring_type = sp.info.damage and 1 or 2
	end
end

--addHook("TouchSpecial", SpecialPusher_Check, MT_STEAM)
--addHook("TouchSpecial", SpecialPusher_Check, MT_FAN)

addHook("MobjCollide", 		Spring_Check, MT_PLAYER)
addHook("MobjMoveCollide", 	Spring_Check, MT_PLAYER)
