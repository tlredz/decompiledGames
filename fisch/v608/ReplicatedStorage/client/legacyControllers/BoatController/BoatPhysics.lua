local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Signal"))
require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("vessels"))
local module = require("../SettingsController")
local module2 = require("../HudController")
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local inputs = ReplicatedStorage:WaitForChild("client"):WaitForChild("inputs")
local flyingBoat = inputs:WaitForChild("FlyingBoat")
local jetskiBoost = inputs:WaitForChild("JetskiBoost")
module2:GetBackpackGui():WaitForChild("hotbar"):WaitForChild("Folder"):WaitForChild("Frame")
local tagged = nil
local tagged2 = nil
local jetskiRacingOverlay = module2:GetPlayerGui():WaitForChild("jetskiRacingOverlay")
local overlay = jetskiRacingOverlay:WaitForChild("overlay")
require("./Boat")
local BoatPhysics = {
	trove = Trove.new()
}
BoatPhysics.controlTrove = BoatPhysics.trove:Extend()
BoatPhysics.controlsEnabled = false
BoatPhysics.currentSpeed = 0
BoatPhysics._springVelocity = 0
BoatPhysics.currentVerticalSpeed = 0
BoatPhysics._springVerticalVelocity = 0
BoatPhysics._springFovVelocity = 0
BoatPhysics.targetVerticalSpeed = 0
BoatPhysics.currentBoost = 0
BoatPhysics.pboostCharge = 0
BoatPhysics.pboostActive = false
BoatPhysics.PlayerBoostStarted = Signal.new()
BoatPhysics.PlayerBoostEnded = Signal.new()

