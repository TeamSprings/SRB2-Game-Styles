local modio = tbsrequire "classic_io"

---@class CvarModule
local module = {
	database = {},
}

local option_t = {
	__call = function(option)
		return option.values[option.cv.value];
	end,
}

--- Creates a new CVAR option.
---@param name string The name of the option.
---@param path string|table The path to the data table or the table itself.
---@param func function? The function to call when the CVAR changes.
---@param addflags number? Additional flags for the CVAR.
---@param priority number? The priority of the CVAR for loading.
---@param nametag string? Adds name for menus and auto assigns CV_MENU
---@param category string? Adds category for menus and auto assigns CV_MENU
---@return table any A table containing information about the CVAR option.
function module:new(name, path, func, addflags, priority, nametag, category)
	local get = type(path) == "string" and tbsrequire(path) or path

	self.database[name] = {
		name = name,
		nametag = nametag,
		category = category,
		
		cv = nil,
		
		tags = {},
		values = {},

		min = INT16_MAX,
		max = INT16_MIN,
	}

	local tags = {}
	local values = {}
	local possible_values = {}

	local minc = INT16_MAX
	local maxc = INT16_MIN
	
	local flags = addflags or 0
	
	local minv = ""

	-- Get minimum + maximum
	---@cast get table
	for k, v in pairs(get) do
		if k < minc then
			minv = v[2]
		end

		minc = min(k, minc)
		maxc = max(k, maxc)

		values[k] = v[1]
		possible_values[v[2]] = k
		tags[k] = v[3]
	end

	if type(func) == "function" then
		flags = $|CV_CALL
	end

	if CV_MENU and (nametag or category) then
		flags = $|CV_MENU
	end

	-- setuping up cvar

	self.database[name].cv = modio:register(priority or 0, {
		name = "classic_"..name,
		defaultvalue = minv,
		flags = flags,
		func = func,
		displayname = nametag,
		category = category,
		PossibleValue = possible_values
	})

	self.database[name].min = minc
	self.database[name].max = maxc
	self.database[name].tags = tags
	self.database[name].priority = priority or 0
	self.database[name].values = values
	self.database[name].flags = flags
	self.database[name].func = func

	return setmetatable(self.database[name], option_t)
end

--- Updates a CVAR option.
---@param name string The name of the option.
---@param path string|table The path to the data table or the table itself.
---@deprecated Not useful due to CV_RegisterVar
function module:update(name, path)
	local get = type(path) == "string" and tbsrequire(path) or path

	local tags = {}
	local values = {}
	local possible_values = {}

	local minc = INT16_MAX
	local maxc = INT16_MIN
	
	local minv = ""

	-- Get minimum + maximum
	---@cast get table	
	for k, v in pairs(get) do
		if k < minc then
			minv = v[2]
		end

		minc = min(k, minc)
		maxc = max(k, maxc)

		values[k] = v[1]
		possible_values[v[2]] = k
		tags[k] = v[3]
	end

	-- setuping up cvar

	self.database[name].cv = modio:register(self.database[name].priority, {
		name = "classic_"..name,
		defaultvalue = minv,
		flags = self.database[name].flags,
		func = self.database[name].func,
		PossibleValue = possible_values
	})

	self.database[name].min = minc
	self.database[name].max = maxc
	self.database[name].tags = tags
	self.database[name].values = values
end


--
-- Global Methods - rather than invidiual
--

--- Gets a CVAR option by name.
---@param name string The name of the option.
---@return table|nil any The CVAR option, or nil if not found.
function module:get(name)
	return self.database[name]
end

--- Gets the CVAR and its min/max values.
---@param name string The name of the option.
---@return table|nil any A table containing the CVAR and its min/max values, or nil if not found.
function module:getCV(name)
	return {self.database[name].cv, self.database[name].min, self.database[name].max}
end

--- Gets the tag, value, and raw value of a CVAR option.
---@param name string The name of the option.
---@return table<string name, any value, integer option>|nil any A table containing the tag, value, and raw value, or nil if not found
function module:getvalue(name)
	if not self.database[name] then return end
	local item = self.database[name]

	return {item.tags[item.cv.value], item.values[item.cv.value], item.cv.value}
end

--- Gets the pure value of a CVAR option.
---@param name string The name of the option.
---@return any any The pure value of the CVAR option.
function module:getPureValue(name)
	if not self.database[name] then return end
	local item = self.database[name]

	return item.values[item.cv.value]
end

--- Checks if a CVAR is available (not a netvar in multiplayer).
---@param name string The name of the option.
---@return boolean any True if the CVAR is available, false otherwise.
function module:available(name)
	if not self.database[name] then return false end
	local item = self.database[name]

	return (not (item.flags & CV_NETVAR)) or isserver
end

return module