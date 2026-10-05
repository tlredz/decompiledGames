local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleBoostConstants = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleBoostConstants)
local FreeCamController = require(ReplicatedStorage.Modules.Client.PlayerController.FreeCamController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local VehicleBoostLines = require(ReplicatedStorage.Modules.Client.Components.Vehicles.VehicleBoostLines)
local VehicleControlsTestController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleControlsTestController)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "VehicleBoostButton"
})
local tweenInfo = TweenInfo.new(0.5)
local flag = false

local function sampleColorRamp(BAR_COLOR_STOPS, p: number)
	if p <= BAR_COLOR_STOPS[1].position then
		return BAR_COLOR_STOPS[1].color
	end

	local v2 = BAR_COLOR_STOPS[#BAR_COLOR_STOPS]

	if v2.position <= p then
		return v2.color
	end

	for i = 1, #BAR_COLOR_STOPS - 1 do
		local v3 = BAR_COLOR_STOPS[i]
		local v4 = BAR_COLOR_STOPS[i + 1]

		if not (v3.position <= p and p <= v4.position) then
			continue
		end

		local v5 = v4.position - v3.position
		local v6 = not (v5 > 0) and 0 or (p - v3.position) / v5
		return v3.color:Lerp(v4.color, v6)
	end

	return v2.color
end

function v:IsBoostUnlocked()
	return UnlockableController.IsFeatureUnlocked(AdFeatures.VEHICLE_BOOST.id, Gamepasses.VEHICLE_BOOST)
end

function v:OnBoostAcquired()
	flag = true
	self.desireButtonVisibilityValue:set(true)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._fireParticlePool = {}
	self._activeFireParticles = {}
	self.scope = Fusion.scoped(Fusion)
	self._Janitor:Add(function()
		Fusion.doCleanup(self.scope)
	end)
	self.desireButtonVisibilityValue = self.scope:Value(false)
	self.OnButtonDownChanged = self._Janitor:Add(Signal.new())
end

function v:CalculateEffectChangeFactor(p2: number)
	if not self.currentVehicle then
		self.currentVehicle = VehicleController.GetCurrentDrivingVehicleModel()
	end

	local magnitude = self.currentVehicle and self.currentVehicle.PrimaryPart.AssemblyLinearVelocity.Magnitude or 0
	return VehicleBoostLines.CalculateEffectFactor(magnitude, p2)
end

function v:AcquireFireParticle()
	local v2 = table.remove(self._fireParticlePool)

	if v2 then
		return v2
	end

	v2 = Instance.new("Frame")
	v2.Name = "FireParticle"
	v2.AnchorPoint = Vector2.new(0.5, 0.5)
	v2.BorderSizePixel = 0
	return v2
end

function v:ReleaseFireParticle(instance)
	instance.Parent = nil

	if #self._fireParticlePool >= VehicleBoostConstants.FIRE_PARTICLE_POOL_SIZE then
		instance:Destroy()
	else
		table.insert(self._fireParticlePool, instance)
	end
end

function v:UpdateFireParticles(p: number)
	local _activeFireParticles = self._activeFireParticles

	for i = #_activeFireParticles, 1, -1 do
		local _activeFireParticle = _activeFireParticles[i]
		_activeFireParticle.elapsed += p
		local backgroundTransparency = _activeFireParticle.elapsed / _activeFireParticle.lifetime

		if backgroundTransparency >= 1 then
			_activeFireParticles[i] = _activeFireParticles[#_activeFireParticles]
			_activeFireParticles[#_activeFireParticles] = nil
			self:ReleaseFireParticle(_activeFireParticle.particle)
		else
			local particle = _activeFireParticle.particle
			particle.Position = _activeFireParticle.startPos:Lerp(_activeFireParticle.endPos, backgroundTransparency)
			local v3 = _activeFireParticle.startSizePixels * (1 - VehicleBoostConstants.FIRE_PARTICLE_SHRINK_FACTOR * backgroundTransparency)
			particle.Size = UDim2.fromOffset(v3, v3)
			particle.BackgroundTransparency = backgroundTransparency
			particle.Rotation = _activeFireParticle.startRotation + _activeFireParticle.rotationDelta * backgroundTransparency
		end
	end

	if #_activeFireParticles == 0 and self._fireUpdaterConnection then
		self._fireUpdaterConnection:Disconnect()
		self._fireUpdaterConnection = nil
	end
end

function v:EmitFireParticles()
	if not (self.fireContainer and self.progressBarFillbar and self.progressBarCanvas) then
		return
	end

	local progressBarFillbar = self.progressBarFillbar
	local progressBarCanvas = self.progressBarCanvas
	local v2 = math.max(progressBarCanvas.AbsoluteSize.X, 1)
	local v3 = math.max(progressBarCanvas.AbsoluteSize.Y, 1)
	local v4 = (progressBarFillbar.AbsolutePosition.Y - progressBarCanvas.AbsolutePosition.Y) / v3
	local v5 = (progressBarFillbar.AbsolutePosition.X - progressBarCanvas.AbsolutePosition.X) / v2
	local v6 = progressBarFillbar.AbsoluteSize.X / v2

	for _ = 1, VehicleBoostConstants.FIRE_PARTICLES_PER_TICK do
		local startSizePixels = math.random(
			VehicleBoostConstants.FIRE_PARTICLE_MIN_SIZE_PIXELS,
			VehicleBoostConstants.FIRE_PARTICLE_MAX_SIZE_PIXELS
		)
		local v8 = v5 + math.random() * v6
		local v9 = math.random(0, 360)
		local uDim = UDim2.fromScale(v8, v4)
		local fireParticle = self:AcquireFireParticle()
		fireParticle.Size = UDim2.fromOffset(startSizePixels, startSizePixels)
		fireParticle.Position = uDim
		fireParticle.Rotation = v9
		fireParticle.BackgroundTransparency = 0
		fireParticle.BackgroundColor3 = VehicleBoostConstants.FIRE_PARTICLE_COLOR_COOL:Lerp(
			VehicleBoostConstants.FIRE_PARTICLE_COLOR_HOT,
			math.random()
		)
		fireParticle.ZIndex = self.fireContainer.ZIndex
		fireParticle.Parent = self.fireContainer
		local v10 = VehicleBoostConstants.FIRE_PARTICLE_RISE_SCALE * (0.6 + math.random() * 0.8)
		local v11 = (math.random() - 0.5) * 0.1
		table.insert(self._activeFireParticles, {
			particle = fireParticle,
			elapsed = 0,
			lifetime = VehicleBoostConstants.FIRE_PARTICLE_LIFETIME_SECONDS,
			startPos = uDim,
			endPos = UDim2.fromScale(v8 + v11, v4 - v10),
			startSizePixels = startSizePixels,
			startRotation = v9,
			rotationDelta = math.random(-90, 90)
		})
	end

	if not self._fireUpdaterConnection then
		self._fireUpdaterConnection = RunService.Heartbeat:Connect(function(dt: number)
			self:UpdateFireParticles(dt)
		end)
		self._Janitor:Add(self._fireUpdaterConnection, "Disconnect", "FireUpdater")
	end
end

function v:SetProgressBar(p: number, flag2: boolean?)
	local currentProgressBarTransparency = p < self.maxValue and 0 or 1

	if currentProgressBarTransparency ~= self.currentProgressBarTransparency then
		self.progressBarTransparency = self.lastProgressBarTransparency
		self.currentProgressBarTransparency = currentProgressBarTransparency
		self.progressBarTransparencyStart = os.clock()
		self.progressBarTransparencyTime = 0.5
	end

	local v3 = p / self.maxValue
	local backgroundColor = sampleColorRamp(VehicleBoostConstants.BAR_COLOR_STOPS, 1 - v3)

	if flag2 then
		TweenService:Create(self.progressBarFillbar, tweenInfo, {
			Size = UDim2.fromScale(1, v3),
			BackgroundColor3 = backgroundColor
		}):Play()
	else
		self.progressBarFillbar.Size = UDim2.fromScale(1, v3)
		self.progressBarFillbar.BackgroundColor3 = backgroundColor
	end

	if VehicleBoostConstants.FIRE_PARTICLES_ENABLED and self.boostEnabled and not FreeCamController.IsFreecamEnabled() then
		self:EmitFireParticles()
	end

	local effectChangeFactor = self:CalculateEffectChangeFactor(1 - v3)

	if self.boostLines then
		self.boostLines:SetSourceIntensity(
			self.Instance,
			not self.boostEnabled and 0 or effectChangeFactor,
			self.currentVehicle
		)
	end

	if self.camera then
		if FreeCamController.IsFreecamEnabled() then
			self.camera.FieldOfView = self.startFieldOfView
			return
		end

		local fieldOfView = self.startFieldOfView + (VehicleBoostConstants.MAX_FIELD_OF_VIEW_INCREASE - self.startFieldOfView) * effectChangeFactor

		if self.cameraTween then
			self.cameraTween:Cancel()
		end

		self.cameraTween = TweenService:Create(
			self.camera,
			TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				FieldOfView = fieldOfView
			}
		)
		self.cameraTween:Play()
	end
end

function v:SetBoostEnabled(boostEnabled: boolean)
	if self.vehiclePanel and self.vehiclePanel:IsBoostDisabled() then
		return false
	end

	if boostEnabled and not UnlockableController.IsFeatureUnlocked(
		AdFeatures.VEHICLE_BOOST.id,
		Gamepasses.VEHICLE_BOOST
	) then
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not currentDrivingVehicleModel then
			return false
		end

		local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
		GamepassController.Show(
			Gamepasses.VEHICLE_BOOST,
			nil,
			"boost",
			nil,
			AdFeatures.VEHICLE_BOOST,
			nil,
			"Vehicle Controls",
			vehicleName
		)
		return false
	else
		if not VehicleController.SetBoost(boostEnabled) then
			return false
		end

		self.boostEnabled = boostEnabled
		self.OnButtonDownChanged:Fire(self.boostEnabled)
		return true
	end
end

function v:StartRefillProgressBar()
	if not self:SetBoostEnabled(false) then
		return
	end

	if self.processTask then
		task.cancel(self.processTask)
	end

	self.boostEnabled = false
	self.processTask = task.spawn(function()
		while self.currentValue < self.maxValue do
			self.currentValue += 1

			if self.currentValue > self.maxValue then
				self.currentValue = self.maxValue
			end

			self:SetProgressBar(self.currentValue, true)
			task.wait(VehicleBoostConstants.PROGRESS_TICK_INTERVAL_SECONDS)
		end
	end)
end

function v:OnButtonStateChanged()
	if not flag then
		return
	end

	if self.boostEnabled then
		if not (self.isButtonDown or self.isShiftPressed or self.isControllerPressed) then
			self:StartRefillProgressBar()
		end
	elseif self.isButtonDown or self.isShiftPressed or self.isControllerPressed then
		self:EnableBoost()
	end
end

function v:EnableBoost()
	if self.vehiclePanel and self.vehiclePanel:IsBoostDisabled() or FreeCamController.IsFreecamEnabled() then
		return
	end

	if not VehicleController.IsDrivingOwnedVehicle() then
		NotificationController.NotifyCenter("You do not own this vehicle!")
		return
	end

	if self.boostEnabled or not self:SetBoostEnabled(true) then
		return
	end

	if self.boostLines ~= nil then
		self.boostLines:TriggerCameraShake()
	end

	if not self.boostEnabled then
		return
	end

	if self.processTask then
		task.cancel(self.processTask)
	end

	self.processTask = task.spawn(function()
		while self.currentValue > 0 do
			self.currentValue -= 1

			if self.currentValue <= 0 then
				self.currentValue = 0
			end

			self:SetProgressBar(self.currentValue, true)
			task.wait(VehicleBoostConstants.PROGRESS_TICK_INTERVAL_SECONDS)
		end

		self:SetProgressBar(0, true)
		self.processTask = nil
		task.wait(VehicleBoostConstants.REFILL_DELAY_AFTER_USE_SECONDS)
		self:StartRefillProgressBar()
	end)
end

function v:_bindToVehiclePanel()
	if not self.vehiclePanel then
		return
	end

	self.Instance.Visible = not self.vehiclePanel:IsBoostDisabled()

	if self._boostDisabledConnection then
		self._boostDisabledConnection:Disconnect()
	end

	self._boostDisabledConnection = self._Janitor:Add(self.vehiclePanel.OnBoostDisabledChanged:Connect(function(p)
		self.Instance.Visible = not p
	end))
end

function v:Start()
	self.maxValue = self.Instance:GetAttribute("MaxValue") or VehicleBoostConstants.DEFAULT_MAX_PROGRESS
	self.currentValue = self.maxValue
	self.boostEnabled = false
	self.camera = workspace.CurrentCamera
	self.startFieldOfView = self.camera.FieldOfView
	self.boostLines = VehicleBoostLines.GetShared()
	local buttonContainer = self.Instance:WaitForChild("ButtonContainer")

	if not buttonContainer then
		warn("VehicleBoostButton:Start() - ButtonContainer not found")
		return
	end

	self.buttonInstance = buttonContainer:WaitForChild("BoostButton")

	if not self.buttonInstance then
		warn("VehicleBoostButton:Start() - Button not found")
		return
	end

	self.progressBarCanvas = self.Instance:WaitForChild("CanvasGroup")
	self.progressBarCanvas.GroupTransparency = 1
	self.currentProgressBarTransparency = 1
	self.progressBar = self.progressBarCanvas:WaitForChild("ProgressBar")

	if not self.progressBar then
		warn("VehicleBoostButton:Start() - ProgressBar not found")
		return
	end

	self.testButtonInstance = self.progressBar:WaitForChild("Icon")
	self.progressBarFillbar = self.progressBar:WaitForChild("Fillbar")

	if not self.progressBarFillbar then
		warn("VehicleBoostButton:Start() - ProgressBarFillbar not found")
		return
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 90
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 225, 225))
	})
	uIGradient.Parent = self.progressBarFillbar
	self._Janitor:Add(uIGradient)
	self.fireContainer = Instance.new("Frame")
	self.fireContainer.Name = "BoostFireParticles"
	self.fireContainer.BackgroundTransparency = 1
	self.fireContainer.Size = UDim2.fromScale(1, 1)
	self.fireContainer.ClipsDescendants = false
	self.fireContainer.ZIndex = self.progressBarFillbar.ZIndex + 1
	self.fireContainer.Parent = self.progressBarCanvas
	self._Janitor:Add(self.fireContainer)
	self._Janitor:Add(function()
		for _, v2 in self._fireParticlePool do
			v2:Destroy()
		end

		table.clear(self._fireParticlePool)
		table.clear(self._activeFireParticles)
	end)
	self.isButtonDown = false
	self.isShiftPressed = false
	self.isControllerPressed = false
	self.hasShownShiftUpsell = false
	self.preferredTouch = self.scope:Value(UserInputService.PreferredInput)
	self._Janitor:Add(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		self.preferredTouch:set(UserInputService.PreferredInput)
	end))
	self.scope:Hydrate(buttonContainer)({
		Visible = self.scope:Computed(function(use)
			return use(self.desireButtonVisibilityValue) and not use(VehicleControlsTestController.IsVisibleValue()) and use(self.preferredTouch) == Enum.PreferredInput.Touch
		end)
	})
	self.scope:Hydrate(self.testButtonInstance)({
		Interactable = self.scope:Computed(function(use)
			return use(self.desireButtonVisibilityValue) and use(VehicleControlsTestController.IsVisibleValue()) and use(self.preferredTouch) == Enum.PreferredInput.Touch
		end)
	})
	self.scope:Hydrate(self.progressBarCanvas)({
		Position = self.scope:Computed(function(use)
			if use(VehicleControlsTestController.IsVisibleValue()) and use(self.preferredTouch) == Enum.PreferredInput.Touch then
				return (UDim2.new(0.94, 0, 0.39, -33))
			end

			return (UDim2.fromScale(0.92, 0.4))
		end)
	})
	self.scope:Hydrate(self.progressBar:WaitForChild("UIAspectRatioConstraint"))({
		AspectRatio = self.scope:Computed(function(use)
			if use(VehicleControlsTestController.IsVisibleValue()) and use(self.preferredTouch) == Enum.PreferredInput.Touch then
				return 0.125
			end

			return 0.05
		end)
	})
	local v2 = { self.progressBar:WaitForChild("UIStroke"), self.progressBarFillbar:WaitForChild("UIStroke") }
	self.lastProgressBarTransparency = 1

	local function isTestBoostVisible()
		return Fusion.peek(self.desireButtonVisibilityValue) and Fusion.peek(VehicleControlsTestController.IsVisibleValue()) and Fusion.peek(self.preferredTouch) == Enum.PreferredInput.Touch
	end

	local function updateTransparency(p)
		if Fusion.peek(self.desireButtonVisibilityValue) and Fusion.peek(VehicleControlsTestController.IsVisibleValue()) and Fusion.peek(self.preferredTouch) == Enum.PreferredInput.Touch then
			self.progressBar.BackgroundTransparency = 0.5 + p * 0.5
			self.progressBarFillbar.BackgroundTransparency = p

			for _, v3 in v2 do
				v3.Transparency = p
			end

			self.progressBarCanvas.GroupTransparency = 0
		else
			self.progressBar.BackgroundTransparency = 0.5
			self.progressBarFillbar.BackgroundTransparency = 0

			for _, v3 in v2 do
				v3.Transparency = 0
			end

			self.progressBarCanvas.GroupTransparency = p
		end

		self.lastProgressBarTransparency = p
	end

	self.scope:Observer(VehicleControlsTestController.IsVisibleValue()):onChange(function()
		updateTransparency(self.lastProgressBarTransparency)
	end)
	self.scope:Observer(self.preferredTouch):onChange(function()
		updateTransparency(self.lastProgressBarTransparency)
	end)
	self.scope:Observer(self.desireButtonVisibilityValue):onChange(function()
		updateTransparency(self.lastProgressBarTransparency)
	end)
	updateTransparency(1)
	self._Janitor:Add(RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if self.progressBarTransparencyStart == nil or self.progressBarTransparencyStart + self.progressBarTransparencyTime < now then
			if self.progressBarTransparencyStart ~= nil then
				updateTransparency(self.currentProgressBarTransparency)
				self.progressBarTransparencyStart = nil
			end
		else
			local v3 = math.min(1, (now - self.progressBarTransparencyStart) / self.progressBarTransparencyTime)
			updateTransparency(self.progressBarTransparency + (self.currentProgressBarTransparency - self.progressBarTransparency) * v3)
		end
	end))

	if self:IsBoostUnlocked() then
		self:OnBoostAcquired()
	end

	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p)
		if p == AdFeatures.VEHICLE_BOOST.id then
			self:OnBoostAcquired()
		end
	end))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(p)
		if flag then
			return
		end

		if Gamepasses.GetById(p) == Gamepasses.VEHICLE_BOOST then
			self:OnBoostAcquired()
		end
	end))
	self._Janitor:Add(self.testButtonInstance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self.isButtonDown = true
			self:OnButtonStateChanged()
		end
	end))
	self._Janitor:Add(self.testButtonInstance.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self.isButtonDown = false
			self:OnButtonStateChanged()
		end
	end))
	self._Janitor:Add(self.buttonInstance.MouseButton1Up:Connect(function()
		self.isButtonDown = false
		self:OnButtonStateChanged()
	end))
	self._Janitor:Add(self.buttonInstance.MouseButton1Down:Connect(function()
		self.isButtonDown = true
		self:OnButtonStateChanged()
	end))
	local vehicleBoostButton = self.Instance.Parent.Parent:FindFirstChild("VehicleBoostButton", true)
	self._Janitor:Add(vehicleBoostButton.MouseButton1Click:Connect(function()
		if self.vehiclePanel and self.vehiclePanel:IsBoostDisabled() then
			return
		end

		if not flag then
			local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

			if not currentDrivingVehicleModel then
				return
			end

			local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
			GamepassController.Show(
				Gamepasses.VEHICLE_BOOST,
				nil,
				"boost",
				nil,
				AdFeatures.VEHICLE_BOOST,
				nil,
				"Vehicle Controls",
				vehicleName
			)
		end
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		self.vehiclePanel = VehicleController.GetVehiclePanel()

		if not self.vehiclePanel then
			return
		end

		self:_bindToVehiclePanel()

		local function OnShiftPressed(_, p2, _)
			if self.vehiclePanel and self.vehiclePanel:IsBoostDisabled() then
				return Enum.ContextActionResult.Sink
			end

			if p2 == Enum.UserInputState.Begin then
				if flag or self.hasShownShiftUpsell then
					self.isShiftPressed = true
					self:OnButtonStateChanged()
					return Enum.ContextActionResult.Sink
				else
					self.hasShownShiftUpsell = true
					local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
					GamepassController.Show(
						Gamepasses.VEHICLE_BOOST,
						nil,
						"boost",
						nil,
						AdFeatures.VEHICLE_BOOST,
						nil,
						"Vehicle Controls",
						vehicleName
					)
					return Enum.ContextActionResult.Sink
				end
			else
				self.isShiftPressed = false
				self:OnButtonStateChanged()
				return Enum.ContextActionResult.Sink
			end
		end

		ContextActionService:BindAction("VehicleBoostShift", OnShiftPressed, false, Enum.KeyCode.LeftShift)
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		ContextActionService:UnbindAction("VehicleBoostShift")
	end))
	self._Janitor:Add(UserInputService.InputEnded:Connect(function(input)
		if not (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonX) then
			return
		end

		self.isControllerPressed = false
		self:OnButtonStateChanged()
	end))
	self._Janitor:Add(UserInputService.InputBegan:Connect(function(input)
		if self.vehiclePanel and self.vehiclePanel:IsBoostDisabled() or input.UserInputType ~= Enum.UserInputType.Gamepad1 or input.KeyCode ~= Enum.KeyCode.ButtonX then
			return
		end

		self.isControllerPressed = true
		self:OnButtonStateChanged()
	end))
	self:SetProgressBar(self.currentValue, false)
end

function v:Stop()
	if self.processTask then
		task.cancel(self.processTask)
	end

	self._Janitor:Destroy()

	if self.boostLines then
		self.boostLines:SetSourceIntensity(self.Instance, 0)
	end

	if self.cameraTween then
		self.cameraTween:Cancel()
		self.cameraTween = nil
	end

	if self.camera then
		self.camera.FieldOfView = self.startFieldOfView
	end

	ContextActionService:UnbindAction("VehicleBoostShift")
end

return v