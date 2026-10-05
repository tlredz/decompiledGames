local createVector = vector.create
game:GetService("RunService")
local FishRoamer = {}
FishRoamer.__index = FishRoamer

function FishRoamer.new(model, part)
	assert(model and model:IsA("Model"), "fishModel must be a Model")
	assert(part and part:IsA("BasePart"), "waterPart must be a BasePart")
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	assert(primaryPart, "fishModel must have a PrimaryPart or at least one BasePart")
	local object = setmetatable({}, FishRoamer)
	object.Fish = model
	object.PrimaryPart = primaryPart
	object.Water = part
	object.Speed = 5
	local _, v = model:GetBoundingBox()
	local v2 = math.max(v.X, v.Y, v.Z)
	local v3 = math.min(part.Size.X, part.Size.Y, part.Size.Z)

	if v3 < v2 then
		local v4 = v3 / v2
		model:ScaleTo(model:GetScale() * v4)
		v *= v4
	end

	object.Radius = v.Magnitude * 0.5
	local v4 = part.Size * 0.5
	object.MaxOffset = Vector3.new(
		math.max(v4.X - object.Radius, 0),
		math.max(v4.Y - object.Radius, 0),
		(math.max(v4.Z - object.Radius, 0))
	)
	object:UpdatePivot()
	object.CurrentTarget = nil
	object.AccumulatedTime = math.random() * 100
	object.OffsetX = math.random()
	object.OffsetY = math.random()
	object.OffsetZ = math.random()
	object.FrequencyX = 0.15 + math.random() * 0.173
	object.FrequencyY = 0.11 + math.random() * 0.197
	object.FrequencyZ = 0.13 + math.random() * 0.211
	local positionAtTime = object:GetPositionAtTime(object.AccumulatedTime)
	local unit = (object:GetPositionAtTime(object.AccumulatedTime + 0.5) - positionAtTime).Unit
	local cframe = CFrame.lookAt(positionAtTime, positionAtTime + unit)
	object.CurrentCFrame = cframe
	object.Fish:PivotTo(cframe)
	return object
end

function FishRoamer:UpdatePivot()
	local center = self.Fish:FindFirstChild("Center")
	local mouth = center and center:FindFirstChild("mouth")

	if not (center and mouth) or mouth.Position.Magnitude < 0.001 then
		return
	end

	local v

	if self.Fish:GetAttribute("UpsideDown") then
		v = CFrame.fromOrientation(0, 0, 3.141592653589793)
	else
		v = CFrame.identity
	end

	center.PivotOffset = CFrame.lookAlong(createVector(0, 0, 0), mouth.Position) * v
end

function FishRoamer.GetRandomPoint(p)
	local vector2 = Vector3.new(
		(math.random() * 2 - 1) * p.MaxOffset.X,
		(math.random() * 2 - 1) * p.MaxOffset.Y,
		(math.random() * 2 - 1) * p.MaxOffset.Z
	)
	return p.Water.CFrame:PointToWorldSpace(vector2)
end

function FishRoamer:GetPositionAtTime(p)
	local v = p * self.Speed * 0.25
	local X = self.MaxOffset.X
	local Y = self.MaxOffset.Y
	local Z = self.MaxOffset.Z
	local v2 = math.sin(v * self.FrequencyX + self.OffsetX * 3.141592653589793 * 2) * X * 0.8
	local v3 = math.sin(v * self.FrequencyY + self.OffsetY * 3.141592653589793 * 2) * Y * 0.6
	local v4 = math.cos(v * self.FrequencyZ + self.OffsetZ * 3.141592653589793 * 2) * Z * 0.8
	local vector2 = Vector3.new(
		v2 + math.cos(v * self.FrequencyX * 0.5 + self.OffsetZ) * X * 0.2,
		v3,
		v4 + math.sin(v * self.FrequencyZ * 0.7 + self.OffsetX) * Z * 0.2
	)
	return self.Water.CFrame:PointToWorldSpace(vector2)
end

function FishRoamer:Update(p)
	self.AccumulatedTime += p
	local positionAtTime = self:GetPositionAtTime(self.AccumulatedTime)
	local v = self:GetPositionAtTime(self.AccumulatedTime + 0.5) - positionAtTime

	if v.Magnitude > 0.001 then
		local unit = v.Unit
		local cframe = CFrame.lookAt(positionAtTime, positionAtTime + unit)
		local v2 = math.min(p * 8, 1)
		self.CurrentCFrame = self.CurrentCFrame:Lerp(cframe, v2)
	else
		self.CurrentCFrame = CFrame.new(positionAtTime) * self.CurrentCFrame.Rotation
	end

	self.Fish:PivotTo(self.CurrentCFrame)
end

return FishRoamer