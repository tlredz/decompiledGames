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
local commonUtils = script.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local Keyboard = require(script:WaitForChild("Keyboard"))
local Gamepad = require(script:WaitForChild("Gamepad"))
local DynamicThumbstick = require(script:WaitForChild("DynamicThumbstick"))
local userFlag = FlagUtil.getUserFlag("UserUpdateInputConnections")
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserDynamicThumbstickSafeAreaUpdate")
end)
local v = success and result
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixTouchJumpBug2")
end)
local v2 = success2 and result2
local TouchThumbstick = require(script:WaitForChild("TouchThumbstick"))
local ClickToMoveController = require(script:WaitForChild("ClickToMoveController"))
local TouchJump = require(script:WaitForChild("TouchJump"))
local VehicleController = require(script:WaitForChild("VehicleController"))
local value = Enum.ContextActionPriority.Medium.Value
local v3 = {
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
local v4 = {
	[Enum.UserInputType.Keyboard] = Keyboard,
	[Enum.UserInputType.MouseButton1] = Keyboard,
	[Enum.UserInputType.MouseButton2] = Keyboard,
	[Enum.UserInputType.MouseButton3] = Keyboard,
	[Enum.UserInputType.MouseWheel] = Keyboard,
	[Enum.UserInputType.MouseMovement] = Keyboard,
	[Enum.UserInputType.Gamepad1] = Gamepad,
	[Enum.UserInputType.Gamepad2] = Gamepad,
	[Enum.UserInputType.Gamepad3] = Gamepad,
	[Enum.UserInputType.Gamepad4] = Gamepad
}
local v5 = nil

function class.new()
	local object = setmetatable({}, class)
	object.controllers = {}
	object.activeControlModule = nil
	object.activeController = nil
	object.touchJumpController = nil
	object.moveFunction = Players.LocalPlayer.Move
	object.humanoid = nil
	object.lastInputType = Enum.UserInputType.None
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
	UserInputService.LastInputTypeChanged:Connect(function(p)
		object:OnLastInputTypeChanged(p)
	end)
	UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
		object:OnTouchMovementModeChange()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
		object:OnTouchMovementModeChange()
	end)
	UserGameSettings:GetPropertyChangedSignal("ComputerMovementMode"):Connect(function()
		object:OnComputerMovementModeChange()
	end)
	Players.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
		object:OnComputerMovementModeChange()
	end)
	object.playerGui = nil
	object.touchGui = nil
	object.playerGuiAddedConn = nil
	GuiService:GetPropertyChangedSignal("TouchControlsEnabled"):Connect(function()
		object:UpdateTouchGuiVisibility()
		object:UpdateActiveControlModuleEnabled()
	end)

	if not UserInputService.TouchEnabled then
		object:OnLastInputTypeChanged(UserInputService:GetLastInputType())
		return object
	end

	object.playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not object.playerGui then
		object.playerGuiAddedConn = Players.LocalPlayer.ChildAdded:Connect(function(playerGui)
			if playerGui:IsA("PlayerGui") then
				object.playerGui = playerGui
				object:CreateTouchGuiContainer()
				object.playerGuiAddedConn:Disconnect()
				object.playerGuiAddedConn = nil
				object:OnLastInputTypeChanged(UserInputService:GetLastInputType())
			end
		end)
		return object
	end

	object:CreateTouchGuiContainer()
	object:OnLastInputTypeChanged(UserInputService:GetLastInputType())
	return object
end

function class:GetMoveVector()
	if self.activeController then
		return self.activeController:GetMoveVector()
	end

	return createVector(0, 0, 0)
end

local function NormalizeAngle(p)
	local v6 = (p + 12.566370614359172) % 6.283185307179586

	if v6 > 3.141592653589793 then
		return v6 - 6.283185307179586
	end

	return v6
end

local function AverageAngle(p, p2)
	local v6 = (p2 - p + 12.566370614359172) % 6.283185307179586

	if v6 > 3.141592653589793 then
		v6 -= 6.283185307179586
	end

	local v7 = (p + v6 / 2 + 12.566370614359172) % 6.283185307179586

	if v7 > 3.141592653589793 then
		return v7 - 6.283185307179586
	end

	return v7
end

