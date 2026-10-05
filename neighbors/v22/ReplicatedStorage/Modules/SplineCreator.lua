local createVector = vector.create
game:GetService("ReplicatedStorage")
local SplineCreator = {}
SplineCreator.__index = SplineCreator
local count = 0

local function getBernsteinPosition(p, p2, p3, p4, p5)
	local v = p5 * p5
	local v2 = v * p5
	local v3 = -v2 + 3 * v - 3 * p5 + 1
	local v4 = 3 * v2 - 6 * v + 3 * p5
	local v5 = -3 * v2 + 3 * v
	return p * v3 + p2 * v4 + p3 * v5 + p4 * v2
end

local function getBernsteinTangent(p, p2, p3, p4, p5)
	local v = p5 * p5
	local v2 = 1 - p5
	local v3 = v2 * v2
	local v4 = (p2 - p) * (3 * v3)
	local v5 = (p3 - p2) * (6 * v2 * p5)
	local v6 = (p4 - p3) * (3 * v)
	return (v4 + v5 + v6).Unit
end

local function createPart(instance)
	local part = Instance.new("Part")
	part.Size = instance.Size or createVector(1, 1, 1)
	part.CFrame = instance.CFrame or CFrame.new()
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = instance.Color or Color3.new(1, 0, 0)
	part.Parent = instance.Parent or workspace
	part.Transparency = instance.Transparency or 0.5
	return part
end

local function getCurveIndexAndT(p, value)
	local v = math.clamp(value, 0, 1)
	local count2 = #p.bezierCurves
	local v2 = math.min(math.floor(v * count2) + 1, count2)

	if v == 1 then
		return v2, 1
	end

	return v2, v * count2 % 1
end

function SplineCreator:_getPositionAlpha(value: number)
	local v = math.clamp(math.clamp(value, 0, 1), 0, 1)
	local count2 = #self.bezierCurves
	local v2 = math.min(math.floor(v * count2) + 1, count2)
	local v3 = v == 1 and 1 or v * count2 % 1
	local bezierCurve = self.bezierCurves[v2]
	local v4 = bezierCurve[1]
	local v5 = bezierCurve[2]
	local v6 = bezierCurve[3]
	local v7 = bezierCurve[4]
	local v8 = v3 * v3
	local v9 = v8 * v3
	local v10 = -v9 + 3 * v8 - 3 * v3 + 1
	local v11 = 3 * v9 - 6 * v8 + 3 * v3
	local v12 = -3 * v9 + 3 * v8
	return v4 * v10 + v5 * v11 + v6 * v12 + v7 * v9
end

function SplineCreator:_getCFrameAlpha(value: number)
	local v = math.clamp(math.clamp(value, 0, 1), 0, 1)
	local count2 = #self.bezierCurves
	local v2 = math.min(math.floor(v * count2) + 1, count2)
	local v3 = v == 1 and 1 or v * count2 % 1
	local bezierCurve = self.bezierCurves[v2]
	local v4 = bezierCurve[1]
	local v5 = bezierCurve[2]
	local v6 = bezierCurve[3]
	local v7 = bezierCurve[4]
	local v8 = v3 * v3
	local v9 = v8 * v3
	local v10 = -v9 + 3 * v8 - 3 * v3 + 1
	local v11 = 3 * v9 - 6 * v8 + 3 * v3
	local v12 = -3 * v9 + 3 * v8
	local v13 = v4 * v10 + v5 * v11 + v6 * v12 + v7 * v9
	local v14 = bezierCurve[1]
	local v15 = bezierCurve[2]
	local v16 = bezierCurve[3]
	local v17 = bezierCurve[4]
	local v18 = v3 * v3
	local v19 = 1 - v3
	local v20 = v19 * v19
	local v21 = (v15 - v14) * (3 * v20)
	local v22 = (v16 - v15) * (6 * v19 * v3)
	local v23 = (v17 - v16) * (3 * v18)
	local unit = (v21 + v22 + v23).Unit
	return CFrame.lookAt(v13, v13 + unit)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getLengthSegment(object, distance)
	local v = math.floor(distance / object.Length * (object.segmentIndex - 1)) + 1
	return object.segmentCache[v]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDistance(object, value)
	if object.Looped then
		return value % object.Length
	end

	return (math.clamp(value, 0, object.Length))
end

function SplineCreator:_getPositionLength(value)
	local distance = getDistance(self, value) -- equivalent call inferred; original call site unknown
	local lengthSegment = getLengthSegment(self, distance) -- equivalent call inferred; original call site unknown

	if not lengthSegment then
		return self:_getPositionAlpha(1)
	end

	local v = (distance - (lengthSegment.Position - lengthSegment.Length)) / lengthSegment.Length
	return lengthSegment.Start:Lerp(lengthSegment.End, v)
end

function SplineCreator:_getCFrameLength(value)
	local distance = getDistance(self, value) -- equivalent call inferred; original call site unknown
	local lengthSegment = getLengthSegment(self, distance) -- equivalent call inferred; original call site unknown

	if not lengthSegment then
		return self:_getCFrameAlpha(1)
	end

	local v = (distance - (lengthSegment.Position - lengthSegment.Length)) / lengthSegment.Length
	local lerped = lengthSegment.Start:Lerp(lengthSegment.End, v)
	local unit = (lengthSegment.End - lengthSegment.Start).Unit
	return CFrame.lookAt(lerped, lerped + unit)
