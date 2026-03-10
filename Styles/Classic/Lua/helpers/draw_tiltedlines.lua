return function(v, x, y1, y2, width, color)
	local scale = v.dupx()
	local intheight = v.height() / scale
	local rest = (intheight - 200)/2
	local newy1 = max(y1 + rest, 0)
	local newy2 = max(y2 + rest, 0)

	if newy2 < 2 then return end

	local new_x = x + (newy1 - intheight/2)
	local colorv = (color or 0)|V_SNAPTOTOP

	local center = width/2

	for y = newy1, newy2 do
		v.drawFill(new_x - center, y, width, 1, colorv)
		new_x = $ + 1
	end
end