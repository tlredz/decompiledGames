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

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local v = 1 - p.Offset * 0.66
	local clone = script.Part.Attachment:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace.Terrain
	clone.GroundSmog.Size = NumberSequence.new(5, 20)
	clone.GroundSmog.Lifetime = NumberRange.new(0.4 * v, 0.6 * v)
	clone.Sparkle.Lifetime = NumberRange.new(0.4 * v, 1.4 * v)
	clone.Sparkle:Emit(3)
	clone.GroundSmog:Emit(1)
	local clone2 = script.SpinWind:Clone()
	clone2.Size *= 0.2
	clone2.CFrame = (cFrame + createVector(0, 2, 0)) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
		math.random() * 3.141592653589793 * 2,
		0,
		0
	)
	clone2.Parent = workspace._WorldOrigin
	local tween = TweenService:Create(clone2, TweenInfo.new((0.4 + math.random() * 0.4) * v, Enum.EasingStyle.Quad), {
		Size = clone2.Size * Vector3.new(1.25, 3.25 * v, 3.25 * v) * (1 + 0.15 * math.random()),
		Transparency = 1,
		CFrame = clone2.CFrame * CFrame.Angles(math.random() * 3.141592653589793 * 2, 0, 0)
	})
	tween.Completed:Connect(function()
		clone2:Destroy()
	end)
	tween:Play()
	wait(1.5 * v)
	clone:Destroy()
end