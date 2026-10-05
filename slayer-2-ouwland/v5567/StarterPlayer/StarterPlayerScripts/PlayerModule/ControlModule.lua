local createVector = vector.create
local ControlModule = {}
ControlModule.__index = ControlModule
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
game:GetService("StarterPlayer")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRService = game:GetService("VRService")
local ContextActionService = game:GetService("ContextActionService")
local CommonUtils = require(script.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserPlayerScriptsCCLIntegrationD")
local userFlag2 = flagUtil.getUserFlag("UserPSSpecifySimulationFrequency")
local userFlag3 = flagUtil.getUserFlag("UserPlayerScriptsBindActivateOnIAS")
local userFlag4 = flagUtil.getUserFlag("UserPlayerScriptsFireThroughScriptableBindings")
local userFlag5 = flagUtil.getUserFlag("UserPlayerScriptsUseReplicatedCameraAPI")
local userFlag6 = flagUtil.getUserFlag("UserPlayerScriptsStopFireCameraAction")
local userFlag7 = flagUtil.getUserFlag("UserPlayerScriptsSAuthDirectAPIs2")
local userFlag8 = flagUtil.getUserFlag("UserPlayerScriptsPlayerControlState2")
local userFlag9 = flagUtil.getUserFlag("UserPlayerScriptsFixSAuthRenderStepMove")
local userFlag10 = flagUtil.getUserFlag("UserPlayerScriptsSupportMicroGamepad")
local userFlag11 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceC")
local _ = {
	SERVER_AUTHORITY_CHANGED = "SERVER_AUTHORITY_CHANGED"
}
local ActionController = require(script:WaitForChild("ActionController"))
local InputReplication

if userFlag or userFlag8 then
	InputReplication = require(script:WaitForChild("InputReplication"))
else
	InputReplication = nil
end

local InputSlots

if userFlag then
	InputSlots = require(script:WaitForChild("InputSlots"))
else
	InputSlots = nil
end

local DynamicThumbstick

if RunService:IsClient() then
	DynamicThumbstick = require(script:WaitForChild("DynamicThumbstick"))
else
	DynamicThumbstick = nil
end

local ClassicThumbstick = require(script:WaitForChild("ClassicThumbstick"))
local ClickToMoveController = require(script:WaitForChild("ClickToMoveController"))
local TouchJump = require(script:WaitForChild("TouchJump"))
local TouchAbilities

if userFlag then
	TouchAbilities = require(script:WaitForChild("TouchAbilities"))
else
	TouchAbilities = nil
end

local VehicleController = require(script:WaitForChild("VehicleController"))
local AvatarAbilitiesInterface, v

if userFlag then
	AvatarAbilitiesInterface = require(script:WaitForChild("AvatarAbilitiesInterface"))
	v = AvatarAbilitiesInterface.get(Players.LocalPlayer)
else
	v = nil
	AvatarAbilitiesInterface = nil
end

local cameraRotationAction = script.Parent:WaitForChild("InputContexts"):WaitForChild("CameraContext"):WaitForChild("CameraRotationAction")
local _ = Enum.ContextActionPriority.Medium.Value
local v2 = {
	[Enum.TouchMovementMode.DPad] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.DPad] = DynamicThumbstick,
	[Enum.TouchMovementMode.Thumbpad] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.Thumbpad] = DynamicThumbstick,
	[Enum.TouchMovementMode.Thumbstick] = ClassicThumbstick,
	[Enum.DevTouchMovementMode.Thumbstick] = ClassicThumbstick,
	[Enum.TouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
	[Enum.TouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevTouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.TouchMovementMode.Default] = DynamicThumbstick,
	[Enum.ComputerMovementMode.Default] = ActionController,
	[Enum.ComputerMovementMode.KeyboardMouse] = ActionController,
	[Enum.DevComputerMovementMode.KeyboardMouse] = ActionController,
	[Enum.DevComputerMovementMode.Scriptable] = nil,
	[Enum.ComputerMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevComputerMovementMode.ClickToMove] = ClickToMoveController
}

