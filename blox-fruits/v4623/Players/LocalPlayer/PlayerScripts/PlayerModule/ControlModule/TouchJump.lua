local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

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

		if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and self.externallyEnabled and self.externallyEnabled then
			self.jumpButton.Visible = true
		end
	else
		self.jumpButton.Visible = false
		self.isJumping = false
		self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
	end
end

function object:UpdateEnabled()
	if self.jumpStateEnabled then
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

	local v = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y) <= 500
	local v2 = v and 70 or 120
	self.jumpButton = Instance.new("ImageButton")
	self.jumpButton.Name = "JumpButton"
	self.jumpButton.Visible = false
	self.jumpButton.BackgroundTransparency = 1
	self.jumpButton.Image = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"
	self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
	self.jumpButton.ImageRectSize = Vector2.new(144, 144)
	self.jumpButton.Size = UDim2.new(0, v2, 0, v2)
	self.jumpButton.Position = v and UDim2.new(1, -(v2 * 1.5 - 10), 1, -v2 - 20) or UDim2.new(
		1,
		-(v2 * 1.5 - 10),
		1,
		-v2 * 1.75
	)
	local v3 = nil
	self.jumpButton.InputBegan:connect(function(p)
		if v3 or p.UserInputType ~= Enum.UserInputType.Touch or p.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		v3 = p
		self.jumpButton.ImageRectOffset = Vector2.new(146, 146)
		self.isJumping = true
	end)
	self.jumpButton.InputEnded:connect(function(p)
		if p == v3 then
			v3 = nil
			self.isJumping = false
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		end
	end)
	GuiService.MenuOpened:connect(function()
		if v3 then
			v3 = nil
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