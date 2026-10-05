local createVector = vector.create
local Debris = game:GetService("Debris")
return function(vector2: Vector3, vector3: Vector3, p, flag: boolean?)
	if flag then
		local magnitude = vector3.Magnitude
		local part = Instance.new("Part")
		part.Size = createVector(0.4, 0.4, 1)
		part.CanCollide = false
		part.Anchored = true
		part.BrickColor = BrickColor.random()
		part.Transparency = 0.5
		part.CFrame = CFrame.new(vector2, vector2 + vector3)
		local blockMesh = Instance.new("BlockMesh", part)
		blockMesh.Scale = Vector3.new(1, 1, magnitude)
		blockMesh.Offset = Vector3.new(0, 0, -magnitude / 2)
		part.Parent = workspace._WorldOrigin
		Debris:AddItem(part, 0.05)
	end

	local part, v, v2 = workspace:FindPartOnRayWithWhitelist(Ray.new(vector2, vector3), p)
	return part, v, v2
end