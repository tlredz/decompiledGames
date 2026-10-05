game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Tech Savvy",
	Icon = "rbxassetid://17702363744",
	Description = "Decreases the amount of time needed to fill up Machines by 5 seconds.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = -5
			numberValue.Parent = cardModifiers
		end
	end
}