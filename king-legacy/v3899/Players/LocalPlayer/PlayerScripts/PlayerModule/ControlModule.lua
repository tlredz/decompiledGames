local createVector = vector.create
local class = {}
class.__index = class
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRService = game:GetService("VRService")
script.Parent:WaitForChild("CommonUtils")
local Keyboard = require(script:WaitForChild("Keyboard"))
local Gamepad = require(script:WaitForChild("Gamepad"))
local DynamicThumbstick = require(script:WaitForChild("DynamicThumbstick"))
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserDynamicThumbstickSafeAreaUpdate")
end)
local v = success and result
local TouchThumbstick = require(script:WaitForChild("TouchThumbstick"))
local ClickToMoveController = require(script:WaitForChild("ClickToMoveController"))
local TouchJump = require(script:WaitForChild("TouchJump"))
local VehicleController = require(script:WaitForChild("VehicleController"))
local value = Enum.ContextActionPriority.Medium.Value
local v2 = {
	[Enum.TouchMovementMode.DPad] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.DPad] = DynamicThumbstick,
	[Enum.TouchMovementMode.Thumbpad] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.Thumbpad] = DynamicThumbstick,
	[Enum.TouchMovementMode.Thumbstick] = TouchThumbstick,
	[Enum.DevTouchMovementMode.Thumbstick] = TouchThumbstick,
	[Enum.TouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
	[Enum.DevTouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
	[Enum.TouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevTouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.TouchMovementMode.Default] = DynamicThumbstick,
	[Enum.ComputerMovementMode.Default] = Keyboard,
	[Enum.ComputerMovementMode.KeyboardMouse] = Keyboard,
	[Enum.DevComputerMovementMode.KeyboardMouse] = Keyboard,
	[Enum.DevComputerMovementMode.Scriptable] = nil,
	[Enum.ComputerMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevComputerMovementMode.ClickToMove] = ClickToMoveController
}

function class.new()
	local object = setmetatable({}, class)
	object.controllers = {}
	object.activeControlModule = nil
	object.activeController = nil
	object.touchJumpController = nil
	object.moveFunction = Players.LocalPlayer.Move
	object.humanoid = nil
	object.controlsEnabled = true
	object.humanoidSeatedConn = nil
	object.vehicleController = nil
	object.touchControlFrame = nil
	object.currentTorsoAngle = 0
	object.inputMoveVector = createVector(0, 0, 0)
	object.vehicleController = VehicleController.new(value)
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		object:OnCharacterAdded(character)
	end)
	Players.LocalPlayer.CharacterRemoving:Connect(function(character)
		object:OnCharacterRemoving(character)
	end)

	if Players.LocalPlayer.Character then
		object:OnCharacterAdded(Players.LocalPlayer.Character)
	end

	RunService:BindToRenderStep("ControlScriptRenderstep", Enum.RenderPriority.Input.Value, function(p)
		object:OnRenderStepped(p)
	end)
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

	object:UpdateMovementMode()
	return object
end

function class:GetMoveVector()
	if self.activeController then
		return self.activeController:GetMoveVector()
	end

	return createVector(0, 0, 0)
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

function class:GetEstimatedVRTorsoFrame()
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

function class.GetActiveController(p)
	return p.activeController
end

function class:UpdateActiveControlModuleEnabled()
	local function fn()
		if self.touchControlFrame and UserInputService.PreferredInput == Enum.PreferredInput.Touch and (self.activeControlModule == ClickToMoveController or self.activeControlModule == TouchThumbstick or self.activeControlModule == DynamicThumbstick) then
			if not self.controllers[TouchJump] then
				self.controllers[TouchJump] = TouchJump.new()
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

	if self.controlsEnabled and (GuiService.TouchControlsEnabled or UserInputService.PreferredInput ~= Enum.PreferredInput.Touch or self.activeControlModule ~= ClickToMoveController and self.activeControlModule ~= TouchThumbstick and self.activeControlModule ~= DynamicThumbstick) then
		fn()
		return
	end

	self.activeController:Enable(false)

	if self.touchJumpController then
		self.touchJumpController:Enable(false)
	end

	if self.moveFunction then
		self.moveFunction(Players.LocalPlayer, createVector(0, 0, 0), true)
	end
end

function class:Enable(flag: boolean?)
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

function class:Disable()
	self:Enable(false)
end

