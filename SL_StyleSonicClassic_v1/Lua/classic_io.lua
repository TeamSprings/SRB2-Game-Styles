--[[

	I/O Config script

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

---@class IOHandler
local handler = {
	file = "",
	registry = {},
	pointer = nil,

	embedded = tbsrequire("styles_emb"),
}

--- Registers a CVAR.
---@param priority number The priority of the CVAR (lower values are loaded first).
---@param ... any Parameters to pass to the original CV_RegisterVar function.
---@return consvar_t|nil any The registered CVAR, or nil if registration failed.
function handler:register(priority, ...)
	local cvar = handler.pointer(...)

	if cvar then
		handler.registry[cvar.name] = {cvar = cvar, priority = priority or 0};

		return cvar;
	else
		Style_DebugPrint("[Game Styles IO] Failed to register CVAR");
	end
end

--- Saves the CVAR values to a file.
---@param savefile string? The path to the save file. If nil, uses the default file.
function handler:save(savefile)
	if self.embedded then return end
	savefile = savefile or self.file

	local string = ""

	for name, struct in pairs(handler.registry) do
		string = $ .. name .. " " .. struct.cvar.value .. "\n"
	end

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
function handler:load(savefile)
	local cache = {};

	if self.embedded then
		Style_DebugPrint("[Game Styles IO] Embedded preset found.");

		for id, value in pairs(self.embedded) do
			local struct = self.registry[id];

			if struct then
				local cvar = struct.cvar;

				if cvar ~= nil and (not ((cvar.flags & CV_NETVAR) and multiplayer) or isserver) then
					table.insert(cache, {value = tonumber(value), cvar = cvar, priority = struct.priority});
				end
			end
		end

		if cache then
			table.sort(cache, handler.cvar_descpriotity);

			for _, struct in ipairs(cache) do
				CV_Set(struct.cvar, struct.value);
			end
		else
			Style_DebugPrint("[Game Styles IO] Invalid config file found, going with default values.");
		end
	else
		savefile = savefile or self.file

		local data = io.openlocal(savefile, "r+");

		if data then
			data:seek("set", 0);

			for line in data:lines() do
				local tokens = {};

				-- Spliting lines
				for w in string.gmatch(line, "%S+") do
					table.insert(tokens, w);
				end

				-- Loading values
				if tokens and tokens[1] and tokens[2] then
					local struct = self.registry[tokens[1]];

					if struct then
						local cvar = struct.cvar;

						if cvar ~= nil and (not ((cvar.flags & CV_NETVAR) and multiplayer) or isserver) then
							table.insert(cache, {value = tokens[2], cvar = cvar, priority = struct.priority});
						end
					end
				else
					continue
				end
			end

			data:close();

			if cache then
				table.sort(cache, handler.cvar_descpriotity);

				for _, struct in ipairs(cache) do
					CV_Set(struct.cvar, struct.value);
				end
			else
				Style_DebugPrint("[Game Styles IO] Invalid config file found, going with default values.");
			end
		else
			Style_DebugPrint("[Game Styles IO] No config file found, going with default values.");
		end
	end
end

addHook("GameQuit", function(quit)
	if not quit then return end

	handler:save();
end)

return handler;