local net = {}

local sending_chao_data = false

-- @var1 - name
-- @var2 - stats SWIM|FLY|RUN|POWER|STAMINA
-- @var3 - attributes SKINCOLOR_ID|TYPE|AGE|HEAD|HANDS|LEGS

COM_AddCommand("dc_sendmpdata", function(player, name, stats, attributes)
	if sending_chao_data then
		-- write Chao send data parsing here.
		sending_chao_data = false
	end
end)

addHook("PlayerJoin", function(p_int)
	sending_chao_data = true
	net[players[p_int]] = {}
	COM_BufInsertText(players[p_int], "dc_sendmpdata \"chao\" 8|2|8|1|4 8|3|4|1|4")
end)

addHook("PlayerQuit", function(player)
	net[player] = nil
end)

function net:getChao(self)
	return
end


return net