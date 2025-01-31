--[[

		Team Blue Spring's Series of Libaries.
		Lite version of Common Library - LIB_TBS_lite.lua

Contributors: Skydusk
@Team Blue Spring 2025

]]

local fontregistry = {}

local FRACUNIT = FRACUNIT
local FRACBITS = FRACBITS

local FixedSqrt = FixedSqrt
local FixedMul = FixedMul
local FixedDiv = FixedDiv

local strbyte = string.byte
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
	local cache = fontregistry[font]

	for byte, char in ipairs(ASCII) do
		local char_check = font..char
		if not v.patchExists(char_check) then
			local byte_check = font..byte

			if v.patchExists(byte_check) then
				cache[char] = v.cachePatch(byte_check)
			else
				cache[char] = v.cachePatch(font..'NONE')
			end
		else
			cache[char] = v.cachePatch(char_check)
		end
	end

	return fontregistry[font][selectchar]
end

local function V_CachePatches(v, patch, str, font, val, padding, i)
	local char = strsub(str, i, i)

	if not ASCII[strbyte(char)] then
		char = " "
	end

	local symbol = fontregistry[font] and (fontregistry[font][char]
	and fontregistry[font][char]
	or V_RegisterFont(v, font, char)) or V_RegisterFont(v, font, char)
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

local function V_FontUnadjustedDrawer(v, font, x, y, scale, value, flags, color, alligment, padding, leftadd, symbol)
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

	if alligment == "center" then
		x = $-(lenght*scale >> 1)
	elseif alligment == "right" then
		x = $-lenght*scale
	end

	local drawer = v.drawScaled

	for i = 1,maxv do
		drawer(x+fontoffset*scale, y, scale, cache[i].patch, flags, color)
		fontoffset = $+cache[i].width
	end
end


--TBSlib.fontlenghtcal(d, patch, str, font, val, padding, i)
local function V_GetCharLenght(v, patch, str, font, val, padding, i)
	local char = strsub(str, i, i)
	return (fontregistry[font] and fontregistry[font][char] or V_RegisterFont(d, font, char)).width+padding
end

return {draw = V_FontDrawer, drawUdj = V_FontUnadjustedDrawer, lenght = V_GetCharLenght}