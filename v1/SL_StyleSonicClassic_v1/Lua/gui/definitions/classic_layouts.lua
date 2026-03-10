local cvdef = tbsrequire("gui/cvars/layouts")

local function LAYOUT(source)
	return tbsrequire("gui/definitions/layouts/layout_"..source)
end

local table = {}

for k, v in pairs(cvdef) do
	table[k] = LAYOUT(v[1])
end

return table