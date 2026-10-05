local Players = game:GetService("Players")
local characterObjects = {}
local v2 = {}

local function handleCharacterUpdate(player, folder)
	for _, connection in v2[player] do
		connection:Disconnect()
	end

	for k, v3 in characterObjects do
		if v3 == player then
			characterObjects[k] = nil
		end
	end

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			characterObjects[part] = player
		end
	end

	table.insert(v2[player], folder.DescendantAdded:Connect(function(part)
		if not part:IsA("BasePart") then
			return
		end

		characterObjects[part] = player
	end))
	table.insert(v2[player], folder.DescendantRemoving:Connect(function(part)
		if not part:IsA("BasePart") then
			return
		end

		characterObjects[part] = nil
	end))
end

local function onPlayerAdded(player)
	v2[player] = {}
	player.CharacterAdded:Connect(function(character)
		handleCharacterUpdate(player, character)
	end)

	if player.Character then
		handleCharacterUpdate(player, player.Character)
	end
end

local function onPlayerRemoving(p)
	for _, connection in v2[p] do
		connection:Disconnect()
	end

	v2[p] = nil

	for k, v3 in characterObjects do
		if v3 == p then
			characterObjects[k] = nil
		end
	end
end

return {
	characterObjects = characterObjects,
	start = function()
		local playerAddedConnection = Players.PlayerAdded:Connect(onPlayerAdded)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(onPlayerRemoving)

		for _, v3 in Players:GetPlayers() do
			onPlayerAdded(v3)
		end

		return playerAddedConnection, playerRemovingConnection
	end,
	onPlayerAdded = onPlayerAdded,
	onPlayerRemoving = onPlayerRemoving
}