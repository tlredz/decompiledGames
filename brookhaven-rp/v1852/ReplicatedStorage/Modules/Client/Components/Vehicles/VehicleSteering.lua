local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSteering"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local VehicleBoostConstants = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleBoostConstants)
local VehicleRoot = require(script.Parent.VehicleRoot)

-- equivalent calls inferred from this helper; original call sites unknown
local function isConsoleControlsEnabled()
	local v2, v3 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()
	return not v2 or v3
end

local function getGamepadTriggerAmount(vector: Vector3)
	local Z = math.abs(vector.Z)

	if Z == 0 then
		Z = math.abs(vector.X)
	end

	if Z == 0 then
		Z = math.abs(vector.Y)
	end

	return (math.clamp(Z, 0, 1))
end

local function storeOriginalPhysicalProperties(part)
	if not (part and part:IsA("BasePart")) then
		return nil
	end

	local customPhysicalProperties = part.CustomPhysicalProperties

	if customPhysicalProperties then
		return {
			Density = customPhysicalProperties.Density,
			Friction = customPhysicalProperties.Friction,
			Elasticity = customPhysicalProperties.Elasticity,
			FrictionWeight = customPhysicalProperties.FrictionWeight,
			ElasticityWeight = customPhysicalProperties.ElasticityWeight
		}
	end

	return {
		Density = 0.7,
		Friction = 0.3,
		Elasticity = 0.5,
		FrictionWeight = 1,
		ElasticityWeight = 1
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateMassWheeliePhysics(part, _originalMassWheelieProps, value: boolean)
	if part and part:IsA("BasePart") and _originalMassWheelieProps then
		local v2 = value and 0.01 or _originalMassWheelieProps.Density
		part.CustomPhysicalProperties = PhysicalProperties.new(
			v2,
			_originalMassWheelieProps.Friction,
			_originalMassWheelieProps.Elasticity,
			_originalMassWheelieProps.FrictionWeight,
			_originalMassWheelieProps.ElasticityWeight
		)
	end
end

local function setupWheelieSystem(object, chassis, children)
	local wheelieValue = chassis:FindFirstChild("Wheelie")

	if not wheelieValue then
		wheelieValue = Instance.new("BoolValue")
		wheelieValue.Name = "Wheelie"
		wheelieValue.Value = false
		wheelieValue.Parent = chassis
	end

	local massWheelie = chassis:FindFirstChild("MassWheelie")
	local wheelieWheels = {}

	for _, item in children do
		if item:HasTag("WheelWheelie") then
			table.insert(wheelieWheels, item)
		end
	end

	object._wheelieValue = wheelieValue
	object._wheelieWheels = wheelieWheels
	object._massWheelie = massWheelie
	object._originalMassWheelieProps = storeOriginalPhysicalProperties(massWheelie)

	if #wheelieWheels > 0 then
		for _, v4 in wheelieWheels do
			local physicalWheel = v4:FindFirstChild("PhysicalWheel")

			if physicalWheel then
				physicalWheel.CanCollide = wheelieValue.Value
			end
		end

		updateMassWheeliePhysics(massWheelie, object._originalMassWheelieProps, wheelieValue.Value) -- equivalent call inferred; original call site unknown
		object._Janitor:Add(wheelieValue.Changed:Connect(function(canCollide)
			for _, v4 in wheelieWheels do
				local physicalWheel = v4:FindFirstChild("PhysicalWheel")

				if physicalWheel then
					physicalWheel.CanCollide = canCollide
				end
			end

			local part = massWheelie
			local _originalMassWheelieProps2 = object._originalMassWheelieProps

			if part and part:IsA("BasePart") then
				if not _originalMassWheelieProps2 then
					return
				end

				local v4 = canCollide and 0.01 or _originalMassWheelieProps2.Density
				part.CustomPhysicalProperties = PhysicalProperties.new(
					v4,
					_originalMassWheelieProps2.Friction,
					_originalMassWheelieProps2.Elasticity,
					_originalMassWheelieProps2.FrictionWeight,
					_originalMassWheelieProps2.ElasticityWeight
				)
			end
		end))
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:_refreshConsoleInputState()
	self._consoleThumbstick = Vector2.zero
	self._consoleR2 = 0
	self._consoleL2 = 0
	local success, result = pcall(function()
		return UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
	end)

	if not (success and result) then
		return
	end

	for _, v2 in result do
		if v2.KeyCode == Enum.KeyCode.Thumbstick1 then
			self._consoleThumbstick = Vector2.new(v2.Position.X, v2.Position.Y)
		elseif v2.KeyCode == Enum.KeyCode.ButtonR2 then
			local position = v2.Position
			local Z = math.abs(position.Z)

			if Z == 0 then
				Z = math.abs(position.X)
			end

			if Z == 0 then
				Z = math.abs(position.Y)
			end

			self._consoleR2 = math.clamp(Z, 0, 1)
		elseif v2.KeyCode == Enum.KeyCode.ButtonL2 then
			local position = v2.Position
			local Z = math.abs(position.Z)

			if Z == 0 then
				Z = math.abs(position.X)
			end

			if Z == 0 then
				Z = math.abs(position.Y)
			end

			self._consoleL2 = math.clamp(Z, 0, 1)
		end
	end
end

function v:Boost()
	if self.lastBoostTime and os.time() - self.lastBoostTime < VehicleBoostConstants.COOLDOWN_SECONDS then
		return
	end

	local primaryPart = self.Instance.PrimaryPart

	if not primaryPart then
		return
	end

	local assemblyLinearVelocity = primaryPart.AssemblyLinearVelocity
	local IMPULSE_VELOCITY = VehicleBoostConstants.IMPULSE_VELOCITY

	if assemblyLinearVelocity.Magnitude > VehicleBoostConstants.MAX_VELOCITY_FOR_BOOST then
		IMPULSE_VELOCITY = VehicleBoostConstants.IMPULSE_VELOCITY_WHILE_MOVING
	end

	self.lastBoostTime = os.time()
	primaryPart.AssemblyLinearVelocity = assemblyLinearVelocity + primaryPart.CFrame.LookVector * IMPULSE_VELOCITY
end

function v:Start()
	local instance = self.Instance
	local vehicleSeat = instance.Seats.VehicleSeat
	local maxSpeed = vehicleSeat:WaitForChild("MaxSpeed")
	self.boostMultiplier = 1
	self._vehicleRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "VehicleRoot", VehicleRoot)
	self._Janitor:Add(self._vehicleRoot.OnBoostChanged:Connect(function(flag: boolean)
		if flag then
			self:Boost()
		end

		self.boostMultiplier = self._vehicleRoot:GetBoostMultiplier()
	end))
	local chassis = instance:FindFirstChild("Chassis")

	if not chassis then
		return
	end

	local wheels = chassis:FindFirstChild("Wheels")

	if not wheels then
		return
	end

	local children = wheels:GetChildren()
	self.wheels = {}

	for _, v2 in children do
		if v2:HasTag("Wheel") or v2:HasTag("WheelSteering") then
			table.insert(self.wheels, v2)
		end
	end

	setupWheelieSystem(self, chassis, children)
	local total = 0
	local total2 = 0
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
	self.gear = 1
	self.RPM = 1
	self.engineSound = instance.Body.SoundEmmiter:FindFirstChild("Engine")
	self.engineStartSound = instance.Body.SoundEmmiter:FindFirstChild("EngineStart")
	local torqueMultiplier = self.Instance.Config:FindFirstChild("TorqueMultiplier")
	self.torqueMultiplier = torqueMultiplier and torqueMultiplier.Value or 1
	self._consoleControlsEnabled = isConsoleControlsEnabled()
	self._consoleThumbstick = Vector2.zero
	self._consoleR2 = 0
	self._consoleL2 = 0

	if self._consoleControlsEnabled and UserInputService.GamepadEnabled then
		self:_refreshConsoleInputState()
		self._Janitor:Add(UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return
			end

			if input.KeyCode == Enum.KeyCode.Thumbstick1 then
				self._consoleThumbstick = Vector2.new(input.Position.X, input.Position.Y)
			elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
				local v5 = self
				local position = input.Position
				local Z = math.abs(position.Z)

				if Z == 0 then
					Z = math.abs(position.X)
				end

				if Z == 0 then
					Z = math.abs(position.Y)
				end

				v5._consoleR2 = math.clamp(Z, 0, 1)
			elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
				local v5 = self
				local position = input.Position
				local Z = math.abs(position.Z)

				if Z == 0 then
					Z = math.abs(position.X)
				end

				if Z == 0 then
					Z = math.abs(position.Y)
				end

				v5._consoleL2 = math.clamp(Z, 0, 1)
			end
		end))
		self._Janitor:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return
			end

			if input.KeyCode == Enum.KeyCode.Thumbstick1 then
				self._consoleThumbstick = Vector2.zero
			elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
				self._consoleR2 = 0
			elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
				self._consoleL2 = 0
			end
		end))
		self._Janitor:Add(UserInputService.GamepadDisconnected:Connect(function(p)
			if p ~= Enum.UserInputType.Gamepad1 then
				return
			end

			self._consoleThumbstick = Vector2.zero
			self._consoleR2 = 0
			self._consoleL2 = 0
		end))
	end

	self.playOnlyWhenMoving = false

	if self.engineSound and self.engineSound:GetAttribute("PlayOnlyWhenMoving") then
		self.playOnlyWhenMoving = true
	end

	if self.engineSound and not self.playOnlyWhenMoving then
		if self.engineStartSound then
			if self.engineStartSound:GetAttribute("TimeToStart") == nil then
				error("Engine start sound requires TimeToStart attribute: " .. self.engineStartSound:GetFullName())
			end

			ContentProvider:PreloadAsync({ self.engineSound })
			self.engineStartSound:Play()
			self._Janitor:Add(task.spawn(function()
				task.wait(self.engineStartSound:GetAttribute("TimeToStart"))
				self.engineSound:Play()
			end))
		else
			self.engineSound:Play()
		end
	end

	local enginePitchConstant = self.Instance.Config:GetAttribute("EnginePitchConstant") or 1
	local enginePitchDivisor = self.Instance.Config:GetAttribute("EnginePitchDivisor") or 50

	local function calculatePitch()
		return (math.min(9, enginePitchConstant + vehicleSeat.Velocity.magnitude / enginePitchDivisor))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isVehicleMoving()
		return vehicleSeat.Velocity.magnitude > 5
	end

	local function update(p)
		if not (vehicleSeat.Occupant and Players.LocalPlayer.Character and Players.LocalPlayer.Character:IsAncestorOf(vehicleSeat.Occupant)) then
			return
		end

		if self.engineSound then
			if self.playOnlyWhenMoving then
				local vehicleMoving = isVehicleMoving() -- equivalent call inferred; original call site unknown

				if vehicleMoving and not self.engineSound.IsPlaying then
					self.engineSound:Play()
				elseif not vehicleMoving and self.engineSound.IsPlaying then
					self.engineSound:Stop()
				end

				if self.engineSound.IsPlaying then
					self.engineSound.Pitch = math.min(
						9,
						enginePitchConstant + vehicleSeat.Velocity.magnitude / enginePitchDivisor
					)
				end
			else
				self.engineSound.Pitch = math.min(
					9,
					enginePitchConstant + vehicleSeat.Velocity.magnitude / enginePitchDivisor
				)
			end
		end

		local steerFloat = self.Instance:GetAttribute("SteerFloat") or vehicleSeat.SteerFloat
		local throttleFloat = self.Instance:GetAttribute("ThrottleFloat") or vehicleSeat.ThrottleFloat

		if self._consoleControlsEnabled and Platform.IsConsole() and not GamepadService.GamepadCursorEnabled then
			local v5 = math.clamp(self._consoleThumbstick.Y, 0, 1)
			local v6 = math.clamp(-self._consoleThumbstick.Y, 0, 1)
			local _consoleR2 = self._consoleR2
			local _consoleL2 = self._consoleL2

			if _consoleR2 > 0.05 or _consoleL2 > 0.05 then
				throttleFloat = math.clamp(_consoleR2 - _consoleL2, -1, 1)
			else
				throttleFloat = math.clamp(v5 - v6, -1, 1)
			end

			steerFloat = math.clamp(self._consoleThumbstick.X, -1, 1)
		end

		local v5 = self.boostMultiplier > 1 and 1 or throttleFloat
		local v6 = math.abs(steerFloat) < 0.05 and 0 or steerFloat
		local v7 = not self.Instance:GetAttribute("AdapativeSpeed") and 35 or (1 - math.clamp(
			(math.abs((chassis.Platform.AssemblyLinearVelocity:Dot(chassis.Platform.CFrame.LookVector))) - 15) / 85,
			0,
			1
		) * 0.78) * 35
		local v8 = -v6 * v7
		local wheels2 = {}
		local wheels3 = {}

		for i = 1, #self.wheels do
			local wheel = self.wheels[i]

			if wheel:HasTag("WheelSteering") then
				table.insert(wheels2, wheel)
			elseif wheel:HasTag("Wheel") then
				table.insert(wheels3, wheel)
			end
		end

		total += (v8 - total) * math.min(p * vehicleSeat.TurnSpeed, 1)
		local v9 = math.abs(v5) < 0.05 and 0 or v5

		for i = 1, #wheels2 do
			local v10 = wheels2[i]

			if not v10:FindFirstChild("AttachmentHolder") then
				return
			end

			local attachment = v10.AttachmentHolder:FindFirstChild("Attachment")

			if not attachment then
				return
			end

			local cylindrical = v10:FindFirstChild("Cylindrical")

			if not cylindrical then
				return
			end

			local v11 = v10:GetAttribute("Invert") and -total or total

			if self.Instance:GetAttribute("UseSteeringDecay") then
				v11 *= 1 - math.min(chassis.Platform.AssemblyLinearVelocity.Magnitude / 100, 1) * 0.5
			end

			attachment.Orientation = Vector3.new(0, v11, -90)

			if v10:HasTag("WheelSki") or not flag then
				continue
			end

			total2 += (v9 - total2) * math.min(p * vehicleSeat.Turbo.Value * self.boostMultiplier * v4[self.gear], 1)
			local torque = vehicleSeat.Torque
			local angularVelocity = maxSpeed.Value * total2 * self.boostMultiplier

			if v9 == 0 then
				if cylindrical.AngularActuatorType == Enum.ActuatorType.Motor then
					cylindrical.MotorMaxAngularAcceleration = 50
				end
			elseif cylindrical.AngularActuatorType == Enum.ActuatorType.None then
				cylindrical.AngularActuatorType = Enum.ActuatorType.Motor
			end

			cylindrical.MotorMaxTorque = torque * v3[self.gear] * self.torqueMultiplier
			cylindrical.AngularVelocity = angularVelocity
		end

		for i = 1, #wheels3 do
			local cylindrical = wheels3[i].Cylindrical

			if not flag then
				continue
			end

			total2 += (v9 - total2) * math.min(p * vehicleSeat.Turbo.Value * v4[self.gear], 1)
			local torque = vehicleSeat.Torque
			local angularVelocity = maxSpeed.Value * total2 * self.boostMultiplier

			if v9 == 0 then
				if cylindrical.AngularActuatorType == Enum.ActuatorType.Motor then
					cylindrical.MotorMaxAngularAcceleration = 50
				end
			elseif cylindrical.AngularActuatorType == Enum.ActuatorType.None then
				cylindrical.AngularActuatorType = Enum.ActuatorType.Motor
			end

			cylindrical.MotorMaxTorque = torque * v3[self.gear] * self.torqueMultiplier
			cylindrical.AngularVelocity = angularVelocity
		end
	end

	local function handleGears()
		while instance do
			local chassis2 = instance:FindFirstChild("Chassis")

			if not chassis2 then
				break
			end

			local v5 = chassis2.Platform.Velocity:Dot(chassis2.Platform.CFrame.LookVector) / 1609.344 / 3.571 * 3600
			self.RPM = v5 / v2[self.gear] * 8

			if not (vehicleSeat and vehicleSeat.Occupant) then
				break
			end

			if v2[self.gear] < v5 and v4[self.gear + 1] and v2[self.gear + 1] and v3[self.gear + 1] then
				flag = false

				for i = 1, #self.wheels do
					if not self.wheels[i]:HasTag("WheelSki") then
						self.wheels[i].Cylindrical.AngularActuatorType = Enum.ActuatorType.None
					end
				end

				task.wait(0.1)
				self.gear += 1
				flag = true

				for i = 1, #self.wheels do
					if not self.wheels[i]:HasTag("WheelSki") then
						self.wheels[i].Cylindrical.AngularActuatorType = Enum.ActuatorType.Motor
					end
				end
			end

			if v2[self.gear - 1] and v3[self.gear - 1] and v4[self.gear - 1] and v5 < v2[self.gear - 1] - 1 then
				flag = false

				for i = 1, #self.wheels do
					if not self.wheels[i]:HasTag("WheelSki") then
						self.wheels[i].Cylindrical.AngularActuatorType = Enum.ActuatorType.None
					end
				end

				task.wait(0.1)
				self.gear -= 1
				flag = true

				for i = 1, #self.wheels do
					if not self.wheels[i]:HasTag("WheelSki") then
						self.wheels[i].Cylindrical.AngularActuatorType = Enum.ActuatorType.Motor
					end
				end
			end

			if v5 < 0 then
				self.gear = -1
			elseif v5 > 0 and self.gear < 0 then
				self.gear = 1
			end

			if v5 > 0 and total2 > 0 or v5 < 0 and total2 < 0 then
				for i = 1, #self.wheels do
					if not self.wheels[i]:HasTag("WheelSki") then
						self.wheels[i].Cylindrical.MotorMaxAngularAcceleration = vehicleSeat.Turbo.Value * self.boostMultiplier * v4[self.gear]
					end
				end
			else
				for i = 1, #self.wheels do
					if not self.wheels[i]:HasTag("WheelSki") then
						self.wheels[i].Cylindrical.MotorMaxAngularAcceleration = 100
					end
				end
			end

			wait(0.1)
		end
	end

	self._Janitor:Add(RunService.Heartbeat:Connect(update))
	handleGears()
