local stash = tbsrequire 'gui/leaderboards/lead_stash'

return {
    {
        name = "",
        min =  104,

        render = stash.players,

        max_size = 99,
    },
    {
        name = "HITS",
        value = "hits",

        max_size = 1,
    },
    {
        name = "DEATHS",
        value = "deaths",

        max_size = 1,
    },
    {
        name = "SCORE",
        value = "score",

        max_size = 99,
    },

    main = "score",
}