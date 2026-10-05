local Players = game:GetService("Players")
local color = Color3.fromRGB(180, 230, 255)
return function(parent)
	if typeof(parent) ~= "Instance" then
		return
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoid == nil or humanoid.Health <= 0 or parent:FindFirstChild("SummonMark") ~= nil then
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart") or parent.PrimaryPart

	if humanoidRootPart == nil or humanoidRootPart2 == nil or (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude > 140 then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "SummonMark"
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 1
	highlight.OutlineColor = color
	highlight.Parent = parent
	humanoid.Died:Once(function()
		highlight:Destroy()
	end)
end