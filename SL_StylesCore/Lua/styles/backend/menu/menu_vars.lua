local menu = {

    toggle = false,
    items = pcall(styleslocal, "data/menu/menuitems"),

    build = {},

    select = 1,
    menuselect = 1,
    prevselect = 1,

    xoff = 0,
    yoff = 0,

    easemin = 0,
    ease = 0, -- 0 <-> FRACUNIT
    easemax = FRACUNIT,

    constyease = FRACUNIT,
    constytimer = FRACUNIT/(FRACUNIT/12),

    pressdelay = 0,

    scorehold = false,
    scoreholdtics = 1,

    renderer = nil,

    music = "OPTS2",
    musicprev = nil,
    musicprev_pos = nil,
    musicprev_looppoint = nil,

    com = "styles_menu"

}

function menu:updateBuild()
    local build = {}
    local numitems = 0

    for key, value in ipairs(self.items[self.menuselect]) do
        build[key] = value
        numitems = $ + 1
    end

    self.build = build
    return self.build
end

return menu