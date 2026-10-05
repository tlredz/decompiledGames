local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local SettingSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SettingSlot"))
local object = setmetatable({}, SettingSlot)
object.__index = object

function object.new(...)
	local self = setmetatable(SettingSlot.new(...), object)
	self.SliderChanged = Signal.new()
	self.InputBox = self.ControlsSettingFrame:WaitForChild("SliderInput"):WaitForChild("Box")
	self.ControlsSettingButtonsFrame = self.ControlsSettingFrame:WaitForChild("Buttons")
	self.IncreaseButton = self.ControlsSettingButtonsFrame:WaitForChild("Increase")
	self.DecreaseButton = self.ControlsSettingButtonsFrame:WaitForChild("Decrease")
	self.SliderContainer = self.ControlsSettingFrame:WaitForChild("Container")
	self.Slider = self.SliderContainer:WaitForChild("Slider")
	self.Dragger = self.Slider:WaitForChild("Dragger")
	self._dragging = false
	self._dragging_connection = nil
	self._console_dragging_connection = nil
	self._console_alpha = nil
	self._console_drag_velocity = 0
	self:_Init()
	return self
end

function object:IncreaseValue(p)
	local v = math.max(1 / self.SettingsInfo.Increment, (self.SettingsInfo.Max - self.SettingsInfo.Min) * 0.1)
	self:InputValue((self.SettingsInfo.VerifyInput(self.Value + v * p)))
end

function object:CancelInputs()
	if self._console_dragging_connection then
		self:_StopDraggingConsole()
	else
		self:_StopDragging()
	end
end

function object:Destroy()
	if self._dragging_connection then
		self._dragging_connection:Disconnect()
		self._dragging_connection = nil
	end

	if self._console_dragging_connection then
		self._console_dragging_connection:Disconnect()
		self._console_dragging_connection = nil
	end

	self.SliderChanged:Destroy()
	SettingSlot.Destroy(self)
end

function object:_GetDisplayValue(p2)
	if self.SettingsInfo.IsPercent then
		return math.floor(p2 * 100 + 0.5) .. "%"
	end

	return p2
end

function object:_UpdateSliderPosition()
	local v = self.ControlsSettingFrame.AbsolutePosition.X + self.ControlsSettingFrame.AbsoluteSize.X - self.SettingFrame.AbsolutePosition.X
	self.SliderContainer.Size = UDim2.new(0, v / self.UIScale.Scale, 0.42, 0)
end

function object:_Update()
	local uDim = UDim2.new(self:_GetAlphaFromValue(self.Value), 0, 0.5, 0)
	self.InputBox.Text = self:_GetDisplayValue(self.Value)

	if self.Dragger:IsDescendantOf(game) then
		self.Dragger:TweenPosition(uDim, "Out", "Quint", 0.25, true)
	else
		self.Dragger.Position = uDim
	end
end

function object:_VerifyInputBox()
	local text = tonumber(self.InputBox.Text)
	local v = self.SettingsInfo.IsPercent and text and text / 100 or self.InputBox.Text
	local v2 = self.SettingsInfo.VerifyInput(v) or self.Value
	self.InputBox.Text = self:_GetDisplayValue(v2)
	self:InputValue(v2)
end

function object:_GetAlphaFromValue(p2)
	return (p2 - self.SettingsInfo.Min) / (self.SettingsInfo.Max - self.SettingsInfo.Min)
end

function object:_GetAlphaFromMouse()
	local mouseLocation = UILibrary:GetMouseLocation()
	local X = self.Slider.AbsolutePosition.X
	local X2 = self.Slider.AbsoluteSize.X
	return (math.clamp((mouseLocation.X - X) / X2, 0, 1))
end

function object:_GetValueFromAlpha(p2)
	local v = self.SettingsInfo.Min + p2 * (self.SettingsInfo.Max - self.SettingsInfo.Min)
	return (self.SettingsInfo.VerifyInput(v))
end

function object:_GetValueFromMouse()
	return self:_GetValueFromAlpha(self:_GetAlphaFromMouse())
end

