--[[
		Linedef Executors for SA inspired Maps

Contributors: Ace Lite
@Team Blue Spring 2022-2023

--]]

if not _G["sfx_advspr"] then
	sfxinfo[freeslot("sfx_advspr")].caption = "Spring"
end

local function SpringBounce(line,mobj,sector)
	mobj.momx = 0
	mobj.momy = 0
    mobj.momz = line.args[0]*FRACUNIT
	S_StartSound(mobj, sfx_advspr)
	
	if not mobj.player then return end
	mobj.player.pflags = $ | PF_JUMPED
	mobj.state = S_PLAY_JUMP
end

addHook("LinedefExecute", SpringBounce, "SPRBNC")