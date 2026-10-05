local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
local tweenInfo2 = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
return function(p: number?, p2: string)
	local color

	if p ~= nil then
		color = Rarities.Gradients[p]
	end

	if color == nil then
		return nil
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = color
	local v2

	if p2 == "Drift" then
		uIGradient.Offset = Vector2.new(-0.5, 0)
		v2 = {
			Offset = Vector2.new(0.5, 0)
		}
	else
		v2 = {
			Rotation = 360
		}
	end

	local v4

	if p2 == "Spin" then
		v4 = tweenInfo
	else
		v4 = tweenInfo2
	end

	local v5 = TweenService:Create(uIGradient, v4, v2)
	v5:Play()
	uIGradient.Destroying:Once(function()
		v5:Cancel()
	end)
	return uIGradient
end