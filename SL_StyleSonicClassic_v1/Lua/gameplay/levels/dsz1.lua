return {
			name = "Deep Sea",
			hash = -888824694,

            -- Cutscenes
            _in = {
                {   tics = 0, func = function(p, mo)
                        P_SetOrigin(mo, mo.x, mo.y, mo.z + 256 * FU)
                        P_InstaThrust(mo, mo.angle, 35 * FU)

                        if p.mo then
                            p.mo.state = S_PLAY_PAIN
                        end
                    end
                },
                {  tics = 3 * TICRATE / 2,
                },
            },
		}