function ControlModule.new()
	local object = setmetatable({}, ControlModule)

	if RunService:IsServer() then
		return object
	end

	object.controllers = {}
	object.activeControlModule = nil
	object.activeController = nil
	object.touchJumpController = nil
	object.touchAbilitiesController = nil
	object.moveFunction = Players.LocalPlayer.Move
	object.humanoid = nil
	object.controlsEnabled = true
	object.enabled = false
	object.humanoidSeatedConn = nil
	object.vehicleController = nil
	object.touchControlFrame = nil
	object.currentTorsoAngle = 0
	object.inputMoveVector = createVector(0, 0, 0)
	object.vehicleController = VehicleController.new()
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		object:OnCharacterAdded(character)
	end)
	Players.LocalPlayer.CharacterRemoving:Connect(function(character)
		object:OnCharacterRemoving(character)
	end)

	if Players.LocalPlayer.Character then
		object:OnCharacterAdded(Players.LocalPlayer.Character)
	end

	UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)
	UserGameSettings:GetPropertyChangedSignal("ComputerMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
		object:UpdateMovementMode()
	end)

	if userFlag then
		v:GetEnabledChangedSignal():Connect(function()
			object:UpdateAbilitiesControllers()
		end)
	end

	object.playerGui = nil
	object.touchGui = nil
	object.playerGuiAddedConn = nil
	GuiService:GetPropertyChangedSignal("TouchControlsEnabled"):Connect(function()
		object:UpdateMovementMode()
		object:UpdateActiveControlModuleEnabled()
	end)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		object:UpdateMovementMode()
	end)
	object.playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not object.playerGui then
		object.playerGuiAddedConn = Players.LocalPlayer.ChildAdded:Connect(function(playerGui)
			if playerGui:IsA("PlayerGui") then
				object.playerGui = playerGui
				object.playerGuiAddedConn:Disconnect()
				object.playerGuiAddedConn = nil
				object:UpdateMovementMode()
			end
		end)
	end

	if userFlag3 then
		ContextActionService:BindActivate(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
	end

	return object
end

local function _fireCustomInputs(localPlayer)
	local inputContexts = localPlayer:FindFirstChild("InputContexts")

	if inputContexts == nil then
		return
	end

	local characterContext = inputContexts:FindFirstChild("CharacterContext")

	if characterContext == nil then
		return
	end

	local cameraContext = inputContexts:FindFirstChild("CameraContext")

	if userFlag7 then
		local rotationAction = characterContext:FindFirstChild("RotationAction")
		local rotationScriptableBinding = rotationAction and rotationAction:FindFirstChild("RotationScriptableBinding")

		if rotationScriptableBinding then
			rotationScriptableBinding:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
		end
	else
		local v3 = true

		if userFlag6 then
			local success, result = pcall(function()
				return localPlayer:GetCameraState()
			end)

			if success and result and result.CFrame ~= CFrame.identity and result.FieldOfView > 0 and result.ViewportSize.Magnitude > 0 then
				v3 = false
			end
		end

		local cameraAction = v3 and cameraContext and cameraContext:FindFirstChild("CameraAction")

		if cameraAction then
			local currentCamera = Workspace.CurrentCamera

			if userFlag4 then
				local cameraScriptableBinding = cameraAction:FindFirstChild("CameraScriptableBinding")

				if cameraScriptableBinding then
					local success, _ = pcall(function()
						cameraScriptableBinding.Type = Enum.InputBindingType.Scriptable
						cameraScriptableBinding:Fire(currentCamera.CFrame.LookVector)
					end)

					if not success then
						cameraAction:Fire(currentCamera.CFrame.LookVector)
					end
				else
					cameraAction:Fire(currentCamera.CFrame.LookVector)
				end
			else
				cameraAction:Fire(currentCamera.CFrame.LookVector)
			end
		end

		if userFlag4 then
			local rotationAction = characterContext:FindFirstChild("RotationAction")

			if rotationAction then
				local rotationScriptableBinding = rotationAction:FindFirstChild("RotationScriptableBinding")

				if not rotationScriptableBinding then
					rotationAction:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
					return
				end

				local success, _ = pcall(function()
					rotationScriptableBinding.Type = Enum.InputBindingType.Scriptable
					rotationScriptableBinding:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
				end)

				if not success then
					rotationAction:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
				end
			end
		else
			local rotationAction = characterContext.RotationAction

			if rotationAction then
				rotationAction:Fire(UserGameSettings.RotationType == Enum.RotationType.CameraRelative)
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _cloneInputs(parent)
	local clone = script.Parent.InputContexts:Clone()
	clone.CharacterContext.Enabled = true
	clone.CameraContext.Enabled = true
	clone.Parent = parent
end

function ControlModule:InitializeServerAuthority()
	if RunService:IsServer() then
		if userFlag then
			for _, v3 in Players:GetPlayers() do
				InputReplication.CloneInputsIfAbsent(v3)
			end

			Players.PlayerAdded:Connect(InputReplication.CloneInputsIfAbsent)
		else
			for _, v3 in Players:GetPlayers() do
				_cloneInputs(v3) -- equivalent call inferred; original call site unknown
			end

			Players.PlayerAdded:Connect(_cloneInputs)
		end

		if userFlag8 then
			for _, v3 in Players:GetPlayers() do
				InputReplication.createPlayerControlState(v3)
			end

			Players.PlayerAdded:Connect(InputReplication.createPlayerControlState)
		end

		if userFlag2 then
			RunService:BindToSimulation(function(p)
				for _, v3 in Players:GetPlayers() do
					self:ProcessInputs(v3, p)
				end
			end, Enum.StepFrequency.Hz60)
		else
			RunService:BindToSimulation(function(p)
				for _, v3 in Players:GetPlayers() do
					self:ProcessInputs(v3, p)
				end
			end)
		end
	else
		if userFlag8 then
			InputReplication.watchForPlayerControlState(Players.LocalPlayer)
		end

		RunService:BindToRenderStep("CameraInput", Enum.RenderPriority.Last.Value, function()
			if userFlag8 then
				InputReplication.writeInputToPCS(Players.LocalPlayer, self, true)
			elseif userFlag then
				InputReplication.FireCustomInputs(Players.LocalPlayer)
			else
				_fireCustomInputs(Players.LocalPlayer)
			end
		end)

		if userFlag2 then
			RunService:BindToSimulation(function(p)
				self:ProcessInputs(Players.LocalPlayer, p)
			end, Enum.StepFrequency.Hz60)
		else
			RunService:BindToSimulation(function(p)
				self:ProcessInputs(Players.LocalPlayer, p)
			end)
		end
	end

	if self.data and self.data.eventBus then
		self.data.isServerAuthority = true
		self.data.eventBus:publish("SERVER_AUTHORITY_CHANGED", true)
	end
end

local function NormalizeAngle(p)
	local v3 = (p + 12.566370614359172) % 6.283185307179586

	if v3 > 3.141592653589793 then
		return v3 - 6.283185307179586
	end

	return v3
end

local function AverageAngle(p, p2)
	local v3 = (p2 - p + 12.566370614359172) % 6.283185307179586

	if v3 > 3.141592653589793 then
		v3 -= 6.283185307179586
	end

	local v4 = (p + v3 / 2 + 12.566370614359172) % 6.283185307179586

	if v4 > 3.141592653589793 then
		return v4 - 6.283185307179586
	end

	return v4
end

function ControlModule:GetEstimatedVRTorsoFrame()
	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local _, v3, _ = userCFrame:ToEulerAnglesYXZ()
	local currentTorsoAngle = -v3

	if VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) and VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand) then
		local userCFrame2 = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
		local userCFrame3 = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
		local v5 = userCFrame.Position - userCFrame2.Position
		local v6 = userCFrame.Position - userCFrame3.Position
		local v7 = -math.atan2(v5.X, v5.Z)
		local v8 = (-math.atan2(v6.X, v6.Z) - v7 + 12.566370614359172) % 6.283185307179586

		if v8 > 3.141592653589793 then
			v8 -= 6.283185307179586
		end

		local v9 = (v7 + v8 / 2 + 12.566370614359172) % 6.283185307179586

		if v9 > 3.141592653589793 then
			v9 -= 6.283185307179586
		end

		local v10 = (currentTorsoAngle - self.currentTorsoAngle + 12.566370614359172) % 6.283185307179586

		if v10 > 3.141592653589793 then
			v10 -= 6.283185307179586
		end

		local v11 = (v9 - self.currentTorsoAngle + 12.566370614359172) % 6.283185307179586

		if v11 > 3.141592653589793 then
			v11 -= 6.283185307179586
		end

		local v12

		if v11 > -1.5707963267948966 then
			v12 = v11 < 1.5707963267948966
		else
			v12 = false
		end

		if not v12 then
			v11 = v10
		end

		local v13 = math.min(v11, v10)
		local v14 = math.max(v11, v10)
		local v15 = 0

		if v13 > 0 then
			v15 = v13
		elseif v14 < 0 then
			v15 = v14
		end

		self.currentTorsoAngle = v15 + self.currentTorsoAngle
	else
		self.currentTorsoAngle = currentTorsoAngle
	end

	return CFrame.new(userCFrame.Position) * CFrame.fromEulerAnglesYXZ(0, -self.currentTorsoAngle, 0)
