game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Suppression",
	Icon = "rbxassetid://17702363523",
	Description = "Reduces the amount of speed Twisteds gain in Panic Mode by 5%.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = -0.05
			numberValue.Parent = cardModifiers
		end
	end
}