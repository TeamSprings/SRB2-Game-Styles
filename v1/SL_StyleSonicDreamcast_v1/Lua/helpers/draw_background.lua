return function(v, img, flags, colormap)
	local intwidth = v.width()
	local intheight = v.height()
	local scale = v.dupx()
	intwidth = (intwidth * FU / img.width) / scale
	intheight = (intheight * FU / img.height) / scale

	v.drawStretched(0, 0, intwidth, intheight, img, V_SNAPTOLEFT|V_SNAPTOTOP|(flags or 0), colormap)
end