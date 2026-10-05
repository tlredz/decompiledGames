local createVector = vector.create
local Emote1272Particles = {}
Emote1272Particles.__index = Emote1272Particles

local function sampleRange(p, p2, p3, p4)
	if typeof(p) ~= "NumberRange" then
		return tonumber(p) or 0
	end

	if p.Min == p.Max then
		return p.Min
	end

	if p2 and p4 > 1 then
		return (math.lerp(p.Min, p.Max, (p3 - 1) / (p4 - 1)))
	end

	return (math.lerp(p.Min, p.Max, math.random()))
end

local function generateSequenceSeed(sequence)
	local result = {}

	if typeof(sequence) ~= "NumberSequence" then
		return result
	end

	for k, keypoint in sequence.Keypoints do
		result[k] = (math.random() * 2 - 1) * keypoint.Envelope
	end

	return result
end

local function sampleNumberSequence(sequence, value, list, value2)
	if typeof(sequence) ~= "NumberSequence" then
		return tonumber(sequence) or value2 or 0
	end

	local keypoints = sequence.Keypoints
	local v = math.clamp(value, 0, 1)

	if v <= keypoints[1].Time then
		return keypoints[1].Value + (list[1] or 0)
	end

	for i = 2, #keypoints do
		local keypoint = keypoints[i]

		if not (v <= keypoint.Time) then
			continue
		end

		local keypoint2 = keypoints[i - 1]
		local v2 = math.max(keypoint.Time - keypoint2.Time, 1e-6)
		local v3 = (v - keypoint2.Time) / v2
		return (math.lerp(keypoint2.Value + (list[i - 1] or 0), keypoint.Value + (list[i] or 0), v3))
	end

	local count = #keypoints
	return keypoints[count].Value + (list[count] or 0)
end

