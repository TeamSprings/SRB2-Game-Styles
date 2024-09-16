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

	advance2 = function(id, skincolor)
		local pl = id > 1 and SKINCOLOR_COMPRESSORGBA2 or SKINCOLOR_COMPRESSORGBA
		local ax = skincolors[skincolor].ramp[6]
		skincolors[pl].ramp = {ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax, ax}
		return pl
	end,

	rush = function(id, skincolor)
		local pl = id > 1 and SKINCOLOR_COMPRESSORGBA2 or SKINCOLOR_COMPRESSORGBA
		local ax = skincolors[skincolor].ramp[4]
		local ay = skincolors[skincolor].ramp[8]
		local az = skincolors[skincolor].ramp[12]
		skincolors[pl].ramp = {ax, ax, ax, ax, ax, ax, ay, ay, ay, ay, ay, az, az, az, az, az}
		return pl
	end,
}