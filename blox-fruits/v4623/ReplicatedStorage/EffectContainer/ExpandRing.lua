local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ring = ReplicatedStorage:WaitForChild("Assets").Meshes.Ring
return function(data)
	local origin = data.Origin or CFrame.new()
	local easingDirection = data.EasingDirection or Enum.EasingDirection.Out
	local easingStyle = data.EasingStyle or Enum.EasingStyle.Sine
	local color = data.Color or Color3.new(1, 1, 1)
	local transparency = data.Transparency or { 0, 1 }
	local size = data.Size or { Vector3.new(), createVector(2, 2, 1) }
	local duration = data.Duration or 1
	local clone = ring:Clone()
	clone.Color = color
	clone.Transparency = transparency[1]
	clone.Size = size[1]
	clone.CFrame = origin
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(duration, easingStyle, easingDirection), {
		Transparency = transparency[2],
		Size = size[2]
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end