local function sampleColorSequence(color, value, color2)
	if typeof(color) ~= "ColorSequence" then
		return typeof(color) == "Color3" and color or color2
	end

	local keypoints = color.Keypoints
	local v = math.clamp(value, 0, 1)

	if v <= keypoints[1].Time then
		return keypoints[1].Value
	end

	for i = 2, #keypoints do
		local keypoint = keypoints[i]

		if not (v <= keypoint.Time) then
			continue
		end

		local keypoint2 = keypoints[i - 1]
		local v2 = math.max(keypoint.Time - keypoint2.Time, 1e-6)
		return keypoint2.Value:Lerp(keypoint.Value, (v - keypoint2.Time) / v2)
	end

	return keypoints[#keypoints].Value
end

local function getTrails(folder, _trailsByPart)
	local v = _trailsByPart[folder]

	if v then
		return v
	end

	local trails = {}

	for _, trail in folder:GetDescendants() do
		if trail:IsA("Trail") then
			table.insert(trails, trail)
		end
	end

	_trailsByPart[folder] = trails
	return trails
end

local function getLongestTrailLifetime(items)
	local v = 0

	for _, item in items do
		v = math.max(v, item.Lifetime)
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTrailsEnabled(trails, enabled, p)
	for _, item in trails do
		item.Enabled = enabled

		if p then
			item:Clear()
		end
	end
end

local function ensureRuntimeHighlight(instance, instance2)
	if not instance2:GetAttribute("RuntimeHighlight") or instance:FindFirstChildOfClass("Highlight") then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.FillColor = instance2:GetAttribute("RuntimeHighlightFillColor") or Color3.new()
	highlight.FillTransparency = instance2:GetAttribute("RuntimeHighlightFillTransparency") or 1
	highlight.OutlineColor = instance2:GetAttribute("RuntimeHighlightOutlineColor") or Color3.new(1, 0, 0)
	highlight.OutlineTransparency = instance2:GetAttribute("RuntimeHighlightOutlineTransparency") or 0
	local runtimeHighlightDepthMode = instance2:GetAttribute("RuntimeHighlightDepthMode")

	if type(runtimeHighlightDepthMode) == "string" then
		highlight.DepthMode = Enum.HighlightDepthMode[runtimeHighlightDepthMode] or Enum.HighlightDepthMode.AlwaysOnTop
	else
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	end

	highlight.Adornee = instance
	highlight.Parent = instance
end

function Emote1272Particles.new(parent)
	local folder = Instance.new("Folder")
	folder.Name = "Emote1272_Particles"
	folder.Parent = parent
	return (setmetatable({
		_folder = folder,
		_active = {},
		_pools = {},
		_emitterData = {},
		_trailsByPart = setmetatable({}, {
			__mode = "k"
		}),
		_destroyed = false
	}, Emote1272Particles))
end

function Emote1272Particles:_acquirePart(p)
	local _pool = self._pools[p]
	local v = _pool and table.remove(_pool) or p.RenderTemplate:Clone()
	v.Anchored = true
	v.CanCollide = false
	v.CanQuery = false
	v.CanTouch = false
	ensureRuntimeHighlight(v, p)
	setTrailsEnabled(getTrails(v, self._trailsByPart), true, true) -- equivalent call inferred; original call site unknown
	v.Parent = self._folder
	return v
end

function Emote1272Particles:_releasePart(state)
	local part = state.Part

	if not part then
		return
	end

	setTrailsEnabled(getTrails(part, self._trailsByPart), false, true) -- equivalent call inferred; original call site unknown
	part.Transparency = 1
	part.Parent = nil
	local parts = self._pools[state.Emitter]

	if not parts then
		parts = {}
		self._pools[state.Emitter] = parts
	end

	table.insert(parts, part)
	state.Part = nil
end

function Emote1272Particles:_getEmitterData(instance)
	local v = self._emitterData[instance]

	if v then
		return v
	end

	local partIcleProperties = instance:FindFirstChild("PartIcleProperties")
	local renderTemplate = instance:FindFirstChild("RenderTemplate")

	if partIcleProperties and renderTemplate then
		local v2 = {
			Count = math.max(0, instance:GetAttribute("EmitCount") or 0),
			Lifetime = partIcleProperties:GetAttribute("Lifetime"),
			Drag = partIcleProperties:GetAttribute("Drag") or 0,
			RotationMode = partIcleProperties:GetAttribute("RotMode") or "OverLife",
			Orientation = partIcleProperties:GetAttribute("Orientation") or "None",
			EmissionDirection = partIcleProperties:GetAttribute("EmissionDirection") or "Top",
			SpreadAngle = partIcleProperties:GetAttribute("SpreadAngle") or Vector2.zero,
			RotX = partIcleProperties:GetAttribute("RotX"),
			RotY = partIcleProperties:GetAttribute("RotY"),
			RotZ = partIcleProperties:GetAttribute("RotZ"),
			RotXEven = partIcleProperties:GetAttribute("RotXEven"),
			RotYEven = partIcleProperties:GetAttribute("RotYEven"),
			RotZEven = partIcleProperties:GetAttribute("RotZEven"),
			PosX = partIcleProperties:GetAttribute("PosX"),
			PosY = partIcleProperties:GetAttribute("PosY"),
			PosZ = partIcleProperties:GetAttribute("PosZ"),
			PosXEven = partIcleProperties:GetAttribute("PosXEven"),
			PosYEven = partIcleProperties:GetAttribute("PosYEven"),
			PosZEven = partIcleProperties:GetAttribute("PosZEven"),
			Speed = partIcleProperties:GetAttribute("Speed"),
			RotationX = partIcleProperties:GetAttribute("RotSpeedX"),
			RotationY = partIcleProperties:GetAttribute("RotSpeedY"),
			RotationZ = partIcleProperties:GetAttribute("RotSpeedZ"),
			SizeX = partIcleProperties:GetAttribute("SizeX"),
			SizeY = partIcleProperties:GetAttribute("SizeY"),
			SizeZ = partIcleProperties:GetAttribute("SizeZ"),
			Transparency = partIcleProperties:GetAttribute("Transparency"),
			Color = partIcleProperties:GetAttribute("Color")
		}
		self._emitterData[instance] = v2
		return v2
	else
		return nil
	end
end

local function sampleSpawnCFrame(data, p, p2, count)
	local cframe = CFrame.Angles(
		math.rad((sampleRange(data.RotX, data.RotXEven, p2, count))),
		math.rad((sampleRange(data.RotY, data.RotYEven, p2, count))),
		(math.rad((sampleRange(data.RotZ, data.RotZEven, p2, count))))
	)
	local vector2 = Vector3.new(
		sampleRange(data.PosX, data.PosXEven, p2, count),
		sampleRange(data.PosY, data.PosYEven, p2, count),
		(sampleRange(data.PosZ, data.PosZEven, p2, count))
	)
	return p * cframe * CFrame.new(vector2)
end

local function sampleDirection(data, p)
	local v = data.EmissionDirection == "Bottom" and -p.UpVector or p.UpVector
	local spreadAngle = data.SpreadAngle

	if spreadAngle.X == 0 and spreadAngle.Y == 0 then
		return v
	end

	local cframe = CFrame.Angles(
		math.rad((math.random() * 2 - 1) * spreadAngle.X),
		math.rad((math.random() * 2 - 1) * spreadAngle.Y),
		0
	)
	return (CFrame.lookAt(createVector(0, 0, 0), v) * cframe).LookVector
end

function Emote1272Particles:_createParticle(emitter, data, p2, p3)
	local v = sampleSpawnCFrame(data, p2, p3, data.Count)
	local _acquirePart = self:_acquirePart(emitter)
	local v2 = {
		Part = _acquirePart,
		Emitter = emitter,
		StartedAt = os.clock(),
		Lifetime = 0,
		TrailLifetime = 0,
		TrailsStopped = false,
		Origin = 0,
		BaseRotation = 0,
		Direction = 0,
		Drag = 0,
		Speed = 0,
		RotationMode = 0,
		RotationX = 0,
		RotationY = 0,
		RotationZ = 0,
		Orientation = 0,
		SizeX = 0,
		SizeY = 0,
		SizeZ = 0,
		Transparency = 0,
		Color = 0,
		Seeds = 0
	}
	local lifetime = data.Lifetime
	local min

	if typeof(lifetime) == "NumberRange" then
		if lifetime.Min == lifetime.Max then
			min = lifetime.Min
		else
			min = math.lerp(lifetime.Min, lifetime.Max, math.random())
		end
	else
		min = tonumber(lifetime) or 0
	end

	v2.Lifetime = math.max(min, 0.001)
	local trails = getTrails(_acquirePart, self._trailsByPart)
	local trailLifetime = 0

	for _, trail in trails do
		trailLifetime = math.max(trailLifetime, trail.Lifetime)
	end

	v2.TrailLifetime = trailLifetime
	v2.Origin = v.Position
	v2.BaseRotation = v.Rotation
	v2.Direction = sampleDirection(data, p2)
	v2.Drag = data.Drag
	v2.Speed = sampleNumberSequence(data.Speed, 0, generateSequenceSeed(data.Speed), 0)
	v2.RotationMode = data.RotationMode
	v2.RotationX = sampleNumberSequence(data.RotationX, 0, generateSequenceSeed(data.RotationX), 0)
	v2.RotationY = sampleNumberSequence(data.RotationY, 0, generateSequenceSeed(data.RotationY), 0)
	v2.RotationZ = sampleNumberSequence(data.RotationZ, 0, generateSequenceSeed(data.RotationZ), 0)
	v2.Orientation = data.Orientation
	v2.SizeX = data.SizeX
	v2.SizeY = data.SizeY
	v2.SizeZ = data.SizeZ
	v2.Transparency = data.Transparency
	v2.Color = data.Color
	v2.Seeds = {}
	v2.Seeds.SizeX = generateSequenceSeed(v2.SizeX)
	v2.Seeds.SizeY = generateSequenceSeed(v2.SizeY)
	v2.Seeds.SizeZ = generateSequenceSeed(v2.SizeZ)
	v2.Seeds.Transparency = generateSequenceSeed(v2.Transparency)
	return v2
end

function Emote1272Particles:Emit(p, p2)
	local _getEmitterData = self:_getEmitterData(p)

	if not _getEmitterData then
		return
	end

	for i = 1, _getEmitterData.Count do
		table.insert(self._active, self:_createParticle(p, _getEmitterData, p2, i))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTravelDistance(speed, drag, p)
	if drag == 0 then
		return speed * p
	end

	return speed * (1 - math.exp(-drag * p)) / drag
end

local function getParticleRotation(data, p, p2, p3, p4)
	local v = data.RotationMode == "Speed" and p or p2
	local v2 = data.BaseRotation * CFrame.Angles(
		math.rad(data.RotationX * v),
		math.rad(data.RotationY * v),
		(math.rad(data.RotationZ * v))
	)

	if data.Orientation ~= "FacingCameraWorldUp" or not p3 then
		return v2
	end

	local v3 = p3.CFrame.Position - p4
	local vector2 = Vector3.new(v3.X, 0, v3.Z)

	if vector2.Magnitude > 0.001 then
		return CFrame.lookAt(createVector(0, 0, 0), vector2.Unit, createVector(0, 1, 0)) * v2
	end

	return v2
end

function Emote1272Particles:_updateParticle(state, p, p2)
	local part = state.Part

	if not (part and part.Parent) then
		return true
	end

	local v = p - state.StartedAt

	if state.Lifetime <= v then
		if not state.TrailsStopped then
			state.TrailsStopped = true
			local trails = getTrails(part, self._trailsByPart)

			for _, trail in trails do
				trail.Enabled = false
			end
		end

		if state.Lifetime + state.TrailLifetime <= v then
			self:_releasePart(state)
			return true
		else
			return false
		end
	else
		local v2 = math.clamp(v / state.Lifetime, 0, 1)
		local travelDistance = getTravelDistance(state.Speed, state.Drag, v) -- equivalent call inferred; original call site unknown
		local v3 = state.Origin + state.Direction * travelDistance
		part.CFrame = CFrame.new(v3) * getParticleRotation(state, v, v2, p2, v3)
		part.Size = Vector3.new(
			math.max(0.001, (sampleNumberSequence(state.SizeX, v2, state.Seeds.SizeX, part.Size.X))),
			math.max(0.001, (sampleNumberSequence(state.SizeY, v2, state.Seeds.SizeY, part.Size.Y))),
			(math.max(0.001, (sampleNumberSequence(state.SizeZ, v2, state.Seeds.SizeZ, part.Size.Z))))
		)
		part.Transparency = math.clamp(sampleNumberSequence(state.Transparency, v2, state.Seeds.Transparency, 0), 0, 1)
		part.Color = sampleColorSequence(state.Color, v2, part.Color)
		return false
	end
end

function Emote1272Particles:Update()
	local now = os.clock()
	local currentCamera = workspace.CurrentCamera

	for i = #self._active, 1, -1 do
		if self:_updateParticle(self._active[i], now, currentCamera) then
			table.remove(self._active, i)
		end
	end
end

function Emote1272Particles:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, v in self._active do
		if v.Part then
			v.Part:Destroy()
		end
	end

	for _, _pool in self._pools do
		for _, v in _pool do
			v:Destroy()
		end
	end

	table.clear(self._active)
	table.clear(self._pools)
	table.clear(self._emitterData)
	self._folder:Destroy()
end

return Emote1272Particles