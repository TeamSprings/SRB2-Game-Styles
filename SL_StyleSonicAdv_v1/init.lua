local gameString = "DC"
local packType = '[Sonic Adventure Style]'
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

// Don't forget to mercilessly tease everyone by git push.

// Man idiot proofing is so so SOO teadious :earless:
if VERSION == 202 and SUBVERSION > 9 then
	print(packType.."As this is WIP version of "..gameString.." pack and UDMF update is not out yet. Game allows to load this pack in "..VERSIONSTRING)
	
	// Libary file check, whenever or not newer version isn't used anywhere else
	//if not TBSlib or ((TBSlib.iteration < libReq) or not TBSlib.iteration) then
	//	dofile("TBS_libary.lua")
	//end
	
	// Settings, I/O etc.
	dofile(gameString.."_cvar_settings.lua")
	
	// Game Assets
	dofile(gameString.."_objects_custom.lua")
	dofile(gameString.."_map_executable.lua")	
	
	dofile(gameString.."_models_common.lua")
	dofile(gameString.."_models_itembox.lua")
	dofile(gameString.."_models_checkpoint.lua")
	dofile(gameString.."_models_capsule.lua")	
	
	dofile(gameString.."_user_interface.lua")
	
	// menutest
	dofile("customexetests/test_testexe.lua")
end
