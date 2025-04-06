--[[

		Sonic Adventure Style's Player Stuff

Contributors: Skydusk
@Team Blue Spring 2022-2025

]]


local cvar = CV_FindVar("dc_playereffects")

local function P_RemoveJumpBall(p)
	if p.styles_jumpball then
		if p.styles_jumpball.valid then
			P_RemoveMobj(p.styles_jumpball)
		end

		p.styles_jumpball = nil
	end

	if p.styles_jumptrail1 then
		if p.styles_jumptrail1.valid then
			P_RemoveMobj(p.styles_jumptrail1)
		end

		p.styles_jumptrail1 = nil
	end

	if p.styles_jumptrail2 then
		if p.styles_jumptrail2.valid then
			P_RemoveMobj(p.styles_jumptrail2)
		end

		p.styles_jumptrail2 = nil
	end
end

states[S_THOK].frame = A|FF_TRANS40|FF_ADD

local emptyTrail = freeslot("MT_STYLES_EMPTYSPINTRAIL")
local newTrail = freeslot("MT_STYLES_SPINTRAIL")
mobjinfo[newTrail].spawnstate = mobjinfo[MT_THOK].spawnstate
mobjinfo[newTrail].flags = mobjinfo[MT_THOK].flags

addHook("PlayerThink", function(p)
	if cvar.value > 0 then
		if p.thokitem == MT_THOK then
			p.thokitem = emptyTrail
		end

		if p.spinitem == MT_THOK then
			p.spinitem = newTrail
		end

		if p.revitem == MT_THOK then
			p.revitem = newTrail
		end

		if p.mo and (p.pflags & PF_JUMPED) and not (p.pflags & PF_NOJUMPDAMAGE) then
			if not (p.styles_jumpball or (p.pflags & PF_THOKKED)) then
				p.styles_jumpball = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_OVERLAY)

				p.styles_jumpball.state = S_INVISIBLE
				p.styles_jumpball.sprite = states[S_THOK].sprite
				p.styles_jumpball.color = p.mo.color
				p.styles_jumpball.frame = states[S_THOK].frame
				p.styles_jumpball.target = p.mo
				p.styles_jumpball.spriteyoffset = -10*FRACUNIT
				p.styles_jumpball.dispoffset = -20
				p.styles_jumpball.fuse = 8

				if cvar.value == 1 then
					p.styles_jumpball.flags2 = MF2_DONTDRAW
				end

				p.styles_jumpball.spritexscale = 5*FRACUNIT/4
				p.styles_jumpball.spriteyscale = 5*FRACUNIT/4

				if cvar.value == 2 then
					-- lel
					if not p.styles_jumptrail1 then
						p.styles_jumptrail1 = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_THOK)
						p.styles_jumptrail1.state = S_INVISIBLE
						p.styles_jumptrail1.sprite = states[S_THOK].sprite
						p.styles_jumptrail1.frame = states[S_THOK].frame
						p.styles_jumptrail1.color = p.mo.color
						p.styles_jumptrail1.spritexscale = p.styles_jumpball.spritexscale/2
						p.styles_jumptrail1.spriteyscale = p.styles_jumpball.spriteyscale/2
						p.styles_jumptrail1.fuse = 8
					end

					if not p.styles_jumptrail2 then
						p.styles_jumptrail2 = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_THOK)
						p.styles_jumptrail2.state = S_INVISIBLE
						p.styles_jumptrail2.sprite = states[S_THOK].sprite
						p.styles_jumptrail2.frame = states[S_THOK].frame
						p.styles_jumptrail2.color = p.mo.color
						p.styles_jumptrail2.spritexscale = p.styles_jumpball.spritexscale/4
						p.styles_jumptrail2.spriteyscale = p.styles_jumpball.spriteyscale/4
						p.styles_jumptrail2.fuse = 8
					end
				end

				if (p.mo.state ~= S_PLAY_JUMP) then
					P_RemoveJumpBall(p)
				end
			else
				if p.styles_jumpball then
					p.styles_jumpball.fuse = 8
				end

				if p.styles_jumptrail1 then
					P_MoveOrigin(p.styles_jumptrail1, p.mo.x - p.mo.momx/2, p.mo.y - p.mo.momy/2, p.mo.z - p.mo.momz/2)
					p.styles_jumptrail1.fuse = 8
				end

				if p.styles_jumptrail2 then
					P_MoveOrigin(p.styles_jumptrail2, p.mo.x - p.mo.momx, p.mo.y - p.mo.momy, p.mo.z - p.mo.momz)
					p.styles_jumptrail2.fuse = 8
				end

				if (p.mo.state ~= S_PLAY_JUMP) then
					P_RemoveJumpBall(p)
				end

				if (p.pflags & PF_THOKKED) then
					P_RemoveJumpBall(p)

					if p.styles_jumptrailtimer and (p.charability == CA_THOK or p.charability == CA_HOMINGTHOK or p.charability == CA_JUMPTHOK) then
						P_SpawnSpinMobj(p, newTrail)

						p.styles_jumptrailtimer = $ - 1
					end
				else
					p.styles_jumptrailtimer = TICRATE/4
				end
			end
		elseif p.styles_jumpball then
			P_RemoveJumpBall(p)
		end
	elseif p.styles_jumpball then
		P_RemoveJumpBall(p)
	else
		if p.realmo and p.realmo.valid then
			if (p.thokitem == emptyTrail or p.revitem == newTrail) then
				p.thokitem = skins[p.mo.skin].thokitem == -1 and MT_THOK or skins[p.mo.skin].thokitem
				p.revitem = skins[p.mo.skin].revitem -1 and MT_NULL or skins[p.mo.skin].revitem
			end

			if p.spinitem == newTrail then
				p.spinitem = skins[p.mo.skin].spinitem == -1 and MT_THOK or skins[p.mo.skin].spinitem
			end
		end
	end
end)