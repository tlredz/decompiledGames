local createVector = vector.create
local SurfaceTracker = {}
SurfaceTracker.__index = SurfaceTracker
SurfaceTracker.__class = "SurfaceTracker"

-- equivalent calls inferred from this helper; original call sites unknown
local function clampToBox(solid, vector2: Vector3)
	local cFrame = solid.CFrame
	local v = solid.Size * 0.5
	return cFrame:PointToWorldSpace(cFrame:PointToObjectSpace(vector2):Max(-v):Min(v))
end

function SurfaceTracker.new(model, skip)
	local object = setmetatable({}, SurfaceTracker)
	object.model = model
	object.skip = skip
	object.solids = {}
	object.links = {}
	object.disposed = false
	object:Rescan()
	object.links = { model.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") and part ~= object.skip and table.find(object.solids, part) == nil then
				table.insert(object.solids, part)
			end
		end), model.DescendantRemoving:Connect(function(descendant)
			local index = table.find(object.solids, descendant)

			if index ~= nil then
				table.remove(object.solids, index)
			end
		end) }
	return object
end

function SurfaceTracker:Destroy()
	if not self.disposed then
		self.disposed = true

		for _, link in self.links do
			link:Disconnect()
		end

		table.clear(self.links)
		table.clear(self.solids)
	end
end

function SurfaceTracker:Rescan()
	local solids = self.solids
	table.clear(solids)

	for _, part in self.model:GetDescendants() do
		local isA = part:IsA("BasePart")

		if isA then
			if part == self.skip then
				isA = false
			else
				isA = part.Parent ~= nil
			end
		end

		if isA then
			solids[#solids + 1] = part
		end
	end
end

function SurfaceTracker.GetClosestSurfacePoint(data, vector2: Vector3, value: number?, p: number?)
	if data.disposed then
		return nil, nil
	end

	if p ~= nil then
		local boundingBox, v = data.model:GetBoundingBox()
		local vector3 = (boundingBox:PointToObjectSpace(vector2):Abs() - v * 0.5):Max(createVector(0, 0, 0))
		local v2 = math.max(p, 0) + 0.01
		local dot = vector3:Dot(vector3)

		if v2 * v2 < dot then
			return nil, nil
		end
	end

	local v = 1e999
	local v2 = nil

	for _, solid in data.solids do
		local v3

		if solid:IsDescendantOf(data.model) then
			v3 = clampToBox(solid, vector2)
		end

		local v4 = not v3 and 1e999 or (vector2 - v3).Magnitude

		if not (v4 < v) then
			continue
		end

		v2 = v3
		v = v4
	end

	local v3 = not v2 and createVector(0, 0, 0) or vector2 - v2
	local v4 = v3.Magnitude < 0.0001 and createVector(0, 1, 0) or v3.Unit
	local selected

	if v2 then
		selected = v2 + v4 * (value or 0)
	end

	return selected, selected and v
end

return SurfaceTracker