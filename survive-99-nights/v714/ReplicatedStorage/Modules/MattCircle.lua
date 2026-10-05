local MattCircle = {}

function MattCircle.SetCircleRadius(instance, p, position, p2)
	local children = instance:GetChildren()
	local cframe = CFrame.new(position)
	local v = 360 / #children

	for _, v2 in pairs(children) do
		local v3 = cframe * CFrame.new(0, 0, -p)
		cframe *= CFrame.Angles(0, math.rad(v), 0)
		local v4 = cframe * CFrame.new(0, 0, -p)
		local magnitude = (v3.Position - v4.Position).Magnitude
		v2.Size = Vector3.new(8, p2, magnitude)
		v2.CFrame = CFrame.lookAt(v3.Position, v4.Position) * CFrame.new(0, 0, -magnitude / 2)
	end
end

function MattCircle.BuildCircle(p)
	local model = Instance.new("Model")
	model.Name = "Fog"

	for _ = 1, p do
		local part = Instance.new("Part")
		part.Color = Color3.fromRGB(94, 96, 109)
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.Parent = model
	end

	return model
end

return MattCircle