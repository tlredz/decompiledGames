local HideKills = {
	Btn = 1,
	SortOrder = 6,
	Val = "HiddenKills",
	Desc = "Hides your kills on the leaderboard"
}
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return HideKills
end

require(script.FormatNumber)

local function playerJoin(instance)
	local leaderstats = instance:WaitForChild("leaderstats")
	local folder = Instance.new("Folder", leaderstats)
	folder.Name = "Hidden"
	local kills = leaderstats:WaitForChild("Kills")

	local function update()
		local value = kills.Value
		kills.Value = -1
		kills.Parent = leaderstats:GetAttribute("HiddenKills") and folder or leaderstats
		kills.Value = value
	end

	local value = kills.Value
	kills.Value = -1
	local parent

	if leaderstats:GetAttribute("HiddenKills") then
		parent = folder or leaderstats
	else
		parent = leaderstats
	end

	kills.Parent = parent
	kills.Value = value
	leaderstats:GetAttributeChangedSignal("HiddenKills"):Connect(update)
end

game.Players.PlayerAdded:Connect(playerJoin)

for _, v in game.Players:GetPlayers() do
	task.spawn(playerJoin, v)
end

return HideKills