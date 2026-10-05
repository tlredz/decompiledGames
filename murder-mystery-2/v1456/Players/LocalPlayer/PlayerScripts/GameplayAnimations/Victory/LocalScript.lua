local sheriffVictory = script.Parent.SheriffVictory
sheriffVictory.Visible = true
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local v = { TweenService:Create(sheriffVictory.Container, tweenInfo, {
		Size = UDim2.new(1, 0, 1, 0)
	}), TweenService:Create(sheriffVictory.KnifeRight, tweenInfo, {
		Position = UDim2.new(0.975, 0, 0.5, 0),
		Rotation = 0
	}), TweenService:Create(sheriffVictory.KnifeLeft, tweenInfo, {
		Position = UDim2.new(0.025, 0, 0.5, 0),
		Rotation = 0
	}) }

for _, v2 in pairs(v) do
	v2:Play()
end