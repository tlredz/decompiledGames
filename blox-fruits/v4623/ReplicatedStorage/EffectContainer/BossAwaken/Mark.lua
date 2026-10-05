local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local color = Color3.fromRGB(255, 90, 40)
return function(player)
	local target = player.Target or player.Character
	local delay = player.Delay or 0

	if typeof(target) ~= "Instance" or not (target:IsA("Model") or target:IsA("BasePart")) then
		return
	end

	if delay > 0 then
		task.wait(delay)
	end

	if not target.Parent then
		return
	end

	local color2

	if typeof(player.Color) == "Color3" then
		color2 = player.Color
	else
		color2 = color
	end

	local hold = player.Hold or 0.9
	local highlight = Instance.new("Highlight")
	highlight.Name = "BossAwakenMark"
	highlight.FillColor = color2
	highlight.OutlineColor = color2
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = target
	highlight.Parent = target
	debris:AddItem(highlight, 0.35 + hold + 0.6 + 0.2)
	TweenService:Create(highlight, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		FillTransparency = player.FillTransparency or 0.45,
		OutlineTransparency = 0
	}):Play()
	task.delay(0.35 + hold, function()
		if not highlight.Parent then
			return
		end

		TweenService:Create(highlight, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			FillTransparency = 1,
			OutlineTransparency = 1
		}):Play()
	end)
end