function object:_UpdateDrag()
	local _GetValueFromMouse = self:_GetValueFromMouse()
	local _GetAlphaFromMouse = self:_GetAlphaFromMouse()
	local v = (_GetValueFromMouse - self.SettingsInfo.Min) / (self.SettingsInfo.Max - self.SettingsInfo.Min)
	local uDim = UDim2.new(v + (_GetAlphaFromMouse - v) * 0.5, 0, 0.5, 0)
	self.Dragger:TweenPosition(uDim, "Out", "Quint", 0.25, true)
	self.InputBox.Text = self:_GetDisplayValue(_GetValueFromMouse)
	self.SliderChanged:Fire(_GetValueFromMouse)
end

function object:_StartDragging()
	if self._dragging or tick() < self._value_change_cooldown then
		return
	end

	self._dragging = true
	self._dragging_connection = UserInputService.InputChanged:Connect(function()
		self:_UpdateDrag()
	end)
end

function object:_StopDragging()
	if not self._dragging then
		return
	end

	self._dragging = false

	if self._dragging_connection then
		self._dragging_connection:Disconnect()
	end

	self:InputValue(self:_GetValueFromMouse())
end

function object:_StartDraggingConsole()
	if self._dragging or tick() < self._value_change_cooldown then
		return
	end

	self._dragging = true
	self._console_alpha = self:_GetAlphaFromValue(self.Value)
	self._dragging_connection = UserInputService.InputChanged:Connect(function(input)
		if input.KeyCode ~= Enum.KeyCode.Thumbstick1 then
			return
		end

		if math.abs(input.Position.X) < 0.1 then
			self._console_drag_velocity = 0
		else
			self._console_drag_velocity = input.Position.X * 0.01
		end
	end)
	self._console_dragging_connection = RunService.RenderStepped:Connect(function(dt)
		self._console_alpha = math.clamp(self._console_alpha + self._console_drag_velocity * dt * 60, 0, 1)
		local _GetValueFromAlpha = self:_GetValueFromAlpha(self._console_alpha)
		self.Dragger.Position = UDim2.new(self._console_alpha, 0, 0.5, 0)
		self.InputBox.Text = self:_GetDisplayValue(_GetValueFromAlpha)
		self.SliderChanged:Fire(_GetValueFromAlpha)
	end)
end

function object:_StopDraggingConsole()
	if not self._dragging then
		return
	end

	self._dragging = false

	if self._dragging_connection then
		self._dragging_connection:Disconnect()
	end

	if self._console_dragging_connection then
		self._console_dragging_connection:Disconnect()
	end

	self:InputValue(self:_GetValueFromAlpha(self._console_alpha))
	self._console_alpha = nil
end

function object:_Setup()
	self:ResizeYSize(1.5)
	self.Dragger.MouseButton1Down:Connect(function()
		self:_StartDragging()
	end)
	table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:_StopDragging()
		end
	end))
end

function object:_Init()
	self.Changed:Connect(function()
		self:_Update()
	end)
	self.SliderChanged:Connect(function(p)
		self:_UpdateDetails(p)
	end)
	self.InputBox.FocusLost:Connect(function()
		self:_VerifyInputBox()
	end)
	self.IncreaseButton.MouseButton1Click:Connect(function()
		self:IncreaseValue(1)
	end)
	self.DecreaseButton.MouseButton1Click:Connect(function()
		self:IncreaseValue(-1)
	end)
	self.IncreaseButton.MouseEnter:Connect(function()
		self.IncreaseButton.ZIndex = 1
		self.DecreaseButton.ZIndex = 0
	end)
	self.DecreaseButton.MouseEnter:Connect(function()
		self.IncreaseButton.ZIndex = 0
		self.DecreaseButton.ZIndex = 1
	end)
	self.SettingFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSliderPosition()
	end)
	self.ControlsSettingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSliderPosition()
	end)
	self.ControlsSettingFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSliderPosition()
	end)
	self.UIScale:GetPropertyChangedSignal("Scale"):Connect(function()
		self:_UpdateSliderPosition()
	end)
	self:_Setup()
	self:_Update()
	self:_UpdateSliderPosition()
	ButtonEffect:Add(self.Dragger)
	ButtonEffect:Add(self.IncreaseButton)
	ButtonEffect:Add(self.DecreaseButton)
end

return object