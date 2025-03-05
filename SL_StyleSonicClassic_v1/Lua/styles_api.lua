local module = {
	data = {},
	hooks = {}
}

local data = module.data
local hooks = module.hooks

local function selfipairs(t, type, ...)
	if not t.used then return end

	local returns = false

	for _,v in ipairs(t.global) do
		returns = v(...) and true or false
	end

	if t.specifics[type] then
		for _,v in ipairs(t.specifics[type]) do
			returns = v(...) and true or false
		end
	end

	return returns
end

-- hooks to part
-- Internal use only
function module:addHook(id)
	if not hooks[id] then
		hooks[id] = {
			used = false,
			specifics = {},
			global = {},
		}
	end

	setmetatable(hooks[id], {__call = selfipairs})
	return hooks[id]
end

-- adds event to hooked part
function module:event(id, func, specifics)
	if not hooks[id] then
		print("[Styles API] Hook warning: Invalid \'"..tostring(id).."\' Hook")
		return
	end

	if type(func) ~= "function" then
		print("[Styles API] Hook warning: Not a function or function is simply missing")
		return
	end

	hooks[id].used = true

	if not specifics then
		table.insert(hooks[id].global, func)
	else
		if not hooks[id].specifics[specifics] then
			hooks[id].specifics[specifics] = {}
		end

		table.insert(hooks[id].specifics[specifics], func)
	end
end

function module:info()
	return "classicstyle"
end

return module