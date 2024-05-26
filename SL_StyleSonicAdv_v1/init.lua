local gameString = "DC"
local packType = '[Sonic Adventure Style]'
local version = '2.2.13'

--[[
	Sonic Adventure Stylized Pack for SRB2
	@ Contributors: Ace Lite,
]]

assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")
assert((SUBVERSION > 12), packType.."Mod requires features from "..version.."+")

-- Pointless really, merely attempt to create iterator, possibly useful for other type of iterations
local function iterator_n(array, n) if n < #array then n = $+1 return n, array[n] end end
local function iterator(array) return iterator_n, array, 0 end

local function macro_dofile(prefix, ...)
	local array = {...}
	for _,use in iterator(array) do
		dofile(prefix..'_'..use)
	end
end

-- Shut up and load it in.

-- Oh yeah, it is quite pointless check in grand scheme of things.
-- I just want to minimalize situation, where some genius decides
-- to play this on older version of SRB2.

-- Don't forget to mercilessly tease everyone by git push.

-- Man idiot proofing is so so SOO teadious :earless:
if VERSION == 202 and SUBVERSION > 9 then
	print(packType.."As this is WIP version of "..gameString.." pack and UDMF update is not out yet. Game allows to load this pack in "..VERSIONSTRING)

	-- Libary file check, whenever or not newer version isn't used anywhere else
	--if not TBSlib or ((TBSlib.iteration < libReq) or not TBSlib.iteration) then
	--	dofile("TBS_libary.lua")
	--end

	dofile("LIB_TBS_lite.lua")

	 macro_dofile(gameString,
	 "game_globals.lua",

	 "objects_custom.lua",

	 "models_common.lua",
	 "models_itembox.lua",
	 "models_checkpoint.lua",
	 "models_capsule.lua",

	 "user_interface.lua")

	-- Globals
	--macro_dofile("game_globals.lua")

	-- Game Assets
	--macro_dofile("objects_custom.lua")

	--macro_dofile("models_common.lua")
	--macro_dofile("models_itembox.lua")
	--macro_dofile("models_checkpoint.lua")
	--macro_dofile("models_capsule.lua")

	--macro_dofile("user_interface.lua")

end
