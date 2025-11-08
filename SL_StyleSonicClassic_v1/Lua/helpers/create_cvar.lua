local modio = tbsrequire "classic_io"

---@class CvarModule
local module = {
	database = {},
	version = 2,
}

---@class OptionItem
---@field value any
---@field cvindex string
---@field tagname string

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

	return item:available()
end


---@param item OptionItem
function module:validateItem(item)
	if type(item) ~= "table" then return "item can only be table" end

	if type(item[2]) ~= "string" then return "console command index should be string" end

	if type(item[3]) ~= "string" then return "name tag can only be a string" end

	return
end


--
-- Option_t
--

local index_t = {}

function index_t:available()
	return (not (self.flags & CV_NETVAR)) or isserver
end

function index_t:value()
	return self.values[self.cv.value]
end

function index_t:index()
	return self.cv.value
end

function index_t:cv()
	return self.cv
end

function index_t:getNext()
	local look = self:value() + 1

	if look > self.max then
		look = look.min
	end

	return self.values[look]
end

function index_t:getPrev()
	local look = self:value() - 1

	if look < self.min then
		look = look.max
	end

	return self.values[look]
end

function index_t:set(value)
	CV_Set(self.cv, value)
end

function index_t:setNext()
	self:set(self:getNext())
end

function index_t:setPrev()
	self:set(self:getPrev())
end

-- Meant for adding options by other mods
-- WARNING: Due to static nature of console commands,
-- this creates additional console commands, so please do it in bulk.
-- this function can only be called in loadtime (when freeslot function can be executed)
---@param items table<OptionItem>
function index_t:add(items)
	local additions = 1

	if type(items) ~= "table" then
		return
	end

	for _, value in ipairs(items) do
		local warning = module:validateItem(value)

		if warning then
			return Style_DebugPrint(Style_PrintPrefix..(self.name)..":add(items) : "..warning)
		end

		local i = self.max + additions

		self.values[i] = value[1]
		self.tags[i] = value[3]
		self.possiblevals[value[2]] = i

		additions = $ + 1
	end

	if additions then
		self.extended = $ + 1
		self.max = $ + additions
		self.cv = CV_RegisterVar{
			name = "classic_"..self.extended..self.name,
			defaultvalue = self:index(),
			flags = self.flags,
			func = self.func,
			displayname = self.displayname,
			category = self.category,
			PossibleValue = self.possiblevals
		}
	end
end

local option_t = {
	__call = function(option)
		return option.values[option.cv.value];
	end,
	__index = index_t
}

--
-- NEW METHOD
--

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
		source = get,
		extended = 0,

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
	self.database[name].possiblevals = possible_values
	self.database[name].displayname = nametag
	self.database[name].category = category
	self.database[name].values = values
	self.database[name].flags = flags
	self.database[name].func = func

	self.database[name] = setmetatable(self.database[name], option_t)

	return self.database[name]
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

return module