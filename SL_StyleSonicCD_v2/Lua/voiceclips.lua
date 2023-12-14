sfxinfo[freeslot("sfx_sonout")].caption = "Timelimit"
sfxinfo[freeslot("sfx_cdjump")].caption = "Jump"

addHook("PlayerSpawn", function(p)
	p.mo.deathfall = false
end)

addHook("PlayerThink", function(p)

	if p.mo.skin == "sonic" and p.mo.state == S_PLAY_WAIT then
		if not p.mo.deathxcounter and p.mo.deathxcounter ~= 0 then
			p.mo.deathxcounter = TICRATE*180
		end
		p.mo.deathxcounter = $ - 1
	else
		p.mo.deathxcounter = nil
	end
	
	local camstuck = {}
	if p.mo.deathxcounter and p.mo.deathxcounter <= 0 and p.mo.state ~= S_PLAY_DEAD then
		camstuck.x = camera.x
		camstuck.y = camera.y
		camstuck.z = camera.z
		p.mo.momx = 15*cos(p.mo.angle)
		p.mo.momy = 15*sin(p.mo.angle)
		p.mo.momz =	18*FRACUNIT
		p.mo.flags = $|MF_NOCLIPHEIGHT|MF_NOCLIP
		p.mo.deathfall = true
		S_StartSound(p.mo, sfx_sonout)
		p.mo.state = S_PLAY_FALL		
	end
	
	if p.mo.deathfall == true and camstuck.x then
		P_TeleportCameraMove(camera, camstuck.x, camstuck.y, camstuck.z)
	end

	if p.mo.state == S_PLAY_SPINDASH then
		if input.gameControlDown(GC_CUSTOM2) then
			p.mo.state = S_PLAY_RUN	
		else
			p.mo.state = S_PLAY_ROLL
		end
	end

end)