function class:SelectComputerMovementModule()
	if not (UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled) then
		return nil, false
	end

	local v3 = nil
	local devComputerMovementMode = Players.LocalPlayer.DevComputerMovementMode

	if devComputerMovementMode == Enum.DevComputerMovementMode.UserChoice then
		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			v3 = Gamepad
		elseif UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
			v3 = Keyboard
		end

		if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove and v3 == Keyboard then
			v3 = ClickToMoveController
		end
	else
		v3 = v2[devComputerMovementMode]

		if not v3 and devComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable then
			warn("No character control module is associated with DevComputerMovementMode ", devComputerMovementMode)
		end
	end

	if v3 then
		return v3, true
	end

	if devComputerMovementMode == Enum.DevComputerMovementMode.Scriptable then
		return nil, true
	end

	return nil, false
end

function class:SelectTouchModule()
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

local function getGamepadRightThumbstickPosition()
	local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

	for _, v3 in pairs(gamepadState) do
		if v3.KeyCode == Enum.KeyCode.Thumbstick2 then
			return v3.Position
		end
	end

	return createVector(0, 0, 0)
end

function class:calculateRawMoveVector(object2, vector2: Vector3)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return vector2
	end

	local cFrame = currentCamera.CFrame

	if VRService.VREnabled and object2.RootPart then
		VRService:GetUserCFrame(Enum.UserCFrame.Head)
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

		local v3 = -getGamepadRightThumbstickPosition().Y * 1.3962634015954636
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

function class:OnRenderStepped(p)
	if self.activeController and self.activeController.enabled and self.humanoid then
		local moveVector = self.activeController:GetMoveVector()
		local isMoveVectorCameraRelative = self.activeController:IsMoveVectorCameraRelative()
		local clickToMoveController = self:GetClickToMoveController()

		if self.activeController == clickToMoveController then
			clickToMoveController:OnRenderStepped(p)
		elseif moveVector.magnitude > 0 then
			clickToMoveController:CleanupPath()
		else
			clickToMoveController:OnRenderStepped(p)
			moveVector = clickToMoveController:GetMoveVector()
			isMoveVectorCameraRelative = clickToMoveController:IsMoveVectorCameraRelative()
		end

		if self.vehicleController then
			local v3
			moveVector, v3 = self.vehicleController:Update(
				moveVector,
				isMoveVectorCameraRelative,
				self.activeControlModule == Gamepad
			)
		end

		if isMoveVectorCameraRelative then
			moveVector = self:calculateRawMoveVector(self.humanoid, moveVector)
		end

		self.inputMoveVector = moveVector

		if VRService.VREnabled then
			moveVector = self:updateVRMoveVector(moveVector)
		end

		self.moveFunction(Players.LocalPlayer, moveVector, false)
		self.humanoid.Jump = self.activeController:GetIsJumping() or self.touchJumpController and self.touchJumpController:GetIsJumping()
	end
end

function class:updateVRMoveVector(p2)
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

function class:OnHumanoidSeated(flag: boolean, vehicleSeat)
	if flag then
		if vehicleSeat and vehicleSeat:IsA("VehicleSeat") then
			if not self.vehicleController then
				self.vehicleController = self.vehicleController.new(value)
			end

			self.vehicleController:Enable(true, vehicleSeat)
		end
	elseif self.vehicleController then
		self.vehicleController:Enable(false, vehicleSeat)
	end
end

function class:OnCharacterAdded(instance)
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

function class:OnCharacterRemoving(_)
	self.humanoid = nil
	self:UpdateMovementMode()
end

function class:UpdateTouchGuiVisibility()
	local v3 = self.humanoid and GuiService.TouchControlsEnabled and UserInputService.PreferredInput == Enum.PreferredInput.Touch

	if v3 and not self.touchGui then
		self:CreateTouchGuiContainer()
	end

	if self.touchGui then
		self.touchGui.Enabled = v3 and true or false
	end
end

function class:SwitchToController(activeControlModule)
	if activeControlModule then
		if not self.controllers[activeControlModule] then
			self.controllers[activeControlModule] = activeControlModule.new(value)
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

function class:UpdateMovementMode()
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

function class:CreateTouchGuiContainer()
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

	if v then
		self.touchGui.ClipToDeviceSafeArea = false
	end

	self.touchControlFrame = Instance.new("Frame")
	self.touchControlFrame.Name = "TouchControlFrame"
	self.touchControlFrame.Size = UDim2.new(1, 0, 1, 0)
	self.touchControlFrame.BackgroundTransparency = 1
	self.touchControlFrame.Parent = self.touchGui
	self.touchGui.Parent = self.playerGui
end

function class:GetClickToMoveController()
	if not self.controllers[ClickToMoveController] then
		self.controllers[ClickToMoveController] = ClickToMoveController.new(value)
	end

	return self.controllers[ClickToMoveController]
end

return class.new()