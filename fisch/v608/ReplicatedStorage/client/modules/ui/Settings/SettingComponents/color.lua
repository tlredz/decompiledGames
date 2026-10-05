local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Trove = require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
require(ReplicatedStorage.shared.playerSettings.Types)
require("../Types")
local color = script:WaitForChild("color")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local Color = {}
Color.__index = Color
TweenInfo.new(0.3, Enum.EasingStyle.Quart)

function Color:GetValue()
	local position = self.GuiObject.wheel.selector.Position
	local position2 = self.GuiObject.lightness.selector.Position
	local v = math.clamp(math.map(position.X.Scale, 0.04, 0.96, 1, 0), 0, 1)
	local v2 = math.clamp(math.map(position.Y.Scale, 0.04, 0.96, 1, 0), 0, 1)
	local v3 = math.clamp(math.map(position2.Y.Scale, 0.015, 0.985, 1, 0), 0, 1)
	local color2 = Color3.fromHSV(v, v2, v3)
	return {
		r = math.round(color2.R * 255),
		g = math.round(color2.G * 255),
		b = math.round(color2.B * 255)
	}, color2
end

function Color:UpdateSliderState()
	local color2 = Color3.fromRGB(self.Value.r, self.Value.g, self.Value.b)
	local HSV, v, v2 = color2:ToHSV()

	if not self.IsDraggingMain then
		self.GuiObject.wheel.selector.Position = UDim2.fromScale(
			math.map(HSV, 1, 0, 0.04, 0.96),
			math.map(v, 1, 0, 0.04, 0.96)
		)
	end

	if not self.IsDraggingValue then
		self.GuiObject.lightness.selector.Position = UDim2.fromScale(0.5, math.map(v2, 1, 0, 0.015, 0.985))
	end

	self.GuiObject.lightness.BackgroundColor3 = Color3.fromHSV(HSV, v, 1)
	local manualcolor = self.GuiObject.manualcolor
	manualcolor.red.choice.Text = tostring(self.Value.r)
	manualcolor.green.choice.Text = tostring(self.Value.g)
	manualcolor.blue.choice.Text = tostring(self.Value.b)
	self.GuiObject.currentcolor.BackgroundColor3 = color2
end

function Color.GetLocalizedName(p)
	return p.GuiObject.title.LocalizedText
end

function Color:_DragUpdate(flag: boolean)
	self.Value = self:GetValue()
	SettingsController:EditSetting(self.Config.Id, self.Value, flag)
end

function Color:TryLoadHex(p: string)
	local success, result = pcall(function()
		return Color3.fromHex(p)
	end)

	if success and result then
		local v = {
			r = math.round(result.R * 255),
			g = math.round(result.G * 255),
			b = math.round(result.B * 255)
		}
		SettingsController:EditSetting(self.Config.Id, v)
	else
		self:UpdateSliderState()
	end
end

