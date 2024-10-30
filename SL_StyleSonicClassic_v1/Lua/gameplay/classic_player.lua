local slope_handler = tbsrequire 'helpers/mo_slope'

--
--	CD Nonsense!
--

local spindash_cv = CV_RegisterVar{
	name = "classic_spindash",
	defaultvalue = "genesis",
	flags = 0,
	PossibleValue = {genesis=0, soniccd=1}
}

local springtwirk_cv = CV_RegisterVar{
	name = "classic_springtwirk",
	defaultvalue = "disabled",
	flags = 0,
	PossibleValue = {disabled=0, soniccd=1}
}

local springtwalk_cv = CV_RegisterVar{
	name = "classic_springairwalk",
	defaultvalue = "disabled",
	flags = 0,
	PossibleValue = {disabled=0, genesis=1}
}

local springtroll_cv = CV_RegisterVar{
	name = "classic_springroll",
	defaultvalue = "disabled",
	flags = 0,
	PossibleValue = {disabled=0, diagonalonly=1, genesis=2}
}

local thok_cv = CV_RegisterVar{
	name = "classic_thok",
	defaultvalue = "enabled",
	flags = 0,
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

	if springtwirk_cv.value and p.mo.style_spring_type == 2
	and (p.mo.state == S_PLAY_SPRING or p.cd_springtwirk) and not p.style_springroll then
		p.drawangle = leveltime*ANG1*16
		p.cd_springtwirk = true
	elseif p.mo.state ~= S_PLAY_SPRING and p.cd_springtwirk then
		p.drawangle = p.mo.angle
		p.cd_springtwirk = nil
	end

	if ((springtroll_cv.value == 2 or (springtroll_cv.value == 1 and p.mo.style_spring_type == 1))
	and not p.cd_springtwirk and p.mo.state == S_PLAY_SPRING
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
			p.cd_springtwirk = false
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
end)

local spring_database = {}

local function Spring_Check(a, k)
	if (k.player) then
		if a.type == MT_STEAM or a.type == MT_FAN then
			k.player.style_springroll = true
		else
			k.style_spring_type = a.info.damage and 1 or 2
		end
	end
end

addHook("TouchSpecial", Spring_Check, MT_STEAM)
addHook("TouchSpecial", Spring_Check, MT_FAN)

local function P_AddSpring(mobjtype)
	if not spring_database[mobjtype] then
		addHook("MobjCollide", Spring_Check, mobjtype)
		spring_database[mobjtype] = 1
	end
end

local function P_CheckNewSpring(start)
	for i = start, #mobjinfo do
		if i == 1675 then break end

		if mobjinfo[i] and mobjinfo[i].flags & MF_SPRING then
			P_AddSpring(i)
		end
	end
end

-- Please, tell me there is better way to do this... I hope my addon loaded hook gets merged...
P_CheckNewSpring(0);
