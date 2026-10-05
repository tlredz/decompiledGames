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
local Keyboard = require(script:WaitForChild("Keyboard"))
local Gamepad = require(script:WaitForChild("Gamepad"))
local DynamicThumbstick = require(script:WaitForChild("DynamicThumbstick"))
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserHideControlsWhenMenuOpen")
end)
local v = success and result
local TouchThumbstick = require(script:WaitForChild("TouchThumbstick"))
local ClickToMoveController = require(script:WaitForChild("ClickToMoveController"))
local TouchJump = require(script:WaitForChild("TouchJump"))
local VehicleController = require(script:WaitForChild("VehicleController"))
local value = Enum.ContextActionPriority.Default.Value
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
local v4 = nil

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

	if v then
		GuiService.MenuOpened:Connect(function()
			if object.touchControlFrame and object.touchControlFrame.Visible then
				object.touchControlFrame.Visible = false
			end
		end)
		GuiService.MenuClosed:Connect(function()
			if object.touchControlFrame then
				object.touchControlFrame.Visible = true
			end
		end)
	end

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

function class.GetActiveController(p)
	return p.activeController
end

function class:UpdateActiveControlModuleEnabled()
	local function fn()
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
	local v5

	if devComputerMovementMode == Enum.DevComputerMovementMode.UserChoice then
		v5 = v3[v4]

		if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove and v5 == Keyboard then
			v5 = ClickToMoveController
		end
	else
		v5 = v2[devComputerMovementMode]

		if not v5 and devComputerMovementMode ~= Enum.DevComputerMovementMode.Scriptable then
			warn("No character control module is associated with DevComputerMovementMode ", devComputerMovementMode)
		end
	end

	if v5 then
		return v5, true
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
	local v5

	if devTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		v5 = v2[UserGameSettings.TouchMovementMode]
		return v5, true
	end

	if devTouchMovementMode == Enum.DevTouchMovementMode.Scriptable then
		return nil, true
	end

	v5 = v2[devTouchMovementMode]
	return v5, true
end

local function calculateRawMoveVector(humanoid, moveVector: Vector3)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return moveVector
	end

	if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		return currentCamera.CFrame:VectorToWorldSpace(moveVector)
	end

	local cFrame = currentCamera.CFrame

	if VRService.VREnabled and humanoid.RootPart and (humanoid.RootPart.CFrame.Position - cFrame.Position).Magnitude < 3 then
		cFrame *= VRService:GetUserCFrame(Enum.UserCFrame.Head)
	end

	local _, _, _, v5, v6, v7, _, _, v8, _, _, v9 = cFrame:GetComponents()

	if v8 < 1 and v8 > -1 then
		v5 = v9
	else
		v7 = -v6 * math.sign(v8)
	end

	local v10 = math.sqrt(v5 * v5 + v7 * v7)
	return (Vector3.new((v5 * moveVector.X + v7 * moveVector.Z) / v10, 0, (v5 * moveVector.Z - v7 * moveVector.X) / v10))
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
			local v5
			moveVector, v5 = self.vehicleController:Update(
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

			if self.touchControlFrame and (self.activeControlModule == ClickToMoveController or self.activeControlModule == TouchThumbstick or self.activeControlModule == DynamicThumbstick) then
				if not self.controllers[TouchJump] then
					self.controllers[TouchJump] = TouchJump.new()
				end

				self.touchJumpController = self.controllers[TouchJump]
				self.touchJumpController:Enable(true, self.touchControlFrame)
			elseif self.touchJumpController then
				self.touchJumpController:Enable(false)
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
	if v4 == p then
		warn("LastInputType Change listener called with current type.")
	end

	v4 = p

	if v4 == Enum.UserInputType.Touch then
		local touchModule, v5 = self:SelectTouchModule()

		if v5 then
			while not self.touchControlFrame do
				wait()
			end

			self:SwitchToController(touchModule)
		end
	elseif v3[v4] ~= nil then
		local computerMovementModule = self:SelectComputerMovementModule()

		if computerMovementModule then
			self:SwitchToController(computerMovementModule)
		end
	end

	self:UpdateTouchGuiVisibility()
end

function class:OnComputerMovementModeChange()
	local computerMovementModule, v5 = self:SelectComputerMovementModule()

	if v5 then
		self:SwitchToController(computerMovementModule)
	end
end

function class:OnTouchMovementModeChange()
	local touchModule, v5 = self:SelectTouchModule()

	if v5 then
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