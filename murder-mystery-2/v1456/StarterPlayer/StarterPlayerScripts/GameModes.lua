local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function onShowTeammates(items)
	for _, childName in items do
		local child = game.Players:FindFirstChild(childName)

		if not (child and child ~= game.Players.LocalPlayer) then
			continue
		end

		local character = child.Character

		if not character then
			break
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			break
		end

		local clone = script.TeamMate:Clone()
		clone.Enabled = true
		clone.Parent = humanoidRootPart
	end
end

ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("ShowTeammates").OnClientEvent:Connect(onShowTeammates)