-- == Custom HUD Functions by TehRealSalt ==
-- Global script that contains extra functions for any HUD-related scripts.

-- USAGE: Main part of customhud is the ability to creating and overwriting existing HUD items, and adding support for other HUD modifications.
-- This helps sort out HUD conflicts that are otherwise impossible to detect without the use of this library.

local VERSIONNUM = {2, 6};
local updating = nil;

local function warn(str)
	print("\131WARNING: \128"..str);
end

local function notice(str)
	print("\x83NOTICE: \x80"..str);
end

-- Should match hud_disable_options in lua_hudlib.c
local defaultitems = {
	{"stagetitle", "titlecard"},
	{"textspectator", "game"},
	{"crosshair", "game"},

	{"score", "game"},
	{"time", "game"},
	{"rings", "game"},
	{"lives", "game"},

	{"weaponrings", "game"},
	{"powerstones", "game"},
	{"teamscores", "gameandscores"},

	{"nightslink", "game"},
	{"nightsdrill", "game"},
	{"nightsrings", "game"},
	{"nightsscore", "game"},
	{"nightstime", "game"},
	{"nightsrecords", "game"},

	{"rankings", "scores"},
	{"coopemeralds", "scores"},
	{"tokens", "scores"},
	{"tabemblems", "scores"},

	{"intermissiontally", "intermission"},
	{"intermissiontitletext", "intermission"},
	{"intermissionmessages", "intermission"},
	{"intermissionemeralds", "intermission"},
};

