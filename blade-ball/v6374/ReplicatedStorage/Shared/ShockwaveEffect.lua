local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
return function(data)
	local vector2 = createVector(0, 0.5, 0)
	local vector3 = Vector3.new(data.diameter or 10, 0.5, data.diameter or 10)

	if data.reverse then
		vector3, vector2 = vector2, vector3
	end

	local clone = ReplicatedStorage.Misc.Wave:Clone()
	clone.Size = vector2
	clone.CFrame = data.cframe or CFrame.identity
	clone.Color = data.color or Color3.new(1, 1, 1)
	clone.Parent = workspace.Runtime

	if data.orientation == "Vertical" then
		clone.CFrame *= CFrame.Angles(1.5707963267948966, 0, 0)
	end

	local duration = data.duration or 0.3
	TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = vector3
	}):Play()
	TweenService:Create(
		clone,
		TweenInfo.new(duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, duration / 2),
		{
			Transparency = data.targetTransparency or 1
		}
	):Play()
	Debris:AddItem(clone, 0.3)
end