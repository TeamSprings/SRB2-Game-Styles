--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

freeslot("MT_BACKERADUMMY", "MT_ROTATEOVERLAY", "MT_NONPRIORITYERADUMMY", "MT_FRONTTIERADUMMY", "MT_PRIORITYERADUMMY", "MT_FRONTERADUMMY", "MT_EXTRAERADUMMY")

mobjinfo[MT_EXTRAERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

mobjinfo[MT_BACKERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = -1
}

mobjinfo[MT_FRONTERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOTHINK|MF_NOBLOCKMAP|MF_NOCLIP|MF_SCENERY,
	dispoffset = 1
}

mobjinfo[MT_FRONTTIERADUMMY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_SCENERY,
	dispoffset = 2
}

---@diagnostic disable-next-line
mobjinfo[MT_ROTATEOVERLAY] = {
	spawnhealth = 1,
	reactiontime = 1,
	speed = 12,
	radius = 1048576,
	height = 6291456,
	mass = 100,
	flags = MF_NOGRAVITY|MF_SCENERY|MF_NOCLIP|MF_NOCLIPHEIGHT
}

---@class mobj_t
---@field alpha fixed_t

---@class rotovrmobj_t : mobj_t
---@field bubble 	boolean?
---@field shield 	boolean?
---@field scaleup 	fixed_t?

---@param a rotovrmobj_t
addHook("MobjThinker", function(a)
	if a.target then
		local x = a.target.x
		local y = a.target.y
		local z = a.target.z

		if a.styles_offx then
			x = $ + a.styles_offx
		end

		if a.styles_offx then
			y = $ + a.styles_offy
		end

		if a.styles_offz then
			z = $ + a.styles_offz
		end

		P_MoveOrigin(a, x, y, z)
	else
		if a.styles_monitorfade then
			if a.alpha > 0 then
				a.alpha = $-FU/(TICRATE/2)
			else
				P_RemoveMobj(a)
			end
		elseif a.styles_monitorflash then
			if a.scale > 80 then
				a.scale = $-FU/(TICRATE/2)
				
			else
				P_RemoveMobj(a)
			end
		elseif a.styles_spla then
			if a.scale > 80 then
				a.scale = 50*$/80
			else
				P_RemoveMobj(a)
			end
		elseif a.bubble then
			if a.alpha > 0 then
				a.alpha = $-FU/10
			else
				P_RemoveMobj(a)
			end
		else
			P_RemoveMobj(a)
		end
	end
end, MT_ROTATEOVERLAY)
