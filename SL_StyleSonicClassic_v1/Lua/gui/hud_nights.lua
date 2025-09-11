
local Options = tbsrequire 'helpers/create_cvar'
local calc_help = tbsrequire 'helpers/c_inter'
local color_profile = tbsrequire 'gui/hud_colors'
local drawlib = tbsrequire 'libs/lib_emb_tbsdrawers'
local fonts = tbsrequire('gui/hud_fonts')

local HOOK = customhud.SetupItem
local write = drawlib.draw

local booster_anim = {
	"NIGHTS_BOOST_ANIM1",
	"NIGHTS_BOOST_ANIM2",
	"NIGHTS_BOOST_ANIM3",
	"NIGHTS_BOOST_ANIM3",
	"NIGHTS_BOOST_ANIM4",
	"NIGHTS_BOOST_ANIM4",
	"NIGHTS_BOOST_ANIM3",
	"NIGHTS_BOOST_ANIM3",
	"NIGHTS_BOOST_ANIM1",
}

local nights_boost_lastreg = 0
local nights_boost_tics = 0
local nights_boost_scale = 0

HOOK("nightsdrill", "classichud", function(v, stplyr)
    if stplyr.powers[pw_carry] == CR_NIGHTSMODE then
        local locx, locy = 16, 180;
        local sca = FU + abs(sin((nights_boost_scale * 360 * FU) / #booster_anim)) / 4

        if stplyr.drillmeter ~= nights_boost_lastreg and not nights_boost_tics then
            if stplyr.drillmeter > nights_boost_lastreg then
                nights_boost_scale = #booster_anim
            end

            nights_boost_tics = #booster_anim
            nights_boost_lastreg = stplyr.drillmeter
        end

        local fillpatch = v.getColormap(TC_DEFAULT, 0, booster_anim[nights_boost_tics])

        v.drawScaled(locx * sca, locy * sca, sca, v.cachePatch("DRILLBAR"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_HUDTRANS, fillpatch);
        for dfill = 0, 96 do
            if not (dfill < stplyr.drillmeter / 20 and dfill < 96) then break end

            v.drawScaled((locx + 2 + dfill)*sca, (locy + 3)*sca, sca, v.cachePatch("DRILLFI1"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_HUDTRANS, fillpatch);
        end

        if nights_boost_tics then
            nights_boost_tics = $ - 1
        end

        if nights_boost_scale then
            nights_boost_scale = $ - 1
        end
    end
end, "game", 1, 3)

local function P_GetNextEmerald()
    if (gamemap >= sstage_start and gamemap <= sstage_end) then
        return (gamemap - sstage_start);
    end

    if (gamemap >= smpstage_start or gamemap <= smpstage_end) then
        return (gamemap - smpstage_start);
    end

    return 0;
end

---@param v videolib
HOOK("nightsrings", "classichud", function(v, stplyr)
    if not ((maptol & TOL_NIGHTS) or G_IsSpecialStage(gamemap)) then return end

    local ssspheres = mapheaderinfo[gamemap].ssspheres

    local isspecialstage = G_IsSpecialStage(gamemap)
    local oldspecialstage = (isspecialstage and not (maptol & TOL_NIGHTS));

    local total_spherecount = 0;
    local total_ringcount = 0;

    local nights_colormap = v.getColormap(TC_DEFAULT, 0, color_profile.nights)

    v.draw(16, 8, v.cachePatch("NBRACKET"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);

    if (isspecialstage) then
        v.draw(24, 16,
        ((stplyr.bonustime and (leveltime & 4) and (states[S_BLUESPHEREBONUS].frame & FF_ANIMATE)) and v.cachePatch("NSSBON") or v.cachePatch("NSSHUD")),
        V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP);
    else
        v.draw(24, 16, (((stplyr.bonustime) and v.cachePatch("NSSBON") or v.cachePatch("NSSHUD"))+((leveltime/2)%12)), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP);
    end

    if (isspecialstage) then
        total_spherecount = 0;
        total_ringcount = 0

        for i = 0, #players-1 do
            if (not players[i]) then
                continue;
            end

            total_spherecount = $ + players[i].spheres;
            total_ringcount = $ + players[i].rings;
        end
    else
        total_spherecount = stplyr.spheres;
        total_ringcount = stplyr.spheres;
    end

    if (stplyr.capsule and stplyr.capsule.valid) then
        local amount;
        local length = 88;

        local origamount = stplyr.capsule.spawnpoint.args[1];

        v.draw(72, 8, v.cachePatch("NBRACKET"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);
        v.draw(74, 12, v.cachePatch("MINICAPS"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP);

        if (stplyr.capsule.reactiontime ~= 0) then

            local orblength = 20;

            for r = 0, 5 do
                v.draw(230 - (7*r), 144, v.cachePatch("REDSTAT"), V_PERPLAYER|V_HUDTRANS);
                v.draw(188 - (7*r), 144, v.cachePatch("ORNGSTAT"), V_PERPLAYER|V_HUDTRANS);
                v.draw(146 - (7*r), 144, v.cachePatch("YELSTAT"), V_PERPLAYER|V_HUDTRANS);
                v.draw(104 - (7*r), 144, v.cachePatch("BYELSTAT"), V_PERPLAYER|V_HUDTRANS);
            end

            amount = (origamount - stplyr.capsule.health);
            amount = (amount * orblength)/origamount;

            if (amount > 0) then
                local t;

                -- Fill up the bar with blue orbs... in reverse! (yuck)
                for r = amount, 0, -1 do
                    t = r;

                    if (r > 15) then t = $ + 1 end;
                    if (r > 10) then t = $ + 1 end;
                    if (r > 5) then t = $ + 1 end;

                    v.draw(69 + (7*t), 144, v.cachePatch("BLUESTAT"), V_PERPLAYER|V_HUDTRANS);
                end
            end
        else
            -- Lil' white box!
            v.draw(15, 42, v.cachePatch("CAPSBAR"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS);

            amount = (origamount - stplyr.capsule.health);
            amount = (amount * length)/origamount;

            for cfill = 0, min(amount, length) do
                v.draw(16 + cfill, 43, v.cachePatch("CAPSFILL"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS, nights_colormap);
            end
        end

        if (total_spherecount >= stplyr.capsule.health) then
            v.draw(40, 13, v.cachePatch("NREDAR"..((leveltime&7) + 1)), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);
        else
            v.draw(40, 13, v.cachePatch("NARROW"..(((leveltime/2)&7) + 1)), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);
        end

    elseif (oldspecialstage and total_spherecount < ssspheres) then

        local length = 88;
        local amount = (total_spherecount * length)/ssspheres;

        local em = P_GetNextEmerald();
        v.draw(72, 8, v.cachePatch("NBRACKET"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);

        local sprite = Options:getPureValue("emeralds")

        if (em <= 6) then
            v.draw(88, 32, v.getSpritePatch(sprite, em, 0, 0), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP);
        end

        v.draw(40, 8 + 5, v.cachePatch("NARROW"..(((leveltime/2)&7)) + 1), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);

        -- Lil' white box!
        v.draw(15, 8 + 34, v.cachePatch("CAPSBAR"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS);

        for cfill = 0, min(amount, length) do
            v.draw(15 + cfill + 1, 8 + 35, v.cachePatch("CAPSFILL"), V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS);
        end
    else
        v.draw(40, 8 + 5, v.cachePatch("NARROW8"), V_HUDTRANS|V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOTOP, nights_colormap);
    end

    if (oldspecialstage) then

        -- invert for s3k style junk
        total_spherecount = ssspheres - total_spherecount;
        if (total_spherecount < 0) then
            total_spherecount = 0;
        end

        if (calc_help.totalcoinnum > 0) then -- don't count down if there ISN'T a valid maximum number of rings, like sonic 3
            total_ringcount = calc_help.totalcoinnum - total_ringcount;
            if (total_ringcount < 0) then
                total_ringcount = 0;
            end
        end

        -- now rings! you know, for that perfect bonus.
        v.draw(272, 8, v.cachePatch("NBRACKET"), V_PERPLAYER|V_SNAPTOTOP|V_SNAPTORIGHT|V_HUDTRANS, nights_colormap);
        v.draw(280, 17, v.cachePatch("NRNG1"), V_PERPLAYER|V_SNAPTOTOP|V_SNAPTORIGHT|V_HUDTRANS);
        v.draw(280, 13, v.cachePatch("NARROW"..(((leveltime/2)&7) + 1)), V_FLIP|V_PERPLAYER|V_SNAPTOTOP|V_SNAPTORIGHT|V_HUDTRANS, nights_colormap);

        write(v, fonts.font..'TNUM', 262*FU, 18*FU, FU, total_ringcount, V_PERPLAYER|V_SNAPTOTOP|V_SNAPTORIGHT|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "center", fonts.padding)
    end

    write(v, fonts.font..'TNUM', 60*FU, 18*FU, FU, total_spherecount, V_PERPLAYER|V_SNAPTOTOP|V_SNAPTOLEFT|V_HUDTRANS, v.getColormap(TC_DEFAULT, 1, color_profile.numbers), "center", fonts.padding)


end, "game", 1, 3)