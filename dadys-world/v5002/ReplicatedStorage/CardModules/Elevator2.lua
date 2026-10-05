game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Etiquette",
	Icon = "rbxassetid://17702364350",
	Description = "Adds 5 seconds to the elevator panic timer.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 5
			numberValue.Parent = cardModifiers
		end
	end
}