local createVector = vector.create
local Spring = require(game.ReplicatedStorage.Util.Spring)
require(script.Parent.Types)
local CameraTarget = {}
CameraTarget.__index = CameraTarget

local function resolvePosition(value)
	if type(value) == "function" then
		value = value()
	end

	if typeof(value) == "Vector3" then
		return value
	end

	if not (typeof(value) ~= "CFrame" and typeof(value) ~= "Instance") then
		return value.Position
	end

	error((`CameraTarget: unsupported target type "{typeof(value)}"`))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapSpring(p)
	p.p = p.g
	p.v = 0
end

function CameraTarget:new(target)
	local position = resolvePosition(target)
	local v = self._currentCFrame.Position - position
	local magnitude = v.Magnitude
	local v2, v3

	if magnitude < 0.5 then
		v2 = 0
		v3 = 0
		magnitude = 10
	else
		v2 = math.atan2(v.X, v.Z)
		v3 = math.clamp(math.asin(v.Y / magnitude), -1.4835298641951802, 1.4835298641951802)
	end

	return (setmetatable({
		_controller = self,
		_target = target,
		_yawSpring = Spring.new(1, 3, v2),
		_pitchSpring = Spring.new(1, 3, v3),
		_distanceSpring = Spring.new(1, 3, magnitude),
		_trackingSpring = Spring.new(1, 3, position),
		_lockedPosition = nil,
		_destroyed = false
	}, CameraTarget))
end

function CameraTarget:PivotAroundY(p: number)
	self._yawSpring:SetGoal(self._yawSpring.g + math.rad(p))

	if self._controller._areAnimationsInstant then
		self:SkipToGoal()
	end
end

function CameraTarget:PivotAroundX(p: number)
	self._pitchSpring:SetGoal((math.clamp(self._pitchSpring.g + math.rad(p), -1.4835298641951802, 1.4835298641951802)))

	if self._controller._areAnimationsInstant then
		self:SkipToGoal()
	end
end

function CameraTarget:Zoom(p: number)
	self._distanceSpring:SetGoal((math.max(p, 0.5)))

	if self._controller._areAnimationsInstant then
		self:SkipToGoal()
	end
end

function CameraTarget:SetTrackingSpring(p2: number, p3: number)
	local v

	if p2 >= 0 then
		v = p3 >= 0
	else
		v = false
	end

	assert(v, "CameraTarget tracking spring must converge")
	self._trackingSpring.d = p2
	self._trackingSpring.f = p3

	if self._controller._areAnimationsInstant then
		self._trackingSpring.p = self._trackingSpring.g
		self._trackingSpring.v = createVector(0, 0, 0)
	end
end

function CameraTarget:SetPositionLocked(flag: boolean)
	local _currentCFrame = self._controller._currentCFrame
	local lockedPosition

	if flag then
		lockedPosition = _currentCFrame.Position
	end

	self._lockedPosition = lockedPosition

	if flag then
		local position = resolvePosition(self._target)
		local v2 = math.max((position - _currentCFrame.Position).Magnitude, 0.5)
		self._trackingSpring.p = _currentCFrame.Position + _currentCFrame.LookVector * v2
		self._trackingSpring.v = createVector(0, 0, 0)
		self._trackingSpring:SetGoal(position)
	end

	self:Update(0)
end

function CameraTarget:SetTarget(target)
	self._target = target

	if self._controller._areAnimationsInstant then
		self:SkipToGoal()
	end
end

function CameraTarget:GetTargetPosition()
	return resolvePosition(self._target)
end

function CameraTarget:SkipToGoal()
	snapSpring(self._yawSpring) -- equivalent call inferred; original call site unknown
	snapSpring(self._pitchSpring) -- equivalent call inferred; original call site unknown
	snapSpring(self._distanceSpring) -- equivalent call inferred; original call site unknown
	self._trackingSpring.p = self._trackingSpring.g
	self._trackingSpring.v = createVector(0, 0, 0)
	self:Update(0)
end

function CameraTarget:Update(p: number)
	local _controller = self._controller
	local position = resolvePosition(self._target)
	self._trackingSpring:SetGoal(position)

	if self._lockedPosition then
		position = self._trackingSpring:Update(p)
	end

	local v = self._yawSpring:Update(p)
	local v2 = math.clamp(self._pitchSpring:Update(p), -1.4835298641951802, 1.4835298641951802)
	local v3 = math.max(self._distanceSpring:Update(p), 0.5)
	local v4 = Vector3.new(math.cos(v2) * math.sin(v), math.sin(v2), math.cos(v2) * math.cos(v)) * v3
	local _lockedPosition = self._lockedPosition or position + v4
	_controller._currentCFrame = CFrame.lookAt(_lockedPosition, position) * _controller.Animations._lastImpulseOffset
end

function CameraTarget:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	local _controller = self._controller

	if _controller and _controller._cameraTarget == self then
		_controller._cameraTarget = nil
	end

	self._controller = nil
end

return CameraTarget