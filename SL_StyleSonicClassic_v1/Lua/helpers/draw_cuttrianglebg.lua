return function(v, x, opening, color)
	if opening > FU then return end

	local procentage = max(opening, 0)

	if procentage == 0 then
		local scale = v.dupx()
		local intwidth = v.width() / scale
		local intheight = v.height() / scale

		v.drawFill(0, 0, intwidth, intheight, color|V_SNAPTOTOP|V_SNAPTOLEFT)
	else
		local scale = v.dupx()
		local intwidth = v.width() / scale
		local intheight = v.height() / scale
		local opent = ease.outsine(procentage, 0, intwidth)

		local new_x = x - intheight/2
		local colorv = (color or 0)|V_SNAPTOTOP

		for y = 0, intheight do
			v.drawFill(new_x - intwidth - opent, y, intwidth, 1, colorv)
			v.drawFill(new_x + opent, y, intwidth, 1, colorv)

			new_x = $ + 1
		end
	end
end