local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local gradient = FX:WaitForChild("Dark").Gradient

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data)
	local transparency = data.Transparency or 0.5
	local duration = data.Duration or 0.5
	local range = data.Range or 250
	local v = (data.Distance or (currentCamera.CFrame.p - currentCamera.Focus.p).Magnitude) / range
	local darkGradient = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Dark/Gradient")

	if data.Toggle then
		if not darkGradient then
			darkGradient = gradient.Gradient:Clone()
			darkGradient.Name = "Dark/Gradient"
			darkGradient.Parent = game.Players.LocalPlayer.PlayerGui
		end

		TweenService:Create(
			darkGradient.Gradient,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				ImageTransparency = transparency + (1 - transparency) * v
			}
		):Play()
	else
		if not darkGradient then
			return
		end

		darkGradient.Name ..= "/Destroying"
		TweenService:Create(
			darkGradient.Gradient,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				ImageTransparency = 1
			}
		):Play()
		task.wait(duration)
		darkGradient:Destroy()
	end
end