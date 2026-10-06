local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local vehicleGui = script:WaitForChild("VehicleGui")
local localPlayer = Players.LocalPlayer
local value = script.Parent:WaitForChild("ScriptsReference").Value
local playerModule = localPlayer.PlayerScripts:WaitForChild("PlayerModule")
local ControlModule = require(playerModule:WaitForChild("ControlModule"))
local Keymap = require(value.Keymap)
local InputImageLibrary = require(value.InputImageLibrary)
local LocalVehicleGui = {}
LocalVehicleGui.__index = LocalVehicleGui

function LocalVehicleGui.new(car, _)
	local object = setmetatable({}, LocalVehicleGui)
	object.connections = {}
	object.car = car
	object.localSeatModule = require(value.LocalVehicleSeating)
	object.chassis = car:WaitForChild("Chassis")
	object.seat = object.chassis:WaitForChild("VehicleSeat")
	object.gui = vehicleGui:Clone()
	object.gui.Name = "ActiveGui"
	object.gui.Parent = script
	object.touchFrame = object.gui:WaitForChild("TouchControlFrame")
	object.accelButton = object.touchFrame:WaitForChild("AccelerateButton")
	object.brakeButton = object.touchFrame:WaitForChild("BrakeButton")
	object.exitButton = object.touchFrame:WaitForChild("ExitButton")
	object.speedoFrame = object.gui:WaitForChild("SpeedoFrame")
	object.speedoFrameOff = object.speedoFrame:WaitForChild("OffFrame")
	object.speedoOff = object.speedoFrameOff:WaitForChild("Speedo")
	object.speedoFrameOn = object.speedoFrame:WaitForChild("OnFrame")
	object.speedoOn = object.speedoFrameOn:WaitForChild("Speedo")
	object.speedText = object.speedoFrame:WaitForChild("SpeedText")
	object.unitText = object.speedoFrame:WaitForChild("UnitText")
	return object
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getLocalHumanoid()
	if localPlayer.Character then
		return localPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

local jumpPower = 50
local v = false

-- equivalent calls inferred from this helper; original call sites unknown
local function enableJumpButton()
	local localHumanoid = getLocalHumanoid() -- equivalent call inferred; original call site unknown

	if v and localHumanoid then
		localHumanoid.JumpPower = jumpPower
		v = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disableJumpButton()
	local localHumanoid = getLocalHumanoid() -- equivalent call inferred; original call site unknown

	if localHumanoid then
		jumpPower = localHumanoid.JumpPower
		localHumanoid.JumpPower = 0
		v = true
	end
end

