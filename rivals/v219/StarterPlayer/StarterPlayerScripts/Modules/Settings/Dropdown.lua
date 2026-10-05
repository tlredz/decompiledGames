local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local DropdownSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("DropdownSlot"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local SettingSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SettingSlot"))
local object = setmetatable({}, SettingSlot)
object.__index = object

function object.new(...)
	local self = setmetatable(SettingSlot.new(...), object)
	self.DropdownContainer = self.ControlsSettingFrame:WaitForChild("Container")
	self.DropdownButton = self.DropdownContainer:WaitForChild("Button")
	self.DropdownText = self.DropdownButton:WaitForChild("Title")
	self._dropdown_slot = nil
	self:_Init()
	return self
end

function object:Destroy()
	if self._dropdown_slot then
		self._dropdown_slot:Destroy()
	end

	WeaponStatusHandler:ClearStatusElements(self.DropdownText)
	SettingSlot.Destroy(self)
end

function object:_Update()
	self.DropdownText.Text = self.Value
	self.DropdownText.Position = UDim2.new(0.05, 0, 0.5, 0)
	WeaponStatusHandler:ClearStatusElements(self.DropdownText)
	WeaponStatusHandler:ApplyItemStatusToText(
		self.DropdownText,
		ItemLibrary.Items[self.Value] and ItemLibrary.Items[self.Value].Status
	)
end

function object:_Init()
	self.Changed:Connect(function()
		self:_Update()
	end)
	self.DropdownButton.MouseButton1Click:Connect(function()
		self.DropdownButton.Visible = false

		if self._dropdown_slot then
			self._dropdown_slot:Cancel()
			self._dropdown_slot = nil
		end

		self._dropdown_slot = DropdownSlot.new(self.DropdownContainer, self.SettingsInfo.Options)
		self._dropdown_slot.Selected:Connect(function(p)
			self.DropdownButton.Visible = true

			if p then
				self:InputValue(p)
			end

			self._dropdown_slot = nil
		end)
	end)
	self:_Update()
	ButtonEffect:Add(self.DropdownButton, nil, {
		ReleaseRatio = 1.025,
		HoverRatio = 1.025
	})
end

return object