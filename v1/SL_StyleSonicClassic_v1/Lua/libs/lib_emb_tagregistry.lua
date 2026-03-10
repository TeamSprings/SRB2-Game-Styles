local module = {
    position = MT_NAMECHECK,
    version = 1,

    tags = {

    },

    tagsinfo = {

        ["#badniks_crawlas_ground"] = {
            MT_BLUECRAWLA,
            MT_REDCRAWLA,
        },

        ["#badniks_crawlas"] = {
            "#badniks_crawlas_ground",
            MT_CRAWLACOMMANDER,
        },

        ["#badniks_jetty"] = {
            MT_JETTBOMBER,
            MT_JETTGUNNER,
        },

        ["#badniks_buzz"] = {
            MT_GOLDBUZZ,
            MT_REDBUZZ,
        },

        ["#badniks_shells"] = {
            MT_SPRINGSHELL,
            MT_YELLOWSHELL,
        },

        ["#badniks_induses"] = {
            MT_MINUS,
            MT_UNIDUS,
        },

        ["#badniks_fishes"] = {
            MT_JETJAW,
            MT_GFZFISH,
        },

        ["#badniks_turrets"] = {
            MT_TURRET,
            MT_POPUPTURRET,
        },

        ["#enemies_badniks"] = {
            "#badniks_crawlas",
            "#badniks_fishes",
            "#badniks_buzz",
            "#badniks_jetty",
            MT_DETON,
            MT_SKIM,
            "#badniks_turrets",
            MT_SPINCUSHION,
            MT_CRUSHSTACEAN,
            MT_BANPYURA,
            MT_SNAILER,
            MT_VULTURE,
            MT_POINTY,
            MT_ROBOHOOD,
            MT_FACESTABBER,
            MT_EGGGUARD,
            MT_GSNAPPER,
            "#badniks_shells",
            MT_CANARIVORE,
            "#badniks_induses",
            MT_PYREFLY,
            MT_PTERABYTE,
            MT_DRAGONBOMBER
        },

        ["#enemies_mario"] = {
            MT_GOOMBA,
            MT_BLUEGOOMBA
        },

        ["#bosses_fang"] = {
            MT_METALSONIC_RACE,
            MT_METALSONIC_BATTLE,
        },

        ["#bosses_metalsonic"] = {
            MT_FANG,
        },

        ["#bosses_eggman"] = {
            MT_EGGMOBILE,
            MT_EGGMOBILE2,
            MT_EGGMOBILE3,
            MT_EGGMOBILE4,
            MT_BLACKEGGMAN,
            MT_CYBRAKDEMON
        },

        ["#bosses_eggman_empire"] = {
            "#bosses_eggman",
            "#bosses_metalsonic"
        },

        ["#bosses_playable_characters"] = {
            "#bosses_fang",
            "#bosses_metalsonic"
        },

        ["#bosses"] = {
            "#bosses_eggman_empire",
            "#bosses_playable_characters",
        },

        ["#enemies"] = {
            "#enemies_badniks",
            "#enemies_mario",
        },

        ["#hostile"] = {
            "#bosses",
            "#enemies",
        },

        ["#friendly"] = {
            MT_ROSY,
        },

        ["#npcs"] = {
            "#hostile",
            "#friendly",
        },

        ["#normal_monitors_stats"] = {
            MT_RING_BOX,
            MT_1UP_BOX,
            MT_EGGMAN_BOX,
            MT_SCORE1K_BOX,
            MT_SCORE10K_BOX,
        },

        ["#normal_monitors_powers"] = {
            MT_PITY_BOX,
            MT_ATTRACT_BOX,
            MT_FORCE_BOX,
            MT_ARMAGEDDON_BOX,
            MT_WHIRLWIND_BOX,
            MT_ELEMENTAL_BOX,
            MT_SNEAKERS_BOX,
            MT_INVULN_BOX,
            MT_GRAVITY_BOX,
            MT_FLAMEAURA_BOX,
            MT_BUBBLEWRAP_BOX,
            MT_THUNDERCOIN_BOX,
        },

        ["#normal_monitors"] = {
            "#normal_monitors_powers",
            "#normal_monitors_stats",
            MT_MIXUP_BOX,
            MT_MYSTERY_BOX,
            MT_RECYCLER_BOX,
        },

        ["#golden_monitors_stats"] = {
            MT_EGGMAN_GOLDBOX,
        },

        ["#golden_monitors_powers"] = {
            MT_PITY_GOLDBOX,
            MT_ATTRACT_GOLDBOX,
            MT_FORCE_GOLDBOX,
            MT_ARMAGEDDON_GOLDBOX,
            MT_WHIRLWIND_GOLDBOX,
            MT_ELEMENTAL_GOLDBOX,
            MT_SNEAKERS_GOLDBOX,
            MT_INVULN_GOLDBOX,
            MT_GRAVITY_GOLDBOX,
            MT_FLAMEAURA_GOLDBOX,
            MT_BUBBLEWRAP_GOLDBOX,
            MT_THUNDERCOIN_GOLDBOX,
        },

        ["#golden_monitors"] = {
            "#golden_monitors_stats",
            "#golden_monitors_powers",
        },

        ["#blueteam_monitors"] = {
            MT_RING_BLUEBOX,
        },

        ["#redteam_monitors"] = {
            MT_RING_REDBOX,
        },

        ["#team_monitors"] = {
            "#blueteam_monitors",
            "#redteam_monitors",
        },

        ["#monitors"] = {
            "#normal_monitors",
            "#golden_monitors",
            "#team_monitors"
        },

        ["#monitor_icons"] = {
            MT_RING_ICON,
            MT_PITY_ICON,
            MT_ATTRACT_ICON,
            MT_FORCE_ICON,
            MT_ARMAGEDDON_ICON,
            MT_WHIRLWIND_ICON,
            MT_ELEMENTAL_ICON,
            MT_SNEAKERS_ICON,
            MT_INVULN_ICON,
            MT_1UP_ICON,
            MT_EGGMAN_ICON,
            MT_MIXUP_ICON,
            MT_GRAVITY_ICON,
            MT_RECYCLER_ICON,
            MT_SCORE1K_ICON,
            MT_SCORE10K_ICON,
            MT_FLAMEAURA_ICON,
            MT_BUBBLEWRAP_ICON,
            MT_THUNDERCOIN_ICON,
        },

        ["#monitors_meta"] = {
            "#monitors",
            "#monitor_icons"
        },

        ["#regular_base_rings"] = {
            MT_RING,
            MT_FLINGRING,
        },

        ["#regular_coins"] = {
            MT_COIN,
            MT_FLINGCOIN,
        },

        ["#team_rings"] = {
            MT_REDTEAMRING,
            MT_BLUETEAMRING,
        },

        ["#regular_rings"] = {
            "#regular_base_rings",
            "#regular_coins",
        },

        ["#rings"] = {
            "#regular_rings",
            "#team_rings"
        },

        ["#blueteam_collectibles"] = {
            MT_BLUETEAMRING,
            MT_BLUEFLAG
        },

        ["#redteam_collectibles"] = {
            MT_REDTEAMRING,
            MT_REDFLAG
        },

        ["#team_collectibles"] = {
            "#blueteam_collectibles",
            "#redteam_collectibles"
        },

        ["#collectibles_emeralds_list"] = {
            MT_EMERALD1,
            MT_EMERALD2,
            MT_EMERALD3,
            MT_EMERALD4,
            MT_EMERALD5,
            MT_EMERALD6,
            MT_EMERALD7,
        },

        ["#collectibles_emeralds"] = {
            "#collectibles_emeralds_list",
            MT_FLINGEMERALD
        },

        ["#collectibles_bluespheres"] = {
            MT_BLUESPHERE,
            MT_FLINGBLUESPHERE
        },

        ["#collectibles_specialstages"] = {
            "#collectibles_emeralds",
            "#collectibles_bluespheres",
            MT_TOKEN
        },

        ["#collectibles_special"] = {
            "#collectibles_specialstages",
            MT_EMBLEM,
        },

        ["#collectibles"] = {
            "#collectibles_special",
            "#team_collectibles",
            "#rings",
        },

        ["#blue_springs"] = {
            MT_BLUEDIAG,
            MT_BLUEHORIZ,
            MT_BLUESPRING,
            MT_BLUESPRINGBALL,
        },

        ["#yellow_springs"] = {
            MT_YELLOWDIAG,
            MT_YELLOWHORIZ,
            MT_YELLOWSPRING,
            MT_YELLOWSPRINGBALL,
        },

        ["#red_springs"] = {
            MT_REDDIAG,
            MT_REDHORIZ,
            MT_REDSPRING,
            MT_REDSPRINGBALL,
        },

        ["#blue_launchers"] = {
            "#blue_springs",
        },

        ["#yellow_launchers"] = {
            "#yellow_springs",
            MT_YELLOWBOOSTER,
        },

        ["#red_launchers"] = {
            "#red_springs",
            MT_REDBOOSTER,
        },

        ["#diagonal_springs"] = {
            MT_BLUEDIAG,
            MT_YELLOWDIAG,
            MT_REDDIAG,
        },

        ["#horizontal_springs"] = {
            MT_BLUEHORIZ,
            MT_YELLOWHORIZ,
            MT_REDHORIZ,
        },

        ["#groundvertical_springs"] = {
            MT_BLUESPRING,
            MT_YELLOWSPRING,
            MT_REDSPRING,
        },

        ["#ballvertical_springs"] = {
            MT_BLUESPRINGBALL,
            MT_YELLOWSPRINGBALL,
            MT_REDSPRINGBALL,
        },

        ["#vertical_springs"] = {
            "#groundvertical_springs",
            "#ballvertical_springs",
        },

        ["#boosters"] = {
            MT_YELLOWBOOSTER,
            MT_REDBOOSTER,
        },

        ["#vertical_launchers_special"] = {
            MT_FAN,
            MT_STEAM,
            MT_BALLOON
        },

        ["#horizontal_launchers"] = {
            "#horizontal_springs",
            "#boosters",
        },

        ["#diagonal_launchers"] = {
            "#diagonal_springs",
        },

        ["#vertical_launchers"] = {
            "#vertical_springs",
            "#vertical_launchers_special",
        },

        ["#springs"] = {
            "#vertical_springs",
            "#horizontal_springs",
            "#diagonal_springs"
        },

        ["#spikes"] = {
            MT_SPIKE,
            MT_SPIKEBALL,
            MT_WALLSPIKE,
        },

        ["#player_launchers"] = {
            "#horizontal_launchers",
            "#diagonal_launchers",
            "#vertical_launchers",
            MT_BUMPER
        },

        ["#player_owntraps"] = {
            MT_SPINFIRE
        },

        ["#projectiles"] = {
            MT_ROCKET,
            MT_LASER,
            MT_TORPEDO,
            MT_TORPEDO2,
            MT_ENERGYBALL,
            MT_MINE,
            MT_JETTBULLET,
            MT_TURRETLASER,
            MT_CANNONBALL,
            MT_ARROW,
            MT_DEMONFIRE
        },

        ["#player_hazards"] = {
            "#spikes",
            "#projectiles",
            MT_BIGMINE
        },

        ["#player_progression"] = {
            MT_STARPOST,
            MT_SIGN
        },

        ["#player_hazards_mp"] = {
            "#player_hazards",
            "#player_owntraps",
        },

        ["#player_alwayspainful"] = {
            "#player_hazards",
            "#hostile",
        },

        ["#player_generic"] = {
            "#monitors",
            "#collectibles",
            "#player_progression",
            "#player_launchers",
            MT_BUBBLES,
        },

        ["#gameplay_objects"] = {
            "#player_generic",
            "#player_hazards_mp",
            "#npcs",
        }
    }
}

