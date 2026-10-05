game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Frugal",
	Icon = "rbxassetid://17702364506",
	Description = "Applies a 10% Discount to all Dandy's Shop items.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 0.9
			numberValue.Parent = cardModifiers
		end
	end
}