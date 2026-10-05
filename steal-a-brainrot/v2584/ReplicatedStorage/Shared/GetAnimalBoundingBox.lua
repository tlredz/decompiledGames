local function GetBoundingBox(folder, p)
	local v = 1e999
	local v2 = 1e999
	local v3 = 1e999
	local v4 = -1e999
	local v5 = -1e999
	local v6 = -1e999

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or not (part.Transparency < 1) or p[part] then
			continue
		end

		local cFrame = part.CFrame
		local v7 = part.Size * 0.5

		for i = -1, 1, 2 do
			for i2 = -1, 1, 2 do
				for i3 = -1, 1, 2 do
					local pointToWorldSpace = cFrame:PointToWorldSpace((Vector3.new(v7.X * i, v7.Y * i2, v7.Z * i3)))
					v = math.min(v, pointToWorldSpace.X)
					v2 = math.min(v2, pointToWorldSpace.Y)
					v3 = math.min(v3, pointToWorldSpace.Z)
					v4 = math.max(v4, pointToWorldSpace.X)
					v5 = math.max(v5, pointToWorldSpace.Y)
					v6 = math.max(v6, pointToWorldSpace.Z)
				end
			end
		end
	end

	local vector = Vector3.new(v4 - v, v5 - v2, v6 - v3)
	local vector2 = Vector3.new((v + v4) / 2, (v2 + v5) / 2, (v3 + v6) / 2)
	return CFrame.new(vector2), vector
end

return function(p: string, instance)
	local v = {}

	if p == "Los Noobinis" then
		v[instance["Cube.003"]] = true
	end

	local fakeRootPart = instance:FindFirstChild("FakeRootPart")

	if fakeRootPart then
		v[fakeRootPart] = true
	end

	local rootPart = p == "Tacorita Bicicleta" and instance:FindFirstChild("RootPart")

	if rootPart then
		v[rootPart] = true
	end

	local v2, v3 = GetBoundingBox(instance, v)
	return v2, v3
end