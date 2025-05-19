--[[

		Team Blue Spring's Series of Libaries.
		Lite version of Common Library - LIB_TBS_lite.lua

Contributors: Skydusk
@Team Blue Spring 2025

]]

local fontregistry = {}
local exceptions = {}
local monospace = {}

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
	local cache = fontregistry[font]

	for byte = 0, 128 do
		local char = ASCII[byte]

		if exceptions[font] and exceptions[font][char] then
			cache[char] = v.cachePatch(exceptions[font])
			continue
		end

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

local function V_RegisterException(font, char, exception)
	if not exceptions[font] then
		exceptions[font] = {}
	end

	fontregistry[char] = exception
end

local function V_RegisterMonospace(font, len)
	monospace[font] = len
end

local function V_CachePatches(v, patch, str, font, val, padding, i)
	local char = strsub(str, i, i)

	local symbol = fontregistry[font] and (fontregistry[font][char]
	and fontregistry[font][char]
	or V_RegisterFont(v, font, char)) or V_RegisterFont(v, font, char)
	return {patch = symbol, width = (monospace[font] or symbol.width)+padding}
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
	return (fontregistry[font] and fontregistry[font][char] or V_RegisterFont(v, font, char)).width+padding
end

local function V_GetTextLenght(v, font, str, padding)
	local lenght = 0
	local lenstr = #str

	if lenstr then
		for i = 1, lenstr do
			lenght = $ + V_GetCharLenght(v, patch, str, font, val, padding, i)
		end
	end

	return lenght
end

local function V_FontAnimDrawer(v, font, x, y, scale, value, flags, color, alligment, padding, leftadd, symbol, progress, anim, offset, ...)
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

	local nprogress = (progress % FRACUNIT) + 1
	local animseq = FRACUNIT / maxv
	local animoff = offset / maxv

	local nx = FixedMul(x, scale)
	local ny = FixedMul(y, scale)

	if alligment == "center" then
		nx = $-(lenght*scale >> 1)
	elseif alligment == "right" then
		nx = $-lenght*scale
	end

	for i = 1,maxv do
		local invprg = min(max(nprogress - (animseq*i - animoff*i), 0)*maxv, FRACUNIT)
		anim(v, nx+fontoffset*scale, ny, scale, cache[i].patch, flags, color, i, invprg, nprogress, {...})
		fontoffset = $+cache[i].width
	end
end

return {draw = V_FontDrawer, exception = V_RegisterException, monospace = V_RegisterMonospace, lenght = V_GetCharLenght, text_lenght = V_GetTextLenght, drawanim = V_FontAnimDrawer}