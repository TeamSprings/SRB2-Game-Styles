--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]


local approximations = {}
local advance3_colors = {
	"Advance3_Gray",
	"Advance3_Red",
	"Advance3_Orange",
	"Advance3_Gold",
	"Advance3_Yellow",
	"Advance3_Shine",
	"Advance3_Ivory",
	"Advance3_Moss",
	"Advance3_Green",
	"Advance3_Emerald",
	"Advance3_Teal",
	"Advance3_Cyan",
	"Advance3_Water",
	"Advance3_Blue",
	"Advance3_Purple",
	"Advance3_Steel",
	"Advance3_GmodError",
	"Advance3_Apple",
	"Advance3_Lavender",
	"Advance3_Pink",
	"Advance3_Meat",
	"Advance3_Beige",
	"Advance3_Brown",
	"Advance3_Mud",
	"Advance3_Browny",
}

local rushapproximations = {}
local rush_colors = {
	"Rush_Gray",
	"Rush_Red",
	"Rush_Orange",
	"Rush_Gold",
	"Rush_Yellow",
	"Rush_Shine",
	"Rush_Ivory",
	"Rush_Moss",
	"Rush_Green",
	"Rush_Emerald",
	"Rush_Teal",
	"Rush_Cyan",
	"Rush_Water",
	"Rush_Blue",
	"Rush_Purple",
	"Rush_Steel",
	"Rush_GmodError",
	"Rush_Apple",
	"Rush_Lavender",
	"Rush_Pink",
	"Rush_Meat",
	"Rush_Beige",
	"Rush_Brown",
	"Rush_Mud",
	"Rush_Browny",
}


local ranges = {31, 47, 63, 71, 79, 83, 87, 95, 111, 119, 127, 139, 143, 159, 169, 175, 187, 191, 199, 207, 215, 223, 231, 139, 251}

return {
	advance3 = function(skincolor)
		if not approximations[skincolor] then
			for i = 1, #ranges do
				if skincolors[skincolor].ramp[8] < ranges[i] then
					approximations[skincolor] = advance3_colors[min(i, #advance3_colors)]
					break
				end
			end
		end

		return approximations[skincolor]
	end,

	advance2 = function(id, skincolor, p)
		if p == displayplayer then
			local pl = id > 1 and SKINCOLOR_COMPRESSORGBA2 or SKINCOLOR_COMPRESSORGBA
			local ax = skincolors[skincolor].ramp[6]
			skincolors[pl].ramp = {ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax}
			return pl
		else
			local pl = id > 1 and SKINCOLOR_COMPRESSORGBA2P2 or SKINCOLOR_COMPRESSORGBAP2
			local ax = skincolors[skincolor].ramp[6]
			skincolors[pl].ramp = {ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax}
			return pl
		end
	end,

	rush = function(id, skincolor)
		local pl = id > 1 and SKINCOLOR_COMPRESSORGBA2 or SKINCOLOR_COMPRESSORGBA
		local ax = skincolors[skincolor].ramp[4]
		local ay = skincolors[skincolor].ramp[10]
		skincolors[pl].ramp = {ax, ax, ax, ax, ax, ax, ax, ax, ay, ay, ax, ay, ay, ay, ay, 31}
		return pl
	end,

	rush2 = function(skincolor)
		if not rushapproximations[skincolor] then
			for i = 1, #ranges do
				if skincolors[skincolor].ramp[8] < ranges[i] then
					rushapproximations[skincolor] = rush_colors[min(i, #rush_colors)]
					break
				end
			end
		end

		return rushapproximations[skincolor]
	end,
}