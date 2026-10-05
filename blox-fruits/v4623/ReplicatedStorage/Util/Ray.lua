local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local v = { workspace:WaitForChild("Terrain"), _WorldOrigin, workspace.CurrentCamera }
return function(vector2: Vector3, vector3: Vector3, options, flag: boolean?)
	if flag then
		local magnitude = vector3.Magnitude
		local part = Instance.new("Part")
		game.Debris:AddItem(part, 0.05)
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
	end

	local v2 = {}

	for _, v3 in next, v, nil do
		table.insert(v2, v3)
	end

	for _, v3 in next, options or {}, nil do
		table.insert(v2, v3)
	end

	local part, v3, v4 = workspace:FindPartOnRayWithIgnoreList(Ray.new(vector2, vector3), v2)
	return part, v3, v4
end