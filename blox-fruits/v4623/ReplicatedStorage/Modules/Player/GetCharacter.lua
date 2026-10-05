local GetPlayer = require(game.ReplicatedStorage.Modules.Player.GetPlayer)
return function(p)
	local player = GetPlayer(p)

	if player then
		return player.Character
	end

	return nil
end