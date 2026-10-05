local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleRotatePartOnMove"
})
local VehicleRoot = require(script.Parent.VehicleRoot)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v2 = {
	X = 1,
	Y = 2,
	Z = 3
}

function v:Construct()
	self._Janitor = Janitor.new()
	self._rotationJanitor = Janitor.new()
end

function v:Start()
	self.hasStarted = false
	self.isDriving = false
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"VehicleRoot",
		VehicleRoot
	)

	if not waitForAncestorComponent then
		warn("VehicleRotatePartOnMove:Start() - VehicleRoot not found")
		return
	end

	self.vehicleSeat = nil
	local instance = self.Instance

	if not instance:IsA("BasePart") then
		warn("VehicleRotatePartOnMove:Start() - Instance must be a BasePart")
		return
	end

	if instance:HasTag("VehicleSeat") then
		self.vehicleSeat = instance
	else
		local instance2 = waitForAncestorComponent.Instance

		if not instance2 then
			warn("VehicleRotatePartOnMove:Start() - VehicleModel not found")
			return
		end

		local seats = instance2:WaitForChild("Seats", 5)

		if not seats then
			warn("VehicleRotatePartOnMove:Start() - Seats folder not found")
			return
		end

		local vehicleSeat = seats:WaitForChild("VehicleSeat", 5)

		if vehicleSeat and vehicleSeat:IsA("BasePart") then
			self.vehicleSeat = vehicleSeat
		else
			warn("VehicleRotatePartOnMove:Start() - VehicleSeat not found")
			return
		end
	end

	self._Janitor:Add(self.vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if self.vehicleSeat.Occupant then
			self.isDriving = true

			if self.hasStarted then
				return
			end

			self.hasStarted = true
			local rotationAxis = instance:GetAttribute("RotationAxis") or "Z"
			local axisIndex = v2[rotationAxis]

			if not axisIndex then
				warn("VehicleRotatePartOnMove:Start() - RotationAxis must be X, Y, or Z; got ", rotationAxis)
				return
			end

			local rotationSpeed = math.rad(instance:GetAttribute("RotationSpeed") or 290)
			local rotationAcceleration = math.rad(instance:GetAttribute("RotationAcceleration") or 720)
			local rotationDeceleration = math.rad(instance:GetAttribute("RotationDeceleration") or 110)
			local parent = instance.Parent and instance.Parent:IsA("Model") and instance.Parent or instance:FindFirstAncestorOfClass("Model")

			if not (parent and parent:IsA("Model") and parent.PrimaryPart) then
				warn("VehicleRotatePartOnMove:Start() - Part's parent or ancestor must be a Model with PrimaryPart")
				return
			end

			self._baseAngleOnAxis = ({ instance.Orientation.X, instance.Orientation.Y, instance.Orientation.Z })[axisIndex]
			self._angleRad = 0
			self._angularVelocityRadPerSec = 0
			self._part = instance
			self._vehicleSeat = self.vehicleSeat
			self._axisIndex = axisIndex
			self._model = parent
			self._radPerSec = rotationSpeed
			self._radAccelPerSec2 = rotationAcceleration
			self._radDecelPerSec2 = rotationDeceleration
			self._rotationJanitor:Add(RunService.RenderStepped:Connect(function(dt: number)
				local _vehicleSeat = self._vehicleSeat
				local _part = self._part
				local _model = self._model

				if not (_vehicleSeat and _part and _part.Parent and _model and _model.PrimaryPart) then
					return
				end

				local v4 = math.abs(_vehicleSeat.Throttle) * self._radPerSec
				local _angularVelocityRadPerSec = self._angularVelocityRadPerSec
				local v5 = (_angularVelocityRadPerSec < v4 and self._radAccelPerSec2 or self._radDecelPerSec2) * dt

				if _angularVelocityRadPerSec < v4 then
					self._angularVelocityRadPerSec = math.min(_angularVelocityRadPerSec + v5, v4)
				elseif v4 < _angularVelocityRadPerSec then
					self._angularVelocityRadPerSec = math.max(_angularVelocityRadPerSec - v5, v4)
				end

				self._angleRad += self._angularVelocityRadPerSec * dt
				local orientation, v7, v8 = _model.PrimaryPart.CFrame:ToOrientation()
				local vector = Vector3.new(math.deg(orientation), math.deg(v7), (math.deg(v8)))
				local _angleRad = math.deg(self._angleRad)
				local v9 = self._baseAngleOnAxis + _angleRad
				_part.Orientation = Vector3.new(
					self._axisIndex == 1 and v9 or vector.X,
					self._axisIndex == 2 and v9 or vector.Y,
					self._axisIndex == 3 and v9 or vector.Z
				)
			end))
		else
			self.isDriving = false
			self.hasStarted = false
			self._rotationJanitor:Cleanup()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v