local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local settingFrame = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("SettingFrame")
local SettingSlot = {}
SettingSlot.__index = SettingSlot

function SettingSlot.new(settingsInfo, p)
	assert(not p, "TEMPLATES NO LONGER SUPPORTED")
	local object = setmetatable({}, SettingSlot)
	object.Changed = Signal.new()
	object.Replicate = Signal.new()
	object.Hovered = Signal.new()
	object.SettingFrame = settingFrame:Clone()
	object.UIScale = object.SettingFrame:WaitForChild("UIScale")
	object.Background = object.SettingFrame:WaitForChild("Background")
	object.BackgroundGradient = object.Background:WaitForChild("UIGradient")
	object.Container = object.SettingFrame:WaitForChild("Container")
	object.DetailsFrame = object.Container:WaitForChild("Details")
	object.DetailsIconFrame = object.DetailsFrame:WaitForChild("Icon")
	object.DetailsIconLabel = object.DetailsIconFrame:WaitForChild("Icon")
	object.DetailsResetButton = object.DetailsIconFrame:WaitForChild("Reset")
	object.DetailsDisplayFrame = object.DetailsFrame:WaitForChild("Display")
	object.DetailsDisplayDescription = object.DetailsDisplayFrame:WaitForChild("Description")
	object.DetailsDisplayTitleContainer = object.DetailsDisplayFrame:WaitForChild("TitleContainer")
	object.DetailsDisplayTitleIcon = object.DetailsDisplayTitleContainer:WaitForChild("Icon")
	object.DetailsDisplayTitleText = object.DetailsDisplayTitleContainer:WaitForChild("Title")
	object.ControlsFrame = object.Container:WaitForChild("Controls")
	object.ControlsConfirmFrame = object.ControlsFrame:WaitForChild("Confirm")
	object.ControlsConfirmButton = object.ControlsConfirmFrame:WaitForChild("Button")
	object.ControlsContainer = object.ControlsFrame:WaitForChild("Container")
	object.ControlsSettingFrame = nil
	object.SettingsInfo = settingsInfo
	object.Value = settingsInfo.DefaultValue
	object._connections = {}
	object._value_change_cooldown = 0
	object._description_override = nil
	object:_Init()
	return object
end

function SettingSlot.GetSelection(p)
	return p.ControlsSettingFrame
end

function SettingSlot.Scale(p, scale)
	p.UIScale.Scale = scale
end

function SettingSlot.ResizeYSize(p, p2)
	p.SettingFrame.Size = UDim2.new(
		p.SettingFrame.Size.X.Scale,
		p.SettingFrame.Size.X.Offset,
		p.SettingFrame.Size.Y.Scale * p2,
		p.SettingFrame.Size.Y.Offset * p2
	)
	p.Container.Size = UDim2.new(1, 0, 1 / p2, 0)
end

function SettingSlot:OverrideDescription(description_override)
	self._description_override = description_override
	self:_UpdateDetails()
end

function SettingSlot:SetSettingsInfo(settingsInfo)
	self.SettingsInfo = settingsInfo
	self:_UpdateDetails()
end

function SettingSlot:SetValue(p, p2, p3)
	if self.SettingsInfo.InputType ~= "Hotkey" and p == nil or not p3 and tick() < self._value_change_cooldown then
		return
	end

	self.Value = p
	self.Changed:Fire(self.Value)

	if not p2 then
		self._value_change_cooldown = tick() + 0.05
		self.Replicate:Fire(self.Value)
	end
end

function SettingSlot:StoreValue(p)
	self.Value = p
	self.Changed:Fire(self.Value)
end

function SettingSlot:InputValue(...)
	if self.SettingsInfo.IsConfirmSetting then
		self:StoreValue(...)
	else
		self:SetValue(...)
	end
end

function SettingSlot.CancelInputs(_) end

function SettingSlot:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self.Changed:Destroy()
	self.Replicate:Destroy()
	self.Hovered:Destroy()
	self.SettingFrame:Destroy()
end

function SettingSlot:_Confirm()
	self:SetValue(self.Value, nil, true)
end

function SettingSlot:_UpdateDetails(p)
	local v = p or self.Value
	self.DetailsDisplayDescription.Text = self._description_override or self.SettingsInfo.Description
	local detailsDisplayTitleContainer = self.DetailsDisplayTitleContainer
	local position

	if self.DetailsDisplayDescription.Text == "" then
		position = UDim2.new(
			self.DetailsDisplayTitleContainer.Position.X.Scale,
			self.DetailsDisplayTitleContainer.Position.X.Offset,
			0.5,
			0
		)
	else
		position = self.DetailsDisplayTitleContainer.Position
	end

	detailsDisplayTitleContainer.Position = position
	local detailsResetButton = self.DetailsResetButton
	detailsResetButton.Visible = self.SettingsInfo.InputType ~= "Divider" and v ~= self.SettingsInfo.DefaultValue
	local detailsIconLabel = self.DetailsIconLabel
	detailsIconLabel.Visible = self.DetailsIconLabel.Image ~= "" and not self.DetailsResetButton.Visible
	self.DetailsIconFrame.Visible = not self.ControlsConfirmFrame.Visible and (self.DetailsIconLabel.Visible or self.DetailsResetButton.Visible)
	local detailsDisplayTitleIcon = self.DetailsDisplayTitleIcon
	detailsDisplayTitleIcon.Visible = self.DetailsDisplayTitleIcon.Image ~= "" and not (self.DetailsIconFrame.Visible and self.DetailsIconLabel.Visible)
end

function SettingSlot:_Setup()
	self.DetailsIconLabel.Image = self.SettingsInfo.Image
	self.DetailsDisplayTitleIcon.Image = self.SettingsInfo.Image
	self.DetailsDisplayTitleText.Text = self.SettingsInfo.DisplayName
	self.ControlsConfirmFrame.Visible = self.SettingsInfo.IsConfirmSetting

	for _, child in pairs(self.ControlsContainer:GetChildren()) do
		if child.Name == self.SettingsInfo.InputType then
			child.Visible = true
			self.ControlsSettingFrame = child
		else
			child.Visible = false
			pcall(task.defer, child.Destroy, child)
		end
	end
end

function SettingSlot:_Init()
	self.Changed:Connect(function()
		self:_UpdateDetails()
	end)
	self.SettingFrame.MouseEnter:Connect(function()
		self.Hovered:Fire()
	end)
	self.SettingFrame.SelectionChanged:Connect(function(p)
		if p then
			self.Hovered:Fire()
		end
	end)
	self.DetailsResetButton.MouseButton1Click:Connect(function()
		self:SetValue(self.SettingsInfo.DefaultValue)
	end)
	self.ControlsConfirmButton.MouseButton1Click:Connect(function()
		self:_Confirm()
	end)
	self:_Setup()
	self:_UpdateDetails()
	ButtonEffect:Add(self.DetailsResetButton)
	task.defer(ButtonEffect.Add, ButtonEffect, self.ControlsConfirmButton)
end

return SettingSlot