function class:GetEstimatedVRTorsoFrame()
	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local _, v6, _ = userCFrame:ToEulerAnglesYXZ()
	local currentTorsoAngle = -v6

	if VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) and VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand) then
		local userCFrame2 = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
		local userCFrame3 = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
		local v8 = userCFrame.Position - userCFrame2.Position
		local v9 = userCFrame.Position - userCFrame3.Position
		local v10 = -math.atan2(v8.X, v8.Z)
		local v11 = (-math.atan2(v9.X, v9.Z) - v10 + 12.566370614359172) % 6.283185307179586

		if v11 > 3.141592653589793 then
			v11 -= 6.283185307179586
		end

		local v12 = (v10 + v11 / 2 + 12.566370614359172) % 6.283185307179586

		if v12 > 3.141592653589793 then
			v12 -= 6.283185307179586
		end

		local v13 = (currentTorsoAngle - self.currentTorsoAngle + 12.566370614359172) % 6.283185307179586

		if v13 > 3.141592653589793 then
			v13 -= 6.283185307179586
		end

		local v14 = (v12 - self.currentTorsoAngle + 12.566370614359172) % 6.283185307179586

		if v14 > 3.141592653589793 then
			v14 -= 6.283185307179586
		end

		local v15

		if v14 > -1.5707963267948966 then
			v15 = v14 < 1.5707963267948966
		else
			v15 = false
		end

		if not v15 then
			v14 = v13
		end

		local v16 = math.min(v14, v13)
		local v17 = math.max(v14, v13)
		local v18 = 0

		if v16 > 0 then
			v18 = v16
		elseif v17 < 0 then
			v18 = v17
		end

		self.currentTorsoAngle = v18 + self.currentTorsoAngle
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
		if v2 then
			if self.touchControlFrame and (self.activeControlModule == ClickToMoveController or self.activeControlModule == TouchThumbstick or self.activeControlModule == DynamicThumbstick) then
				if not self.controllers[TouchJump] then
					self.controllers[TouchJump] = TouchJump.new()
				end

				self.touchJumpController = self.controllers[TouchJump]
				self.touchJumpController:Enable(true, self.touchControlFrame)
			elseif self.touchJumpController then
				self.touchJumpController:Enable(false)
			end
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

	if self.controlsEnabled and (GuiService.TouchControlsEnabled or not UserInputService.TouchEnabled or self.activeControlModule ~= ClickToMoveController and self.activeControlModule ~= TouchThumbstick and self.activeControlModule ~= DynamicThumbstick) then
		fn()
		return
	end

	self.activeController:Enable(false)

	if v2 and self.touchJumpController then
		self.touchJumpController:Enable(false)
	end

	if self.moveFunction then
		self.moveFunction(Players.LocalPlayer, createVector(0, 0, 0), true)
	end
end

function class:Enable(flag: boolean?)
	self.controlsEnabled = flag == nil or flag

	if not self.activeController then
		return
	end

	self:UpdateActiveControlModuleEnabled()
end

function class:Disable()
	self.controlsEnabled = false
	self:UpdateActiveControlModuleEnabled()
end

function class:SelectComputerMovementModule()
	if not (UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled) then
		return nil, false
	end

	local devComputerMovementMode = Players.LocalPlayer.DevComputerMovementMode
	local v6

	if devComputerMovementMode == Enum.DevComputerMovementMode.UserChoice then
		v6 = v4[v5]

		if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove and v6 == Keyboard then
			v6 = ClickToMoveController
		end
	else
		v6 = v3[devComputerMovementMode]

		if not v6 and devComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable then
			warn("No character control module is associated with DevComputerMovementMode ", devComputerMovementMode)
		end
	end

	if v6 then
		return v6, true
	end

	if devComputerMovementMode == Enum.DevComputerMovementMode.Scriptable then
		return nil, true
	end

	return nil, false
end

function class:SelectTouchModule()
	if not UserInputService.TouchEnabled then
		return nil, false
	end

	local devTouchMovementMode = Players.LocalPlayer.DevTouchMovementMode
	local v6

	if devTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		v6 = v3[UserGameSettings.TouchMovementMode]
		return v6, true
	end

	if devTouchMovementMode == Enum.DevTouchMovementMode.Scriptable then
		return nil, true
	end

	v6 = v3[devTouchMovementMode]
	return v6, true
end

local function getGamepadRightThumbstickPosition()
	local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

	for _, v6 in pairs(gamepadState) do
		if v6.KeyCode == Enum.KeyCode.Thumbstick2 then
			return v6.Position
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

		local v6 = -getGamepadRightThumbstickPosition().Y * 1.3962634015954636
		local v7 = math.atan2(-vector3.X, -vector3.Z)
		local _, v8, _ = cFrame:ToEulerAnglesYXZ()
		local v9 = v7 + v8
		return CFrame.fromEulerAnglesYXZ(v6, v9, 0).LookVector
	else
		local _, _, _, v6, v7, v8, _, _, v9, _, _, v10 = cFrame:GetComponents()

		if v9 < 1 and v9 > -1 then
			v6 = v10
		else
			v8 = -v7 * math.sign(v9)
		end

		local v11 = math.sqrt(v6 * v6 + v8 * v8)
		return (Vector3.new((v6 * vector2.X + v8 * vector2.Z) / v11, 0, (v6 * vector2.Z - v8 * vector2.X) / v11))
	end
