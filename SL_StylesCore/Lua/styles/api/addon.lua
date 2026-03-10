local module = {}

local validtype = tbsrequire("@TypeValid")

module.addonsOrder = {
    [0] = "core",
}

module.addons = {
    core = {
        name = "Styles Core",
        ver = Style_VersionString,

        desc = "Core of the framework, useless alone. Download any styles addon",
        sum = "Core of the framework",

        img = "NULL",
    },
}

function module.verify(def)
    return validtype{
		[def.id]     = {"def_t->id",                 "string"},
		[def.name]   = {"def_t->name",               "string"},
		[def.ver]    = {"def_t->ver",                "string"},
		[def.desc]   = {"def_t->desc",       {"string", "nil"}},
        [def.sum]    = {"def_t->sum",        {"string", "nil"}},
        [def.img]    = {"def_t->img",        {"string", "patch_t", "nil"}}
	}
end

function module:add(def)
    if self.verify(def) then
        return -- TODO: Print out error
    end

    self.addons[def.id] = def
    table.insert(self.addonsOrder, def.id)
end

function module:get()
    local data = {}

    for _, pack in self.addonsOrder do
        table.insert(data, self.addons[pack])
    end

    return data
end

return module