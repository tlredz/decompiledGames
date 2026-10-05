local GetPlayer = require(game.ReplicatedStorage.Modules.Player.GetPlayer)
return function(p)
	local player = GetPlayer(p)

	if player and player.Character then
		return player.Character:FindFirstChildOfClass("Humanoid")
	end

	return nil
end