if (rawget(_G, "customhud")) then
	local oldnum = customhud.GetVersionNum();
	local numlength = max(#VERSIONNUM, #oldnum);

	local loadednum = "";
	local newnum = "";

	for i = 1,numlength
		local num1 = oldnum[i];
		local num2 = VERSIONNUM[i];

		if (num1 == nil) then
			num1 = 0;
		end
		if (num2 == nil) then
			num2 = 0;
		end

		if (loadednum == "") then
			loadednum = "v"..num1;
		else
			loadednum = $1.."."..num1;
		end

		if (newnum == "") then
			newnum = "v"..num2;
		else
			newnum = $1.."."..num2;
		end

		if (num1 < num2) then
			updating = true;
		elseif (num1 > num2) then
			break;
		end
	end

	if (updating == nil) then
		-- Existing version is OK
		return;
	end

	if customhud.Overwritten then
		for k, overwrite in pairs(customhud.Overwritten) do
			rawset(hud, k, overwrite)
		end
	end

	notice("An old version of customhud was detected ("..loadednum.."). Switching to newer ("..newnum.."), errors may occur.");
else
	rawset(_G, "customhud", {});
end

customhud.Overwritten = {}
customhud.Overwritten["enable"] = hud.enable
customhud.Overwritten["enabled"] = hud.enabled
customhud.Overwritten["disable"] = hud.disable

local hudenable =  customhud.Overwritten["enable"]
local hudenabled = customhud.Overwritten["enabled"]
local huddisable = customhud.Overwritten["disable"]

function customhud.GetVersionNum()
	-- Make sure you cannot overwrite the version number by copying it into another table
	-- That'd be really silly :V
	local tempNum = {};

	for k,v in ipairs(VERSIONNUM) do
		tempNum[k] = v;
	end

	return tempNum;
end

if (updating == nil)
	customhud.hudItems = {};
end

local huditems = customhud.hudItems

customhud.hookTypes = {
	"game",
	"scores",
	"title",
	"titlecard",
	"intermission",
	"gameandscores",
	"continue",
	"playersetup"
};

local hooktypes = customhud.hookTypes

local function FindItem(itemName)
	for _,hook in pairs(hooktypes) do
		for _,item in pairs(huditems[hook]) do
			if (item.name == itemName) then
				return item;
			end
		end
	end

	return nil;
end

function customhud.FindItem(itemName)
	return FindItem(itemName);
end

local function CreateNewItem(itemName)
	local newItem = {
		-- The name ID we use for this item.
		name = itemName,
		-- All of the rendering functions given to this item.
		funcs = {},
		-- The current rendering function index for this item.
		-- ("vanilla" is a reserved mod name for reverting a modded hud item
		-- back to its original state, cannot be set for custom hud items)
		type = nil,
		-- Is this hud item supposed to be visible?
		enabled = true,
		-- Determine render order of this item.
		-- Higher values are rendered on top, lower values are rendered below.
		-- (Base game items are always on the lowest layer due to limitations.)
		layer = 0,
		-- Determines if this is a default HUD item defined by the game.
		-- Should never be true for custom HUD elements.
		isDefaultItem = false,
	};

	return newItem;
end

function customhud.CreateNewItem(itemName)
	return CreateNewItem(itemName);
end

for _,v in pairs(hooktypes) do
	if (huditems[v] == nil) then
		huditems[v] = {};
	end
end

for _,v in pairs(defaultitems) do
	local itemName = v[1];
	local hookType = v[2];

	local item = customhud.FindItem(itemName);
	local updatingItem = true;

	if (item == nil) then
		item = customhud.CreateNewItem(itemName);
		updatingItem = false;
	end

	item.funcs["vanilla"] = nil;

	if (updatingItem == false) then
		item.type = "vanilla";
		item.enabled = hudenabled(itemName);
	end

	item.layer = INT32_MIN;
	item.isDefaultItem = true;

	table.insert(huditems[hookType], item);
end

function customhud.ItemExists(itemName)
	return (FindItem(itemName) != nil);
end

function customhud.UpdateHudItemStatus(item)
	-- Update status of default hud items
	if (item.isDefaultItem != true) then
		return;
	end

	if (item.enabled == true and item.type == "vanilla") then
		hudenable(item.name);
	else
		huddisable(item.name);
	end
end

function customhud.enable(itemName)
	local item = customhud.FindItem(itemName);
	if (item == nil) then
		return false;
	end

	item.enabled = true;
	customhud.UpdateHudItemStatus(item);
	return true;
end

function customhud.disable(itemName)
	local item = customhud.FindItem(itemName);
	if (item == nil) then
		return false;
	end

	item.enabled = false;
	customhud.UpdateHudItemStatus(item);
	return true;
end

function customhud.enabled(itemName)
	local item = customhud.FindItem(itemName);
	if (item == nil) then
		return false;
	end

	if (item.isDefaultItem == true and item.type == "vanilla") then
		return hudenabled(itemName);
	end

	return item.enabled;
end

---	Returns the current mod identifier that a HUD item is using. If the HUD item doesn't exist, then this returns nil.
---@param itemName string Item here means "rings" "time" "score" etc.
---@return string|nil
function customhud.CheckType(itemName)
	local item = FindItem(itemName);
	if (item == nil) then
		return nil;
	end

	return item.type;
end

function customhud.SetupItem(itemName, modName, itemFunc, hook, layer)
	if (type(itemName) != "string") then
		warn("Invalid item string \""..itemName.."\" in customhud.SetupItem");
		return;
	end

	if (type(modName) != "string") then
		warn("Invalid type string \""..modName.."\" in customhud.SetupItem");
		return;
	end

	local item = FindItem(itemName);
	if (item == nil)
		-- Create new item
		if (type(hook) != "string")
			hook = "game";
		end

		if (huditems[hook] == nil)
			warn("Invalid hook string \""..hook.."\" in customhud.SetupItem")
			return false;
		end

		if (type(layer) != "number")
			layer = 0;
		end

		local newItem = CreateNewItem(itemName);

		newItem.funcs[modName] = itemFunc;
		newItem.type = modName;
		newItem.layer = layer;

		-- Insert the new item, and then re-sort the layers
		table.insert(huditems[hook], newItem);
		table.sort(huditems[hook], function(a, b)
			return (a.layer < b.layer);
		end);

		return true;
	end

	-- Updating existing item
	if (item.type == modName) then
		-- Already set to this type.
		return false;
	end

	if (modName == "vanilla") and (item.isDefaultItem != true) then
		-- Trying to set a custom HUD item to "vanilla".
		warn("Type string \"vanilla\" is only reserved for base game HUD items in customhud.SetupItem")
		return false;
	end

	if (itemFunc != nil) then
		// Change the function it uses
		item.funcs[modName] = itemFunc;
	end
	item.type = modName;

	customhud.UpdateHudItemStatus(item)
	return true;
end

COM_AddCommand("customhud_setitem", function(_, itemName, modName)
	local item = customhud.FindItem(itemName);
	if (item == nil)
		-- Item doesn't exist.
		return;
	end

	customhud.SetupItem(itemName, modName);
end, COM_LOCAL);


local function RunCustomHooks(hook, v, ...)
	if (huditems[hook] == nil) then
		return;
	end

	for _,item in pairs(huditems[hook]) do
		if (item.enabled == false)
			continue;
		end

		if (item.type == nil)
			continue;
		end

		local func = item.funcs[item.type];
		if (func == nil)
			continue;
		end

		local arg = {...};
		func(v, unpack(arg));
	end
end

hud.add(function(v, player, camera)
	RunCustomHooks("game", v, player, camera);
	RunCustomHooks("gameandscores", v);
end, "game");

hud.add(function(v)
	RunCustomHooks("scores", v);
	RunCustomHooks("gameandscores", v);
end, "scores");

hud.add(function(v)
	RunCustomHooks("title", v);
end, "title");

hud.add(function(v, player, ticker, endtime)
	RunCustomHooks("titlecard", v, player, ticker, endtime);
end, "titlecard");

hud.add(function(v)
	RunCustomHooks("intermission", v);
end, "intermission");

rawset(hud, "enable",  customhud.enable)
rawset(hud, "enabled", customhud.enabled)
rawset(hud, "disable", customhud.disable)

--#endregion
--#region Fonts -- Currently unsupported

if not customhud.fonts then
	customhud.fonts = {};
end

local fonts = customhud.fonts;

local function CreateNewFont(fontName, kerning, space, mono)
	if (type(kerning) ~= "number") then
		kerning = 0;
	end

	if (type(space) ~= "number") then
		space = 4;
	end

	local newFont = {
		name = fontName,
		kerning = kerning,
		space = space,
		mono = nil,
		patches = {},
		number = false,
	};

	if (type(mono) == "number") then
		newFont.mono = mono;
	end

	return newFont;
end

function customhud.CreateNewFont(fontName, kerning, space, mono)
	return CreateNewFont(fontName, kerning, space, mono)
end

---Defines a new font. This should be done before using any of the font functions.
---@param fontName string is the font's prefix. This is used for determining the patch to use, which is in xxxxxyyy, where x is the font prefix and y is the ASCII decimal of each character. This cannot be longer than 5 characters.
---@param kerning number? is the spacing between letters. Negative numbers makes letters overlap, positive numbers are spaced farther apart. Defaults to 0.
---@param space number? is how many pixels a space should be. Defaults to 4
---@param mono number? makes all characters mono-spaced instead of being based on each patch size. Defaults to nil, for a variable-width font.
---@return table|nil
function customhud.SetupFont(fontName, kerning, space, mono)
	if (type(fontName) ~= "string") then
		warn("Invalid font name \""..fontName.."\" in customhud.SetupFont");
		return;
	end

	if (fontName:find(" ")) then
		warn("Font name \""..fontName.."\" cannot have spaces in customhud.SetupFont");
		return;
	end

	if (fontName:len() > 5) or (fontName:len() < 1) then
		warn("Bad font name length in customhud.SetupFont");
		return;
	end

	fonts[fontName] = CreateNewFont(fontName, kerning, space, mono);
end

---Returns font data from customhud.SetupFont or customhud.SetupNumberFont.
---@param fontName string
---@return table
function customhud.GetFont(fontName)
	return fonts[fontName];
end

local function FontPatchNameDirect(fontName, charByte)
	return fontName .. string.format("%03d", charByte);
end

function customhud.FontPatchNameDirect(fontName, charByte)
	return FontPatchNameDirect(fontName, charByte);
end

local function FontPatchName(v, fontName, charByte)
	local patchName = FontPatchNameDirect(fontName, charByte);

	local capsOffset = 32;
	if (charByte >= 65 and charByte <= 90 and not v.patchExists(patchName)) then
		charByte = $1 + capsOffset;
		patchName = FontPatchNameDirect(fontName, charByte);
	elseif (charByte >= 97 and charByte <= 122 and not v.patchExists(patchName)) then
		charByte = $1 - capsOffset;
		patchName = FontPatchNameDirect(fontName, charByte);
	end

	return patchName;
end

function customhud.FontPatchName(v, fontName, charByte)
	return FontPatchName(v, fontName, charByte);
end

local function NumberPatchName(v, fontName, charByte)
	local charNumber = charByte - 48;
	if (charNumber >= 0 and charNumber <= 9) then
		return fontName .. string.format("%d", charNumber);
	end
	return "";
end

function customhud.NumberPatchName(v, fontName, charByte)
	return NumberPatchName(v, fontName, charByte);
end

---Caches and returns a specific character patch from font data.
---@param v 	   videolib
---@param font 	   table
---@param charByte number
---@return patch_t|nil
function customhud.GetFontPatch(v, font, charByte)
	if not (font.patches[charByte] and font.patches[charByte].valid) then
		local patchName = "";

		if (font.number == true) then -- Number-only font
			patchName = NumberPatchName(v, font.name, charByte);
		else
			patchName = FontPatchName(v, font.name, charByte);
		end

		if (patchName == "") then
			return nil;
		end

		-- Try to create a new patch & cache it
		if (v.patchExists(patchName)) then
			font.patches[charByte] = v.cachePatch(patchName);
		end
	end

	return font.patches[charByte];
end

---Caches and returns a specific character patch from font data.
---@param v 	   videolib
---@param str 	   string
---@param fontName string?
---@param scale    number?
---@return number|nil
function customhud.CustomFontStringWidth(v, str, fontName, scale)
	if not (type(str) == "string") then
		warn("No string given in customhud.CustomFontStringWidth");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontStringWidth");
		return;
	end

	local font = customhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	local strwidth = 0;
	if (str == "") then
		return strwidth;
	end

	if (type(scale) ~= "number") then
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale ~= nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale ~= nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono ~= nil and scale ~= nil) then
		mono = $1 * scale;
	end

	for i = 1,str:len() do
		local charByte = str:byte(i,i);
		local patch = customhud.GetFontPatch(v, font, charByte);

		if (patch and patch.valid) then
			local charWidth = patch.width;

			if (mono ~= nil) then
				charWidth = mono;
			elseif (scale ~= nil) then
				charWidth = $1 * scale;
			end

			strwidth = $1 + charWidth + kerning;
		else
			strwidth = $1 + space;
		end
	end

	return strwidth;
