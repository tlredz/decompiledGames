local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ColorPicker = require(Players.LocalPlayer.PlayerScripts.Modules.ColorPicker)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(0, 0, 0)
local object = setmetatable({}, ColorPicker)
object.__index = object

function object.new(...)
	local self = setmetatable(ColorPicker.new(...), object)
	self.ColorWheelFrame = self.Frame:WaitForChild("ColorWheel")
	self.Picture = self.ColorWheelFrame:WaitForChild("Picture")
	self.PictureIcon = self.Picture:WaitForChild("Icon")
	self.Cursor = self.ColorWheelFrame:WaitForChild("Cursor")
	self.CursorImage = self.Cursor:WaitForChild("ImageLabel")
	self.ValueSliderFrame = self.Frame:WaitForChild("ValueSlider")
	self.ValueColor = self.ValueSliderFrame:WaitForChild("Color")
	self.Slider = self.ValueSliderFrame:WaitForChild("Slider")
	self._color_picker_connection = nil
	self._ignore_next_cursor_and_slider_update = false
	self:_Init()
	return self
end

function object:Destroy()
	self:_ClearConnections()
	ColorPicker.Destroy(self)
end

function object:_ClearConnections()
	if self._color_picker_connection then
		self._color_picker_connection:Disconnect()
		self._color_picker_connection = nil
	end
end

function object:_UpdateValueColor()
	local HSV, v, v2 = Utility:Color3FromHex(self.Value):ToHSV()
	local color3 = Color3.fromHSV(HSV, v, 1)
	self.ValueColor.BackgroundColor3 = color3
	self.PictureIcon.ImageColor3 = Color3.new(v2, v2, v2)
	local cursorImage = self.CursorImage
	local imageColor

	if v2 < 0.35 then
		imageColor = color
	else
		imageColor = color2
	end

	cursorImage.ImageColor3 = imageColor
end

function object:_UpdateFromCursorAndSlider()
	local v = self.Cursor.AbsolutePosition + self.Cursor.AbsoluteSize / 2 - (self.Picture.AbsolutePosition + self.Picture.AbsoluteSize / 2)
	local v2 = v.Magnitude / (self.Picture.AbsoluteSize.Y / 2)
	local v3 = math.atan(v.Y / v.X) + (v.X < 0 and 3.141592653589793 or 0)
	local v4 = math.clamp(v3 ~= v3 and 0 or (v3 + 1.5707963267948966) / 6.283185307179586, 0, 1)
	local v5 = math.clamp(v2, 0, 1)
	local v6 = math.clamp(1 - self.Slider.Position.Y.Scale, 0, 1)
	self:SetColor(Utility:HexFromColor3((Color3.fromHSV(v4, v5, v6))), true)
end

function object:_RepositionCursorAndSlider()
	if self._ignore_next_cursor_and_slider_update then
		task.defer(function()
			self._ignore_next_cursor_and_slider_update = false
		end)
		return
	end

	local color3FromHex = Utility:Color3FromHex(self.Value)
	local HSV, v, v2 = color3FromHex:ToHSV(color3FromHex)
	local v3 = HSV * 6.283185307179586 - 1.5707963267948966
	local v4 = v * (self.Picture.AbsoluteSize.Y / 2)
	local v5 = math.cos(v3) * v4 / self.Picture.AbsoluteSize.X
	local v6 = math.sin(v3) * v4 / self.Picture.AbsoluteSize.Y
	self.Slider.Position = UDim2.new(0.5, 0, 1 - v2, 0)
	self.Cursor.Position = UDim2.new(0.5 + v5, 0, 0.5 + v6, 0)
end

function object:_Setup()
	self.Cursor.Visible = true
	self.Slider.Visible = true

	if CONSTANTS.DEVICE == "Console" then
		return
	end

	self.ColorWheelFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:_ClearConnections()
			self._color_picker_connection = RunService.RenderStepped:Connect(function()
				local v = UILibrary:GetMouseLocation() - (self.Picture.AbsolutePosition + self.Picture.AbsoluteSize / 2)
				local v2 = math.clamp(v.Magnitude, 0, self.Picture.AbsoluteSize.Y / 2)
				local v3 = math.atan(v.Y / v.X) + (v.X < 0 and 3.141592653589793 or 0)
				local v4 = math.cos(v3) * v2 / self.Picture.AbsoluteSize.X
				local v5 = math.sin(v3) * v2 / self.Picture.AbsoluteSize.Y
				self._ignore_next_cursor_and_slider_update = true
				self.Cursor.Position = UDim2.new(0.5 + v4, 0, 0.5 + v5, 0)
				self.Cursor.Visible = true
				self:_UpdateFromCursorAndSlider()
			end)
		end
	end)
	self.ColorWheelFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:_ClearConnections()
			self:SetColor(self.Value)
		end
	end)
	self.ValueSliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:_ClearConnections()
			self._color_picker_connection = RunService.RenderStepped:Connect(function()
				local v = math.clamp(
					(UILibrary:GetMouseLocation().Y - self.ValueSliderFrame.AbsolutePosition.Y) / self.ValueSliderFrame.AbsoluteSize.Y,
					0,
					1
				)
				self._ignore_next_cursor_and_slider_update = true
				self.Slider.Position = UDim2.new(0.5, 0, v, 0)
				self.Slider.Visible = true
				self:_UpdateFromCursorAndSlider()
			end)
		end
	end)
	self.ValueSliderFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:_ClearConnections()
			self:SetColor(self.Value)
		end
	end)
end

function object:_Init()
	self.Updated:Connect(function()
		self:_UpdateValueColor()
		self:_RepositionCursorAndSlider()
	end)
	self.Changed:Connect(function()
		self:_UpdateValueColor()
		self:_RepositionCursorAndSlider()
	end)
	self:_Setup()
	self:_RepositionCursorAndSlider()
end

return object