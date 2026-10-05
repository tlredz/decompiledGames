game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Sparkplug",
	Icon = "rbxassetid://17701467532",
	Description = "Toons will glow slightly brighter during Blackouts.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 1.15
			numberValue.Parent = cardModifiers
		end
	end
}