end

function ControlModule.GetActiveController(p)
	return p.activeController
end

function ControlModule:UpdateAbilitiesControllers()
	local touchControlFrame = self.enabled and self.touchControlFrame

	if touchControlFrame then
		if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			touchControlFrame = self.activeControlModule == ClickToMoveController or self.activeControlModule == ClassicThumbstick or self.activeControlModule == DynamicThumbstick
		else
			touchControlFrame = false
		end
	end

	local v3 = touchControlFrame and not v:isEnabled()
	local v4 = touchControlFrame and v:isEnabled()

	if v3 then
		if not self.controllers[TouchJump] then
			self.controllers[TouchJump] = TouchJump.new(self.data, self.playerData)
		end

		self.touchJumpController = self.controllers[TouchJump]
		self.touchJumpController:Enable(true, self.touchControlFrame)
	elseif self.touchJumpController then
		self.touchJumpController:Enable(false)
	end

	if v4 then
		if not self.controllers[TouchAbilities] then
			self.controllers[TouchAbilities] = TouchAbilities.new(self.touchControlFrame)
		end

		self.touchAbilitiesController = self.controllers[TouchAbilities]
		self.touchAbilitiesController:Enable(true)
	elseif self.touchAbilitiesController then
		self.touchAbilitiesController:Enable(false)
	end
