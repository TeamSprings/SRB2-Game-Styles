--
-- 2.0 Options for Styles
--

local validtype = tbsrequire("@TypeValid")
local module = {}

local OPSTYLES_NET     = 1
local OPSTYLES_ADMIN   = 2
local OPSTYLES_NOSAVE  = 4

module.database = {}
module.order = {}

---@param item OptionItem
function module.validateItem(item)
	if type(item) ~= "table" then return "item can only be table" end

	if type(item[2]) ~= "string" then return "console command index should be string" end

	if type(item[3]) ~= "string" then return "name tag can only be a string" end

	return
end

local index_t = {}

function index_t:index()
	local index = 0

	if multiplayer and (self.flags & OPSTYLES_NET) then
        index = self.netselect
    else
        index = self.select
    end

	return self.ordering[index] or 0
end

function index_t:available()
	return (not (self.flags & OPSTYLES_NET)) or isserver
end

function index_t:value()
	return self.values[self:index()] or "NULL"
end

function index_t:label()
	return self.tags[self:index()] or "NULL"
end

function index_t:count()
	return self.numopt or 0
end

function index_t:add(def)
	local definitions = type(def) == "string" and tbsrequire(def) or def

    if not definitions then
        return
    end

	def._default = nil

	if def[1] and def[1][2] and not (self.select or self.netselect) then
		self.select = def[1][2]
		self.netselect = def[1][2]
	end

	for key, data in pairs(def) do
		if module.validateItem(data) then return end
		if type(key) ~= "number" then continue end

		table.insert(self.ordering, data[2])

		self.tags[data[2]] = data[3]
		self.values[data[2]] = data[1]

		self.numopt = $ + 1
	end
end

---@deprecated
function index_t:cv()
	return nil
end

function index_t:getNext()
	local look = self:index() + 1
	local _max = self:count()

	if look > _max then
		look = _max
	end

	return self.values[look]
end

function index_t:getPrev()
	local look = self:index() - 1

	if look < 1 then
		look = self:count()
	end

	return self.values[look]
end

function index_t:set(value)
    COM_BufInsertText(consoleplayer, ("styles_"..self.name).." "..tostring(value))
end

function index_t:setNext()
	self:set(self:getNext())
end

function index_t:setPrev()
	self:set(self:getPrev())
end

function index_t:getSub()
	local _ty = type(self.suboptions)

	if _ty == "function" then
		return self.suboptions(self)
	elseif _ty == "table" then
		return self.suboptions
	end
end

function module.callInternalOption(player, option, var)
	local index = 0

	if option.indextags[var] then
		index = option.indextags[var]
	elseif type(tonumber(var)) == "number" then
		index = tonumber(var)
	else
		return
	end

	if index == nil then return end

	local _max = option:count()
	index = max(min(index, _max), _max > 0 and 1 or 0)

	if multiplayer and (option.flags & OPSTYLES_NET) then
		option.netselect = index
    else
        if consoleplayer == player then
			option.select = index
		end
    end

	if option.func then
		option.func(option, index)
	end
end

local option_t = {
	__call = function(option)
		return option:value();
	end,
	__index = index_t
}

function module:validateOption(consname, def, func, flags, priority, name, category, suboptions)
	return validtype{
		[consname]   = {"consname",                    "string"},
		[def]        = {"def",            {"string",   "table"}},
		[func]       = {"func",           {"function", "nil"}},
		[flags]      = {"flags",          {"number",   "nil"}},
		[priority]   = {"priority",       {"number",   "nil"}},
		[name]       = {"name",           {"string",   "nil"}},
		[category]   = {"category",       {"string",   "nil"}},
		[suboptions] = {"suboptions",     {"function", "table", "nil"}},
	}
end

function module:new(consname, def, func, flags, priority, name, category, suboptions)
	if module:validateOption(consname, def, func, flags, priority, name, category, suboptions) then
		return
	end

	local definitions = type(def) == "string" and tbsrequire(def) or def

    if module.database[consname] and definitions then
        module.database[consname]:add(definitions)
		return
    end

	local default = definitions._default

	local selection = default

	if self.handler and self.handler[consname] then
		selection = self.handler[consname]
	end

	module.database[consname] = {
		name = consname,
		flags = flags or 0,
		priority = priority or 0,

		nametag = name,
		category = category,
		source = def,
		numopt = 0,
		extended = 0, -- legacy
		func = func,

		default = default,
		select = selection,
		netselect = selection,

		cv = nil,

		ordering = {},
		tags = {},
		values = {},

		suboptions = suboptions
	}

	self.database[consname] = setmetatable(self.database[consname], option_t)
	module.database[consname]:add(definitions)

	COM_AddCommand(consname, function(player, arg)
		module.callInternalOption(player, self.database[consname], arg)
	end, (
	(flags & OPSTYLES_ADMIN) and COM_ADMIN or 0) | (
	(flags & OPSTYLES_NET) and COM_LOCAL or 0))

	return self.database[consname]
end


return module