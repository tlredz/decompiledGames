local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame
	delay(p.Delay, function()
		local clone = script.SpinWind:Clone()
		clone.Size = clone.Size * 0.7 * createVector(4, 1, 1)
		clone.CFrame = (cFrame + createVector(0, 2, 0)) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			0,
			0
		)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.2 + math.random() * 0.3, Enum.EasingStyle.Quad), {
			Size = clone.Size * createVector(0, 2.5, 1) * 0.5 * (1 + 0.15 * math.random()),
			Transparency = 1,
			CFrame = clone.CFrame * CFrame.Angles(math.random() * 3.141592653589793 * 2, 0, 0)
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end)
end