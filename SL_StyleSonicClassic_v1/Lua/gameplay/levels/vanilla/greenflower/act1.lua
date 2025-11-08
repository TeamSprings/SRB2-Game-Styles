return {
    name    = "Greenflower",
    hash    = -1131512167,
    --actnum  = 1,

    _func = function()
        if Styles_SpecialEntryAvailable() and StylesC_SPE() == 3 then
            local special_ring1 = ab.getthing(567)
            
            if special_ring1 then
                special_ring1.styles_nochecks = true
                special_ring1.styles_noscaling = true
            end
            
            ab.deletething(233)
            ab.deletething(234)
            ab.deletething(235)
            ab.deletething(236)
            ab.deletething(237)
            ab.deletething(238)
        end
    end,
}