end

function class:OnRenderStepped(p)
	if self.activeController and self.activeController.enabled and self.humanoid then
		if not userFlag then
			self.activeController:OnRenderStepped(p)
		end

		local moveVector = self.activeController:GetMoveVector()
		local isMoveVectorCameraRelative = self.activeController:IsMoveVectorCameraRelative()
		local clickToMoveController = self:GetClickToMoveController()

		if self.activeController == clickToMoveController then
			if userFlag then
				clickToMoveController:OnRenderStepped(p)
			end
		elseif moveVector.magnitude > 0 then
			clickToMoveController:CleanupPath()
		else
			clickToMoveController:OnRenderStepped(p)
			moveVector = clickToMoveController:GetMoveVector()
			isMoveVectorCameraRelative = clickToMoveController:IsMoveVectorCameraRelative()
		end

		if self.vehicleController then
			local v6
			moveVector, v6 = self.vehicleController:Update(
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
	local v6 = (currentCamera.Focus.Position - currentCamera.CFrame.Position).Magnitude < 5

	if p2.Magnitude ~= 0 or not v6 or not VRService.AvatarGestures or not self.humanoid or self.humanoid.Sit then
		return p2
	end

	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local v7 = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale
	local v8 = -0.7 * self.humanoid.RootPart.Size.Y / 2
	local v9 = (currentCamera.CFrame * v7 * CFrame.new(0, v8, 0)).Position - self.humanoid.RootPart.CFrame.Position
	return (Vector3.new(v9.x, 0, v9.z))
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

	self:UpdateTouchGuiVisibility()

	if self.humanoidSeatedConn then
		self.humanoidSeatedConn:Disconnect()
		self.humanoidSeatedConn = nil
	end

	self.humanoidSeatedConn = self.humanoid.Seated:Connect(function(p, p2)
		self:OnHumanoidSeated(p, p2)
	end)
end

function class:OnCharacterRemoving(_)
	self.humanoid = nil
	self:UpdateTouchGuiVisibility()
end

function class:UpdateTouchGuiVisibility()
	if self.touchGui then
		local touchControlsEnabled = self.humanoid and GuiService.TouchControlsEnabled
		self.touchGui.Enabled = touchControlsEnabled and true or false
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

			if not v2 then
				if self.touchControlFrame and (self.activeControlModule == ClickToMoveController or self.activeControlModule == TouchThumbstick or self.activeControlModule == DynamicThumbstick) then
					if not self.controllers[TouchJump] then
						self.controllers[TouchJump] = TouchJump.new()
					end

					self.touchJumpController = self.controllers[TouchJump]
					self.touchJumpController:Enable(true, self.touchControlFrame)
				elseif self.touchJumpController then
					self.touchJumpController:Enable(false)
				end
			end

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

function class:OnLastInputTypeChanged(p)
	if v5 == p then
		warn("LastInputType Change listener called with current type.")
	end

	v5 = p

	if v5 == Enum.UserInputType.Touch then
		local touchModule, v6 = self:SelectTouchModule()

		if v6 then
			while not self.touchControlFrame do
				wait()
			end

			self:SwitchToController(touchModule)
		end
	elseif v4[v5] ~= nil then
		local computerMovementModule = self:SelectComputerMovementModule()

		if computerMovementModule then
			self:SwitchToController(computerMovementModule)
		end
	end

	self:UpdateTouchGuiVisibility()
end

function class:OnComputerMovementModeChange()
	local computerMovementModule, v6 = self:SelectComputerMovementModule()

	if v6 then
		self:SwitchToController(computerMovementModule)
	end
end

function class:OnTouchMovementModeChange()
	local touchModule, v6 = self:SelectTouchModule()

	if v6 then
		while not self.touchControlFrame do
			wait()
		end

		self:SwitchToController(touchModule)
	end
end

function class:CreateTouchGuiContainer()
	if self.touchGui then
		self.touchGui:Destroy()
	end

	self.touchGui = Instance.new("ScreenGui")
	self.touchGui.Name = "TouchGui"
	self.touchGui.ResetOnSpawn = false
	self.touchGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self:UpdateTouchGuiVisibility()

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