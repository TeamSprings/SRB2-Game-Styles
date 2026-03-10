local stash = tbsrequire 'gui/leaderboards/lead_stash'

return {
    {
        name = "",
        min =  104,

        render = stash.players,

        max_size = 99,
    },
    {
        name = "TIME",

        render = stash.time,
        max_size = 99,
    },
    {
        name = "SCORE",
        value = "score",

        max_size = 99,
    },

    main = "score",
}