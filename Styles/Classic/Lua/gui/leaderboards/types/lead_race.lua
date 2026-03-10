local stash = tbsrequire 'gui/leaderboards/lead_stash'

return {
    {
        name = "",
        min =  104,

        render = stash.players,

        max_size = 99,
    },
    {
        name = "LAPS",
        value = "laps",

        max_size = 1,
    },
    {
        name = "TIME",

        render = stash.time,
        max_size = 99,
    },

    main = "time",
}