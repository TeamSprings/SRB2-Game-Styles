--[[

	I/O Config script

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local json = tbsrequire("@JSON")
local opt = tbsrequire("@Options")
local log = tbsrequire("@LOG")

local OPSTYLES_NOSAVE  = 4

---@class IOHandler
local handler = {
	file = "",
	registry = {},
	pointer = nil,

	embedded = nil,
}

opt.handler = handler

--- Saves the CVAR values to a file.
---@param savefile string? The path to the save file. If nil, uses the default file.
function handler:save(savefile)
	if self.embedded then return end
	savefile = savefile or self.file

	for _, option in pairs(opt.database) do
		if (option.flags & OPSTYLES_NOSAVE) then continue end
		self.registry[option.name] = option.select
	end

	local string = json.encode(self.registry)

	if string then
		local file = io.openlocal(savefile, "w")

		file:seek("set", 0)
		file:write(string)
		file:close()
	end
end

function handler.cvar_descpriotity(a, b)
	return a.priority > b.priority;
end

function handler:isEmbedded()
	return (self.embedded) and true or false
end

--- Loads the CVAR values from a file.
---@param savefile string? The path to the load file. If nil, uses the default file.
---TODO: SORTING
function handler:load(savefile)
	local cache = {};

	if self.embedded then
		self.registry = self.embedded
	else
		savefile = savefile or self.file

		local data = io.openlocal(savefile, "r+");

		if data then
			local rawjson = data:read("*a")
			self.registry = json.decode(rawjson)
		end
	end
end

addHook("GameQuit", function(quit)
	if not quit then return end

	handler:save();
end)

return handler;