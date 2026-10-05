local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local CustomColorPicker = {}
CustomColorPicker.__index = CustomColorPicker

function CustomColorPicker.new(guiObject, onChanged)
	local object = setmetatable({}, CustomColorPicker)
	object.Trove = Trove.new()
	object.GuiObject = guiObject
	object.OnChanged = onChanged
	object.IsDraggingMain = false
	object.IsDraggingValue = false
	object.Value = {
		r = 255,
		g = 255,
		b = 255
	}
	object.Trove:Add(guiObject.wheel.selector.UIDragDetector.DragStart:Connect(function()
		object.IsDraggingMain = true
		object:_DragUpdate()
		fx:PlaySound(ui.settingEnabled, guiObject, false)
	end))
	object.Trove:Add(guiObject.wheel.selector.UIDragDetector.DragContinue:Connect(function()
		object:_DragUpdate()
	end))
	object.Trove:Add(guiObject.wheel.selector.UIDragDetector.DragEnd:Connect(function()
		object.IsDraggingMain = false
		object:_DragUpdate()
		fx:PlaySound(ui.open, guiObject, false)
	end))
	object.Trove:Add(guiObject.lightness.selector.UIDragDetector.DragStart:Connect(function()
		object.IsDraggingValue = true
		object:_DragUpdate()
		fx:PlaySound(ui.settingEnabled, guiObject, false)
	end))
	object.Trove:Add(guiObject.lightness.selector.UIDragDetector.DragContinue:Connect(function()
		object:_DragUpdate()
	end))
	object.Trove:Add(guiObject.lightness.selector.UIDragDetector.DragEnd:Connect(function()
		object.IsDraggingValue = false
		object:_DragUpdate()
		fx:PlaySound(ui.open, guiObject, false)
	end))
	object.Trove:Add(guiObject.wheel.Activated:Connect(function(p)
		if object.IsDraggingMain then
			return
		end

		local absoluteSize = guiObject.wheel.AbsoluteSize
		local absolutePosition = guiObject.wheel.AbsolutePosition
		local v = (p.Position.X - absolutePosition.X) / absoluteSize.X
		local v2 = (p.Position.Y - absolutePosition.Y) / absoluteSize.Y
		local _, v3 = object:GetValue()
		local _, _, v4 = v3:ToHSV()
		local v5 = v4 == 0 and 1 or v4
		object:SetColor((Color3.fromHSV(1 - v, 1 - v2, v5)))
		fx:PlaySound(ui.open, guiObject, false)
	end))
	object.Trove:Add(guiObject.lightness.Activated:Connect(function(p)
		if object.IsDraggingValue then
			return
		end

		local absoluteSize = guiObject.lightness.AbsoluteSize
		local absolutePosition = guiObject.lightness.AbsolutePosition
		local v = (p.Position.Y - absolutePosition.Y) / absoluteSize.Y
		local _, v2 = object:GetValue()
		local HSV, v3 = v2:ToHSV()
		object:SetColor((Color3.fromHSV(HSV, v3, 1 - v)))
		fx:PlaySound(ui.open, guiObject, false)
	end))
	local manualcolor = guiObject.manualcolor
	object.Trove:Add(manualcolor.red.choice.FocusLost:Connect(function()
		local text = tonumber(manualcolor.red.choice.Text)

		if text and math.isfinite(text) then
			object.Value.r = math.round((math.clamp(text, 0, 255)))
			object:_PushValue()
		else
			object:UpdateSliderState()
		end
	end))
	object.Trove:Add(manualcolor.green.choice.FocusLost:Connect(function()
		local text = tonumber(manualcolor.green.choice.Text)

		if text and math.isfinite(text) then
			object.Value.g = math.round((math.clamp(text, 0, 255)))
			object:_PushValue()
		else
			object:UpdateSliderState()
		end
	end))
	object.Trove:Add(manualcolor.blue.choice.FocusLost:Connect(function()
		local text = tonumber(manualcolor.blue.choice.Text)

		if text and math.isfinite(text) then
			object.Value.b = math.round((math.clamp(text, 0, 255)))
			object:_PushValue()
		else
			object:UpdateSliderState()
		end
	end))
	object:UpdateSliderState()
	return object
end

function CustomColorPicker:GetValue()
	local position = self.GuiObject.wheel.selector.Position
	local position2 = self.GuiObject.lightness.selector.Position
	local v = math.clamp(math.map(position.X.Scale, 0.04, 0.96, 1, 0), 0, 1)
	local v2 = math.clamp(math.map(position.Y.Scale, 0.04, 0.96, 1, 0), 0, 1)
	local v3 = math.clamp(math.map(position2.Y.Scale, 0.015, 0.985, 1, 0), 0, 1)
	local color = Color3.fromHSV(v, v2, v3)
	return {
		r = math.round(color.R * 255),
		g = math.round(color.G * 255),
		b = math.round(color.B * 255)
	}, color
end

function CustomColorPicker:UpdateSliderState()
	local color = Color3.fromRGB(self.Value.r, self.Value.g, self.Value.b)
	local HSV, v, v2 = color:ToHSV()

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
	self.GuiObject.currentcolor.BackgroundColor3 = color
end

function CustomColorPicker:_DragUpdate()
	self.Value = self:GetValue()
	self:UpdateSliderState()
	self.OnChanged(Color3.fromRGB(self.Value.r, self.Value.g, self.Value.b))
end

function CustomColorPicker:_PushValue()
	self:UpdateSliderState()
	self.OnChanged(Color3.fromRGB(self.Value.r, self.Value.g, self.Value.b))
end

function CustomColorPicker:SetColor(color: Color3)
	self.Value = {
		r = math.round(color.R * 255),
		g = math.round(color.G * 255),
		b = math.round(color.B * 255)
	}
	self:UpdateSliderState()
	self.OnChanged(color)
end

function CustomColorPicker:LoadColor(color: Color3)
	self.Value = {
		r = math.round(color.R * 255),
		g = math.round(color.G * 255),
		b = math.round(color.B * 255)
	}
	self:UpdateSliderState()
end

function CustomColorPicker:Destroy()
	self.Trove:Destroy()
	table.clear(self)
end

return CustomColorPicker