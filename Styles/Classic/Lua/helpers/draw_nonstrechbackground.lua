return function(v, img, flags, colormap)
	local intwidth = v.width()
	local intheight = v.height()
	local scale = v.dupx()
	intwidth = intwidth / scale
	intheight = intheight / scale

    local xpos = 0
    local ypos = 0

    local imgwidth = img.width
    local imgheight = img.height

    while (xpos < intwidth) do
        ypos = 0

        while (ypos < intheight) do
            v.draw(xpos, ypos, img, V_SNAPTOLEFT|V_SNAPTOTOP|(flags or 0), colormap)
            ypos = $ + imgheight
        end

        xpos = $ + imgwidth
    end
end