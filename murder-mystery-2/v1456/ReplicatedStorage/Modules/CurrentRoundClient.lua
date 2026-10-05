local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getCurrentPlayerData = remotes:WaitForChild("Gameplay"):WaitForChild("GetCurrentPlayerData")
local CurrentRoundClient = {
	PlayerData = {},
	PlayerDataChanged = script:WaitForChild("PlayerDataChanged")
}

local function onPlayerDataChanged(playerData)
	CurrentRoundClient.PlayerData = playerData
	CurrentRoundClient.PlayerDataChanged:Fire()
end

function CurrentRoundClient.GetLatestPlayerData()
	return getCurrentPlayerData:InvokeServer()
end

function CurrentRoundClient.GetMurdererPerk()
	for _, v in CurrentRoundClient.PlayerData do
		if v.Role == "Murderer" then
			return v.Perk
		end
	end

	return nil
end

CurrentRoundClient.PlayerData = getCurrentPlayerData:InvokeServer() or {}
remotes:WaitForChild("Gameplay"):WaitForChild("PlayerDataChanged").OnClientEvent:Connect(onPlayerDataChanged)
return CurrentRoundClient