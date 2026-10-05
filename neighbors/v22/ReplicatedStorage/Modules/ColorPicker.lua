local ColorPicker = {}
local UserInputService = game:GetService("UserInputService")
local Janitor = require(game.ReplicatedStorage.Modules.Janitor)
local FastSignal = require(game.ReplicatedStorage.Modules.FastSignal)
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ColorPickerFrame"
screenGui.DisplayOrder = 3
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local function isValidColor(color: Color3)
	local success, _ = pcall(function()
		return color:ToHex()
	end)

	if success then
		return true
	end

	return false
end

function ColorPicker.new(uDim, anchorPoint: Vector2?)
	local object = setmetatable({}, {
		__index = ColorPicker
	})
	object.Janitor = Janitor.new()
	object.Frame = script.ColorPicker:Clone()
	object.Wheel = object.Frame.Wheel.ColorWheel
	object.Cursor = object.Wheel.Cursor
	object.ActiveColor = object.Frame.ActiveColor
	object.Value = object.Frame.ValueSelector
	object.ValueCursor = object.Value.Cursor
	object.Hex = object.Frame.Hex
	object.Color = Color3.fromRGB(255, 255, 255)
	object.Instance = nil
	object.CursorPosition = nil
	object.ValuePosition = nil
	object.ColorUpdated = FastSignal.new()
	local frame = object.Frame

	if typeof(uDim) == "Vector2" then
		uDim = UDim2.new(0, uDim.X, 0, uDim.Y) or uDim
	end

	frame.Position = uDim

	if anchorPoint then
		object.Frame.AnchorPoint = anchorPoint
	end

	object.Frame.Parent = screenGui
	object.Janitor:Add(object.ColorUpdated, "Destroy")
	object.Janitor:LinkToInstance(object.Frame)
	object:Build()
	return object
end

function ColorPicker:Build()
	self.WheelActive = false
	self.ValueActive = false
	self.Janitor:Add(self.Wheel.MouseButton1Down:Connect(function()
		self.WheelActive = true
		self:SetCursorPosition(mouse.X, mouse.Y)
	end))
	self.Janitor:Add(self.Value.MouseButton1Down:Connect(function()
		self.ValueActive = true
		self:SetValuePosition(mouse.Y)
	end))
	self.Janitor:Add(mouse.Move:Connect(function()
		if self.WheelActive then
			self:SetCursorPosition(mouse.X, mouse.Y)
		elseif self.ValueActive then
			self:SetValuePosition(mouse.Y)
		end
	end))
	self.Janitor:Add(self.Wheel.MouseButton1Up:Connect(function()
		self.WheelActive = false
		self.ValueActive = false
	end))
	self.Janitor:Add(UserInputService.InputEnded:Connect(function(input)
		if (self.WheelActive or self.ValueActive) and (input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonR2) then
			self.WheelActive = false
			self.ValueActive = false
		end
	end))
	self.Janitor:Add(self.Value.MouseButton1Up:Connect(function()
		self.WheelActive = false
		self.ValueActive = false
	end))
	self.Hex.FocusLost:Connect(function()
		local success, result = pcall(function()
			return Color3.fromHex(self.Hex.Text)
		end)

		if success and result then
			self:SetColor(result)
		else
			self.Hex.Text = ""
		end
	end)
end

function ColorPicker:SetColor(color: Color3)
	local success, _ = pcall(function()
		return color:ToHex()
	end)

	if not success then
		color = Color3.fromRGB(255, 255, 255)
	end

	self.Color = color
	self:UpdateCursorAndValuePosition()
end

function ColorPicker:SetCursorPosition(p: number, p2: number)
	local scale = self:GetScale()
	local v = self.Wheel.AbsoluteSize * 0.5
	local v2 = self.Wheel.AbsolutePosition + v
	local v3 = Vector2.new(p, p2) - v2
	local v4 = math.atan2(v3.Y, v3.X)
	local v5 = math.min(v3.Magnitude, v.X) / scale
	local v6 = Vector2.new(math.cos(v4), -math.sin(v4)) * v5
	self.Cursor.Position = UDim2.new(0.5, v6.X, 0.5, -v6.Y)
	return self:SetColorBasedOnCursor()
end

function ColorPicker:SetValuePosition(p: number)
	local v = math.clamp((p - self.Value.AbsolutePosition.Y) / self.Value.AbsoluteSize.Y, 0, 1)
	self.ValueCursor.Position = UDim2.new(0, 0, v, 0)
	return self:SetColorBasedOnCursor()
end

function ColorPicker:SetColorBasedOnCursor()
	local v = self.Wheel.AbsoluteSize.X * 0.5
	local scale = self:GetScale()
	local v2 = Vector2.new(self.Cursor.Position.X.Offset, -self.Cursor.Position.Y.Offset) * scale
	local v3 = 1 - self.ValueCursor.Position.Y.Scale
	local v4 = math.deg((math.atan2(v2.Y, v2.X)))

	if v4 <= 0 then
		v4 += 360
	end

	local v5 = v4 / 360
	local v6 = math.clamp(v2.Magnitude / v, 0, 1)

	if v2.Magnitude == 0 then
		self.Color = Color3.fromHSV(0, 0, v3)
	else
		self.Color = Color3.fromHSV(v5, v6, v3)
	end

	self:Update()
end

function ColorPicker:UpdateCursorAndValuePosition()
	local v = self.Wheel.AbsoluteSize.X * 0.5
	local scale = self:GetScale()
	local HSV, v2, v3 = self.Color:ToHSV()
	local v4 = math.rad(HSV * 360)
	local v5 = Vector2.new(math.cos(v4), (math.sin(v4))) * v2 * v
	self.Cursor.Position = UDim2.new(0.5, v5.X / scale, 0.5, -v5.Y / scale)
	self.ValueCursor.Position = UDim2.new(0, 0, 1 - v3, 0)
	self:Update()
end

function ColorPicker:Update()
	local _, _, v = self.Color:ToHSV()
	local success, result = pcall(function()
		return self.Color:ToHex()
	end)
	self.Wheel.ImageColor3 = Color3.new(v, v, v)
	self.ActiveColor.BackgroundColor3 = self.Color

	if success and result then
		self.Hex.Text = `#{result:upper()}`
	else
		self.Hex.Text = ""
	end

	self.ColorUpdated:Fire(self.Color)
end

function ColorPicker:GetScale()
	return 1
end

function ColorPicker:Destroy()
	self.Janitor:Destroy()
	self.Frame:Destroy()
	table.clear(self)
end

return ColorPicker