function BoatPhysics:Tick(p: number)
	local DISTANCE_EPSILON = 0.0001

	if not self.currentBoat or not self.currentBoatData or not self.currentBoat.VehicleSeat or Players.LocalPlayer.GameplayPaused then
		return
	end

	debug.profilebegin("BoatPhysics::Tick")
	local throttleFloat = 0
	local steerFloat = 0
	local touchingSurface

	if self.currentBoat.BuoyancySensor then
		touchingSurface = self.currentBoat.BuoyancySensor.TouchingSurface or FischUtils.GetZoneMeta(self.currentBoat.Base.Position).FakeWater
	else
		touchingSurface = false
	end

	local accelerateOnly = self.currentBoat.Instance:GetAttribute("AccelerateOnly") == true
	local v2 = self.currentBoat.Instance:GetAttribute("NoMometumLoss") == true or self.currentBoatData.NoMomentumLossOnImpact == true

	if self.controlsEnabled and (not self.currentBoat.Instance:GetAttribute("BlockControls") or accelerateOnly) then
		if module:GetSettingValue("steeringMode") == "simple" then
			local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			throttleFloat = not humanoid and 0 or (humanoid.MoveDirection * createVector(1, 0, 1)).Magnitude or 0
			self.currentBoat.VehicleSeat.ThrottleFloat = throttleFloat

			if workspace.CurrentCamera.CameraSubject == self.currentBoat.VehicleSeat then
				workspace.CurrentCamera.CameraSubject = humanoid
			end

			local v3 = humanoid.MoveDirection * createVector(1, 0, 1)
			local simpleSteer = self.currentBoat.SimpleSteer
			simpleSteer.Enabled = v3.Magnitude > DISTANCE_EPSILON and not accelerateOnly
			local steer = self.currentBoat.Steer
			steer.Enabled = v3.Magnitude <= DISTANCE_EPSILON and not accelerateOnly

			if v3.Magnitude > DISTANCE_EPSILON then
				local cframe = CFrame.lookAlong(createVector(0, 0, 0), v3)

				if self.currentBoat.Base.CFrame.LookVector:Dot(cframe.LookVector) <= -0.75 then
					throttleFloat *= -1
					v3 *= -1
				end

				self.currentBoat.SimpleSteer.CFrame = CFrame.lookAlong(createVector(0, 0, 0), v3)
				self.currentBoat.SimpleSteer.MaxAngularVelocity = self.currentBoatData.TurningSpeed * 1.5 * (1 + self.currentBoost / self.currentBoatData.MaxSpeed)
			end
		else
			throttleFloat = math.clamp(self.currentBoat.VehicleSeat.ThrottleFloat, -1, 1)
			self.currentBoat.Steer.AngularVelocity = accelerateOnly and createVector(0, 0, 0) or Vector3.new(
				0,
				self.currentBoat.VehicleSeat.SteerFloat * -self.currentBoatData.TurningSpeed * 1.5 * module:GetSettingValue("steeringSensitivity") * (1 + self.currentBoost / self.currentBoatData.MaxSpeed),
				0
			)
			steerFloat = self.currentBoat.VehicleSeat.SteerFloat
			self.currentBoat.SimpleSteer.Enabled = false
			self.currentBoat.Steer.Enabled = true
		end
	else
		self.currentBoat.Steer.AngularVelocity = createVector(0, 0, 0)
		self.currentBoat.Steer.Enabled = true
		self.currentBoat.SimpleSteer.Enabled = false
	end

	local v3 = self.currentBoat.BuoyancySensor and not (self.currentBoat.BuoyancySensor.TouchingSurface or touchingSurface) and 0 or throttleFloat
	local v4 = v3 * self.currentBoatData.MaxSpeed
	local v5

	if math.isfinite(self.currentBoatData.MaxSpeed) then
		v5 = not math.isfinite(v4) and 0 or v4
	else
		v5 = v3 * 999999999999999
	end

	local accel = self.currentBoatData.Accel

	if math.abs(v3) > 0.01 and math.abs(self.currentSpeed) > 0.1 and math.sign(v3) ~= math.sign(self.currentSpeed) then
		accel *= self.currentBoatData.StopEfficiency or 1
		v5 = 0
	elseif v3 < 0 then
		accel *= self.currentBoatData.BackwardsEfficiency
	end

	if math.abs(self.currentSpeed) > 25 and (self.currentBoat.Base.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude < 5 and not v2 then
		self.currentSpeed = 0
	end

	if math.abs(self.currentVerticalSpeed) > 25 and math.abs(self.currentBoat.Base.AssemblyLinearVelocity.Y) < 5 and not v2 then
		self.currentVerticalSpeed = 0
	end

	local smoothDamp, springVelocity = TweenService:SmoothDamp(
		self.currentSpeed,
		v5,
		self._springVelocity,
		0.1,
		accel * 100,
		p
	)
	self.currentSpeed = smoothDamp
	self._springVelocity = springVelocity
	self.currentTotalSpeed = self.currentSpeed + self.currentBoost

	if self.currentBoatData.BoostEnabled then
		if self.pboostActive and self.currentBoatData.BoostMaxSpeed and self.currentBoatData.BoostMaxTime then
			local v7 = self.pboostCharge * self.currentBoatData.BoostMaxSpeed
			self.currentTotalSpeed += v7
			local v8 = 1 + v7 / math.max(self.currentBoatData.MaxSpeed, self.currentTotalSpeed)
			self.currentBoat.SimpleSteer.MaxAngularVelocity *= v8
			self.currentBoat.Steer.AngularVelocity *= v8
			self.pboostCharge = math.clamp(self.pboostCharge - p / self.currentBoatData.BoostMaxTime, 0, 1)

			if self.pboostCharge <= 0 then
				self.pboostActive = false
				self.PlayerBoostEnded:Fire()
			end
		elseif not self.pboostActive and self.currentBoatData.BoostChargeTime and self.controlsEnabled and not self.currentBoat.Instance:GetAttribute("BlockControls") then
			self.pboostCharge = math.clamp(self.pboostCharge + p / self.currentBoatData.BoostChargeTime, 0, 1)
		end

		if self.controlsEnabled then
			for _, v7 in tagged2 do
				v7.bar.Size = UDim2.fromScale(self.pboostCharge, 1)
				v7.bar.glow1.ImageTransparency = 1 - self.pboostCharge
				v7.tip.Visible = self.pboostActive or self.pboostCharge > 0.25
			end
		end
	end

	self.currentBoat.Motor.LineVelocity = accelerateOnly and 0 or self.currentTotalSpeed
	local v7 = self.currentBoat.Base.AssemblyMass * 1000
	self.currentBoat.MoveResist.MaxAxesForce = Vector3.new(
		v7 * math.max(0.5, math.max(self.currentSpeed, 1) / math.max(self.currentTotalSpeed, 1)),
		0,
		0
	)
	local v8

	if self.currentBoatData.StupidPhysics then
		v8 = v7 * 1000000
	else
		v8 = self.currentBoat.BuoyancySensor and not (self.currentBoat.BuoyancySensor.TouchingSurface or touchingSurface) and 0 or v7
	end

	self.currentBoat.Motor.MaxForce = v8 * 5
	self.currentBoat.Rot.MaxTorque = Vector3.new(v8 * 10, 0, v8 * 10)
	self.currentBoat.SimpleSteer.MaxTorque = v8 * 100
	self.currentBoat.Steer.MaxTorque = v8 * 1000
	self.currentBoat.BaseCenter.WorldPosition = self.currentBoat.Base.AssemblyCenterOfMass
	local v9 = math.sin(tick() / self.currentBoatData.BobbingSpeed) * self.currentBoatData.Bobbing
	local v10 = not math.isfinite(v9) and 0 or v9

	if self.currentBoatData.SteerTilt then
		v10 += -steerFloat * (self.currentTotalSpeed / 100) * self.currentBoatData.SteerTilt
	end

	local _, v11 = self.currentBoat.Base.CFrame:ToOrientation()
	local cframe = CFrame.fromOrientation(0, v11, 0)
	self.currentBoat.Rot.CFrame = cframe:ToWorldSpace(CFrame.fromOrientation(
		0,
		0,
		(math.rad((math.clamp(v10, -70, 70))))
	))

	if self.currentBoat.SimpleSteer.Enabled then
		self.currentBoat.SimpleSteer.CFrame *= CFrame.fromOrientation(0, 0, (math.rad((math.clamp(v10, -70, 70)))))
	end

	if self.currentBoatData.FlyingBoat or self.currentBoatData.IsSubmarine and self.currentBoat.BuoyancySensor then
		local flyingBoat2 = self.currentBoatData.FlyingBoat or self.currentBoat.BuoyancySensor.TouchingSurface or touchingSurface
		self.currentBoat.FlightMotor.Enabled = flyingBoat2
		self.currentBoat.FlightMotor.MaxForce = v8 * workspace.Gravity * 10

		if flyingBoat2 then
			self.currentBoat.MoveResist.MaxAxesForce = Vector3.new(v8, 0, 0) * workspace.Gravity
			self.currentBoat.Motor.MaxForce *= workspace.Gravity * 5
			local accel2 = self.currentBoatData.Accel

			if math.abs(self.targetVerticalSpeed) > 0.01 and math.abs(self.currentVerticalSpeed) > 0.1 and math.sign(self.targetVerticalSpeed) ~= math.sign(self.currentVerticalSpeed) then
				accel2 *= self.currentBoatData.StopEfficiency or 1
			end

			local smoothDamp2, springVerticalVelocity = TweenService:SmoothDamp(
				self.currentVerticalSpeed,
				self.targetVerticalSpeed,
				self._springVerticalVelocity,
				0.1,
				accel2 * 100,
				p
			)
			self.currentVerticalSpeed = smoothDamp2
			self._springVerticalVelocity = springVerticalVelocity
			self.currentBoat.FlightMotor.LineVelocity = self.currentVerticalSpeed
		else
			self.currentBoat.FlightMotor.LineVelocity = 0
			self.currentVerticalSpeed = 0
		end
	end

	if self.controlsEnabled then
		for _, v12 in tagged do
			v12.Text = string.format("Speed: %.1f S/ps", self.currentTotalSpeed)
			v12.bar.Size = UDim2.fromScale(
				math.clamp(math.abs(self.currentTotalSpeed) / self.currentBoatData.MaxSpeed, 0, 1),
				0.2
			)
		end

		if self.currentBoatData.BoostEnabled then
			local v12 = 70

			if self.pboostActive then
				v12 = 70 + self.pboostCharge * 40
				overlay.ImageTransparency = 1 - self.pboostCharge
			else
				overlay.ImageTransparency = 1
			end

			local currentCamera = workspace.CurrentCamera
			local smoothDamp2, springFovVelocity = TweenService:SmoothDamp(
				workspace.CurrentCamera.FieldOfView,
				v12,
				self._springFovVelocity,
				0.25,
				nil,
				p
			)
			currentCamera.FieldOfView = smoothDamp2
			self._springFovVelocity = springFovVelocity
		end
	end

	debug.profileend()
end

function BoatPhysics:DisableControls()
	self.controlsEnabled = false
	self.controlTrove:Clean()
	self.targetVerticalSpeed = 0
	flyingBoat.Enabled = false
	jetskiBoost.Enabled = false

	for _, v in tagged do
		v.Visible = false
	end

	for _, v in tagged2 do
		v.Visible = false
	end

	workspace.CurrentCamera.FieldOfView = 70
	jetskiRacingOverlay.Enabled = false
end

function BoatPhysics:EnableControls()
	if not self.currentBoatData then
		return
	end

	self.controlsEnabled = true
	self.controlTrove:Clean()

	for _, v in tagged do
		v.Visible = true
	end

	flyingBoat.Enabled = self.currentBoatData.FlyingBoat or self.currentBoatData.IsSubmarine or false
	jetskiBoost.Enabled = self.currentBoatData.BoostEnabled or false

	for _, v in tagged2 do
		v.Visible = self.currentBoatData.BoostEnabled or false
	end

	jetskiRacingOverlay.Enabled = self.currentBoatData.BoostEnabled or false
	self:_UpdateBoostInputText()
end

function BoatPhysics:CheckControlState()
	if not (self.currentBoat and self.currentBoat.VehicleSeat) then
		return
	end

	if self.currentBoat.VehicleSeat.Occupant and Players.LocalPlayer.Character and self.currentBoat.VehicleSeat.Occupant.Parent == Players.LocalPlayer.Character then
		self:EnableControls()
	else
		self:DisableControls()
	end
end

function BoatPhysics:UpdateVerticalTarget()
	if not (self.controlsEnabled and self.currentBoatData) then
		return
	end

	local v = 0

	if flyingBoat.BoatAscend:GetState() then
		v += 1
	end

	if flyingBoat.BoatDescend:GetState() then
		v -= 1
	end

	self.targetVerticalSpeed = v * (self.currentBoatData.VerticalMaxSpeed or self.currentBoatData.SubmarineVerticalSpeed or 50)
end

function BoatPhysics:Cleanup(p)
	if p and p ~= self.currentBoat then
		return
	end

	self:DisableControls()
	self.currentBoat = nil
	self.currentBoatData = nil
	self.currentSpeed = 0
	self.currentVerticalSpeed = 0
	self.currentBoost = 0
	self.pboostCharge = 0
	self.pboostActive = false
end

function BoatPhysics:Init(currentBoat)
	self.trove:Clean()
	self.trove:Add(self.controlTrove)
	self.currentBoat = currentBoat
	self.currentBoatData = currentBoat.BoatData
	self.trove:Add(RunService.PreSimulation:Connect(function(dt: number)
		self:Tick(dt)
	end))
	self.trove:Add(assert(currentBoat.VehicleSeat):GetPropertyChangedSignal("Occupant"):Connect(function()
		self:CheckControlState()
	end))
	self:CheckControlState()
end

function BoatPhysics:Boost(p2: number, p3: number, duration: number?)
	self.currentBoost += p2
	local v = p2
	BoatPhysics.trove:Add(task.spawn(function()
		if duration then
			task.wait(duration)
		end

		repeat
			local v2 = RunService.PostSimulation:Wait()

			if not Players.LocalPlayer.GameplayPaused then
				local v3 = math.min(p2 * (v2 / p3), v)
				v -= v3
				self.currentBoost = math.max(self.currentBoost - v3, 0)
			end
		until v <= 0 or self.currentBoost <= 0
	end))
end

local v = {
	Touch = "TAP HERE",
	Xbox = "B",
	PS = "CIRCLE",
	KeyboardAndMouse = "Q"
}

function BoatPhysics:_UpdateBoostInputText()
	if self.pboostActive then
		for _, v2 in tagged2 do
			v2.tip.Text = "BOOSTING"
		end
	else
		local v2

		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			v2 = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonX) == "ButtonSquare" and "CIRCLE" or "B"
		else
			v2 = v[UserInputService.PreferredInput.Name] or "CLICK HERE"
		end

		for _, v3 in tagged2 do
			v3.tip.Text = `{v2} TO BOOST`
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateUIRefs()
	tagged = CollectionService:GetTagged("BoatSpeedUI")
	tagged2 = CollectionService:GetTagged("BoatBoostUI")
