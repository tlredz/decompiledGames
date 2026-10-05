local createVector = vector.create
return function(data)
	assert(typeof(data) == "table")
	assert(data.goal)
	assert(data.origin)
	local origin = data.origin
	local goal = data.goal
	local visualize = data.visualize
	local magnitude = (goal - origin).Magnitude
	local part = Instance.new("Part")
	part.Name = "_visualizedRay" .. debug.traceback()
	part.CastShadow = false
	part.CanQuery = false
	part.CanTouch = false
	part.Size = createVector(0.4, 0.4, 1)
	part.CanCollide = false
	part.Anchored = true
	part.Color = visualize.lineColor or BrickColor.Random().Color
	part.Transparency = 0.5
	part.CFrame = CFrame.new(origin, goal)
	local blockMesh = Instance.new("BlockMesh", part)
	blockMesh.Scale = Vector3.new(1, 1, magnitude)
	blockMesh.Offset = Vector3.new(0, 0, -magnitude / 2)
	local part2 = Instance.new("Part")
	part2.Name = "_visualizedPoint" .. debug.traceback()
	part2.Size = createVector(1, 1, 1)
	part2.BrickColor = BrickColor.new("Really red")
	part2.Shape = Enum.PartType.Ball
	part2.Material = Enum.Material.Neon
	part2.CFrame = CFrame.new(goal)
	part2.Anchored = true
	part2.Parent = workspace._WorldOrigin
	part.Parent = workspace._WorldOrigin
	task.delay(visualize.lineExpires or 1, function()
		part:Destroy()
	end)
	task.delay(visualize.pointExpires or 1, function()
		part2:Destroy()
	end)
end