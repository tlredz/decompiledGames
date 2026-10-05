local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Trove = require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
require(ReplicatedStorage.shared.playerSettings.Types)
require("../Types")
local slider = script:WaitForChild("slider")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local Slider = {}
Slider.__index = Slider
TweenInfo.new(0.3, Enum.EasingStyle.Quart)

function Slider:GetValueFromNotch()
	return math.map(
		self.GuiObject.title.slider.notch.Position.X.Scale,
		self.PosMin,
		self.PosMax,
		self.Config.MinValue,
		self.Config.MaxValue
	)
end

function Slider:UpdateSliderState()
	if self.IsDragging then
		return
	end

	self.GuiObject.title.slider.notch.Position = UDim2.fromScale(
		math.map(self.Value, self.Config.MinValue, self.Config.MaxValue, self.PosMin, self.PosMax),
		0.5
	)
end

function Slider.GetLocalizedName(p)
	return p.GuiObject.title.title.LocalizedText
end

function Slider.new(config, p: number)
	local object = setmetatable({}, Slider)
	object.Trove = Trove.new()
	object.Config = config
	object.Value = p
	local guiObject = object.Trove:Add(slider:Clone())
	guiObject.title.title.Text = config.Name .. ":"
	guiObject.LayoutOrder = config.Order
	guiObject.Name = config.Id

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updatePosClamp()
		object.PosMin = object.NotchSize.X / object.SliderSize.X * 0.5
		object.PosMax = 1 - object.PosMin

		if object.GuiObject and math.isfinite(object.PosMin) then
			object:UpdateSliderState()
		end
	end

	object.SliderSize = guiObject.title.slider.AbsoluteSize
	object.NotchSize = guiObject.title.slider.notch.AbsoluteSize
	updatePosClamp() -- equivalent call inferred; original call site unknown
	object.Trove:Add(guiObject.title.slider:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		object.SliderSize = guiObject.title.slider.AbsoluteSize
		updatePosClamp() -- equivalent call inferred; original call site unknown
	end))
	object.Trove:Add(guiObject.title.slider.notch:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		object.NotchSize = guiObject.title.slider.notch.AbsoluteSize
		updatePosClamp() -- equivalent call inferred; original call site unknown
	end))
	local slider2 = guiObject.title.slider
	slider2.fill.BackgroundColor3 = config.FillColor or Color3.fromRGB(171, 255, 126)
	slider2.bg.BackgroundColor3 = config.BgColor or Color3.fromRGB(83, 83, 83)

	if config.Description then
		guiObject.desc.Text = config.Description
	else
		guiObject.desc.Visible = false
	end

	guiObject.title.title.TextSize = workspace.CurrentCamera.ViewportSize.Y > 650 and 24 or 18
	object.Trove:Add(SettingsController:GetSettingChangedSignal(config.Id):Connect(function(p2)
		object.Value = p2
		object:UpdateSliderState()
	end))
	local uIDragDetector = slider2.notch.UIDragDetector
	object.Trove:Add(uIDragDetector.DragStart:Connect(function()
		object.IsDragging = true
		object.Value = object:GetValueFromNotch()
		SettingsController:EditSetting(object.Config.Id, object.Value, true)
		fx:PlaySound(ui.settingEnabled, guiObject, false)
	end))
	object.Trove:Add(uIDragDetector.DragContinue:Connect(function()
		object.Value = object:GetValueFromNotch()
		SettingsController:EditSetting(object.Config.Id, object.Value, true)
	end))
	object.Trove:Add(uIDragDetector.DragEnd:Connect(function()
		object.IsDragging = false
		object.Value = object:GetValueFromNotch()
		SettingsController:EditSetting(object.Config.Id, object.Value)
		fx:PlaySound(ui.open, guiObject, false)
	end))
	object.Trove:Add(slider2.Activated:Connect(function(p2)
		if object.IsDragging then
			return
		end

		local X = slider2.AbsoluteSize.X
		local v2 = (p2.Position.X - slider2.AbsolutePosition.X) / X
		SettingsController:EditSetting(
			object.Config.Id,
			math.map(v2, 0, 1, object.Config.MinValue, object.Config.MaxValue)
		)
		fx:PlaySound(ui.open, guiObject, false)
	end))
	object.Trove:Add(slider2.notch:GetPropertyChangedSignal("Position"):Connect(function()
		slider2.fill.Size = UDim2.fromScale(slider2.notch.Position.X.Scale, 0.5)
	end))
	object.GuiObject = guiObject
	object:UpdateSliderState()
	return object, guiObject
end

function Slider:Destroy()
	self.Trove:Destroy()
	table.clear(self)
end

return Slider