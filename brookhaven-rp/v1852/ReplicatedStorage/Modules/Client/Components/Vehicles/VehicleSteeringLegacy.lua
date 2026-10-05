local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSteeringLegacy"
})

function v.SetupSteering(p)
	local _ = p.vehicleRoot.Chassis.Wheels
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local instance = p.Instance
	local stop = p.Instance:WaitForChild("Stop")
	local vehicleSeat = instance.Seats.VehicleSeat
	local topSpeed = vehicleSeat:WaitForChild("TopSpeed")
	local wheels = instance.Chassis.Wheels
	local attachment = wheels.WheelFL.AttachmentHolder.Attachment
	local attachment2 = wheels.WheelFR.AttachmentHolder.Attachment
	local attachment3 = wheels.WheelBL.AttachmentHolder.Attachment
	local attachment4 = wheels.WheelBR.AttachmentHolder.Attachment
	local cylindrical = wheels.WheelFL.Cylindrical
	local cylindrical2 = wheels.WheelFR.Cylindrical
	local cylindrical3 = wheels.WheelBL.Cylindrical
	local cylindrical4 = wheels.WheelBR.Cylindrical
	local total = 0
	local total2 = 0
	local heartbeatConnection = nil
	local v2 = {
		[-1] = -25,
		[1] = 25,
		[2] = 50,
		[3] = 75,
		[4] = 100,
		[5] = 125,
		[6] = 150,
		[7] = 175
	}
	local v3 = {
		[-1] = 2.9,
		[1] = 2.97,
		[2] = 2.07,
		[3] = 1.43,
		[4] = 1,
		[5] = 0.71,
		[6] = 0.57,
		[7] = 0.48
	}
	local v4 = {
		[-1] = 0.5,
		[1] = 1,
		[2] = 0.9,
		[3] = 0.8,
		[4] = 0.7,
		[5] = 0.6,
		[6] = 0.5,
		[7] = 0.4
	}
	local flag = true
	local v5 = 1
	local v6 = 1

	function CalculatePitch()
		return 1 + vehicleSeat.Velocity.magnitude / 50
	end

	local function Update(p2)
		local v7 = -vehicleSeat.SteerFloat * 35
		local v8 = math.rad(90 - math.abs(v7))
		local magnitude = ((attachment4.WorldPosition + attachment3.WorldPosition) / 2 - (attachment2.WorldPosition + attachment.WorldPosition) / 2).Magnitude
		local magnitude2 = (attachment.WorldPosition - attachment2.WorldPosition).Magnitude
		local v9 = 90 - math.deg((math.atan2(math.tan(v8) * magnitude + magnitude2, magnitude)))
		total += (v7 - total) * math.min(p2 * vehicleSeat.TurnSpeed, 1)

		if v7 > 0 then
			attachment.Orientation = Vector3.new(0, total, -90)
			attachment2.Orientation = Vector3.new(
				0,
				attachment2.Orientation.Y + (v9 - attachment2.Orientation.Y) * math.min(p2 * vehicleSeat.TurnSpeed, 1),
				-90
			)
		else
			attachment.Orientation = Vector3.new(
				0,
				attachment.Orientation.Y + (-v9 - attachment.Orientation.Y) * math.min(p2 * vehicleSeat.TurnSpeed, 1),
				-90
			)
			attachment2.Orientation = Vector3.new(0, total, -90)
		end

		if flag then
			local throttleFloat = vehicleSeat.ThrottleFloat
			total2 += (throttleFloat - total2) * math.min(p2 * vehicleSeat.Turbo.Value * v4[v5], 1)
			local torque = vehicleSeat.Torque
			local angularVelocity = topSpeed.Value * total2

			if vehicleSeat.ThrottleFloat == 0 then
				if cylindrical3.AngularActuatorType == Enum.ActuatorType.Motor then
					cylindrical3.MotorMaxAngularAcceleration = 50
					cylindrical4.MotorMaxAngularAcceleration = 50
					cylindrical.MotorMaxAngularAcceleration = 50
					cylindrical2.MotorMaxAngularAcceleration = 50
				end
			elseif cylindrical3.AngularActuatorType == Enum.ActuatorType.None then
				cylindrical3.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical4.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical2.AngularActuatorType = Enum.ActuatorType.Motor
			end

			cylindrical3.MotorMaxTorque = torque * v3[v5]
			cylindrical4.MotorMaxTorque = torque * v3[v5]
			cylindrical2.MotorMaxTorque = torque * v3[v5]
			cylindrical.MotorMaxTorque = torque * v3[v5]
			cylindrical.AngularVelocity = angularVelocity
			cylindrical2.AngularVelocity = -angularVelocity
			cylindrical4.AngularVelocity = -angularVelocity
			cylindrical3.AngularVelocity = angularVelocity
		end
	end

	local function Gears()
		while true do
			local v7 = instance.Chassis.Platform.Velocity:Dot(instance.Chassis.Platform.CFrame.LookVector) / 1609.344 / 3.571 * 3600
			v6 = v7 / v2[v5] * 8

			if not vehicleSeat.Occupant then
				break
			end

			if v2[v5] < v7 and v4[v5 + 1] and v2[v5 + 1] and v3[v5 + 1] then
				flag = false
				cylindrical3.AngularActuatorType = Enum.ActuatorType.None
				cylindrical4.AngularActuatorType = Enum.ActuatorType.None
				cylindrical.AngularActuatorType = Enum.ActuatorType.None
				cylindrical2.AngularActuatorType = Enum.ActuatorType.None
				wait(0.1)
				v5 += 1
				flag = true
				cylindrical3.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical4.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical2.AngularActuatorType = Enum.ActuatorType.Motor
			end

			if v2[v5 - 1] and v3[v5 - 1] and v4[v5 - 1] and v7 < v2[v5 - 1] - 1 then
				flag = false
				cylindrical3.AngularActuatorType = Enum.ActuatorType.None
				cylindrical4.AngularActuatorType = Enum.ActuatorType.None
				cylindrical.AngularActuatorType = Enum.ActuatorType.None
				cylindrical2.AngularActuatorType = Enum.ActuatorType.None
				wait(0.1)
				v5 -= 1
				flag = true
				cylindrical3.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical4.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical.AngularActuatorType = Enum.ActuatorType.Motor
				cylindrical2.AngularActuatorType = Enum.ActuatorType.Motor
			end

			if v7 < 0 then
				v5 = -1
			elseif v7 > 0 and v5 < 0 then
				v5 = 1
			end

			if v7 > 0 and total2 > 0 or v7 < 0 and total2 < 0 then
				cylindrical3.MotorMaxAngularAcceleration = vehicleSeat.Turbo.Value * v4[v5]
				cylindrical4.MotorMaxAngularAcceleration = vehicleSeat.Turbo.Value * v4[v5]
				cylindrical.MotorMaxAngularAcceleration = vehicleSeat.Turbo.Value * v4[v5]
				cylindrical2.MotorMaxAngularAcceleration = vehicleSeat.Turbo.Value * v4[v5]
			else
				cylindrical3.MotorMaxAngularAcceleration = 100
				cylindrical4.MotorMaxAngularAcceleration = 100
				cylindrical.MotorMaxAngularAcceleration = 100
				cylindrical2.MotorMaxAngularAcceleration = 100
			end

			wait(0.1)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Start()
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(Update)
		Gears()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Stop()
		heartbeatConnection:Disconnect()
		cylindrical3.AngularActuatorType = Enum.ActuatorType.None
		cylindrical4.AngularActuatorType = Enum.ActuatorType.None
		cylindrical.AngularActuatorType = Enum.ActuatorType.None
		cylindrical2.AngularActuatorType = Enum.ActuatorType.None
		v5 = 1
		script:Destroy()
	end

	Start() -- equivalent call inferred; original call site unknown

	if not stop.Value then
		stop.Changed:Connect(function(p2)
			if not p2 then
				return
			end

			Stop() -- equivalent call inferred; original call site unknown
		end)
		return
	end

	Stop() -- equivalent call inferred; original call site unknown
end

function v:Stop()
	self._Janitor:Destroy()
end

return v