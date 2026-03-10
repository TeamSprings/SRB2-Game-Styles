local __require__ = dofile(stylesCoreLocation.."tools/require.lua")
local __logging__ = dofile(stylesCoreLocation.."tools/logging.lua")

dofile(stylesCoreLocation.."libs/sal-customhud.lua")

local globals = {

    --
    -- CONSTANTS
    --

    -- TIME CONSTANTS
    ["SEC"] =       TICRATE,
    ["SECOND"] =    TICRATE,
    ["MINUTE"] =    TICRATE * 60,
    -- UNITS
    ["UNIT"] =      FU,
    -- FIXEDPOINT
    ["FP"] =        FU,
    ["FPHALF"] =    FU/2,
    ["FPQUART"] =   FU/4,

    --
    -- GLOBAL STYLES LIBRARY
    --

    ["tbsrequire"]    = __require__.add, -- Backwards compatibility

    ["stylesalias"]   = __require__.alias,
    ["stylesrequire"] = __require__.add,
    ["styleslocal"]   = function(path)
        return __require__.add(stylesCoreLocation..path)
    end,
    ["stylesdofile"]  = __require__.dofile,
    ["styleslogging"] = __logging__
}

for key, value in pairs(globals) do
    rawset(_G, key, value)
end