end

function BoatPhysics:Start()
	updateUIRefs() -- equivalent call inferred; original call site unknown
	flyingBoat.BoatAscend.StateChanged:Connect(function(_)
		self:UpdateVerticalTarget()
	end)
	flyingBoat.BoatDescend.StateChanged:Connect(function(_)
		self:UpdateVerticalTarget()
	end)
	jetskiBoost.TriggerBoost.Pressed:Connect(function()
		if self.currentBoatData and self.currentBoatData.BoostEnabled and self.controlsEnabled and not self.pboostActive then
			self.pboostActive = true
			self.PlayerBoostStarted:Fire(self.pboostCharge)
		end
	end)
	self.PlayerBoostStarted:Connect(function()
		self:_UpdateBoostInputText()
	end)
	self.PlayerBoostEnded:Connect(function()
		self:_UpdateBoostInputText()
	end)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		self:_UpdateBoostInputText()
	end)
	CollectionService:GetInstanceAddedSignal("BoatSpeedUI"):Connect(updateUIRefs)
	CollectionService:GetInstanceRemovedSignal("BoatSpeedUI"):Connect(updateUIRefs)
	CollectionService:GetInstanceAddedSignal("BoatBoostUI"):Connect(updateUIRefs)
	CollectionService:GetInstanceRemovedSignal("BoatBoostUI"):Connect(updateUIRefs)
	self:_UpdateBoostInputText()
end

return BoatPhysics