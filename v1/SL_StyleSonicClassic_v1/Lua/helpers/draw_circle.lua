--https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
--https://stackoverflow.com/questions/27755514/circle-with-thickness-drawing-algorithm (M Oehm)
local function V_DrawLine_x(v, x_1, x_2, y, color)
	v.drawFill(x_1, y, x_2-x_1, 1, color)
end

local function V_DrawLine_y(v, x, y_1, y_2, color)
	v.drawFill(x, y_1, 1, y_2-y_1, color)
end

-- Draws hollowed circle, with option of both inner and outer radius
--https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
--https://stackoverflow.com/questions/27755514/circle-with-thickness-drawing-algorithm (M Oehm)
---@param v 		videolib
---@param x_center  number
---@param y_center  number
---@param inner 	number inner circle radius
---@param outer 	number outer circle radius
---@param color 	number color + flags see v.drawFill
local function V_DrawThickCircle(v, x_center, y_center, inner, outer, color)
	local x_o = outer
	local x_i = inner
	local y = 0
	local erro = 1 - x_o
	local erri = 1 - x_i

	local bandaid = 3*(outer-inner)/4
	v.drawFill(x_center - 5*x_o/7, y_center - 5*x_o/7, bandaid, bandaid, color)

	while (x_o >= y) do
		V_DrawLine_x(v, x_center + x_i, x_center + x_o, y_center + y, color)
		V_DrawLine_y(v, x_center + y, y_center + x_i, y_center + x_o, color)
		V_DrawLine_x(v, x_center - x_o, x_center - x_i, y_center + y, color)
		V_DrawLine_y(v, x_center - y, y_center + x_i, y_center + x_o, color)
		V_DrawLine_x(v, x_center - x_o, x_center - x_i, y_center - y, color)
		V_DrawLine_y(v, x_center - y, y_center - x_o, y_center - x_i, color)
		V_DrawLine_x(v, x_center + x_i, x_center + x_o, y_center - y, color)
		V_DrawLine_y(v, x_center + y, y_center - x_o, y_center - x_i, color)

		y = $+1

		if erro < 0 then
			erro = $+2*y+1
		else
			x_o = $-1
			erro = $+2*(y-x_o+1)
		end

		if (y > inner) then
			x_i = y
		else
			if erri < 0 then
				erri = $+2*y+1
			else
				x_i = $-1
				erri = $+2*(y-x_i+1)
			end
		end
	end
end

return V_DrawThickCircle