end

---Draws a single character of a custom font. Returns the X position to draw another character at, if trying to draw an entire string.
---@param v videolib
---@param x fixed_t|number
---@param y fixed_t|number
---@param charByte number
---@param fontName string
---@param flags number
---@param scale fixed_t
---@param color number
---@return number|nil
function customhud.CustomFontChar(v, x, y, charByte, fontName, flags, scale, color)
	if not (type(charByte) == "number") then
		warn("No character byte given in customhud.CustomFontChar");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontChar");
		return;
	end

	local font = customhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	if (type(scale) ~= "number") then
		scale = nil;
	end

	if (type(flags) != "number") then
		flags = 0;
	end

	local kerning = font.kerning;
	if (scale ~= nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale ~= nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono ~= nil and scale ~= nil) then
		mono = $1 * scale;
	end

	local wc = nil;
	if (color) then
		wc = v.getColormap(TC_DEFAULT, color);
	end

	local patch = customhud.GetFontPatch(v, font, charByte);
	if (patch and patch.valid) then
		if (scale ~= nil) then
			v.drawScaled(x, y, scale, patch, flags, wc);
		else
			v.draw(x, y, patch, flags, wc);
		end
	end

	local nextx = x;
	if (patch and patch.valid) then
		local charWidth = patch.width;

		if (mono ~= nil) then
			charWidth = mono;
		elseif (scale ~= nil) then
			charWidth = $1 * scale;
		end

		nextx = $1 + charWidth + kerning;
	else
		nextx = $1 + space;
	end

	return nextx;
