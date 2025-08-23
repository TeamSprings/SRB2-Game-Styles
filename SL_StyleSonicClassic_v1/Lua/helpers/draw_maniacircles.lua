local circledraw = tbsrequire 'helpers/draw_circle'
local cos 	= cos
local sin 	= sin
local FU 	= FU

return function(v, x_center, y_center, radius, rotation, color1, color2)
	if radius < 5 then return end
	local circlsz = radius-5
	local circlsx = radius-2

	circledraw(v, x_center, y_center, circlsz, radius, color1)

	local x = (cos(rotation) * circlsx)/FU
	local y = (sin(rotation) * circlsx)/FU

	-- Circle 1
	circledraw(v, x_center+x, y_center+y, 0, 11, color1)

	-- Circle 2
	circledraw(v, x_center-x, y_center-y, 0, 24, color2)
	circledraw(v, x_center-x, y_center-y, 20, 24, color1)
end