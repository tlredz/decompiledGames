game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Electrician",
	Icon = "rbxassetid://17702364713",
	Description = "Decreases the chance of a Blackout occuring on future floors.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 0.9
			numberValue.Parent = cardModifiers
		end
	end
}