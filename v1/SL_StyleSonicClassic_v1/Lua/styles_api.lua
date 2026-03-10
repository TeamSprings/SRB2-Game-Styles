local module = {
	data = {},
	hooks = {}
}

local data = module.data
local hooks = module.hooks

local gametype = Style_GamePrefix

-- Byte code level optimalization
local insert = table.insert
local localtype = type
local debugprint = Style_DebugPrint
local _tostring = tostring

local hook_meta = {
	-- Iterating meta function
	__call = function(t, type, ...)
		if not t.used then return end

		local returns = false

		local globals = t.global
		local len_gl = #globals

		-- Iterating

		for it = 1, len_gl do
			local test = globals[it](...)
			returns = test == nil and returns or test
		end

		if t.specifics[type] then
			local specif = t.specifics[type]
			local len_sp = #specif
			
			for it = 1, len_sp do
				local test = specif[it](...)
				returns = test == nil and returns or test
			end
		end

		return returns
	end
}

-- This initializes hooks
-- Can be used elsewhere, intended however for internal use ONLY
function module:addHook(id)
	if hooks[id] then return end

	hooks[id] = {
		used = false,
		specifics = {},
		global = {},
	}

	return setmetatable(hooks[id], hook_meta)
end

-- Adds event to hooked part
function module:event(id, func, specifics)
	if not hooks[id] then
		debugprint("[Styles API] Hook warning: Invalid \'".._tostring(id).."\' Hook")
		return
	end

	if localtype(func) ~= "function" then
		debugprint("[Styles API] Hook warning: Not a function or function is simply missing")
		return
	end

	local hook = hooks[id]

	hook.used = true

	if not specifics then
		insert(hook.global, func)
	else
		local spec = hook.specifics

		if not spec[specifics] then
			spec[specifics] = {}
		end

		insert(spec[specifics], func)
	end
end

function module:info()
	return gametype
end

return module