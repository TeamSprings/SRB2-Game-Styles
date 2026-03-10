local f_err

local module = {
    cache = {},
    redirect = dofile(stylesCoreLocation.."tools/states/filealias.lua"),
    loaded = 0,
    total = 0,
}

function module.add(path)
    local _path = path

    if module.redirect[_path] then
        _path = module.redirect[_path]
    end

    local path = _path .. ".lua"
    if module.cache[path] then
        return module.cache[path]
    else
        module.total = $ + 1

        local func, err = loadfile(path)
        if not func then
            pcall(f_err, "[Game Styles] Error loading module '"..path.."': "..err)
        else
            module.cache[path] = func()
            module.loaded = $ + 1

            return module.cache[path]
        end
    end
end

function module.dofile(path)
	local func, err = loadfile(path)

	if func then
		local status, result = pcall(func)

		if not status then
			pcall(f_err, "[Game Styles] Error loading or executing " .. path .. ": " .. result)
		else
			module.loaded = $ + 1
		end
	else
		pcall(f_err, "[Game Styles] Error loading " .. path .. ": " .. err)
	end

	module.total = $ + 1
end

function module.alias(alias, redirect)
    module.redirect[alias] = redirect
end

local log = module.add(stylesCoreLocation.."tools/logging")
f_err = log.printErr

log.print("Initializing Module Loading")

return module