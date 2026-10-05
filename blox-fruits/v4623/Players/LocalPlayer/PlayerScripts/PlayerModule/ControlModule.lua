local createVector = vector.create
local class = {}
class.__index = class
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local Keyboard = require(script:WaitForChild("Keyboard"))
local Gamepad = require(script:WaitForChild("Gamepad"))
local _, _ = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserTheMovementModeInquisition")
end)
local _, _ = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserMakeThumbstickDynamic")
end)
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserSiblingTouchGui")
end)
local v = success and result
local TouchDPad = require(script:WaitForChild("TouchDPad"))
local TouchThumbpad = require(script:WaitForChild("TouchThumbpad"))
local TouchThumbstick = require(script:WaitForChild("TouchThumbstick"))
local ClickToMoveController = require(script:WaitForChild("ClickToMoveController"))
local TouchJump = require(script:WaitForChild("TouchJump"))
local VehicleController = require(script:WaitForChild("VehicleController"))
local value = Enum.ContextActionPriority.Default.Value
local v2 = {
	[Enum.TouchMovementMode.DPad] = TouchDPad,
	[Enum.DevTouchMovementMode.DPad] = TouchDPad,
	[Enum.TouchMovementMode.Thumbpad] = TouchThumbpad,
	[Enum.DevTouchMovementMode.Thumbpad] = TouchThumbpad,
	[Enum.TouchMovementMode.Thumbstick] = TouchThumbstick,
	[Enum.DevTouchMovementMode.Thumbstick] = TouchThumbstick,
	[Enum.TouchMovementMode.DynamicThumbstick] = false,
	[Enum.DevTouchMovementMode.DynamicThumbstick] = false,
	[Enum.TouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevTouchMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.TouchMovementMode.Default] = false,
	[Enum.ComputerMovementMode.Default] = Keyboard,
	[Enum.ComputerMovementMode.KeyboardMouse] = Keyboard,
	[Enum.DevComputerMovementMode.KeyboardMouse] = Keyboard,
	[Enum.DevComputerMovementMode.Scriptable] = nil,
	[Enum.ComputerMovementMode.ClickToMove] = ClickToMoveController,
	[Enum.DevComputerMovementMode.ClickToMove] = ClickToMoveController
}
local v3 = {
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

function class.new()
	local object = setmetatable({}, class)
	object.controllers = {}
	object.activeControlModule = nil
	object.activeController = nil
	object.touchJumpController = nil
	object.moveFunction = Players.LocalPlayer.Move
	object.humanoid = nil
	object.lastInputType = Enum.UserInputType.None
	object.humanoidSeatedConn = nil
	object.vehicleController = nil
	object.touchControlFrame = nil
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
	local _ = {
		UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
			object:OnTouchMovementModeChange()
		end),
		Players.LocalPlayer:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
			object:OnTouchMovementModeChange()
		end),
		UserGameSettings:GetPropertyChangedSignal("ComputerMovementMode"):Connect(function()
			object:OnComputerMovementModeChange()
		end),
		Players.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
			object:OnComputerMovementModeChange()
		end)
	}
	object.playerGui = nil
	object.touchGui = nil
	object.playerGuiAddedConn = nil

	if not UserInputService.TouchEnabled then
		object:OnLastInputTypeChanged(UserInputService:GetLastInputType())
		return object
	end

	local function setup()
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
			return
		end

		object:CreateTouchGuiContainer()
		object:OnLastInputTypeChanged(UserInputService:GetLastInputType())
	end

	if RunService:IsStudio() then
		task.delay(2, setup)
		return object
	end

	setup()
	return object
end

function class:GetMoveVector()
	if self.activeController then
		return self.activeController:GetMoveVector()
	end

	return createVector(0, 0, 0)
end

function class.GetActiveController(p)
	return p.activeController
end

function class:EnableActiveControlModule()
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

function class:Enable(p)
	if not self.activeController then
		return
	end

	if p == nil or p then
		self:EnableActiveControlModule()
	else
		self:Disable()
	end
end

function class:Disable()
	if self.activeController then
		self.activeController:Enable(false)

		if self.moveFunction then
			self.moveFunction(Players.LocalPlayer, createVector(0, 0, 0), true)
		end
	end
end

