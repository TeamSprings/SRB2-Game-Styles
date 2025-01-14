--[[ 
		Pipe Kingdom Zone's Collectibles

Description:
Scripts needed on collectible side

Contributors: Ace Lite, Krabs(Checkpoints)
@Team Blue Spring 2022

Contains:
	SMS Alfredo - Shelmet; Mushroom Movement Thinker
--]]

freeslot("SPR_SCDC")

addHook("MapThingSpawn", function(a, tm)
	a.scale = $+FRACUNIT/4
		local topSuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_FRONTERADUMMY)
		topSuSpawn.target = a
		topSuSpawn.scale = a.scale
		topSuSpawn.state = S_BUSH
		topSuSpawn.sprite = SPR_SCDC
		topSuSpawn.frame = A|FF_TRANS20
		topSuSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION	

		local topSuSpawn = P_SpawnMobjFromMobj(a, 0,0,0, MT_BACKERADUMMY)
		topSuSpawn.target = a
		topSuSpawn.scale = a.scale
		topSuSpawn.state = S_BUSH
		topSuSpawn.sprite = SPR_SCDC
		topSuSpawn.frame = B
		topSuSpawn.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_PAPERCOLLISION
end, MT_EGGTRAP)
