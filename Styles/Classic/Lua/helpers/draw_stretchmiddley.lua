return function(v, y, heightprc, color)
	if heightprc == 0 then return end

	local procentage = min(max(heightprc, 0), FU)

    local scale = v.dupx()
	local intwidth = v.width() / scale

	local intheight = (v.height() / scale * heightprc)/FU
	local newy = y - intheight/2

	v.drawFill(0, newy, intwidth, intheight, V_SNAPTOLEFT|(color or 0))
end