function LocalVehicleGui:Enable()
	self.gui.Enabled = true
	self:EnableKeyboardUI()
	self:ConfigureButtons()

	local function UpdateInputType(lastInputType)
		if lastInputType == Enum.UserInputType.Touch then
			self:EnableTouchUI()
			self:ConfigureButtons()
		elseif lastInputType.Value >= Enum.UserInputType.Gamepad1.Value and lastInputType.Value <= Enum.UserInputType.Gamepad8.Value then
			self:EnableGamepadUI()
			self:ConfigureButtons()
		elseif lastInputType == Enum.UserInputType.Keyboard then
			self:EnableKeyboardUI()
			self:ConfigureButtons()
		end
	end

	self.connections[#self.connections + 1] = UserInputService.LastInputTypeChanged:Connect(UpdateInputType)
	UpdateInputType(UserInputService:GetLastInputType())

	function self.OnExit(_)
		self:Destroy()
	end

	self.localSeatModule.OnSeatExitEvent(self.OnExit)
	self.connections[#self.connections + 1] = self.gui.AncestryChanged:Connect(function()
		if not self.gui:IsDescendantOf(game) then
			self:Destroy()
		end
	end)
	self.connections[#self.connections + 1] = self.chassis.AncestryChanged:Connect(function()
		if not self.chassis:IsDescendantOf(Workspace) then
			self:Destroy()
		end
	end)
	self.connections[#self.connections + 1] = self.exitButton.Activated:Connect(function()
		enableJumpButton() -- equivalent call inferred; original call site unknown
		self:Destroy()
		self.localSeatModule.ExitSeat()
	end)
	self.connections[#self.connections + 1] = self.exitButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self.exitButton.ImageTransparency = 1
			self.exitButton.Pressed.ImageTransparency = 0
		end
	end)
	self.connections[#self.connections + 1] = self.exitButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self.exitButton.ImageTransparency = 0
			self.exitButton.Pressed.ImageTransparency = 1
		end
	end)
	self.connections[#self.connections + 1] = RunService.RenderStepped:Connect(function()
		local v2 = self.seat.Velocity.Magnitude * 0.6263
		local v3 = math.min(v2 / 130, 1)
		local v4 = math.floor(self.speedoFrame.AbsoluteSize.X * v3 + 0.5)
		self.speedoFrameOn.Size = UDim2.new(0, v4, 1, 0)
		self.speedText.Text = tostring((math.floor(v2 + 0.5)))

		if self.touchEnabled then
			self.steeringInput = -ControlModule:GetMoveVector().X
		end
	end)
end

function LocalVehicleGui:Destroy()
	self.localSeatModule.DisconnectFromSeatExitEvent(self.OnExit)

	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end

	if self.gui then
		self.gui:Destroy()
	end

	enableJumpButton() -- equivalent call inferred; original call site unknown
end

function LocalVehicleGui:ConfigureButtons()
	self.accelButton.Image = "rbxassetid://2847847852"
	self.accelButton.Pressed.Image = "rbxassetid://2847847961"
	self.accelButton.Size = UDim2.new(0, 70, 0, 70)
	self.accelButton.AnchorPoint = Vector2.new(1, 1)
	self.accelButton.Position = UDim2.new(1, -24, 1, -20)
	self.brakeButton.Size = UDim2.new(0, 44, 0, 44)
	self.brakeButton.AnchorPoint = Vector2.new(1, 1)
	self.brakeButton.Position = UDim2.new(1, -(24 + self.accelButton.Size.X.Offset + 20), 1, -20)
	self.brakeButton.Image = "rbxassetid://2847848304"
	self.brakeButton.Pressed.Image = "rbxassetid://2847848400"
	self.exitButton.Image = "rbxassetid://2847857948"
	self.exitButton.Pressed.Image = "rbxassetid://2847858038"
	self.exitButton.KeyImage.ImageRectSize = Vector2.new(0, 0)
	self.exitButton.KeyImage.ImageRectOffset = Vector2.new(0, 0)
	self.exitButton.KeyImage.ButtonText.Visible = false
	local lastInputType = UserInputService:GetLastInputType()

	if lastInputType == Enum.UserInputType.Touch then
		self.exitButton.Size = UDim2.new(0, 44, 0, 44)
		self.exitButton.AnchorPoint = Vector2.new(1, 1)
		self.exitButton.Position = UDim2.new(1, -24, 1, -(20 + self.accelButton.Size.Y.Offset + 20))
		self.exitButton.KeyImage.Image = ""
	else
		self.exitButton.Size = UDim2.new(0, 72, 0, 72)
		self.exitButton.AnchorPoint = Vector2.new(1, 1)
		self.exitButton.Position = UDim2.new(1, -24, 1, -(20 + self.accelButton.Size.Y.Offset + 20))

		if lastInputType.Value >= Enum.UserInputType.Gamepad1.Value and lastInputType.Value <= Enum.UserInputType.Gamepad8.Value then
			local imageLabel = InputImageLibrary:GetImageLabel(Keymap.EnterVehicleGamepad, "Light")
			self.exitButton.KeyImage.Image = imageLabel.Image
			self.exitButton.KeyImage.ImageRectOffset = imageLabel.ImageRectOffset
			self.exitButton.KeyImage.ImageRectSize = imageLabel.ImageRectSize
		else
			self.exitButton.KeyImage.Image = "rbxassetid://2935912536"
			self.exitButton.KeyImage.ButtonText.Visible = true
			self.exitButton.KeyImage.ButtonText.Text = Keymap.EnterVehicleKeyboard.Name
		end
	end
end

function LocalVehicleGui:EnableDriverControls()
	self.driverControlsEnabled = true

	if self.touchEnabled then
		self:DisplayTouchDriveControls()
	end
end

function LocalVehicleGui.EnableSpeedo(p)
	p.speedoFrame.Visible = true
end

function LocalVehicleGui.DisableSpeedo(p)
	p.speedoFrame.Visible = false
end

function LocalVehicleGui:DisplayTouchDriveControls()
	self.brakeButton.Visible = true
	self.accelButton.Visible = true
	local flag = false
	local flag2 = false
	local flag3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ProcessTouchThrottle()
		if flag and flag2 or not (flag or flag2) then
			self.throttleInput = 0
		elseif flag then
			self.throttleInput = 1
		elseif flag2 then
			self.throttleInput = -1
		end

		if flag3 then
			self.handBrakeInput = 1
		else
			self.handBrakeInput = 0
		end
	end

	self.accelButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			flag = true
			self.accelButton.ImageTransparency = 1
			self.accelButton.Pressed.ImageTransparency = 0
			ProcessTouchThrottle() -- equivalent call inferred; original call site unknown
		end
	end)
	self.accelButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			flag = false
			self.accelButton.ImageTransparency = 0
			self.accelButton.Pressed.ImageTransparency = 1
			ProcessTouchThrottle() -- equivalent call inferred; original call site unknown
		end
	end)
	local now = 0
	local now2 = 0
	self.brakeButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			if tick() - now <= 0.3 then
				flag3 = true
			else
				now2 = tick()
				flag2 = true
			end

			self.brakeButton.ImageTransparency = 1
			self.brakeButton.Pressed.ImageTransparency = 0
			ProcessTouchThrottle() -- equivalent call inferred; original call site unknown
		end
	end)
	self.brakeButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			if not flag3 and tick() - now2 <= 0.2 then
				now = tick()
			end

			now2 = 0
			flag3 = false
			flag2 = false
			self.brakeButton.ImageTransparency = 0
			self.brakeButton.Pressed.ImageTransparency = 1
			ProcessTouchThrottle() -- equivalent call inferred; original call site unknown
		end
	end)
