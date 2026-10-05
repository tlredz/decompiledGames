local createVector = vector.create
local Spring = require(game.ReplicatedStorage.Util.Spring)
require(script.Parent.Types)
local Animations = {}
Animations.__index = Animations

-- equivalent calls inferred from this helper; original call sites unknown
local function toOrientation(_currentCFrame: CFrame)
	return (Vector3.new(_currentCFrame:ToOrientation()))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pivotCFrame(pivotPoint: Vector3, pivotAxis: Vector3, p: number, baseCFrame: CFrame)
	return CFrame.new(pivotPoint) * CFrame.fromAxisAngle(pivotAxis, p) * CFrame.new(-pivotPoint) * baseCFrame
end

local function shortestRotationGoal(vector2: Vector3, vector3: Vector3)
	local function wrap(p: number)
		return (math.atan2(math.sin(p), (math.cos(p))))
	end

	local X = vector2.X
	local v = vector3.X - vector2.X
	local v2 = X + math.atan2(math.sin(v), (math.cos(v)))
	local Y = vector2.Y
	local v3 = vector3.Y - vector2.Y
	local v4 = Y + math.atan2(math.sin(v3), (math.cos(v3)))
	local Z = vector2.Z
	local v5 = vector3.Z - vector2.Z
	return (Vector3.new(v2, v4, Z + math.atan2(math.sin(v5), (math.cos(v5)))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBaseCFrame(object)
	return object._controller._currentCFrame * object._lastImpulseOffset:Inverse()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBaseCFrame(object, cframe: CFrame)
	object._controller._currentCFrame = cframe * object._lastImpulseOffset
end

function Animations.new(controller)
	return (setmetatable({
		_controller = controller,
		_animating = false,
		_goalCFrame = nil,
		_positionSpring = nil,
		_rotationSpring = nil,
		_pivoting = false,
		_pivotPoint = nil,
		_pivotAxis = nil,
		_pivotStartCFrame = nil,
		_pivotSpring = nil,
		_fieldOfViewSpring = nil,
		_impulseSpring = Spring.new(0.5, 6, createVector(0, 0, 0)),
		_rotationImpulseSpring = Spring.new(0.5, 6, createVector(0, 0, 0)),
		_lastImpulseOffset = CFrame.identity
	}, Animations))
end

function Animations:AnimateFieldOfView(value: number, value2: number?, value3: number?)
	local _controller = self._controller
	local currentFieldOfView = math.clamp(value, 1, 120)

	if _controller._areAnimationsInstant then
		self:_stopFieldOfView()
		_controller._currentFieldOfView = currentFieldOfView
	else
		local _currentFieldOfView = _controller._currentFieldOfView or _controller._camera.FieldOfView
		local fieldOfViewSpring = Spring.new(value2 or 1, value3 or 2, _currentFieldOfView)
		fieldOfViewSpring:SetGoal(currentFieldOfView)

		if self._fieldOfViewSpring then
			fieldOfViewSpring.v = self._fieldOfViewSpring:GetVelocity()
		end

		_controller._currentFieldOfView = _currentFieldOfView
		self._fieldOfViewSpring = fieldOfViewSpring
	end
end

function Animations:AnimateTo(goalCFrame: CFrame, value: number?, value2: number?)
	local _controller = self._controller

	if _controller._cameraTarget then
		_controller._cameraTarget:Destroy()
	end

	if _controller._areAnimationsInstant then
		self:_stopTransform()
		setBaseCFrame(self, goalCFrame) -- equivalent call inferred; original call site unknown
	else
		local _currentCFrame = _controller._currentCFrame
		local orientation = toOrientation(_currentCFrame) -- equivalent call inferred; original call site unknown
		local positionSpring = Spring.new(value or 1, value2 or 2, _currentCFrame.Position)
		positionSpring:SetGoal(goalCFrame.Position)
		local rotationSpring = Spring.new(value or 1, value2 or 2, orientation)
		rotationSpring:SetGoal((shortestRotationGoal(orientation, Vector3.new(goalCFrame:ToOrientation()))))

		if self._animating and self._positionSpring and self._rotationSpring then
			positionSpring.v = self._positionSpring:GetVelocity()
			rotationSpring.v = self._rotationSpring:GetVelocity()
		end

		self:_stopTransform()
		self._positionSpring = positionSpring
		self._rotationSpring = rotationSpring
		self._goalCFrame = goalCFrame
		self._animating = true
	end
end

function Animations:PivotAroundX(vector2: Vector3, p: number, p2: number?, p3: number?)
	self:_pivotAround(createVector(1, 0, 0), vector2, p, p2, p3)
end

function Animations:PivotAroundY(vector2: Vector3, p: number, p2: number?, p3: number?)
	self:_pivotAround(createVector(0, 1, 0), vector2, p, p2, p3)
end

function Animations:PivotAroundZ(vector2: Vector3, p: number, p2: number?, p3: number?)
	self:_pivotAround(createVector(0, 0, 1), vector2, p, p2, p3)
end

function Animations:_pivotAround(pivotAxis: Vector3, pivotPoint: Vector3, p: number, value: number?, value2: number?)
	local _controller = self._controller

	if _controller._cameraTarget then
		_controller._cameraTarget:Destroy()
	end

	if _controller._areAnimationsInstant then
		self:_stopTransform()
		local v = math.rad(p)
		local baseCFrame = getBaseCFrame(self) -- equivalent call inferred; original call site unknown
		local v2 = pivotCFrame(pivotPoint, pivotAxis, v, baseCFrame) -- equivalent call inferred; original call site unknown
		setBaseCFrame(self, v2) -- equivalent call inferred; original call site unknown
	else
		local pivotSpring = Spring.new(value or 1, value2 or 2, 0)
		pivotSpring:SetGoal((math.rad(p)))

		if self._pivoting and self._pivotSpring then
			pivotSpring.v = self._pivotSpring:GetVelocity()
		end

		self:_stopTransform()
		self._pivoting = true
		self._pivotPoint = pivotPoint
		self._pivotAxis = pivotAxis
		self._pivotStartCFrame = _controller._currentCFrame
		self._pivotSpring = pivotSpring
	end
end

function Animations:Impulse(vector2: Vector3)
	self._impulseSpring.v += vector2
end

function Animations:RotationImpulse(vector2: Vector3)
	self._rotationImpulseSpring.v += vector2
end

function Animations:IsAnimating()
	return self._animating or self._pivoting or self._fieldOfViewSpring ~= nil
end

function Animations:_stopTransform()
	self._animating = false
	self._positionSpring = nil
	self._rotationSpring = nil
	self._goalCFrame = nil
	self._pivoting = false
	self._pivotPoint = nil
	self._pivotAxis = nil
	self._pivotStartCFrame = nil
	self._pivotSpring = nil
end

function Animations:_stopFieldOfView()
	self._fieldOfViewSpring = nil
end

function Animations:Stop()
	self:_stopTransform()
	self:_stopFieldOfView()
end

function Animations:SkipToGoal()
	local _goalCFrame = nil

	if self._pivoting and self._pivotSpring then
		_goalCFrame = pivotCFrame(self._pivotPoint, self._pivotAxis, self._pivotSpring.g, self._pivotStartCFrame)
	elseif self._animating and self._goalCFrame then
		_goalCFrame = self._goalCFrame
	end

	if _goalCFrame then
		self:_stopTransform()
		setBaseCFrame(self, _goalCFrame) -- equivalent call inferred; original call site unknown
	end

	local _fieldOfViewSpring = self._fieldOfViewSpring

	if _fieldOfViewSpring then
		self:_stopFieldOfView()
		self._controller._currentFieldOfView = _fieldOfViewSpring.g
	end
end

function Animations:_hasImpulse()
	return self._impulseSpring:GetPosition().Magnitude > 0.001 or self._impulseSpring:GetVelocity().Magnitude > 0.001 or self._rotationImpulseSpring:GetPosition().Magnitude > 0.0001 or self._rotationImpulseSpring:GetVelocity().Magnitude > 0.0001
end

function Animations:_resetImpulses()
	self._impulseSpring.p = createVector(0, 0, 0)
	self._impulseSpring.v = createVector(0, 0, 0)
	self._rotationImpulseSpring.p = createVector(0, 0, 0)
	self._rotationImpulseSpring.v = createVector(0, 0, 0)
end

function Animations:Update(p: number)
	local _controller = self._controller
	local v = self._lastImpulseOffset ~= CFrame.identity
	local _fieldOfViewSpring = self._fieldOfViewSpring

	if _fieldOfViewSpring then
		local v2 = _fieldOfViewSpring:Update(p)
		_controller._currentFieldOfView = math.clamp(v2, 1, 120)

		if math.abs(_fieldOfViewSpring.g - v2) < 0.001 and math.abs((_fieldOfViewSpring:GetVelocity())) < 0.001 then
			_controller._currentFieldOfView = _fieldOfViewSpring.g
			self:_stopFieldOfView()
		end
	end

	if not (self._animating or self._pivoting or v or self:_hasImpulse()) then
		return
	end

	local _goalCFrame = _controller._currentCFrame * self._lastImpulseOffset:Inverse()

	if self._pivoting and self._pivotSpring then
		local _pivotSpring = self._pivotSpring
		local _pivotPoint = self._pivotPoint
		local _pivotAxis = self._pivotAxis
		local _pivotStartCFrame = self._pivotStartCFrame
		local v2 = _pivotSpring:Update(p)
		_goalCFrame = pivotCFrame(_pivotPoint, _pivotAxis, v2, _pivotStartCFrame)

		if math.abs(_pivotSpring.g - v2) < 0.0001 and math.abs((_pivotSpring:GetVelocity())) < 0.0001 then
			_goalCFrame = pivotCFrame(_pivotPoint, _pivotAxis, _pivotSpring.g, _pivotStartCFrame)
			self:_stopTransform()
		end
	elseif self._animating and self._positionSpring and self._rotationSpring then
		local v2 = self._positionSpring:Update(p)
		local v3 = self._rotationSpring:Update(p)
		_goalCFrame = CFrame.new(v2) * CFrame.fromOrientation(v3.X, v3.Y, v3.Z)
		local v4

		if (self._positionSpring.g - v2).Magnitude < 0.001 then
			v4 = self._positionSpring:GetVelocity().Magnitude < 0.001
		else
			v4 = false
		end

		local v5

		if (self._rotationSpring.g - v3).Magnitude < 0.0001 then
			v5 = self._rotationSpring:GetVelocity().Magnitude < 0.0001
		else
			v5 = false
		end

		if v4 and v5 then
			_goalCFrame = self._goalCFrame
			self:_stopTransform()
		end
	end

	local identity = CFrame.identity

	if self:_hasImpulse() then
		local v2 = self._impulseSpring:Update(p)
		local v3 = self._rotationImpulseSpring:Update(p)

		if self:_hasImpulse() then
			identity = CFrame.new(v2) * CFrame.fromOrientation(v3.X, v3.Y, v3.Z)
		else
			self:_resetImpulses()
		end
	end

	self._lastImpulseOffset = identity
	_controller._currentCFrame = _goalCFrame * identity
end

function Animations:Destroy()
	self:Stop()
	self._controller = nil
end

return Animations