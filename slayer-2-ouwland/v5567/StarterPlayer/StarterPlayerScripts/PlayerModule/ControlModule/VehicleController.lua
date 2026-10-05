local createVector = vector.create
local vehicleContext = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("VehicleContext")
local throttleAction = vehicleContext:WaitForChild("ThrottleAction")
local steerAction = vehicleContext:WaitForChild("SteerAction")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
CommonUtils.get("FlagUtil")
local VehicleController = {}
VehicleController.__index = VehicleController

function VehicleController.new()
	local self = setmetatable({}, VehicleController)
	self.enabled = false
	self.vehicleSeat = nil
	return self
end

function VehicleController:Enable(enabled: boolean, vehicleSeat)
	if enabled == self.enabled and vehicleSeat == self.vehicleSeat then
		return
	end

	self.enabled = enabled

	if enabled then
		if not vehicleSeat then
			return
		end

		self.vehicleSeat = vehicleSeat
		vehicleContext.Enabled = true
	else
		vehicleContext.Enabled = false
		self.vehicleSeat = nil
	end
end

function VehicleController:Update(vector2: Vector3, flag: boolean)
	if not self.vehicleSeat then
		return vector2, false
	end

	if flag then
		local state = throttleAction:GetState()
		local v = vector2 + Vector3.new(steerAction:GetState(), 0, -state)
		self.vehicleSeat.ThrottleFloat = -v.Z
		self.vehicleSeat.SteerFloat = v.X
		return v, true
	else
		local vectorToObjectSpace = self.vehicleSeat.Occupant.RootPart.CFrame:VectorToObjectSpace(vector2)
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

function VehicleController:ComputeSteer(p)
	if p == createVector(0, 0, 0) then
		return 0
	end

	return -math.atan2(-p.x, -p.z) * 57.29577951308232
end

return VehicleController