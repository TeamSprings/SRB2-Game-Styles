--[[

		Team Blue Spring's Series of Libaries.
		Lite version of Common Library - LIB_TBS_lite.lua

Contributors: Skydusk
@Team Blue Spring 2025

]]

local fontregistry = {}
local exceptions = {}
local monospace = {}

local FU = FU
local FixedMul = FixedMul

local strchar = string.char
local strbyt = string.byte
local strrep = string.rep

local DEFAULT 	= ";"
local CENTER 	= "center"
local LEFT 		= "right"

--
-- Utilities
--

local ASCII 	= {}
local ASCII_len = 128

for i = 0, ASCII_len do
	ASCII[i] = strchar(i) or "NONE"
end

local function V_RegisterFont(v, font)
	fontregistry[font] = {}

	if not exceptions[font] then
		exceptions[font] = {}
	end

	local cache = fontregistry[font]
	local expec = exceptions[font]
	local mono 	= monospace[font]
	local none 	= v.cachePatch(font..'NONE')

	for byte = 0, ASCII_len do
		local char_check = font .. ASCII[byte]
		
		local patch = none

		if expec[byte] and v.patchExists(expec[byte]) then
			patch = v.cachePatch(expec[byte])
		elseif v.patchExists(char_check) then
			patch = v.cachePatch(char_check)
		else
			local byte_check = font .. byte

			if v.patchExists(byte_check) then
				patch = v.cachePatch(byte_check)
			end
		end

		cache[byte] = {patch = patch, width = mono or patch.width}
	end
end

local function V_RegisterException(font, char, exception)
	if not exceptions[font] then
		exceptions[font] = {}
	end

	exceptions[font][strbyt(char)] = exception
end

local function V_RegisterMonospace(font, len)
	monospace[font] = len
end

local function V_CachePatches(v, font, text, space, size, scale)
	local lenght 	= 0
	local cache 	= {}

	if not fontregistry[font] then
		V_RegisterFont(v, font)
	end

	local registry = fontregistry[font]

	for i = 1, size do
		local char 	= registry[strbyt(text, i, i)]
		local width = (char.width + space) * scale

		cache[i] 	= {patch = char.patch, width = width}
		lenght		= $ + width
	end

	return cache, lenght
end

---@param v videolib
local function V_FontDrawer(v, font, x, y, scale, value, flags, color, alligment, spacing, padding, padsymbol)
	if value == nil then return end
	local text = value..""
	local size = #text

	if padding then
		local delta = max(padding - #text, 0)
		text = strrep(padsymbol or DEFAULT, delta)..text
		size = $ + delta
	end

	local space = spacing or 0

	local cache, lenght = V_CachePatches(v, font, text, space, size, scale)
	local nx, ny = FixedMul(x, scale), FixedMul(y, scale)

	if alligment == CENTER then
		nx = $ -(lenght / 2)
	elseif alligment == LEFT then
		nx = $ - lenght
	end

	local drawer = v.drawScaled

	for i = size, 1, -1 do
		lenght = $ - cache[i].width
		drawer(nx + lenght, ny, scale, cache[i].patch, flags, color)
	end
end

local function V_DropShadowDraw(x, y, patch, flags, color, dropshadow, v)
	v.draw(x + dropshadow, y + dropshadow, patch, (flags &~ V_ALPHAMASK)|V_50TRANS, v.getColormap(TC_DEFAULT, 0, "PITCH_BLACK_DROPSHADOW"))
	v.draw(x, y, patch, flags, color)
end

local function V_DropShadowDrawScaled(x, y, scale, patch, flags, color, dropshadow, v)
	v.drawScaled(x + dropshadow, y + dropshadow * scale, scale, patch, (flags &~ V_ALPHAMASK)|V_50TRANS, v.getColormap(TC_DEFAULT, 0, "PITCH_BLACK_DROPSHADOW"))
	v.drawScaled(x, y, scale, patch, flags, color)
end

---@param v videolib
local function V_FontShadowDrawer(v, font, x, y, scale, value, flags, color, alligment, spacing, padding, padsymbol, dropshadow)
	if value == nil then return end
	local text = value..""
	local size = #text

	if padding then
		local delta = max(padding - #text, 0)
		text = strrep(padsymbol or DEFAULT, delta)..text
		size = $ + delta
	end

	local space = spacing or 0

	local cache, lenght = V_CachePatches(v, font, text, space, size, scale)
	local nx, ny = FixedMul(x, scale), FixedMul(y, scale)

	if alligment == CENTER then
		nx = $ -(lenght / 2)
	elseif alligment == LEFT then
		nx = $ - lenght
	end

	local shadowoffset = dropshadow and dropshadow * scale or 0
	local drawer = dropshadow and V_DropShadowDrawScaled or v.drawScaled

	for i = size, 1, -1 do
		lenght = $ - cache[i].width
		drawer(nx + lenght, ny, scale, cache[i].patch, flags, color, shadowoffset, v)
	end
end

local function V_GetTextLenght(v, font, text, spacing)
	local lenght = 0
	local lenstr = string.len(text)
	local _font = fontregistry[font]

	if not _font then
		V_RegisterFont(v, font)
		_font = fontregistry[font]
	end

	for i = 1, lenstr do
		lenght = $ + _font[strbyt(text, i, i)].width
	end

	return lenght + spacing * lenstr
end

local function V_FontAnimDrawer(v, font, x, y, scale, value, flags, color, alligment, spacing, padding, padsymbol, progress, anim, offset, ...)
	if value == nil then return end
	local text = value..""

	if padding then
		text = strrep(padsymbol or ";", max(padding - #text, 0))..text
	end

	local space = spacing or 0
	local size = #text

	local nprogress = (progress % FU) + 1
	local animseq = FU / size
	local animoff = offset / size

	local cache, lenght = V_CachePatches(v, font, text, space, size, scale)
	local nx, ny = FixedMul(x, scale), FixedMul(y, scale)

	if alligment == "center" then
		nx = $ -(lenght / 2)
	elseif alligment == "right" then
		nx = $ - lenght
	end

	for i = size, 1, -1 do
		lenght = $ - cache[i].width
		local invprg = min(max(nprogress - (animseq*i - animoff*i), 0) * size , FU)
		anim(v, nx + lenght, ny, scale, cache[i].patch, flags, color, i, invprg, nprogress, {...})
	end
end

return {
	-- Text Drawers
	draw = V_FontDrawer,	
	drawanim = V_FontAnimDrawer,
	drawshadowed = V_FontShadowDrawer,

	patchshadowed = V_DropShadowDraw,
	patchshadowedint = V_DropShadowDraw,

	exception = V_RegisterException,
	monospace = V_RegisterMonospace,
	
	text_lenght = V_GetTextLenght}