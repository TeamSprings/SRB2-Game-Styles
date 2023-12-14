local gameString = "GBA"
local packType = '[Sonic Adv Style]'
local libReq = 1
local version = '2.2.12' -- Currently 2.2.10. UDMF support comes with 2.2.12


/*
	Sonic 3 Stylized Pack for SRB2
	@ Contributors: Ace Lite,
*/


assert((VERSION == 202), packType.."Mod doesn't support this version of SRB2")
assert((SUBVERSION > 9), packType.."Mod requires features from "..version.."+")


-- Shut up and load it in.

// Oh yeah, it is quite pointless check in grand scheme of things. 
// I just want to minimalize situation, where some genius decides 
// to play this on older version of SRB2.

// Man idiot proofing is so so SOO teadious :earless:
if VERSION == 202 and SUBVERSION > 9 then
	print(packType.."As this is WIP version of "..gameString.." pack and UDMF update is not out yet. Game allows to load this pack in "..VERSIONSTRING)
	
	// Libary file check, whenever or not newer version isn't used anywhere else
	if not TBSlib or ((TBSlib.iteration < libReq) or not TBSlib.iteration) then
		dofile("TBS_libary.lua")
	end
	
	// Game Assets
	dofile(gameString.."_sprite_models.lua")
	dofile(gameString.."_hud.lua")

end
