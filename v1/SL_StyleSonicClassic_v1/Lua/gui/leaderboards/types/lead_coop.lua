local stash = tbsrequire 'gui/leaderboards/lead_stash'

return {
    {
        name = "",
        min =  104,

        render = stash.players,

        max_size = 99,
    },
    {
        name = "RINGS",
        value = "rings",
        max =  200,

        max_size = 1,
    },
    {
        name = "LIVES",
        value = "lives",
        max =  200,

        max_size = 1,
    },
    {
        name = "SCORE",
        value = "score",

        max_size = 99,
    },

    main = "score",
}