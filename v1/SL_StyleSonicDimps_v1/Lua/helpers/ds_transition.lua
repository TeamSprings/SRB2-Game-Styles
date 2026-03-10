--[[

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

return {
	[1] = function(v, x, y, width, flags)
		local cache = v.cachePatch("GBA_MENU_TR1")
		v.draw(x, y, cache, flags)
		v.drawFill(x, y, width, cache.height, 133|flags)
		v.draw(x + width, y, cache, flags|V_FLIP)
	end,

	[2] = function(v, x, y, width, flags)
		local cache = v.cachePatch("GBA_MENU_TR2")
		v.draw(x, y, cache, flags)
		v.drawFill(x, y, width, cache.height, 135|flags)
		v.draw(x + width, y, cache, flags|V_FLIP)
	end,

	[3] = function(v, x, y, width, flags)
		local cache = v.cachePatch("GBA_MENU_TR3")
		v.draw(x, y, cache, flags)
		v.drawFill(x, y, width, cache.height, 152|flags)
		v.draw(x + width, y, cache, flags|V_FLIP)
	end,
}