local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers.SettingsController)
local Crosshair = require(Players.LocalPlayer.PlayerScripts.Modules.Crosshair)
local mobileButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MobileButton")
local Inspect = {}
Inspect.__index = Inspect

function Inspect.new(page)
	local self = setmetatable({}, Inspect)
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("Inspect")
	self.Container = self.Frame:WaitForChild("Container")
	self.DescriptionFrame = self.Container:WaitForChild("Description")
	self.DescriptionText = self.DescriptionFrame:WaitForChild("Description")
	self.DescriptionInvisibleText = self.DescriptionFrame:WaitForChild("InvisibleDescription")
	self.DescriptionTitleContainer = self.DescriptionFrame:WaitForChild("TitleContainer")
	self.DescriptionTitleIcon = self.DescriptionTitleContainer:WaitForChild("Icon")
	self.DescriptionTitleText = self.DescriptionTitleContainer:WaitForChild("Title")
	self.MapFrame = self.Container:WaitForChild("Map")
	self.MapContainer = self.MapFrame:WaitForChild("Container")
	self.MapBackground = self.MapContainer:WaitForChild("Background")
	self.MapCurrent = self.MapBackground:WaitForChild("Current")
	self.MapNext = self.MapBackground:WaitForChild("Next")
	self._current_settings_info = nil
	self._map_hash = 0
	self._map_num = 0
	self._crosshair = Crosshair.new()
	self._mobile_button = mobileButton:Clone()
	self._mobile_input_name_connections = {}
	self._current_mobile_input_name = nil
	self:_Init()
	return self
end

function Inspect:Inspect(current_settings_info)
	if current_settings_info == self._current_settings_info or current_settings_info and current_settings_info.InputType == "Divider" then
		return
	end

	for _, _mobile_input_name_connection in pairs(self._mobile_input_name_connections) do
		_mobile_input_name_connection:Disconnect()
	end

	self._mobile_input_name_connections = {}
	self._current_settings_info = current_settings_info
	self._current_mobile_input_name = self:_GetMobileInputNameFromSettingsName(self._current_settings_info and self._current_settings_info.Name) or self._current_mobile_input_name or "mobile_shoot"
	self.DescriptionFrame.Visible = self._current_settings_info ~= nil
	self:_UpdateMapVisibility()
	self:_UpdateMobileButton()

	if not self._current_settings_info then
		return
	end

	self.DescriptionTitleIcon.Image = self._current_settings_info.Image
	self.DescriptionTitleIcon.Visible = self.DescriptionTitleIcon.Image ~= ""
	self.DescriptionTitleText.Text = self._current_settings_info.DisplayName
	self.DescriptionInvisibleText.Text = self._current_settings_info.Description

	if not self._current_mobile_input_name then
		return
	end

	table.insert(
		self._mobile_input_name_connections,
		PlayerDataController:GetSettingChangedSignal("MobileButton " .. self._current_mobile_input_name .. " Enabled"):Connect(function()
			self:_UpdateMobileButton()
		end)
	)
	table.insert(
		self._mobile_input_name_connections,
		PlayerDataController:GetSettingChangedSignal("Mobile Buttons Transparency"):Connect(function()
			self:_UpdateMobileButton()
		end)
	)
	table.insert(
		self._mobile_input_name_connections,
		PlayerDataController:GetSettingChangedSignal("MobileButton " .. self._current_mobile_input_name .. " Transparency"):Connect(function()
			self:_UpdateMobileButton()
		end)
	)
	table.insert(self._mobile_input_name_connections, PlayerDataController.SettingsSliderChanged:Connect(function(p, p2)
		self:_UpdateMobileButton({
			[p] = p2
		})
	end))
end

function Inspect:SetVisible(visible)
	self.Frame.Visible = visible
end

function Inspect:SetPage(p)
	self:Inspect(nil)
	self:SetVisible(p ~= "Hotkeys")
	self._crosshair:SetVisible(p == "Crosshair")
	self:_UpdateMapVisibility()
	self:_UpdateMobileButton()
end

function Inspect:Open()
	self._map_hash += 1
	task.spawn(self._PlayMapEffect, self)
end

function Inspect:Close()
	self._map_hash += 1
	self:Inspect(nil)
end

