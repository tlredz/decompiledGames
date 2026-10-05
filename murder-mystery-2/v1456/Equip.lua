script.Parent.Parent.Game.Knife.Activated:connect(function()
	for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
		if not (tool:IsA("Tool") and tool:FindFirstChild("KnifeClient")) then
			continue
		end

		tool.Parent = game.Players.LocalPlayer.Character
		return
	end

	for _, tool in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
		if not (tool:IsA("Tool") and tool:FindFirstChild("KnifeClient")) then
			continue
		end

		tool.Parent = game.Players.LocalPlayer.Backpack
		break
	end
end)
script.Parent.Parent.Game.Gun.Activated:connect(function()
	for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
		if not (tool:IsA("Tool") and tool:FindFirstChild("KnifeLocal")) then
			continue
		end

		tool.Parent = game.Players.LocalPlayer.Character
		return
	end

	for _, tool in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
		if not (tool:IsA("Tool") and tool:FindFirstChild("KnifeLocal")) then
			continue
		end

		tool.Parent = game.Players.LocalPlayer.Backpack
		break
	end
end)