end

function ControlModule:UpdateActiveControlModuleEnabled()
	local function fn()
		if userFlag then
			self.enabled = false
		end

		self.activeController:Enable(false)

		if userFlag then
			self:UpdateAbilitiesControllers()
		elseif self.touchJumpController then
			self.touchJumpController:Enable(false)
		end

		if self.moveFunction and not (userFlag and v:isEnabled()) then
			self.moveFunction(Players.LocalPlayer, createVector(0, 0, 0), true)
		end
	end

	local function fn2()
		if userFlag then
			self.enabled = true
			self:UpdateAbilitiesControllers()
		elseif self.touchControlFrame and UserInputService.PreferredInput == Enum.PreferredInput.Touch and (self.activeControlModule == ClickToMoveController or self.activeControlModule == ClassicThumbstick or self.activeControlModule == DynamicThumbstick) then
			if not self.controllers[TouchJump] then
				self.controllers[TouchJump] = TouchJump.new(self.data, self.playerData)
			end

			self.touchJumpController = self.controllers[TouchJump]
			self.touchJumpController:Enable(true, self.touchControlFrame)
		elseif self.touchJumpController then
			self.touchJumpController:Enable(false)
		end

		if self.activeControlModule == ClickToMoveController then
			self.activeController:Enable(
				true,
				Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice,
				self.touchJumpController
			)
		elseif self.touchControlFrame then
			self.activeController:Enable(true, self.touchControlFrame)
		else
			self.activeController:Enable(true)
		end
	end

	if not self.activeController then
		return
	end

	if not self.controlsEnabled then
		fn()
	elseif GuiService.TouchControlsEnabled or UserInputService.PreferredInput ~= Enum.PreferredInput.Touch or self.activeControlModule ~= ClickToMoveController and self.activeControlModule ~= ClassicThumbstick and self.activeControlModule ~= DynamicThumbstick then
		fn2()
	else
		fn()
	end
end

function ControlModule:Enable(flag: boolean?)
	local controlsEnabled = flag == nil or flag

	if self.controlsEnabled == controlsEnabled then
		return
	end

	self.controlsEnabled = controlsEnabled

	if not self.activeController then
		return
	end

	self:UpdateActiveControlModuleEnabled()
end

