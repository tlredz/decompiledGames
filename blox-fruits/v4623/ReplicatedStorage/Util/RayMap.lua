local createVector = vector.create
local Debris = game:GetService("Debris")

function cast(vector2: Vector3, vector3: Vector3, flag: boolean?)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local raycastResult = workspace:Raycast(vector2, vector3, raycastParams)

	if not raycastResult then
		return nil, vector2 + vector3, createVector(0, 0, 0)
	end

	local instance = raycastResult.Instance
	local position = raycastResult.Position
	local normal = raycastResult.Normal

	if instance and instance.Name == "WaterBase-Plane" then
		return nil, vector2 + vector3, createVector(0, 0, 0)
	end

	if not flag then
		return instance, position, normal
	end

	local v = position - vector2
	local magnitude = v.magnitude
	local part = Instance.new("Part")
	part.Size = createVector(0.4, 0.4, 1)
	part.CanCollide = false
	part.Anchored = true
	part.BrickColor = BrickColor.random()
	part.Transparency = 0.5
	part.CFrame = CFrame.new(vector2, vector2 + v)
	local blockMesh = Instance.new("BlockMesh", part)
	blockMesh.Scale = Vector3.new(1, 1, magnitude)
	blockMesh.Offset = Vector3.new(0, 0, -magnitude / 2)
	part.Parent = workspace._WorldOrigin
	Debris:AddItem(part, 0.05)
	return instance, position, normal
end

return cast