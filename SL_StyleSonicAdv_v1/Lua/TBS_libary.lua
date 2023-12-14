local TBSlib = {
	stringversion = '0.1',
	iteration = 1,
}


//
// Utilities
//


-- Crappy font drawer
-- Going to be depricated by some future patch anyway, since official font drawer is in works.

--TBSlib.fontdrawer(d, font, x, y, scale, value, flags, color, alligment, padding, leftadd)
TBSlib.fontdrawer = function(d, font, x, y, scale, value, flags, color, alligment, padding, leftadd, tradded)
	local patch, val
	local str = ''..value
	local fontoffset, allig, actlinelenght = 0, 0, 0
	local trans = V_TRANSLUCENT

	if leftadd ~= nil and leftadd ~= 0 then
		local strlefttofill = leftadd-#str
		if strlefttofill > 0 then
			for i = 1,strlefttofill do
				str = (tradded and ";"..str or ":"..str)
			end
		end
	end

	for i = 1,#str do	
		actlinelenght = $+TBSlib.fontlenghtcal(d, patch, str, font, val, padding, i)
	end
	
	if alligment == "center" then
		allig = FixedMul(-actlinelenght/2*FRACUNIT, scale)
	elseif alligment == "right" then
		allig = FixedMul(-actlinelenght*FRACUNIT, scale)	
	end
	
	for i = 1,#str do
		val = string.sub(str, i,i)
		if val ~= nil then
			patch = d.cachePatch(font..''..val)
			if not d.patchExists(font..''..val) then
				if d.patchExists(font..''..string.byte(val)) then
					patch = d.cachePatch(font..''..string.byte(val))
				else
					patch = d.cachePatch(font..'NONE')
				end
			end
 		else
			return
		end
		d.drawScaled(FixedMul(x+allig+(fontoffset)*FRACUNIT, scale), FixedMul(y, scale), scale, patch, (val == ";" and flags|trans or flags), color)
		fontoffset = $+patch.width+(padding or 0)
	end

end

--TBSlib.fontlenghtcal(d, patch, str, font, val, padding, i)
TBSlib.fontlenghtcal = function(d, patch, str, font, val, padding, i)
	val = string.sub(str, i,i)
	patch = d.cachePatch(font..''..val)
	if not d.patchExists(font..''..val) then
		if d.patchExists(font..''..string.byte(val)) then
			patch = d.cachePatch(font..''..string.byte(val))
		else
			patch = d.cachePatch(font..'NONE')
		end
	end
	return patch.width+(padding or 0)
end

//
// Extra Math Section
//

--TBSlib.atan(x)
TBSlib.atan = function(x)
    return asin(FixedDiv(x,(1 + FixedMul(x,x)))^(1/2))    
end

TBSlib.FixedPointPower = function(x, n)
	for i = 1, (n-1) do
		x = FixedMul(x, x)
	end
	return x
end

//TBS's Fixedpoint interpretation of Roblox's lua doc interpretation's of Bezier's curves.
	
TBSlib.quadBezier = function(t, p0, p1, p2)
	return FixedMul(FixedMul(FRACUNIT - t, FRACUNIT - t), p0) + 2 * FixedMul(FixedMul(FRACUNIT - t, t), p1) + FixedMul(FixedMul(t, t), p2)
end


rawset(_G, "TBSlib", TBSlib)
