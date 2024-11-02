--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]


return {
	ngage = function(v, x, y, width, height, color, color2)
		v.drawFill(x, y, width/2, height, color-2)
		v.drawFill(x+width/2, y, width/2, height, color2+2)
		v.drawFill(x+5*width/16, y, 2*width/16, height, color-1)
		v.drawFill(x+8*width/16, y, 2*width/16, height, color2+1)
		v.drawFill(x+6*width/16, y, 3*width/16, height, color2-2)
	end,
}