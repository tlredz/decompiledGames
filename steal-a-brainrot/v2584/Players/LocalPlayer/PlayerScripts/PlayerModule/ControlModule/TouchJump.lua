game:GetService("Players")
local GuiService = game:GetService("GuiService")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local ConnectionUtil = require(commonUtils:WaitForChild("ConnectionUtil"))
local CharacterUtil = require(commonUtils:WaitForChild("CharacterUtil"))
local _ = {
	HUMANOID_STATE_ENABLED_CHANGED = "HUMANOID_STATE_ENABLED_CHANGED",
	HUMANOID_JUMP_POWER = "HUMANOID_JUMP_POWER",
	HUMANOID = "HUMANOID",
	JUMP_INPUT_ENDED = "JUMP_INPUT_ENDED",
	MENU_OPENED = "MENU_OPENED"
}
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

function object.new()
	local self = setmetatable(BaseCharacterController.new(), object)
	self.parentUIFrame = nil
	self.jumpButton = nil
	self.externallyEnabled = false
	self.isJumping = false
	self._active = false
	self._connectionUtil = ConnectionUtil.new()
	return self
end

function object:_reset()
	self.isJumping = false
	self.touchObject = nil

	if self.jumpButton then
		self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
	end
end

function object:EnableButton(active)
	if active == self._active then
		self:_reset()
		return
	end

	if active then
		if not self.jumpButton then
			self:Create()
		end

		self.jumpButton.Visible = true
		self._connectionUtil:trackConnection("JUMP_INPUT_ENDED", self.jumpButton.InputEnded:Connect(function(input)
			if input == self.touchObject then
				self:_reset()
			end
		end))
		self._connectionUtil:trackConnection("MENU_OPENED", GuiService.MenuOpened:Connect(function()
			if self.touchObject then
				self:_reset()
			end
		end))
	else
		if self.jumpButton then
			self.jumpButton.Visible = false
		end

		self._connectionUtil:disconnect("JUMP_INPUT_ENDED")
		self._connectionUtil:disconnect("MENU_OPENED")
	end

	self:_reset()
	self._active = active
end

function object:UpdateEnabled()
	local child = CharacterUtil.getChild("Humanoid", "Humanoid")

	if child and self.externallyEnabled and child.JumpPower > 0 and child:GetStateEnabled(Enum.HumanoidStateType.Jumping) then
		self:EnableButton(true)
	else
		self:EnableButton(false)
	end
end

function object:_setupConfigurations()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self:UpdateEnabled()
	end

	local v = CharacterUtil.onChild("Humanoid", "Humanoid", function(instance)
		update() -- equivalent call inferred; original call site unknown
		self._connectionUtil:trackConnection(
			"HUMANOID_JUMP_POWER",
			instance:GetPropertyChangedSignal("JumpPower"):Connect(update)
		)
		self._connectionUtil:trackConnection(
			"HUMANOID_STATE_ENABLED_CHANGED",
			instance.StateEnabledChanged:Connect(function(p, p2)
				if p == Enum.HumanoidStateType.Jumping and p2 ~= self._active then
					update() -- equivalent call inferred; original call site unknown
				end
			end)
		)
	end)
	self._connectionUtil:trackConnection("HUMANOID", v)
end

function object:Enable(externallyEnabled, parentUIFrame)
	if parentUIFrame then
		self.parentUIFrame = parentUIFrame
	end

	if self.externallyEnabled == externallyEnabled then
		return
	end

	self.externallyEnabled = externallyEnabled
	self:UpdateEnabled()

	if externallyEnabled then
		self:_setupConfigurations()
	else
		self._connectionUtil:disconnectAll()
	end
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
	self.jumpButton:AddTag("JumpButton")

	local function ResizeJumpButton()
		local v = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y) <= 500
		local v2 = v and 70 or 120
		self.jumpButton.Size = UDim2.new(0, v2, 0, v2)
		self.jumpButton.Position = v and UDim2.new(1, -(v2 * 1.5 - 10), 1, -v2 - 20) or UDim2.new(
			1,
			-(v2 * 1.5 - 10),
			1,
			-v2 * 1.75
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
	self.jumpButton.Parent = self.parentUIFrame
end

return object