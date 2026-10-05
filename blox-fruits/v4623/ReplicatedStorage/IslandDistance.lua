local createVector = vector.create

local function generateBoundaryPoints()
	local result = {}

	for _, child in ipairs(workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations"):GetChildren()) do
		local radius = child.Size.X * child.Mesh.Scale.X / 2

		if not (radius >= 400) or not (child.CFrame.Position.Y - radius <= 0) or child.Name:match("Trial") or not ((child.Position * createVector(
			1,
			0,
			1
		)).Magnitude < 60000) then
			continue
		end

		if child.Name == "Sea" then
			continue
		end

		table.insert(result, {
			Name = child.Name,
			Radius = radius,
			Position = child.Position
		})
	end

	return result
end

local v = generateBoundaryPoints()

-- equivalent calls inferred from this helper; original call sites unknown
local function locateObject(p)
	for k, v2 in pairs(v) do
		if v2.Model == p then
			return k
		end
	end

	return nil
end

local function verifyObject(model)
	task.wait(1)

	if model:IsA("Model") and model.Name:find("Island") then
		-- equivalent call inferred; original call site unknown
		if not locateObject(model) then
			local boundingBox, v2 = model:GetBoundingBox()
			local radius = v2.Magnitude / 2
			local position = boundingBox.Position

			if position.Y - radius * 2 <= 0 then
				table.insert(v, {
					Name = model.Name,
					Model = model,
					Radius = radius,
					Position = position
				})
			end
		end
	end
end

local function clearObject(p)
	task.wait(1.1)
	local k = locateObject(p) -- equivalent call inferred; original call site unknown

	if k then
		table.remove(v, k)
	end
end

for _, v2 in pairs({ workspace.Map, workspace.Map:FindFirstChild("RaidMap") }) do
	v2.ChildAdded:Connect(verifyObject)
	v2.ChildRemoved:Connect(clearObject)
end

local function getDistanceFromClosestIsland(position: Vector3, items)
	local v2 = {}
	local count = 0

	for k, item in pairs(items) do
		if not (items[k] and item ~= nil) then
			continue
		end

		v2[k] = item
		count += 1
	end

	if count < 2 then
		return 1e999
	end

	local v3 = 1e999
	local v4 = nil

	for i = 1, #v2 do
		local v5 = v2[i]
		local radius = v5.Radius
		local v6 = (v5.Position - position).Magnitude - radius

		if not (v6 < v3) then
			continue
		end

		v4 = v5
		v3 = v6
	end

	return v3, v4
end

return function(position)
	local v2 = nil

	if typeof(v2) == "CFrame" then
		position = v2.Position
	else
		assert(typeof(position) == "Vector3", "bad point")
	end

	return getDistanceFromClosestIsland(position, v)
end