end

function v:Stop()
	self._consoleControlsEnabled = false
	self._consoleThumbstick = nil
	self._consoleR2 = nil
	self._consoleL2 = nil

	if self.engineSound then
		self.engineSound:Stop()
	end

	if self.engineStartSound then
		self.engineStartSound:Stop()
	end

	for i = 1, #self.wheels do
		if not self.wheels[i] or self.wheels[i]:HasTag("WheelSki") or not self.wheels[i].Cylindrical then
			continue
		end

		self.wheels[i].Cylindrical.AngularActuatorType = Enum.ActuatorType.None
	end

	self.gear = 1

	if self._wheelieWheels then
		for _, _wheelieWheel in self._wheelieWheels do
			local physicalWheel = _wheelieWheel:FindFirstChild("PhysicalWheel")

			if physicalWheel then
				physicalWheel.CanCollide = false
			end
		end
	end

	if self._massWheelie and self._originalMassWheelieProps then
		local _massWheelie = self._massWheelie
		local _originalMassWheelieProps = self._originalMassWheelieProps

		if _massWheelie and _massWheelie:IsA("BasePart") and _originalMassWheelieProps then
			local density = _originalMassWheelieProps.Density
			_massWheelie.CustomPhysicalProperties = PhysicalProperties.new(
				density,
				_originalMassWheelieProps.Friction,
				_originalMassWheelieProps.Elasticity,
				_originalMassWheelieProps.FrictionWeight,
				_originalMassWheelieProps.ElasticityWeight
			)
		end
	end

	if self._wheelieValue then
		self._wheelieValue.Value = false
	end

	self._Janitor:Destroy()
end

return v