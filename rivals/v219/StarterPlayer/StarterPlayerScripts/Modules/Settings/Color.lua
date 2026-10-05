local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ColorWheel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ColorPicker"):WaitForChild("ColorWheel"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local SettingSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SettingSlot"))
local object = setmetatable({}, SettingSlot)
object.__index = object

function object.new(...)
	local self = setmetatable(SettingSlot.new(...), object)
	self.SliderChanged = Signal.new()
	self.EditButton = self.ControlsSettingFrame:WaitForChild("Edit")
	self.EditButtonBackground = self.EditButton:WaitForChild("Background")
	self.ColorWheelFrame = self.ControlsSettingFrame:WaitForChild("ColorWheel")
	self.ColorWheel = ColorWheel.new(self.ColorWheelFrame)
	self._close_connection = nil
	self._open_time = 0
	self._is_open = false
	self:_Init()
	return self
end

function object:SetOpen(is_open)
	assert(typeof(is_open) == "boolean", "Argument 1 invalid, expected a boolean")
	self._is_open = is_open
	self.ColorWheelFrame.Visible = self._is_open
	self.SettingFrame.ZIndex = self._is_open and 999 or 1
	self.EditButton.Interactable = not self._is_open

	if self._close_connection then
		self._close_connection:Disconnect()
		self._close_connection = nil
	end

	if self._is_open then
		self._open_time = tick()
		self._close_connection = UserInputService.InputEnded:Connect(function(input, _)
			if tick() - self._open_time < 0.25 or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch and input.KeyCode ~= Enum.KeyCode.ButtonA then
				return
			end

			if not UILibrary:IsMouseWithinBounds(
				self.ColorWheelFrame.AbsolutePosition,
				self.ColorWheelFrame.AbsoluteSize
			) then
				self:SetOpen(false)
			end
		end)
	end
end

function object:SetAlwaysOpen()
	self:SetOpen(true)
	self.ColorWheelFrame.Position = UDim2.new(0.325, 0, 0, 0)
end

function object.Destroy(p)
	p.ColorWheel:Destroy()
	p.SliderChanged:Destroy()
	SettingSlot.Destroy(p)
end

function object:_Update()
	self.ColorWheel:SetStartingColor(self.Value)
	self.EditButtonBackground.ImageColor3 = Utility:Color3FromHex(self.Value)
end

function object:_Init()
	self.Changed:Connect(function()
		self:_Update()
	end)
	self.ColorWheel.Updated:Connect(function(p, p2)
		if p2 then
			self:StoreValue(p)
		else
			self:SetValue(p)
		end

		self.SliderChanged:Fire(p)
	end)
	self.EditButton.MouseButton1Click:Connect(function()
		self:SetOpen(not self._is_open)
	end)
	self:_Update()
	ButtonEffect:Add(self.EditButton)
end

return object