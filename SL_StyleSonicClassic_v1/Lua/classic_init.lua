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
		P_MoveOrigin(a, a.target.x, a.target.y, a.target.z)
	else
		if a.bubble then
			if a.alpha then
				a.alpha = $-FU/10
			else
				P_RemoveMobj(a)
			end
		else
			P_RemoveMobj(a)
		end
	end
end, MT_ROTATEOVERLAY)