local recusiveApply

recusiveApply = function(tag, search, levels)
    if search[tag] then return end

    local group = module.tagsinfo[tag]
    if not group then return end

    local LUT = {}

    local _levels = {}

    if levels then
        for i = 1, #levels do
            _levels[i] = levels[i]
        end
    end

    _levels[#_levels+1] = tag

    for i = 1, #group do
        local _item = group[i]
        local _type = type(_item)

        if _type == "string" then
            recusiveApply(_item, search, _levels)
        else
            if search[tag] then continue end -- loop break

            table.insert(search, tag)

            if not mobjinfo[_item].grouptags then
                mobjinfo[_item].grouptags = {}
            end

            for y = 1, #_levels do
                local intag = _levels[y]
                mobjinfo[_item].grouptags[intag] = true

                module.tags[intag][_item] = true
            end
        end
    end

    if not LUT then return end
end

function module:applyTag(tags)
    local search = {}

    for tag, _ in pairs(tags or self.tagsinfo) do
        self.tags[tag] = {}
    end

    for tag, group in pairs(tags or self.tagsinfo) do
        if not group then continue end
        recusiveApply(tag, search)

        search = {}
    end

    if not tags then
        self.tagsinfo = nil
    end
end

function module:checker()

end

module:applyTag()

print("[Styles Tag Registry] REGISTERING VANILLA OBJECTS INTO GROUP TAGS")

for tag, content in pairs(module.tags) do
    print("TAG: ".. tag .." REGISTERED - ".. #content .. " OBJECTS TOTAL")
end


return module