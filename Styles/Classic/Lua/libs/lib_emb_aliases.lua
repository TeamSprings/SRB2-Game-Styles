local globals = {
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
}

for key, value in pairs(globals) do
    rawset(_G, key, value)
end