local Ragdoll = require(game.ReplicatedStorage.Modules.Ragdoll)

local function register_character(p)
	return Ragdoll:Register(p)
end

local function register_player(player)
	player.CharacterAdded:connect(register_character)

	if player.Character then
		return task.spawn(register_character, player.Character)
	end
end

game.Players.PlayerAdded:connect(register_player)

for _, v in game.Players:GetPlayers() do
	v.CharacterAdded:connect(register_character)

	if v.Character then
		task.spawn(register_character, v.Character)
	end
end