function class:SelectComputerMovementModule()
	if not (UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled) then
		return nil, false
	end

	local devComputerMovementMode = Players.LocalPlayer.DevComputerMovementMode
	local v4

	if devComputerMovementMode == Enum.DevComputerMovementMode.UserChoice then
		v4 = v3[lastInputType]

		if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove and v4 == Keyboard then
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

function class:SelectTouchModule()
	if not UserInputService.TouchEnabled then
		return nil, false
	end

	local devTouchMovementMode = Players.LocalPlayer.DevTouchMovementMode
	local v4

	if devTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		v4 = v2[UserGameSettings.TouchMovementMode]
		return v4, true
	end

	if devTouchMovementMode == Enum.DevTouchMovementMode.Scriptable then
		return nil, true
	end

	v4 = v2[devTouchMovementMode]
	return v4, true
end

local function calculateRawMoveVector(humanoid, moveVector)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return moveVector
	end

	if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		return currentCamera.CFrame:VectorToWorldSpace(moveVector)
	end

	local _, _, _, v4, v5, v6, _, _, v7, _, _, v8 = currentCamera.CFrame:GetComponents()

	if v7 < 1 and v7 > -1 then
		v4 = v8
	else
		v6 = -v5 * math.sign(v7)
	end

	local v9 = math.sqrt(v4 * v4 + v6 * v6)
	return (Vector3.new((v4 * moveVector.x + v6 * moveVector.z) / v9, 0, (v4 * moveVector.z - v6 * moveVector.x) / v9))
end

function class:OnRenderStepped(p)
	if self.activeController and self.activeController.enabled and self.humanoid then
		self.activeController:OnRenderStepped(p)
		local moveVector = self.activeController:GetMoveVector()
		local isMoveVectorCameraRelative = self.activeController:IsMoveVectorCameraRelative()
		local clickToMoveController = self:GetClickToMoveController()

		if self.activeController ~= clickToMoveController then
			if moveVector.magnitude > 0 then
				clickToMoveController:CleanupPath()
			else
				clickToMoveController:OnRenderStepped(p)
				moveVector = clickToMoveController:GetMoveVector()
				isMoveVectorCameraRelative = clickToMoveController:IsMoveVectorCameraRelative()
			end
		end

		if self.vehicleController then
			local v4
			moveVector, v4 = self.vehicleController:Update(
				moveVector,
				isMoveVectorCameraRelative,
				self.activeControlModule == Gamepad
			)
		end

		if isMoveVectorCameraRelative then
			moveVector = calculateRawMoveVector(self.humanoid, moveVector)
		end

		self.moveFunction(Players.LocalPlayer, moveVector, false)
		self.humanoid.Jump = self.activeController:GetIsJumping() or self.touchJumpController and self.touchJumpController:GetIsJumping()
	end
end

function class:OnHumanoidSeated(p2, vehicleSeat)
	if p2 then
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

	if self.touchGui then
		self.touchGui.Enabled = true
	end

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

	if self.touchGui then
		self.touchGui.Enabled = false
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

			if self.touchControlFrame and (self.activeControlModule == TouchThumbpad or self.activeControlModule == TouchThumbstick or self.activeControlModule == ClickToMoveController or self.activeControlModule == false) then
				if not self.controllers[TouchJump] then
					self.controllers[TouchJump] = TouchJump.new()
				end

				self.touchJumpController = self.controllers[TouchJump]
				self.touchJumpController:Enable(true, self.touchControlFrame)
			elseif self.touchJumpController then
				self.touchJumpController:Enable(false)
			end

			self:EnableActiveControlModule()
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
	if lastInputType == p then
		warn("LastInputType Change listener called with current type.")
	end

	lastInputType = p

	if lastInputType == Enum.UserInputType.Touch then
		local touchModule, v4 = self:SelectTouchModule()

		if v4 then
			while not self.touchControlFrame do
				task.wait()
			end

			self:SwitchToController(touchModule)
		end
	else
		local v4 = v3[lastInputType] ~= nil and self:SelectComputerMovementModule()

		if v4 then
			self:SwitchToController(v4)
		end
	end
end

function class:OnComputerMovementModeChange()
	local computerMovementModule, v4 = self:SelectComputerMovementModule()

	if v4 then
		self:SwitchToController(computerMovementModule)
	end
end

function class:OnTouchMovementModeChange()
	local touchModule, v4 = self:SelectTouchModule()

	if v4 then
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

	if v then
		self.touchGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	end

	self.touchGui.Enabled = self.humanoid ~= nil
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