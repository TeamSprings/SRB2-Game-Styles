--[[

		Team Blue Spring's Series of Libaries.
		Lite version of Common Library - LIB_TBS_lite.lua

Contributors: Skydusk
@Team Blue Spring 2025

]]

local fontregistry = {}

local FU = FU
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

	local symbol = fontregistry[font] and (fontregistry[font][char]
	and fontregistry[font][char]
	or V_RegisterFont(v, font, char)) or V_RegisterFont(v, font, char)
	return {patch = symbol, width = symbol.width+padding}
end

local function V_FontScrollDrawer(v, font, x, y, scale, value, flags, color, alligment, padding, leftadd, symbol, scroll, width)
	if value == nil then return end
	local str = value..""
	local fontoffset = 0
	local lenght = 0
	local cache = {}

	if leftadd then
		str = strrep(symbol or ";", max(leftadd-#str, 0))..str
	end

	local maxv = #str
	local start = 0
	local cut = 0

	for i = 1,maxv do
		local cur = V_CachePatches(v, patch, str, font, val, padding or 0, i)
		cache[i] = cur
		lenght = $+cur.width

		if start == 0 and scroll < lenght then
			cut = lenght-scroll
			start = i
		end
	end

	local nx = FixedMul(x, scale)
	local ny = FixedMul(y, scale)

	if alligment == "center" then
		nx = $-(lenght*scale >> 1)
	elseif alligment == "right" then
		nx = $-lenght*scale
	end

	local drawer = v.drawScaled
	local endp = 0

	--v.drawCropped(nx, ny, scale, scale, cache[start].patch, flags, color, 0, 0, cut*FU, 360*FU) -- Reverse, as if inserting anim
	v.drawCropped(nx, ny, scale, scale, cache[start].patch, flags, color, (cache[start].width-cut)*FU, 0, 360*FU, 360*FU)
	fontoffset = $+cut

	for i = start+1, maxv do
		if fontoffset > width and not endp then endp = i; break; end

		drawer(nx+fontoffset*scale, ny, scale, cache[i].patch, flags, color)
		fontoffset = $+cache[i].width
	end

	for i = 1, start-1 do
		if fontoffset > width and not endp then endp = i; break; end
		if endp then break end

		drawer(nx+fontoffset*scale, ny, scale, cache[i].patch, flags, color)
		fontoffset = $+cache[i].width
	end

	if endp then
		v.drawCropped(nx+fontoffset*scale, ny, scale, scale, cache[endp].patch, flags, color, 0, 0, max(cache[endp].width+(width-fontoffset), 0)*FU, 360*FU)
	end
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

	local nprogress = (progress % FU) + 1
	local animseq = FU / maxv
	local animoff = offset / maxv

	local nx = FixedMul(x, scale)
	local ny = FixedMul(y, scale)

	if alligment == "center" then
		nx = $-(lenght*scale >> 1)
	elseif alligment == "right" then
		nx = $-lenght*scale
	end

	for i = 1,maxv do
		local invprg = min(max(nprogress - (animseq*i - animoff*i), 0)*maxv, FU)
		anim(v, nx+fontoffset*scale, ny, scale, cache[i].patch, flags, color, i, invprg, nprogress, {...})
		fontoffset = $+cache[i].width
	end
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

return {draw = V_FontDrawer, drawScroll = V_FontScrollDrawer, drawAnim = V_FontAnimDrawer, lenght = V_GetCharLenght}