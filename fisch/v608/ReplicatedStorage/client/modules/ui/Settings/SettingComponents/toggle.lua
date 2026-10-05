local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Trove = require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
require(ReplicatedStorage.shared.playerSettings.Types)
require("../Types")
local toggle = script:WaitForChild("toggle")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local Toggle = {}
Toggle.__index = Toggle
local color = Color3.fromRGB(171, 255, 126)
local color2 = Color3.fromRGB(255, 62, 62)
local uDim = UDim2.fromScale(0.3, 0.5)
local uDim2 = UDim2.fromScale(0.7, 0.5)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart)

function Toggle:UpdateSwitchState(flag: boolean)
	local toggleSwitch = self.GuiObject.control.toggleSwitch
	local enableColor = self.Value and (self.Config.EnableColor or color) or self.Config.DisableColor or color2
	local position = self.Value and uDim2 or uDim

	if not flag then
		fx:PlaySound(self.Value and ui.settingEnabled or ui.settingDisabled, toggleSwitch, false)
	end

	if flag or GuiService.ReducedMotionEnabled then
		toggleSwitch.bg.BackgroundColor3 = enableColor
		toggleSwitch.switch.stroke.Color = enableColor
		toggleSwitch.switch.Position = position
	else
		TweenService:Create(toggleSwitch.bg, tweenInfo, {
			BackgroundColor3 = enableColor
		}):Play()
		TweenService:Create(toggleSwitch.switch.stroke, tweenInfo, {
			Color = enableColor
		}):Play()
		TweenService:Create(toggleSwitch.switch, tweenInfo, {
			Position = position
		}):Play()
	end
end

function Toggle.GetLocalizedName(p)
	return p.GuiObject.detail.title.title.LocalizedText
end

function Toggle.new(config, flag: boolean)
	local object = setmetatable({}, Toggle)
	object.Trove = Trove.new()
	object.Config = config
	object.Value = flag
	local guiObject = object.Trove:Add(toggle:Clone())
	guiObject.detail.title.title.Text = config.Name
	guiObject.LayoutOrder = config.Order
	guiObject.Name = config.Id

	if config.Description then
		guiObject.detail.desc.Text = config.Description
	else
		guiObject.detail.desc.Visible = false
	end

	guiObject.detail.title.title.TextSize = workspace.CurrentCamera.ViewportSize.Y > 650 and 24 or 18
	object.Trove:Add(SettingsController:GetSettingChangedSignal(config.Id):Connect(function(p)
		object.Value = p
		object:UpdateSwitchState(false)
	end))
	object.Trove:Add(guiObject.control.toggleSwitch.Activated:Connect(function()
		SettingsController:EditSetting(config.Id, not object.Value)
	end))
	object.GuiObject = guiObject
	object:UpdateSwitchState(true)
	return object, guiObject
end

function Toggle:Destroy()
	self.Trove:Destroy()
	table.clear(self)
end

return Toggle