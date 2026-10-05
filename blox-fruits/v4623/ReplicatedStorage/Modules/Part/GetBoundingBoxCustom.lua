local createVector = vector.create
local getDescendants = Instance.new("Part").GetDescendants
local cframe = CFrame.new()
local toObjectSpace = cframe.ToObjectSpace
local getComponents = cframe.GetComponents
local pointToWorldSpace = cframe.PointToWorldSpace
return function(items, cframe2: CFrame)
	if type(items) ~= "table" then
		items = getDescendants(items) or items
	end

	local v = cframe2 or cframe
	local v2 = 1e999
	local v3 = 1e999
	local v4 = 1e999
	local v5 = -1e999
	local v6 = -1e999
	local v7 = -1e999

	for _, part in items do
		local cframe3 = nil
		local size = nil

		if typeof(part) == "Vector3" then
			cframe3 = CFrame.new(part)
			size = createVector(0, 0, 0)
		elseif typeof(part) == "CFrame" then
			cframe3 = part
			size = createVector(0, 0, 0)
		elseif part:IsA("BasePart") then
			cframe3 = toObjectSpace(v, part.CFrame)
			size = part.Size
		end

		local X = size.X
		local Y = size.Y
		local Z = size.Z
		local components, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18 = getComponents(cframe3)
		local v19 = 0.5 * (math.abs(v10) * X + math.abs(v11) * Y + math.abs(v12) * Z)
		local v20 = 0.5 * (math.abs(v13) * X + math.abs(v14) * Y + math.abs(v15) * Z)
		local v21 = 0.5 * (math.abs(v16) * X + math.abs(v17) * Y + math.abs(v18) * Z)

		if components - v19 < v2 then
			v2 = components - v19 or v2
		end

		if v8 - v20 < v3 then
			v3 = v8 - v20 or v3
		end

		if v9 - v21 < v4 then
			v4 = v9 - v21 or v4
		end

		if v5 < components + v19 then
			v5 = components + v19 or v5
		end

		if v6 < v8 + v20 then
			v6 = v8 + v20 or v6
		end

		if v7 < v9 + v21 then
			v7 = v9 + v21 or v7
		end
	end

	local vector2 = Vector3.new(v2, v3, v4)
	local vector3 = Vector3.new(v5, v6, v7)
	return v - v.Position + pointToWorldSpace(v, (vector3 + vector2) * 0.5), vector3 - vector2
end