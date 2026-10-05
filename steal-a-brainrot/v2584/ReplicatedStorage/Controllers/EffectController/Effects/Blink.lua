local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require(script:FindFirstAncestor("Effects").Parent.Types)
local Blink = {}
local _ = script.Name
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
colorCorrectionEffect.Brightness = 0
colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
colorCorrectionEffect.Parent = workspace.CurrentCamera
local tween = TweenService:Create(
	colorCorrectionEffect,
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	{
		Brightness = 0
	}
)

function Blink.Activate(_)
	colorCorrectionEffect.Brightness = ReplicatedStorage:GetAttribute("WaterEvent") and 2 or 1
	tween:Cancel()
	tween:Play()
end

return Blink