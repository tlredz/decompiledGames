local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
local EggEnergyOrbField = {}
EggEnergyOrbField.__index = EggEnergyOrbField
EggEnergyOrbField.__class = "EggEnergyOrbField"

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getOrbTransparency(p: number)
	if p < 0.14 then
		return 1 - p / 0.14
	end

	if p > 0.72 then
		return (p - 0.72) / 0.28
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomUnitVector(object)
	local number = object:NextNumber(-1, 1)
	local number2 = object:NextNumber(0, 6.283185307179586)
	local v = math.sqrt((math.max(1 - number * number, 0)))
	return (Vector3.new(v * math.cos(number2), v * math.sin(number2), number))
end

local function randomOrbitPlane(object)
	local vector2 = randomUnitVector(object) -- equivalent call inferred; original call site unknown
	local unit = vector2:Cross(math.abs(vector2.Y) < 0.9 and createVector(0, 1, 0) or createVector(1, 0, 0)).Unit
	return unit, vector2:Cross(unit).Unit
end

function EggEnergyOrbField.new(parent, color: Color3)
	t.strict(t.Instance)(parent)
	t.strict(t.Color3)(color)
	local self = setmetatable({}, EggEnergyOrbField)
	self._color = color
	self._parent = parent
	self._rng = Random.new()
	self._orbs = {}
	self._spawnAccumulator = 0
	self._destroyed = false
	return self
end

function EggEnergyOrbField:_resetOrb(state, vector2: Vector3)
	local _rng = self._rng
	local vector3 = randomUnitVector(_rng) -- equivalent call inferred; original call site unknown
	local unit = vector3:Cross(math.abs(vector3.Y) < 0.9 and createVector(0, 1, 0) or createVector(1, 0, 0)).Unit
	local unit2 = vector3:Cross(unit).Unit
	state.PlaneU = unit
	state.PlaneV = unit2
	state.Radius = _rng:NextNumber(4.5, 6.5)
	state.Angle = _rng:NextNumber(0, 6.283185307179586)
	state.AngularSpeed = _rng:NextNumber(3, 7) * (_rng:NextInteger(0, 1) == 0 and -1 or 1)
	state.Age = 0
	state.CurrentRadius = state.Radius
	state.Part.Position = vector2 + (state.PlaneU * math.cos(state.Angle) + state.PlaneV * math.sin(state.Angle)) * state.Radius
	state.Part.Transparency = 1
	state.Trail.Enabled = true
	state.Trail:Clear()
end

function EggEnergyOrbField:_createOrb(vector2: Vector3)
	local part = Instance.new("Part")
	part.Name = "EnergyOrb"
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = self._color
	part.Size = createVector(0.26, 0.26, 0.26)
	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(0, 0.13, 0)
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(0, -0.13, 0)
	attachment2.Parent = part
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Lifetime = 0.32
	trail.LightEmission = 1
	trail.LightInfluence = 0
	trail.FaceCamera = true
	trail.MinLength = 0
	trail.Color = ColorSequence.new(self._color)
	trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 0) })
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	trail.Parent = part
	local v = {
		Part = part,
		Trail = trail,
		CurrentRadius = 6.5,
		PlaneU = createVector(1, 0, 0),
		PlaneV = createVector(0, 0, 1),
		Radius = 6.5,
		Angle = 0,
		AngularSpeed = 3,
		Age = 0,
		AbsorbSeconds = self._rng:NextNumber(0.9, 1.8)
	}
	self:_resetOrb(v, vector2)
	part.Parent = self._parent
	return v
end

function EggEnergyOrbField:Step(vector2: Vector3, value: number, p: number)
	if self._destroyed then
		return
	end

	local _orbs = self._orbs

	if #_orbs < 26 then
		self._spawnAccumulator += p
		local v = math.clamp(value, 0, 1) * -0.19999999999999998 + 0.24

		while v <= self._spawnAccumulator and #_orbs < 26 do
			self._spawnAccumulator -= v
			table.insert(_orbs, self:_createOrb(vector2))
		end
	end

	for _, _orb in _orbs do
		_orb.Age += p
		local v = _orb.Age / _orb.AbsorbSeconds

		if v >= 1 then
			self:_resetOrb(_orb, vector2)
		else
			_orb.Angle += _orb.AngularSpeed * p * (1 + v * 2.5)
			_orb.CurrentRadius = _orb.Radius * (1 - v) ^ 1.5
			_orb.Part.Position = vector2 + (_orb.PlaneU * math.cos(_orb.Angle) + _orb.PlaneV * math.sin(_orb.Angle)) * _orb.CurrentRadius
			local part = _orb.Part
			part.Transparency = getOrbTransparency(v)
			_orb.Trail.Enabled = v <= 0.72
		end
	end
end

function EggEnergyOrbField:Absorb(vector2: Vector3, p: number, callback)
	if self._destroyed then
		return
	end

	self._destroyed = true
	local clone = table.clone(self._orbs)
	table.clear(self._orbs)

	if #clone == 0 then
		return
	end

	local total = 0

	while total < p do
		local v = RunService.Heartbeat:Wait()
		total += v
		local v2 = math.min(total / p, 1)
		local v3 = 1 - TweenService:GetValue(v2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		local v4 = math.max((v2 - 0.72) / 0.28, 0)

		for _, v5 in clone do
			v5.Angle += v5.AngularSpeed * v * 3.5
			v5.Part.Position = vector2 + (v5.PlaneU * math.cos(v5.Angle) + v5.PlaneV * math.sin(v5.Angle)) * (v5.CurrentRadius * v3)
			v5.Part.Transparency = math.max(v5.Part.Transparency, v4)

			if v2 >= 0.82 then
				v5.Trail.Enabled = false
			end
		end

		if callback ~= nil then
			callback(v)
		end
	end

	for _, v in clone do
		v.Part.Transparency = 1
		v.Trail.Enabled = false
		Debris:AddItem(v.Part, 0.32)
	end
end

function EggEnergyOrbField:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, _orb in self._orbs do
		_orb.Part:Destroy()
	end

	table.clear(self._orbs)
end

return EggEnergyOrbField