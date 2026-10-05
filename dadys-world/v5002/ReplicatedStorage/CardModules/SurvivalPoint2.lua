game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Penny Pincher",
	Icon = "rbxassetid://17702363111",
	Description = "Every Toon receives 45 Tapes.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 15
			numberValue.Parent = cardModifiers

			for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
				if not child then
					continue
				end

				local child2 = workspace.Info.PlayerStats:FindFirstChild(child.Name)

				if not child2 then
					continue
				end

				local survivalPoints = child2:WaitForChild("SurvivalPoints")
				survivalPoints.Value += 45
			end
		end
	end
}