local createVector = vector.create
local ContextActionService = game:GetService("ContextActionService")
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserBetterHandlingVehicleInputStates")
end)
local v = success and result
local VehicleController = {}
VehicleController.__index = VehicleController

function VehicleController.new(CONTROL_ACTION_PRIORITY)
	local self = setmetatable({}, VehicleController)
	self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY
	self.enabled = false
	self.vehicleSeat = nil
	self.throttle = 0
	self.steer = 0
	self.acceleration = 0
	self.decceleration = 0
	self.turningRight = 0
	self.turningLeft = 0
	self.vehicleMoveVector = createVector(0, 0, 0)
	self.autoPilot = {}
	self.autoPilot.MaxSpeed = 0
	self.autoPilot.MaxSteeringAngle = 0
	return self
end

function VehicleController:BindContextActions()
	ContextActionService:BindActionAtPriority("throttleAccel", function(p, p2, p3)
		self:OnThrottleAccel(p, p2, p3)
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonR2)
	ContextActionService:BindActionAtPriority("throttleDeccel", function(p, p2, p3)
		self:OnThrottleDeccel(p, p2, p3)
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonL2)
	ContextActionService:BindActionAtPriority("arrowSteerRight", function(p, p2, p3)
		self:OnSteerRight(p, p2, p3)
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Right)
	ContextActionService:BindActionAtPriority("arrowSteerLeft", function(p, p2, p3)
		self:OnSteerLeft(p, p2, p3)
		return Enum.ContextActionResult.Pass
	end, false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Left)
end

function VehicleController:Enable(enabled, vehicleSeat)
	if enabled == self.enabled and vehicleSeat == self.vehicleSeat then
		return
	end

	self.enabled = enabled
	self.vehicleMoveVector = createVector(0, 0, 0)

	if enabled then
		if vehicleSeat then
			self.vehicleSeat = vehicleSeat
			self:SetupAutoPilot()
			self:BindContextActions()
		end
	else
		ContextActionService:UnbindAction("throttleAccel")
		ContextActionService:UnbindAction("throttleDeccel")
		ContextActionService:UnbindAction("arrowSteerRight")
		ContextActionService:UnbindAction("arrowSteerLeft")
		self.vehicleSeat = nil
	end
end

function VehicleController:OnThrottleAccel(_, p, _)
	if v then
		if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			self.acceleration = 0
		else
			self.acceleration = -1
		end
	else
		self.acceleration = p == Enum.UserInputState.End and 0 or -1
	end

	self.throttle = self.acceleration + self.decceleration
end

function VehicleController:OnThrottleDeccel(_, p, _)
	if v then
		if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			self.decceleration = 0
		else
			self.decceleration = 1
		end
	else
		self.decceleration = p == Enum.UserInputState.End and 0 or 1
	end

	self.throttle = self.acceleration + self.decceleration
end

function VehicleController:OnSteerRight(_, p, _)
	if v then
		if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			self.turningRight = 0
		else
			self.turningRight = 1
		end
	else
		self.turningRight = p == Enum.UserInputState.End and 0 or 1
	end

	self.steer = self.turningRight + self.turningLeft
end

function VehicleController:OnSteerLeft(_, p, _)
	if v then
		if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			self.turningLeft = 0
		else
			self.turningLeft = -1
		end
	else
		self.turningLeft = p == Enum.UserInputState.End and 0 or -1
	end

	self.steer = self.turningRight + self.turningLeft
end

function VehicleController:Update(p, p2, _)
	if not self.vehicleSeat then
		return p, false
	end

	if p2 then
		local v2 = p + Vector3.new(self.steer, 0, self.throttle)
		self.vehicleSeat.ThrottleFloat = -v2.Z
		self.vehicleSeat.SteerFloat = v2.X
		return v2, true
	else
		local vectorToObjectSpace = self.vehicleSeat.Occupant.RootPart.CFrame:VectorToObjectSpace(p)
		self.vehicleSeat.ThrottleFloat = self:ComputeThrottle(vectorToObjectSpace)
		self.vehicleSeat.SteerFloat = self:ComputeSteer(vectorToObjectSpace)
		return createVector(0, 0, 0), true
	end
end

function VehicleController:ComputeThrottle(p)
	if p == createVector(0, 0, 0) then
		return 0
	end

	return -p.Z
end

function VehicleController:ComputeSteer(p2)
	if p2 == createVector(0, 0, 0) then
		return 0
	end

	return -math.atan2(-p2.x, -p2.z) * 57.29577951308232 / self.autoPilot.MaxSteeringAngle
end

function VehicleController:SetupAutoPilot()
	self.autoPilot.MaxSpeed = self.vehicleSeat.MaxSpeed
	self.autoPilot.MaxSteeringAngle = 35
end

return VehicleController