end

function SplineCreator:GetPositionAtAlpha(p)
	if self.isLengthBased then
		return self:_getPositionLength(p)
	end

	return self:_getPositionAlpha(p)
end

function SplineCreator:GetCFrameAtAlpha(p)
	if self.isLengthBased then
		return self:_getCFrameLength(p)
	end

	return self:_getCFrameAlpha(p)
end

function SplineCreator:DrawDebug(value: number, color: Color3)
	local formatted = `_DEBUG_SPLINE_{self.ID}`
	local parent = workspace:FindFirstChild(formatted) or Instance.new("Folder")
	parent.Name = formatted
	parent.Parent = workspace
	parent:ClearAllChildren()
	local v2 = value or 2500
	local v3 = nil

	for i = 0, v2 do
		local v4 = i / v2 * (self.isLengthBased == false and 1 or self.Length)
		local positionAtAlpha = self:GetPositionAtAlpha(v4)
		createPart({
			Size = createVector(1, 1, 1),
			CFrame = CFrame.new(positionAtAlpha),
			Parent = parent,
			Color = color or Color3.new(1, 0, 0)
		})

		if v3 then
			local v5 = positionAtAlpha - v3
			local magnitude = v5.Magnitude

			if magnitude > 0 then
				createPart({
					Size = Vector3.new(0.25, 0.25, magnitude),
					CFrame = CFrame.lookAt(v3 + v5 * 0.5, positionAtAlpha),
					Parent = parent,
					Color = Color3.new(0, 1, 0)
				})
			end
		end

		createPart({
			Size = createVector(0.5, 0.5, 1),
			CFrame = self:GetCFrameAtAlpha(v4) * CFrame.new(0, 0, -0.5),
			Parent = parent,
			Color = Color3.new(0, 0, 1)
		})
		v3 = positionAtAlpha
	end
end

function SplineCreator:RemoveDebug()
	local formatted = `_DEBUG_SPLINE_{self.ID}`
	local child = workspace:FindFirstChild(formatted)

	if child then
		child:Destroy()
	end
end

function SplineCreator:Destroy()
	self:RemoveDebug()

	if self.bezierCurves then
		table.clear(self.bezierCurves)
	end

	if self.Points then
		table.clear(self.Points)
	end

	if self.segmentCache then
		table.clear(self.segmentCache)
	end
end

function SplineCreator.new(points, options)
	local self = setmetatable({}, SplineCreator)
	self.Points = points
	self.Settings = options or {}
	self.bezierCurves = {}
	self.Tension = self.Settings.Tension or 1
	self.Looped = self.Settings.Looped ~= nil and (self.Settings.Looped or false)
	self.ID = count
	self.samplingSteps = not self.Settings.samplingSteps and 10000 or math.floor(self.Settings.samplingSteps) or 10000
	self.segmentSize = not self.Settings.segmentSize and 5 or math.floor(self.Settings.segmentSize) or 5
	self.Length = 0

	for k, part in points do
		if typeof(part) == "Instance" and part:IsA("BasePart") then
			points[k] = {
				Position = part.Position
			}
		elseif typeof(part) == "CFrame" then
			points[k] = {
				Position = part.Position,
				Direction = part.LookVector
			}
		else
			points[k] = {
				Position = part
			}
		end
	end

	for i = 1, #points do
		local point = points[(i - 2) % #points + 1]
		local point2 = points[(i - 1) % #points + 1]
		local point3 = points[i % #points + 1]
		local point4 = points[(i + 1) % #points + 1]
		local v2

		if point2.Direction then
			local magnitude = (point3.Position - point.Position).Magnitude
			v2 = point2.Direction * magnitude * (self.Tension / 6)
		else
			v2 = (point3.Position - point.Position) * (self.Tension / 6)
		end

		local v3

		if point3.Direction then
			local magnitude = (point4.Position - point2.Position).Magnitude
			v3 = point3.Direction * magnitude * (self.Tension / 6)
		else
			v3 = (point4.Position - point2.Position) * (self.Tension / 6)
		end

		self.bezierCurves[i] = {
			point2.Position,
			point2.Position + v2,
			point3.Position - v3,
			point3.Position
		}
	end

	if not self.Looped then
		self.bezierCurves[#points] = nil
	end

	if self.Settings.isLengthBased then
		self.segmentCache = {}
		self.segmentIndex = 0
		local positionAtAlpha = self:GetPositionAtAlpha(0)

		for i = 1, self.samplingSteps do
			local positionAtAlpha2 = self:GetPositionAtAlpha(i / self.samplingSteps)
			local magnitude = (positionAtAlpha2 - positionAtAlpha).Magnitude

			if not (self.segmentSize <= magnitude or i == self.samplingSteps) then
				continue
			end

			local segmentIndex = self.segmentIndex
			self.Length += magnitude
			self.segmentIndex += 1
			self.segmentCache[segmentIndex] = {
				Start = positionAtAlpha,
				End = positionAtAlpha2,
				Length = magnitude,
				Position = self.Length - magnitude
			}
			positionAtAlpha = positionAtAlpha2
		end
	end

	self.isLengthBased = self.Settings.isLengthBased ~= nil and (self.Settings.isLengthBased or false)
	count += 1
	return self
end

return SplineCreator