end

---Draws a string in a custom font. If scale is not nil, then the X/Y coordinates are expected to be in fixed point scale, otherwise they are expected to be integers. color uses skincolors rather than the base games' text colors.
---@param v videolib
---@param x fixed_t|number
---@param y fixed_t|number
---@param str number
---@param fontName string
---@param flags number
---@param align string
---@param scale fixed_t
---@param color number
function customhud.CustomFontString(v, x, y, str, fontName, flags, align, scale, color)
	if not (type(str) == "string") then
		warn("No string given in customhud.CustomFontString");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontChar");
		return;
	end

	local font = customhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	if (type(scale) ~= "number") then
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale ~= nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale ~= nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono ~= nil and scale ~= nil) then
		mono = $1 * scale;
	end

	local wc = nil;
	if (color) then
		wc = v.getColormap(TC_DEFAULT, color);
	end

	local nextx = x;

	if (align == "right") then
		nextx = $1 - customhud.CustomFontStringWidth(v, str, fontName, scale);
	elseif (align == "center") then
		nextx = $1 - (customhud.CustomFontStringWidth(v, str, fontName, scale) / 2);
	end

	for i = 1,str:len() do
		local nextByte = str:byte(i,i);
		nextx = customhud.CustomFontChar(v, nextx, y, nextByte, fontName, flags, scale, color);
	end
