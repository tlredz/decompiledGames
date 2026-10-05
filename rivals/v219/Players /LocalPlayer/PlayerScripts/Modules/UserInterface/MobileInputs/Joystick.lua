local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local Joystick = {}
Joystick.__index = Joystick

function Joystick.new(mobileInputs)
	local self = setmetatable({}, Joystick)
	self.MobileInputs = mobileInputs
	self.Frame = self.MobileInputs.Frame:WaitForChild("JoystickArea")
	self._hooked = false
	self._touch_gui = nil
	self._joystick_frame = nil
	self._joystick_original_position = nil
	self._joystick_original_anchor_point = nil
	self._joystick_left_handed_position = nil
	self._joystick_left_handed_anchor_point = nil
	self:_Init()
	return self
end

function Joystick:_Update()
	self.Frame.Visible = self._hooked and self.MobileInputs.EditorEnabled

	if not self.Frame.Visible then
		return
	end

	local setting = PlayerDataController:GetSetting("Left Handed Touch Controls")
	self._joystick_frame.Position = setting and self._joystick_left_handed_position or self._joystick_original_position
	self._joystick_frame.AnchorPoint = setting and self._joystick_left_handed_anchor_point or self._joystick_original_anchor_point
	local vector = Vector2.new(
		math.clamp(
			self._joystick_frame.AbsolutePosition.X + (self._touch_gui.AbsolutePosition.X - UILibrary.MainGui.AbsolutePosition.X),
			0,
			self.Frame.AbsoluteSize.X
		),
		(math.clamp(
			self._joystick_frame.AbsolutePosition.Y + (self._touch_gui.AbsolutePosition.Y - UILibrary.MainGui.AbsolutePosition.Y),
			0,
			self.Frame.AbsoluteSize.Y
		))
	)
	local vector2 = Vector2.new(
		self._joystick_frame.AbsolutePosition.X + self._joystick_frame.AbsoluteSize.X - vector.X,
		self._joystick_frame.AbsolutePosition.Y + self._joystick_frame.AbsoluteSize.Y - vector.Y
	)
	self.Frame.Position = UDim2.new(0, vector.X, 0, vector.Y)
	self.Frame.Size = UDim2.new(0, vector2.X, 0, vector2.Y)
end

function Joystick:_HookTouchGui()
	local silentWaitForChild = Utility:SilentWaitForChild(Players.LocalPlayer:WaitForChild("PlayerGui"), "TouchGui")
	local dynamicThumbstickFrame = silentWaitForChild:WaitForChild("TouchControlFrame"):WaitForChild("DynamicThumbstickFrame")
	self._hooked = true
	self._touch_gui = silentWaitForChild
	self._joystick_frame = dynamicThumbstickFrame
	self._joystick_original_position = self._joystick_frame.Position
	self._joystick_original_anchor_point = self._joystick_frame.AnchorPoint
	self._joystick_left_handed_position = UDim2.new(
		1 - self._joystick_original_position.X.Scale,
		-self._joystick_original_position.X.Offset,
		self._joystick_original_position.Y.Scale,
		self._joystick_original_position.Y.Offset
	)
	self._joystick_left_handed_anchor_point = Vector2.new(
		1 - self._joystick_original_anchor_point.X,
		self._joystick_original_anchor_point.Y
	)
	self._touch_gui:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end)
	self._joystick_frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end)
	self._joystick_frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self:_Update()
	task.spawn(function()
		local thumbstickStart = dynamicThumbstickFrame:WaitForChild("ThumbstickStart")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			thumbstickStart.Visible = false
		end

		thumbstickStart:GetPropertyChangedSignal("Visible"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end)
end

function Joystick:_Setup()
	self.Frame.AnchorPoint = Vector2.zero
end

function Joystick:_Init()
	self.MobileInputs.EditorEnabledChanged:Connect(function()
		self:_Update()
	end)
	self.MobileInputs.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end)
	self.MobileInputs.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	UILibrary.MainGui:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end)
	PlayerDataController:GetSettingChangedSignal("Left Handed Touch Controls"):Connect(function()
		self:_Update()
	end)
	self:_Setup()
	self:_Update()
	task.defer(self._HookTouchGui, self)
end

return Joystick