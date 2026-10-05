local Workspace = game:GetService("Workspace")
local v = {
	Anchored = true,
	CanCollide = false,
	CanQuery = false,
	CanTouch = false,
	CastShadow = false,
	Name = "ParticleStage",
	Transparency = 1
}
local class = {}
class.__index = class

local function sortedKeys(items)
	local result = {}

	for k in items do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function write(p, items)
	local v2 = {}

	for k in items do
		table.insert(v2, k)
	end

	table.sort(v2)

	for _, v3 in v2 do
		p[v3] = items[v3]
	end
end

function class.Emitter(items, items2)
	local particleEmitter = Instance.new("ParticleEmitter")
	write(particleEmitter, items) -- equivalent call inferred; original call site unknown

	if items2 ~= nil then
		write(particleEmitter, items2) -- equivalent call inferred; original call site unknown
	end

	return particleEmitter
end

function class.Scale(data, p: number)
	write(data, {
		Acceleration = data.Acceleration * p,
		Size = class.ScaleSequence(data.Size, p),
		Speed = NumberRange.new(data.Speed.Min * p, data.Speed.Max * p),
		ZOffset = data.ZOffset * p
	}) -- equivalent call inferred; original call site unknown
end

function class.ScaleSequence(sequence, p: number)
	local numberSequenceKeypoints = table.create(#sequence.Keypoints)

	for k, keypoint in sequence.Keypoints do
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function class.QualityBudget()
	local value = UserSettings().GameSettings.SavedQualityLevel.Value

	if value <= 0 then
		return 1
	end

	return (value / 10) ^ 1.25
end

function class.SetEnabled(items, enabled: boolean)
	for _, item in items do
		item.Enabled = enabled
	end
end

function class.new(depth: number, thickness: number)
	local self = setmetatable({}, class)
	self.depth = depth
	self.thickness = thickness
	self.watchers = {}
	local part = Instance.new("Part")
	write(part, v) -- equivalent call inferred; original call site unknown
	self.Part = part
	self:Follow()
	return self
end

function class:Fit()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return
	end

	local cFrame = currentCamera.CFrame
	local lookVector = cFrame.LookVector
	local v2 = self.depth + self.thickness * 0.5
	local viewportSize = currentCamera.ViewportSize

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onFarPlane(p: number, p2: number)
		local direction = currentCamera:ViewportPointToRay(p, p2).Direction
		return cFrame.Position + direction * (v2 / direction:Dot(lookVector))
	end

	local v3 = onFarPlane(0, 0) -- equivalent call inferred; original call site unknown
	local direction = currentCamera:ViewportPointToRay(viewportSize.X, viewportSize.Y).Direction
	local v4 = cFrame.Position + direction * (v2 / direction:Dot(lookVector))
	local vector = v4 - v3
	local v5 = (v3 + v4) * 0.5 - lookVector * (self.thickness * 0.5)
	self.Part.Size = Vector3.new(
		math.abs((vector:Dot(cFrame.RightVector))),
		math.abs((vector:Dot(cFrame.UpVector))),
		self.thickness
	)
	self.Part.CFrame = cFrame.Rotation + v5
end

function class:Follow()
	for _, watcher in self.watchers do
		watcher:Disconnect()
	end

	table.clear(self.watchers)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return
	end

	self:Fit()
	self.Part.Parent = currentCamera

	local function refit()
		self:Fit()
	end

	table.insert(self.watchers, currentCamera:GetPropertyChangedSignal("CFrame"):Connect(refit))
	table.insert(self.watchers, currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refit))
	table.insert(self.watchers, currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(refit))
	table.insert(self.watchers, Workspace:GetPropertyChangedSignal("CurrentCamera"):Once(function()
		self:Follow()
	end))
end

function class.Adopt(p, p2)
	p2.Parent = p.Part
end

function class.Dispose(p)
	for _, watcher in p.watchers do
		watcher:Disconnect()
	end

	table.clear(p.watchers)
	p.Part:Destroy()
end

return table.freeze(class)