function ControlModule:Disable()
	self:Enable(false)
end

function ControlModule:SelectComputerMovementModule()
	local v3 = false

	if userFlag10 then
		pcall(function()
			v3 = UserInputService.PreferredInput == Enum.PreferredInput.MicroGamepad
		end)
	end

	if UserInputService.PreferredInput ~= Enum.PreferredInput.KeyboardAndMouse and UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad and not v3 then
		return nil, false
	end

	local v4 = ActionController
	local devComputerMovementMode = Players.LocalPlayer.DevComputerMovementMode

	if devComputerMovementMode == Enum.DevComputerMovementMode.UserChoice then
		if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove then
			v4 = ClickToMoveController
		end
	else
		v4 = v2[devComputerMovementMode]

		if not v4 and devComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable then
			warn("No character control module is associated with DevComputerMovementMode ", devComputerMovementMode)
		end
	end

	if v4 then
		return v4, true
	end

	if devComputerMovementMode == Enum.DevComputerMovementMode.Scriptable then
		return nil, true
	end

	return nil, false
end

function ControlModule:SelectTouchModule()
	local devTouchMovementMode = Players.LocalPlayer.DevTouchMovementMode
	local v3

	if devTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		v3 = v2[UserGameSettings.TouchMovementMode]
		return v3, true
	end

	if devTouchMovementMode == Enum.DevTouchMovementMode.Scriptable then
		return nil, true
	end

	v3 = v2[devTouchMovementMode]
	return v3, true
end

function ControlModule:calculateRawMoveVector(object2, vector2: Vector3)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return vector2
	end

	local cFrame = currentCamera.CFrame

	if VRService.VREnabled and object2.RootPart then
		local estimatedVRTorsoFrame = self:GetEstimatedVRTorsoFrame()

		if (currentCamera.Focus.Position - cFrame.Position).Magnitude < 3 then
			cFrame *= estimatedVRTorsoFrame
		else
			cFrame = currentCamera.CFrame * (estimatedVRTorsoFrame.Rotation + estimatedVRTorsoFrame.Position * currentCamera.HeadScale)
		end
	end

	if object2:GetState() == Enum.HumanoidStateType.Swimming then
		if not VRService.VREnabled then
			return cFrame:VectorToWorldSpace(vector2)
		end

		local vector3 = Vector3.new(vector2.X, 0, vector2.Z)

		if vector3.Magnitude < 0.01 then
			return createVector(0, 0, 0)
		end

		local v3 = not (cameraRotationAction and cameraRotationAction.Enabled) and 0 or -cameraRotationAction:GetState().Y / 2.31
		local v4 = math.atan2(-vector3.X, -vector3.Z)
		local _, v5, _ = cFrame:ToEulerAnglesYXZ()
		local v6 = v4 + v5
		return CFrame.fromEulerAnglesYXZ(v3, v6, 0).LookVector
	else
		local _, _, _, v3, v4, v5, _, _, v6, _, _, v7 = cFrame:GetComponents()

		if v6 < 1 and v6 > -1 then
			v3 = v7
		else
			v5 = -v4 * math.sign(v6)
		end

		local v8 = math.sqrt(v3 * v3 + v5 * v5)
		return (Vector3.new((v3 * vector2.X + v5 * vector2.Z) / v8, 0, (v3 * vector2.Z - v5 * vector2.X) / v8))
	end
end

function ControlModule:initialize(p, playerData)
	self.data = p
	self.playerData = playerData
	self:UpdateMovementMode()
	ActionController.initializeActions(self.data, self.playerData)

	if userFlag then
		InputSlots.setupSlotActions(self.playerData.player, self.data.isServerAuthority)
	end
end

