--[[

		Team Blue Spring's Series of Libaries.
		Lite version of Common Library - LIB_TBS_lite.lua

Contributors: Skydusk
@Team Blue Spring 2024

]]

local fontregistry = {}

local FRACUNIT = FRACUNIT
local FRACBITS = FRACBITS

local FixedSqrt = FixedSqrt
local FixedMul = FixedMul
local FixedDiv = FixedDiv

local strchar = string.char
local strsub = string.sub
local strrep = string.rep

--
-- Utilities
--

local ASCII = {}

for i = 0, 128 do
	ASCII[i] = strchar(i) or "NONE"
end

local function V_RegisterFont(v, font, selectchar)
	fontregistry[font] = {}
	for byte = 0, 128 do
		local char = ASCII[byte]

		local char_check = font..char
		if not v.patchExists(char_check) then
			local byte_check = font..byte

			if v.patchExists(byte_check) then
				fontregistry[font][char] = v.cachePatch(byte_check)
			else
				fontregistry[font][char] = v.cachePatch(font..'NONE')
			end
		else
			fontregistry[font][char] = v.cachePatch(char_check)
		end
	end

	return fontregistry[font][selectchar]
end

local function V_CachePatches(v, patch, str, font, val, padding, i)
	local char = strsub(str, i, i)

	local symbol = fontregistry[font] and
	(fontregistry[font][char] or V_RegisterFont(v, font, char)) or V_RegisterFont(v, font, char)

	return {patch = symbol, width = symbol.width+padding}
end

local function V_FontDrawer(v, font, x, y, scale, value, flags, color, alligment, padding, leftadd, symbol)
	if value == nil then return end
	local str = value..""
	local fontoffset = 0
	local lenght = 0
	local cache = {}

	if leftadd then
		str = strrep(symbol or ";", max(leftadd-#str, 0))..str
	end

	local maxv = #str

	for i = 1,maxv do
		local cur = V_CachePatches(v, patch, str, font, val, padding or 0, i)
		cache[i] = cur
		lenght = $+cur.width
	end

	local nx = FixedMul(x, scale)
	local ny = FixedMul(y, scale)

	if alligment == "center" then
		nx = $-(lenght*scale >> 1)
	elseif alligment == "right" then
		nx = $-lenght*scale
	end

	local drawer = v.drawScaled

	for i = 1,maxv do
		drawer(nx+fontoffset*scale, ny, scale, cache[i].patch, flags, color)
		fontoffset = $+cache[i].width
	end
end

--TBSlib.fontlenghtcal(d, patch, str, font, val, padding, i)
local function V_GetCharLenght(v, patch, str, font, val, padding, i)
	local char = strsub(str, i, i)
	return (fontregistry[font] and fontregistry[font][char] or V_RegisterFont(d, font, char)).width+padding
end

--
-- Extra Math Section
--

local function atan(x)
    return asin(FixedDiv(x,(1 + FixedMul(x,x)))^(1/2))
end

local function FixedPower(x, n)
	for i = 1, (n-1) do
		x = FixedMul(x, x)
	end
	return x
end

-- sTBS's Fixedpoint interpretation of Roblox's lua doc interpretation's of Bezier's curves.

local function Math_QuadBezier(t, p0, p1, p2)
	return FixedMul(FixedMul(FRACUNIT - t, FRACUNIT - t), p0) + 2 * FixedMul(FixedMul(FRACUNIT - t, t), p1) + FixedMul(FixedMul(t, t), p2)
end

rawset(_G, "atan", atan)
rawset(_G, "FixedPower", FixedPower)

rawset(_G, "TBS_FontDrawer", V_FontDrawer)
rawset(_G, "TBS_GetCharLenght", V_GetCharLenght)

rawset(_G, "Math_QuadBezier", Math_QuadBezier)