function Inspect:_GetMobileInputNameFromSettingsName(value)
	if not value or string.sub(value, 1, 13) ~= "MobileButton " then
		return nil
	end

	local v = string.sub(value, 14, #value)
	local v2 = string.find(v, " ")

	if v2 then
		return (string.sub(v, 1, v2 - 1))
	end

	return nil
end

function Inspect:_UpdateMobileButton(p)
	local _mobile_button = self._mobile_button
	_mobile_button.Visible = self.Page.CurrentPage == "Touch" and self._current_mobile_input_name ~= nil

	if not self._mobile_button.Visible then
		return
	end

	local mobileButtonSetting = SettingsController:GetMobileButtonSetting(
		self._current_mobile_input_name,
		"Mobile Buttons Transparency",
		"Transparency",
		p
	)
	local setting = PlayerDataController:GetSetting("MobileButton " .. self._current_mobile_input_name .. " Enabled")
	local image = InputLibrary.MobileButtons[self._current_mobile_input_name].Image
	self._mobile_button.Invisible.Visible = not setting
	self._mobile_button.IconContainer.ImageTransparency = math.clamp(mobileButtonSetting * 2, 0, 1) * 1 + 0
	self._mobile_button.IconContainer.Icon.ImageTransparency = math.clamp(mobileButtonSetting, 0, 1)
	self._mobile_button.IconContainer.Icon.Image = image
end

function Inspect:_UpdateMapVisibility()
	local mapFrame = self.MapFrame
	local _current_mobile_input_name

	if self.Page.CurrentPage == "Crosshair" then
		_current_mobile_input_name = true
	elseif self.Page.CurrentPage == "Touch" then
		_current_mobile_input_name = self._current_mobile_input_name
	else
		_current_mobile_input_name = false
	end

	mapFrame.Visible = _current_mobile_input_name
end

function Inspect:_GetMapImage(p)
	return DuelLibrary.Maps[DuelLibrary.MapOrder[(p - 1) % #DuelLibrary.MapOrder + 1]].Image
end

function Inspect:_PlayMapEffect()
	self._map_hash += 1
	local _map_hash = self._map_hash

	while true do
		self._map_num += 1
		self.MapNext.Image = self:_GetMapImage(self._map_num + 1)
		self.MapCurrent.Image = self:_GetMapImage(self._map_num)
		self.MapCurrent.Position = UDim2.new(0.625, 0, 0.5, 0)
		self.MapCurrent:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.25, true)
		wait(5)

		if _map_hash ~= self._map_hash then
			break
		end

		self.MapCurrent:TweenPosition(UDim2.new(0.375, 0, 0.5, 0), "In", "Quint", 0.25, true)
		wait(0.25)

		if _map_hash ~= self._map_hash then
			break
		end
	end
end

function Inspect:_UpdateCrosshairAppearance(p2)
	self._crosshair:SetAppearance(SettingsLibrary:GenerateCrosshairAppearance(PlayerDataController, p2))
	self._crosshair:SetSpacing(self._crosshair:GetAppearanceSpacing())
end

function Inspect:_UpdateText()
	self.DescriptionText.Text = self.DescriptionInvisibleText.Text
	self.DescriptionText.Size = UDim2.new(
		0.9,
		0,
		self.DescriptionInvisibleText.Size.Y.Scale * math.ceil(self.DescriptionInvisibleText.TextBounds.X / self.DescriptionText.AbsoluteSize.X),
		0
	)
end

function Inspect:_Setup()
	self._crosshair:SetParent(self.MapContainer)
	self._mobile_button.Parent = self.MapContainer
	self._mobile_button.AnchorPoint = Vector2.new(0.5, 0.5)
	self._mobile_button.Position = UDim2.new(0.5, 0, 0.5, 0)
	self._mobile_button.Size = UDim2.new(0.5, 0, 0.5, 0)
	self._mobile_button.Resize.Visible = false
end

function Inspect:_Init()
	self.DescriptionInvisibleText:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateText()
	end)
	self.DescriptionInvisibleText:GetPropertyChangedSignal("Text"):Connect(function()
		self:_UpdateText()
	end)
	self.DescriptionInvisibleText:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateText()
	end)
	self.DescriptionInvisibleText:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateText()
	end)
	self.DescriptionText:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateText()
	end)
	PlayerDataController.SettingsSliderChanged:Connect(function(p, p2)
		self:_UpdateCrosshairAppearance({
			[p] = p2
		})
	end)

	for k, v in pairs(SettingsLibrary.Info) do
		if v.Section == "Crosshair" then
			PlayerDataController:GetSettingChangedSignal(k):Connect(function()
				self:_UpdateCrosshairAppearance()
			end)
		end
	end

	self:_Setup()
	self:_UpdateText()
	self:_UpdateCrosshairAppearance()
end

return Inspect