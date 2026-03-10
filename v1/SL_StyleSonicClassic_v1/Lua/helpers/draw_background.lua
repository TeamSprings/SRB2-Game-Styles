return function(v, img, flags, colormap)
	local intwidth = v.width()
	local intheight = v.height()
	local scale = v.dupx()
	intwidth = (intwidth * FU / 320) / scale
	intheight = (intheight * FU / 200) / scale

	v.drawStretched(0, 0, intwidth, intheight, img, V_SNAPTOLEFT|V_SNAPTOTOP|(flags or 0), colormap)
end