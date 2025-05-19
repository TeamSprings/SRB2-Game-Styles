--[[

	Polishing Experience

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]

local Options = tbsrequire 'helpers/create_cvar'
local retrolib = {val = 0}
local monitoriconrot = 0

local retro_opt = Options:new("polish", {
	[0] = {0, "disabled",		"Disabled"},
	[1] = {1, "custom",			"Custom"},
	[2] = {2, "mania",			"Custom Mania"},
},
function(var)
	retrolib.val = var.value
end)

local rotation_opt = Options:new("monitoriconrot", {
	[0] = {0, "disabled",		"Disabled/Knuckles Chaotix"},
	[1] = {1, "classic",		"Classic"},
	--[2] = {2, "mania",			"Mania"},
},
function(var)
	monitoriconrot = var.value
end, CV_NETVAR)


function retrolib.shortFading(mo)
	if retrolib.val then
		mo.flags2 = $ &~ MF2_DONTDRAW

		if mo.fuse and mo.fuse < TICRATE/4 then
			mo.alpha = mo.fuse * FRACUNIT / (TICRATE/4)
		end
	end
end

function retrolib.fading(mo)
	if retrolib.val then
		mo.flags2 = $ &~ MF2_DONTDRAW

		if mo.fuse and mo.fuse < 2 * TICRATE then
			mo.alpha = mo.fuse * FRACUNIT / (2 * TICRATE)
		end
	end
end

local recursion_limit = 32

function retrolib.fadingStateNull(mo)
	if retrolib.val and not mo.styles_toolong then
		if mo.styles_lifespan == nil then
			mo.styles_lifespan = 0
			local nextst = mo.info.spawnstate
			local recus = 0

			while (nextst ~= S_NULL) do
				if recursion_limit < recus then
					mo.styles_toolong = true
					break
				end

				recus = $ + 1
				mo.styles_lifespan = $ + max(states[nextst].tics, 0)
				nextst = states[nextst].nextstate
			end
		elseif mo.styles_lifespan then
			mo.styles_lifespan = $ - 1
		end

		if mo.styles_lifespan < 3 then
			mo.alpha = (mo.styles_lifespan * 6 / 3) * FRACUNIT / 6
		end
	end
end

function retrolib.fadingStateNullLonger(mo)
	if retrolib.val and not mo.styles_toolong then
		if mo.styles_lifespan == nil then
			mo.styles_lifespan = 0
			local nextst = mo.info.spawnstate
			local recus = 0

			while (nextst ~= S_NULL) do
				if recursion_limit < recus then
					mo.styles_toolong = true
					break
				end

				recus = $ + 1
				mo.styles_lifespan = $ + max(states[nextst].tics, 0)
				nextst = states[nextst].nextstate
			end
		elseif mo.styles_lifespan then
			mo.styles_lifespan = $ - 1
		end

		if mo.styles_lifespan < TICRATE/3 then
			mo.alpha = (mo.styles_lifespan) * FRACUNIT / (TICRATE/3)
		end
	end
end

function retrolib.fadingMonitorStateNull(mo)
	if monitoriconrot then
		mo.frame = states[mo.info.spawnstate].frame
		mo.momz = P_MobjFlip(mo) * mo.scale * 6

		if retrolib.val and not styles_toolong then
			if mo.styles_lifespan == nil then
				mo.styles_lifespan = 0
				local nextst = mo.info.spawnstate
				local recus = 0

				while (nextst ~= S_NULL) do
					if recursion_limit < recus then
						mo.styles_toolong = true
						break
					end

					recus = $ + 1
					mo.styles_lifespan = $ + max(states[nextst].tics, 0)

					nextst = states[nextst].nextstate
				end
			elseif mo.styles_lifespan then
				mo.styles_lifespan = $ - 1
			end

			if mo.styles_lifespan < 3 then
				mo.alpha = (mo.styles_lifespan * 6 / 3) * FRACUNIT / 6
			end
		end
	end
end


addHook("MobjThinker", retrolib.fadingStateNullLonger, MT_SCORE)

addHook("MobjThinker", retrolib.fading, MT_FLINGRING)
addHook("MobjThinker", retrolib.fading, MT_FLINGBLUESPHERE)
addHook("MobjThinker", retrolib.fading, MT_FLINGEMERALD)
addHook("MobjThinker", retrolib.fading, MT_FLINGNIGHTSCHIP)
addHook("MobjThinker", retrolib.fading, MT_FLINGNIGHTSSTAR)

return retrolib