end

function LocalVehicleGui:EnableTouchControls()
	if self.touchEnabled then
		return
	end

	self.touchEnabled = true
	disableJumpButton() -- equivalent call inferred; original call site unknown
	self:ConfigureButtons()

	if self.driverControlsEnabled then
		self:DisplayTouchDriveControls()
	end
end

function LocalVehicleGui:DisableTouchControls()
	if not self.touchEnabled then
		return
	end

	self.touchEnabled = false
	enableJumpButton() -- equivalent call inferred; original call site unknown
	self.brakeButton.Visible = false
	self.accelButton.Visible = false
end

function LocalVehicleGui:EnableKeyboardUI()
	self.speedoFrame.Size = UDim2.new(0, 400, 0, 90)
	self.speedoOn.Size = self.speedoFrame.Size
	self.speedoOff.Size = self.speedoFrame.Size
	self.speedoFrame.Position = UDim2.new(0.5, 0, 1, -40)
	self.speedoOn.Image = "rbxassetid://2848312414"
	self.speedoOff.Image = "rbxassetid://2848312878"
	self.speedText.TextSize = 40
	self.speedText.Size = UDim2.new(0, 60, 0, 40)
	self.speedText.Position = UDim2.new(0, 215, 0, 94)
	self.unitText.TextSize = 20
	self.unitText.Size = UDim2.new(0, 30, 0, 20)
	self.unitText.Position = UDim2.new(0, 225, 0, 90)
	self:DisableTouchControls()
end

function LocalVehicleGui:EnableTouchUI()
	self.speedoFrame.Size = UDim2.new(0, 240, 0, 54)
	self.speedoOn.Size = self.speedoFrame.Size
	self.speedoOff.Size = self.speedoFrame.Size
	self.speedoFrame.Position = UDim2.new(0.5, 0, 1, -20)
	self.speedoOn.Image = "rbxassetid://2847843718"
	self.speedoOff.Image = "rbxassetid://2847843839"
	self.speedText.TextSize = 24
	self.speedText.Size = UDim2.new(0, 36, 0, 24)
	self.speedText.Position = UDim2.new(0, 120, 0, 54)
	self.unitText.TextSize = 12
	self.unitText.Size = UDim2.new(0, 18, 0, 12)
	self.unitText.Position = UDim2.new(0, 125, 0, 54)
	self:EnableTouchControls()
end

function LocalVehicleGui:EnableGamepadUI()
	self.speedoFrame.Size = UDim2.new(0, 600, 0, 135)
	self.speedoOn.Size = self.speedoFrame.Size
	self.speedoOff.Size = self.speedoFrame.Size
	self.speedoFrame.Position = UDim2.new(0.5, 0, 1, -40)
	self.speedoOn.Image = "rbxassetid://2836208803"
	self.speedoOff.Image = "rbxassetid://2836208488"
	self.speedText.TextSize = 60
	self.speedText.Size = UDim2.new(0, 90, 0, 60)
	self.speedText.Position = UDim2.new(0, 315, 0, 140)
	self.unitText.TextSize = 30
	self.unitText.Size = UDim2.new(0, 45, 0, 30)
	self.unitText.Position = UDim2.new(0, 325, 0, 135)
	self:DisableTouchControls()
end

return LocalVehicleGui