function Color.new(config, p)
	local object = setmetatable({}, Color)
	object.Trove = Trove.new()
	object.Config = config
	object.Value = p
	local guiObject = object.Trove:Add(color:Clone())
	guiObject.title.Text = config.Name
	guiObject.LayoutOrder = config.Order
	guiObject.Name = config.Id
	object.Trove:Add(SettingsController:GetSettingChangedSignal(config.Id):Connect(function(p2)
		object.Value = p2
		object:UpdateSliderState()
	end))
	local uIDragDetector = guiObject.wheel.selector.UIDragDetector
	object.Trove:Add(uIDragDetector.DragStart:Connect(function()
		object.IsDraggingMain = true
		object:_DragUpdate(true)
		fx:PlaySound(ui.settingEnabled, guiObject, false)
	end))
	object.Trove:Add(uIDragDetector.DragContinue:Connect(function()
		object:_DragUpdate(true)
	end))
	object.Trove:Add(uIDragDetector.DragEnd:Connect(function()
		object.IsDraggingMain = false
		object:_DragUpdate(false)
		fx:PlaySound(ui.open, guiObject, false)
	end))
	local uIDragDetector2 = guiObject.lightness.selector.UIDragDetector
	object.Trove:Add(uIDragDetector2.DragStart:Connect(function()
		object.IsDraggingValue = true
		object:_DragUpdate(true)
		fx:PlaySound(ui.settingEnabled, guiObject, false)
	end))
	object.Trove:Add(uIDragDetector2.DragContinue:Connect(function()
		object:_DragUpdate(false)
	end))
	object.Trove:Add(uIDragDetector2.DragEnd:Connect(function()
		object.IsDraggingValue = false
		object:_DragUpdate(false)
		fx:PlaySound(ui.open, guiObject, false)
	end))
	object.Trove:Add(guiObject.wheel.Activated:Connect(function(p2)
		if object.IsDraggingMain then
			return
		end

		local absoluteSize = guiObject.wheel.AbsoluteSize
		local absolutePosition = guiObject.wheel.AbsolutePosition
		local v2 = (p2.Position.X - absolutePosition.X) / absoluteSize.X
		local v3 = (p2.Position.Y - absolutePosition.Y) / absoluteSize.Y
		local _, v4 = object:GetValue()
		local _, _, v5 = v4:ToHSV()
		local v6 = v5 == 0 and 1 or v5
		local color2 = Color3.fromHSV(1 - v2, 1 - v3, v6)
		local v7 = {
			r = math.round(color2.R * 255),
			g = math.round(color2.G * 255),
			b = math.round(color2.B * 255)
		}
		SettingsController:EditSetting(object.Config.Id, v7)
		fx:PlaySound(ui.open, guiObject, false)
	end))
	object.Trove:Add(guiObject.lightness.Activated:Connect(function(p2)
		if object.IsDraggingValue then
			return
		end

		local absoluteSize = guiObject.lightness.AbsoluteSize
		local absolutePosition = guiObject.lightness.AbsolutePosition
		local v2 = (p2.Position.Y - absolutePosition.Y) / absoluteSize.Y
		local _, v3 = object:GetValue()
		local HSV, v4 = v3:ToHSV()
		local color2 = Color3.fromHSV(HSV, v4, 1 - v2)
		local v5 = {
			r = math.round(color2.R * 255),
			g = math.round(color2.G * 255),
			b = math.round(color2.B * 255)
		}
		SettingsController:EditSetting(object.Config.Id, v5)
		fx:PlaySound(ui.open, guiObject, false)
	end))
	local manualcolor = guiObject.manualcolor
	object.Trove:Add(manualcolor.red.choice.FocusLost:Connect(function()
		local text = manualcolor.red.choice.Text
		local v2 = tonumber(text)

		if v2 and math.isfinite(v2) then
			object.Value.r = math.round((math.clamp(v2, 0, 255)))
			SettingsController:EditSetting(object.Config.Id, object.Value)
		else
			object:TryLoadHex(text)
		end
	end))
	object.Trove:Add(manualcolor.green.choice.FocusLost:Connect(function()
		local text = manualcolor.green.choice.Text
		local v2 = tonumber(text)

		if v2 and math.isfinite(v2) then
			object.Value.g = math.round((math.clamp(v2, 0, 255)))
			SettingsController:EditSetting(object.Config.Id, object.Value)
		else
			object:TryLoadHex(text)
		end
	end))
	object.Trove:Add(manualcolor.blue.choice.FocusLost:Connect(function()
		local text = manualcolor.blue.choice.Text
		local v2 = tonumber(text)

		if v2 and math.isfinite(v2) then
			object.Value.b = math.round((math.clamp(v2, 0, 255)))
			SettingsController:EditSetting(object.Config.Id, object.Value)
		else
			object:TryLoadHex(text)
		end
	end))
	object.GuiObject = guiObject
	object:UpdateSliderState()
	return object, guiObject
end

function Color:Destroy()
	self.Trove:Destroy()
	table.clear(self)
end

return Color