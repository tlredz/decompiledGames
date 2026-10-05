local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "TextFloatingEffect"
})
local TweenService = game:GetService("TweenService")

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local instance = p.Instance
	local position = instance.Position
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			TextTransparency = 0.42
		}
	)
	local tween2 = TweenService:Create(
		instance,
		TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
		{
			Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset - 8)
		}
	)
	tween:Play()
	tween2:Play()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v