function ControlModule:Update(p, data, p2)
	assert(data.player)
	assert(data.character)
	ActionController.initializeActions(p, data)

	if not (data.actions.MoveAction and data.actions.JumpAction) then
		return
	end

	if self.activeController and self.activeController.enabled and self.humanoid then
		ActionController.update(data)
		self:GetClickToMoveController():Update(data, p2)
		local vector2 = Vector3.new(data.moveVector.X, 0, -data.moveVector.Y)

		if self.vehicleController then
			local v3
			vector2, v3 = self.vehicleController:Update(vector2, true)
		end

		local rawMoveVector = self:calculateRawMoveVector(self.humanoid, vector2)
		self.inputMoveVector = rawMoveVector

		if VRService.VREnabled then
			rawMoveVector = self:updateVRMoveVector(rawMoveVector)
		end

		if userFlag8 then
			if not p.isServerAuthority then
				if userFlag and v:isEnabled() then
					InputReplication.writeInputToPCS(Players.LocalPlayer, self, false)
					return
				end

				self.moveFunction(Players.LocalPlayer, rawMoveVector, false)
				self.humanoid.Jump = data.isJumping
			end
		elseif not (userFlag9 and p.isServerAuthority or userFlag and v:isEnabled()) then
			self.moveFunction(Players.LocalPlayer, rawMoveVector, false)
			self.humanoid.Jump = data.isJumping
		end
	end
end

function ControlModule:updateVRMoveVector(p2)
	local currentCamera = workspace.CurrentCamera
	local v3 = (currentCamera.Focus.Position - currentCamera.CFrame.Position).Magnitude < 5

	if p2.Magnitude ~= 0 or not v3 or not VRService.AvatarGestures or not self.humanoid or self.humanoid.Sit then
		return p2
	end

	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local v4 = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale
	local v5 = -0.7 * self.humanoid.RootPart.Size.Y / 2
	local v6 = (currentCamera.CFrame * v4 * CFrame.new(0, v5, 0)).Position - self.humanoid.RootPart.CFrame.Position
	return (Vector3.new(v6.x, 0, v6.z))
end

function ControlModule:OnHumanoidSeated(flag: boolean, vehicleSeat)
	if flag then
		if vehicleSeat and vehicleSeat:IsA("VehicleSeat") then
			if not self.vehicleController then
				self.vehicleController = self.vehicleController.new()
			end

			self.vehicleController:Enable(true, vehicleSeat)
		end
	elseif self.vehicleController then
		self.vehicleController:Enable(false, vehicleSeat)
	end
end

function ControlModule:OnCharacterAdded(instance)
	self.humanoid = instance:FindFirstChildOfClass("Humanoid")

	while not self.humanoid do
		instance.ChildAdded:wait()
		self.humanoid = instance:FindFirstChildOfClass("Humanoid")
	end

	if self.humanoidSeatedConn then
		self.humanoidSeatedConn:Disconnect()
		self.humanoidSeatedConn = nil
	end

	self.humanoidSeatedConn = self.humanoid.Seated:Connect(function(p, p2)
		self:OnHumanoidSeated(p, p2)
	end)
	self:UpdateMovementMode()
end

function ControlModule:OnCharacterRemoving(_)
	self.humanoid = nil
	self:UpdateMovementMode()
end

function ControlModule:UpdateTouchGuiVisibility()
	local v3 = self.humanoid and GuiService.TouchControlsEnabled and UserInputService.PreferredInput == Enum.PreferredInput.Touch

	if v3 and not self.touchGui then
		self:CreateTouchGuiContainer()
	end

	if self.touchGui then
		self.touchGui.Enabled = v3 and true or false
	end
end

function ControlModule:SwitchToController(activeControlModule)
	if activeControlModule then
		if not self.controllers[activeControlModule] then
			self.controllers[activeControlModule] = activeControlModule.new(self.playerData)
		end

		if self.activeController ~= self.controllers[activeControlModule] then
			if self.activeController then
				self.activeController:Enable(false)
			end

			self.activeController = self.controllers[activeControlModule]
			self.activeControlModule = activeControlModule
			self:UpdateActiveControlModuleEnabled()
		end
	else
		if self.activeController then
			self.activeController:Enable(false)
		end

		self.activeController = nil
		self.activeControlModule = nil
	end
end

function ControlModule:UpdateMovementMode()
	self:UpdateTouchGuiVisibility()

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		local touchModule, v3 = self:SelectTouchModule()

		if v3 and self.touchControlFrame then
			self:SwitchToController(touchModule)
		end
	else
		self:SwitchToController((self:SelectComputerMovementModule()))
	end
end

