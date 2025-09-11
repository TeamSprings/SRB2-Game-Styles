local chaotixblock = true

addHook("AddonLoaded", function()
	if chaotixblock and chaotix then
		local _chaotix = chaotix

		local mighty = _chaotix.mighty

		-- Scaffolding because I do not trust anything with chaotix name
		-- Give me unique mod IDs already!
		if mighty then
			customhud.ToggleRaws("game", "Lua/2_Mighty/mighty_memes.lua", nil, nil, nil, false)
			chaotixblock = nil
		end
	end
end)