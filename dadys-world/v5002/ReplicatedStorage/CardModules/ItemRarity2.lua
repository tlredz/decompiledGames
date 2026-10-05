game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Covetous",
	Icon = "rbxassetid://17702364184",
	Description = "Slightly increases the chances of rarer items appearing on Floors and in Dandy's Shop.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 0.9
			numberValue.Parent = cardModifiers
		end
	end
}