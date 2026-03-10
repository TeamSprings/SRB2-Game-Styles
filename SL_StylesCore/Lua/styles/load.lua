local function load()
    local prefix = stylesCoreLocation

    local PHASE_BACKEND = 1

    local phases = {
        PHASE_BACKEND,
    }

    local files = {
        [PHASE_BACKEND] = {
            ["api/"] = {
                "addon",
                "hooks"
            },

            ["backend/"] = {
                "inter",
                "jingles",
                "levels",
                --"menu",
                --"preset",
                "sounds"
            }
        }
    }

    for _, phase in ipairs(phases) do
        local _phfiles = files[phase]

        for folder, _flfiles in pairs(_phfiles) do
            for _, afiles in ipairs(_flfiles) do
                tbsrequire(prefix..folder..afiles)
            end
        end
    end
end

load()