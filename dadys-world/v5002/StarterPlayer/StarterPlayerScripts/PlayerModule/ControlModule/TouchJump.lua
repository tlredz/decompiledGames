local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixTouchJumpBug2")
end)
local v = success and result

function object.new()
	local self = setmetatable(BaseCharacterController.new(), object)
	self.parentUIFrame = nil
	self.jumpButton = nil
	self.characterAddedConn = nil
	self.humanoidStateEnabledChangedConn = nil
	self.humanoidJumpPowerConn = nil
	self.humanoidParentConn = nil
	self.externallyEnabled = false
	self.jumpPower = 0
	self.jumpStateEnabled = true
	self.isJumping = false
	self.humanoid = nil
	return self
end

function object:EnableButton(p)
	if p then
		if not self.jumpButton then
			self:Create()
		end

		local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

		if humanoid and self.externallyEnabled and self.externallyEnabled and humanoid.JumpPower > 0 then
			self.jumpButton.Visible = true
		end
	else
		self.jumpButton.Visible = false

		if v then
			self.touchObject = nil
		end

		self.isJumping = false
		self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
	end
end

function object:UpdateEnabled()
	if self.jumpPower > 0 and self.jumpStateEnabled then
		self:EnableButton(true)
	else
		self:EnableButton(false)
	end
end

function object:HumanoidChanged(p)
	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		if p == "JumpPower" then
			self.jumpPower = humanoid.JumpPower
			self:UpdateEnabled()
		elseif p == "Parent" and not humanoid.Parent then
			self.humanoidChangeConn:Disconnect()
		end
	end
end

function object:HumanoidStateEnabledChanged(p, jumpStateEnabled)
	if p == Enum.HumanoidStateType.Jumping then
		self.jumpStateEnabled = jumpStateEnabled
		self:UpdateEnabled()
	end
end

function object:CharacterAdded(instance)
	if self.humanoidChangeConn then
		self.humanoidChangeConn:Disconnect()
		self.humanoidChangeConn = nil
	end

	self.humanoid = instance:FindFirstChildOfClass("Humanoid")

	while not self.humanoid do
		instance.ChildAdded:wait()
		self.humanoid = instance:FindFirstChildOfClass("Humanoid")
	end

	self.humanoidJumpPowerConn = self.humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
		self.jumpPower = self.humanoid.JumpPower
		self:UpdateEnabled()
	end)
	self.humanoidParentConn = self.humanoid:GetPropertyChangedSignal("Parent"):Connect(function()
		if not self.humanoid.Parent then
			self.humanoidJumpPowerConn:Disconnect()
			self.humanoidJumpPowerConn = nil
			self.humanoidParentConn:Disconnect()
			self.humanoidParentConn = nil
		end
	end)
	self.humanoidStateEnabledChangedConn = self.humanoid.StateEnabledChanged:Connect(function(p, p2)
		self:HumanoidStateEnabledChanged(p, p2)
	end)
	self.jumpPower = self.humanoid.JumpPower
	self.jumpStateEnabled = self.humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
	self:UpdateEnabled()
end

function object:SetupCharacterAddedFunction()
	self.characterAddedConn = Players.LocalPlayer.CharacterAdded:Connect(function(character)
		self:CharacterAdded(character)
	end)

	if Players.LocalPlayer.Character then
		self:CharacterAdded(Players.LocalPlayer.Character)
	end
end

function object:Enable(externallyEnabled, parentUIFrame)
	if parentUIFrame then
		self.parentUIFrame = parentUIFrame
	end

	self.externallyEnabled = externallyEnabled
	self:EnableButton(externallyEnabled)
end

function object:Create()
	if not self.parentUIFrame then
		return
	end

	if self.jumpButton then
		self.jumpButton:Destroy()
		self.jumpButton = nil
	end

	if self.absoluteSizeChangedConn then
		self.absoluteSizeChangedConn:Disconnect()
		self.absoluteSizeChangedConn = nil
	end

	self.jumpButton = Instance.new("ImageButton")
	self.jumpButton.Name = "JumpButton"
	self.jumpButton.Visible = false
	self.jumpButton.BackgroundTransparency = 1
	self.jumpButton.Image = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"
	self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
	self.jumpButton.ImageRectSize = Vector2.new(144, 144)

	local function ResizeJumpButton()
		local v2 = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y) <= 500
		local v3 = v2 and 70 or 120
		self.jumpButton.Size = UDim2.new(0, v3, 0, v3)
		self.jumpButton.Position = v2 and UDim2.new(1, -(v3 * 1.5 - 10), 1, -v3 - 20) or UDim2.new(
			1,
			-(v3 * 1.5 - 10),
			1,
			-v3 * 1.75
		)
	end

	ResizeJumpButton()
	self.absoluteSizeChangedConn = self.parentUIFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeJumpButton)
	self.touchObject = nil
	self.jumpButton.InputBegan:connect(function(touchObject)
		if self.touchObject or touchObject.UserInputType ~= Enum.UserInputType.Touch or touchObject.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		self.touchObject = touchObject
		self.jumpButton.ImageRectOffset = Vector2.new(146, 146)
		self.isJumping = true
	end)
	self.jumpButton.InputEnded:connect(function(p)
		if p == self.touchObject then
			self.touchObject = nil
			self.isJumping = false
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		end
	end)
	GuiService.MenuOpened:connect(function()
		if self.touchObject then
			self.touchObject = nil
			self.isJumping = false
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		end
	end)

	if not self.characterAddedConn then
		self:SetupCharacterAddedFunction()
	end

	self.jumpButton.Parent = self.parentUIFrame
end

return object