end

---Defines a new number font. Unlike standard fonts, the font prefix can be up to 7 characters long, but it only uses 0-9 as bytes to represent numbers. Generally, it's recommended to use customhud.SetupFont instead, as this is mostly only for backwards compatibility with some older mods' number font names.
---@param fontName string
---@param kerning number?
---@param space number?
---@param mono number?
function customhud.SetupNumberFont(fontName, kerning, space, mono)
	if (type(fontName) ~= "string") then
		warn("Invalid font name \""..fontName.."\" in customhud.SetupNumberFont");
		return;
	end

	if (fontName:find(" ")) then
		warn("Font name \""..fontName.."\" cannot have spaces in customhud.SetupNumberFont");
		return;
	end

	if (fontName:len() > 7) or (fontName:len() < 1) then
		warn("Bad font name length in customhud.SetupNumberFont");
		return;
	end

	local newFont = CreateNewFont(fontName, kerning, space, mono);
	newFont.number = true;

	fonts[fontName] = newFont;
end

---Returns the width of a number if it were drawn in a custom font. padding is the number of padding zeroes to use, set to nil for no padding.
---@param v 		videolib
---@param num 		number
---@param fontName 	string
---@param padding 	string?
---@param scale 	fixed_t?
---@return number|nil
function customhud.CustomNumWidth(v, num, fontName, padding, scale)
	local str = "";

	if (padding ~= nil) then
		str = string.format("%0"..padding.."d", num);
	else
		str = string.format("%d", num);
	end

	return customhud.CustomFontStringWidth(v, str, fontName, scale);
end

---Draws a number in a custom number font.
---comment
---@param v videolib
---@param x fixed_t|number
---@param y fixed_t|number
---@param num number
---@param fontName string
---@param padding number?
---@param flags number?
---@param align string?
---@param scale number?
---@param color number?
---@return nil
function customhud.CustomNum(v, x, y, num, fontName, padding, flags, align, scale, color)
	local str = "";

	if (padding ~= nil) then
		str = string.format("%0"..padding.."d", num);
	else
		str = string.format("%d", num);
	end

	return customhud.CustomFontString(v, x, y, str, fontName, flags, align, scale, color);
end

--#endregion