function ControlModule:CreateTouchGuiContainer()
	if not self.playerGui then
		return
	end

	if self.touchGui then
		self.touchGui:Destroy()
	end

	self.touchGui = Instance.new("ScreenGui")
	self.touchGui.Name = "TouchGui"
	self.touchGui.ResetOnSpawn = false
	self.touchGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.touchGui.DisplayOrder = -1

	if userFlag and userFlag11 then
		self.touchGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	end

	self.touchGui.ClipToDeviceSafeArea = false
	self.touchControlFrame = Instance.new("Frame")
	self.touchControlFrame.Name = "TouchControlFrame"
	self.touchControlFrame.Size = UDim2.new(1, 0, 1, 0)
	self.touchControlFrame.BackgroundTransparency = 1
	self.touchControlFrame.Parent = self.touchGui
	self.touchGui.Parent = self.playerGui
end

function ControlModule:GetClickToMoveController()
	if not self.controllers[ClickToMoveController] then
		self.controllers[ClickToMoveController] = ClickToMoveController.new()
	end

	return self.controllers[ClickToMoveController]
end

function ControlModule:ProcessInputs(player, _: number)
	if userFlag then
		if not AvatarAbilitiesInterface.get(player):isEnabled() then
			if userFlag8 then
				InputReplication.processPCSInputs(player)
			else
				InputReplication.SendInputToHumanoidForServerAuth(player)
			end
		end
	else
		if userFlag8 then
			InputReplication.processPCSInputs(player)
			return
		end

		local character = player.Character

		if character == nil then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid == nil then
			return
		end

		local inputContexts = player:FindFirstChild("InputContexts")

		if inputContexts == nil then
			return
		end

		local characterContext = inputContexts:FindFirstChild("CharacterContext")

		if characterContext == nil then
			return
		end

		local cameraContext = inputContexts:FindFirstChild("CameraContext")
		local moveAction = characterContext.MoveAction
		local cameraAction = cameraContext and cameraContext.CameraAction
		local rotationAction = characterContext.RotationAction
		local jumpAction = characterContext.JumpAction

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isValidInput2D(point: Vector2)
			return point.X == point.X and point.Y == point.Y and point.X ~= 1e999 and point.Y ~= 1e999
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isValidInput3D(vector2: Vector3)
			return vector2.X == vector2.X and vector2.Y == vector2.Y and vector2.Z == vector2.Z and vector2.X ~= 1e999 and vector2.Y ~= 1e999 and vector2.Z ~= 1e999
		end

		local vector2

		if moveAction == nil then
			vector2 = Vector2.new(0, 0)
		else
			vector2 = moveAction:GetState()
		end

		local lookVector = nil
		local lookVector2

		if userFlag7 then
			lookVector2 = player:GetCameraState().CFrame.LookVector
		elseif userFlag5 then
			local success, result = pcall(function()
				return player:GetCameraState()
			end)

			if success and result then
				local cFrame = result.CFrame

				if cFrame ~= CFrame.identity and result.FieldOfView > 0 and result.ViewportSize.Magnitude > 0 then
					lookVector = cFrame.LookVector
				end
			end

			lookVector2 = lookVector or cameraAction == nil and createVector(0, 0, 0) or cameraAction:GetState()
		else
			lookVector2 = cameraAction == nil and createVector(0, 0, 0) or cameraAction:GetState()
		end

		if isValidInput2D(vector2) and isValidInput3D(lookVector2) and lookVector2.Magnitude > 0 then
			if humanoid:GetState() ~= Enum.HumanoidStateType.Swimming then
				lookVector2 = Vector3.new(lookVector2.X, 0, lookVector2.Z).Unit
			end

			local unit = lookVector2:Cross(createVector(0, 1, 0)).Unit
			humanoid:Move(lookVector2 * vector2.Y + unit * vector2.X)

			if rotationAction:GetState() then
				humanoid.AutoRotate = false

				if humanoid.SeatPart == nil and humanoid.RootPart ~= nil and not (humanoid.Sit or humanoid.RootPart:IsGrounded()) then
					humanoid.RootPart.CFrame = CFrame.new(
						humanoid.RootPart.CFrame.Position,
						humanoid.RootPart.CFrame.Position + lookVector2
					)
				end
			else
				humanoid.AutoRotate = true
			end
		end

		humanoid.Jump = jumpAction ~= nil and jumpAction:GetState()
	end
end

if RunService:IsClient() then
	return ControlModule.new()
end

return ControlModule