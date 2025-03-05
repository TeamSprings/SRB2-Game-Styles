local module = {
	database = {},
}

function module:new(name, path, func, addflags)
	local get = tbsrequire(path)

	self.database[name] = {
		name = name,
		cv = nil,
		tags = {},
		values = {},
		min = 800,
		max = -800,
	}

	local tags = {}
	local values = {}
	local possible_values = {}
	local minc = 800
	local maxc = -800
	local flags = addflags or 0
	local minv = ""

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


	self.database[name].cv = CV_RegisterVar{
		name = "classic_"..name,
		defaultvalue = minv,
		flags = flags,
		func = func,
		PossibleValue = possible_values
	}

	self.database[name].min = minc
	self.database[name].max = maxc
	self.database[name].tags = tags
	self.database[name].values = values

	return self.database[name]
end

function module:get(name)
	return self.database[name]
end

function module:getCV(name)
	return {self.database[name].cv, self.database[name].min, self.database[name].max}
end

function module:getvalue(name)
	if not self.database[name] then return end
	local item = self.database[name]

	return {item.tags[item.cv.value], item.values[item.cv.value], item.cv.value}
end

function module:getPureValue(name)
	if not self.database[name] then return end
	local item = self.database[name]

	return item.values[item.cv.value]
end

return module