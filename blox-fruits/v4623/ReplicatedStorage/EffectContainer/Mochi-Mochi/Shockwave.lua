local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local mochiMochi = FX:WaitForChild("Mochi-Mochi")
return function(list)
	local cFrame, v2, v3, v4 = unpack(list)
	local v5 = v4 and Vector3.new(1, v4, 1) * 0.004999999888241291 or createVector(0.005, 0.004, 0.005)
	local clone = mochiMochi.Shockwave:Clone()
	clone.Mesh.Scale = Vector3.new()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(clone, tweenInfo, {
		Transparency = 1
	})
	local tween2 = TweenService:Create(clone.Mesh, tweenInfo, {
		Scale = v5 * v2
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	tween2:Play()
end