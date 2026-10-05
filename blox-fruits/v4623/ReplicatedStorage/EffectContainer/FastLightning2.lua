local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
return function(data)
	local position0 = data.Position0
	local position1 = data.Position1
	local length = data.Length or 8
	local offset = data.Offset or 9
	local color = data.Color or Color3.fromRGB(128, 187, 219)
	local thickness = data.Thickness or 4
	local lifetime = data.Lifetime or 0.3
	local magnitude = (position0 - currentCamera.CFrame.p).magnitude

	if 200 + length * 10 < magnitude then
		return
	end

	local magnitude2 = (position0 - position1).magnitude
	local v = magnitude2 / length

	for i = 0, v do
		local part = Instance.new("Part")
		part.Anchored = true
		part.Color = color
		part.Transparency = 0
		part.CanCollide = false
		part.Material = "Neon"
		part.Size = createVector(0.2, 0.2, 0.2)
		local blockMesh = Instance.new("BlockMesh", part)
		blockMesh.Name = "Mesh"
		local vector2 = Vector3.new(
			offset * (math.random() - 0.5),
			offset * (math.random() - 0.5),
			offset * (math.random() - 0.5)
		)
		local v2 = CFrame.new(position0, position1) * CFrame.new(0, 0, magnitude2 / v).p + vector2

		if i == v then
			local magnitude3 = (position0 - position1).magnitude
			blockMesh.Scale = Vector3.new(thickness, thickness, magnitude3) / 0.2
			part.CFrame = CFrame.new(position0, position1) * CFrame.new(0, 0, -magnitude3 / 2)
		else
			blockMesh.Scale = Vector3.new(thickness, thickness, magnitude2 / v) / 0.2
			part.CFrame = CFrame.new(position0, v2) * CFrame.new(0, 0, magnitude2 / v / 2)
		end

		position0 = part.CFrame * Vector3.new(0, 0, magnitude2 / v / 2)
		part.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(blockMesh, TweenInfo.new(lifetime), {
			Scale = blockMesh.Scale * createVector(0, 0, 1)
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
	end
end