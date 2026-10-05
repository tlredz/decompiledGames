game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Endurance",
	Icon = "rbxassetid://17702363283",
	Description = "Increases the max Stamina of all Toons by 10.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 10
			numberValue.Parent = cardModifiers

			for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
				if not child then
					continue
				end

				local stats = child:WaitForChild("Stats")
				local originalStamina = stats:WaitForChild("OriginalStamina")
				local currentStamina = stats:WaitForChild("CurrentStamina")
				originalStamina.Value += numberValue.Value
				currentStamina.Value += numberValue.Value
			end
		end
	end
}