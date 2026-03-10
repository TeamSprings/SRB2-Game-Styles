local foundClassic = false

local cutscenes = {}

local function get(path)
    local path = path .. ".lua"
    if cutscenes[path] then
        return cutscenes[path]
    else
        Style_DebugScriptsTotal = $ + 1

        local func, err = loadfile(path)
        if func then
            cutscenes[path] = func()
            Style_DebugScriptsLoaded = $ + 1

            return cutscenes[path]
        end
    end
end


addHook("AddonLoaded", function()
    if not foundClassic and Style_ClassicVersionString then
        local df = tbsrequire('gameplay/stash/cutscenes')

        Style_RegisterAddonClassic("classic style cutscenes", "0.1", "Cut cutscenes from Classic Style")

        local gfz1cutscenes = get("greenflower1")
        local gfz1 = tbsrequire('gameplay/levels/vanilla/greenflower/act1')
        local gfz2 = tbsrequire('gameplay/levels/vanilla/greenflower/act2')

        local dsz1 = tbsrequire('gameplay/levels/vanilla/deepsea/act1')

        gfz1._in = gfz1cutscenes._in
        gfz1._out = gfz1cutscenes._out

        gfz2._in = df.fallOff

        dsz1._in = {
            {
                tics = 0, func = function(p, mo)
                    P_SetOrigin(mo, mo.x, mo.y, mo.z + 256 * FU)
                    P_InstaThrust(mo, mo.angle, 35 * FU)

                    if p.mo then
                        p.mo.state = S_PLAY_PAIN
                    end
                end
            },
            {  tics = 3 * TICRATE / 2, },
        }

        foundClassic = true
    end
end)

