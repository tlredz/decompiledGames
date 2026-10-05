local v = {
	0,
	1,
	2,
	3,
	4,
	5,
	6,
	7
}
local v2 = {
	0,
	1,
	3,
	4,
	5,
	7
}
local v3 = {
	0,
	1,
	4,
	5,
	6
}
local ViewportModel = {}
ViewportModel.__index = ViewportModel
ViewportModel.ClassName = "ViewportModel"

-- equivalent calls inferred from this helper; original call sites unknown
local function getIndices(part)
	if part:IsA("WedgePart") then
		return v2
	end

	if part:IsA("CornerWedgePart") then
		return v3
	end

	return v
end

local function getCorners(cFrame, p, indices)
	local result = {}

	for _, item in pairs(indices) do
		result[item + 1] = cFrame * (p * Vector3.new(
			math.floor(item / 4) % 2 * 2 - 1,
			math.floor(item / 2) % 2 * 2 - 1,
			2 * (item % 2) - 1
		))
	end

	return result
end

local function getModelPointCloud(folder)
	local corners = {}

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local indices = getIndices(part) -- equivalent call inferred; original call site unknown
		local corners2 = getCorners(part.CFrame, part.Size / 2, indices)

		for _, corner in pairs(corners2) do
			table.insert(corners, corner)
		end
	end

	return corners
end

local function viewProjectionEdgeHits(items, p, Z, p2)
	local v4 = -1e999
	local v5 = 1e999

	for _, item in pairs(items) do
		local v6 = p2 * (Z - item.Z)
		local v7 = item[p] + v6
		local v8 = item[p] - v6
		v4 = math.max(v4, v7, v8)
		v5 = math.min(v5, v7, v8)
	end

	return v4, v5
end

function ViewportModel.new(viewportFrame, camera)
	local self = setmetatable({}, ViewportModel)
	self.Model = nil
	self.ViewportFrame = viewportFrame
	self.Camera = camera
	self._points = {}
	self._modelCFrame = CFrame.new()
	self._modelSize = Vector3.new()
	self._modelRadius = 0
	self._viewport = {}
	self:Calibrate()
	return self
end

function ViewportModel:SetModel(model)
	self.Model = model
	local boundingBox, modelSize = model:GetBoundingBox()
	self._points = getModelPointCloud(model)
	self._modelCFrame = boundingBox
	self._modelSize = modelSize
	self._modelRadius = modelSize.Magnitude / 2
end

function ViewportModel:Calibrate()
	local absoluteSize = self.ViewportFrame.AbsoluteSize
	local viewport = {
		aspect = absoluteSize.X / absoluteSize.Y,
		yFov2 = math.rad(self.Camera.FieldOfView / 2)
	}
	viewport.tanyFov2 = math.tan(viewport.yFov2)
	viewport.xFov2 = math.atan(viewport.tanyFov2 * viewport.aspect)
	viewport.tanxFov2 = math.tan(viewport.xFov2)
	viewport.cFov2 = math.atan(viewport.tanyFov2 * math.min(1, viewport.aspect))
	viewport.sincFov2 = math.sin(viewport.cFov2)
	self._viewport = viewport
end

function ViewportModel:GetFitDistance(p)
	local v4 = not p and 0 or (p - self._modelCFrame.Position).Magnitude or 0
	return (self._modelRadius + v4) / self._viewport.sincFov2
end

function ViewportModel:GetMinimumFitCFrame(p)
	if not self.Model then
		return CFrame.new()
	end

	local inverse = (p - p.Position):Inverse()
	local _points = self._points
	local v4 = { inverse * _points[1] }
	local Z = v4[1].Z

	for i = 2, #_points do
		local v5 = inverse * _points[i]
		Z = math.min(Z, v5.Z)
		v4[i] = v5
	end

	local v5, v6 = viewProjectionEdgeHits(v4, "X", Z, self._viewport.tanxFov2)
	local v7, v8 = viewProjectionEdgeHits(v4, "Y", Z, self._viewport.tanyFov2)
	local v9 = math.max((v5 - v6) / 2 / self._viewport.tanxFov2, (v7 - v8) / 2 / self._viewport.tanyFov2)
	return p * CFrame.new((v5 + v6) / 2, (v7 + v8) / 2, Z + v9)
end

return ViewportModel