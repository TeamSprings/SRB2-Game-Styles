local ab = tbsrequire 'helpers/levels_abstr' ---@type level_abstr

return 	{
    name = "Egg Rock",
    hash = -1710163032,

    _func = function()
        if Styles_SpecialEntryAvailable() and StylesC_SPE() == 3 then
            local special_ring1 = ab.getthing(29)

            if special_ring1 then
                special_ring1.styles_nochecks = true
                special_ring1.flags2 = $ | MF2_OBJECTFLIP
            end
        end
    end,
}