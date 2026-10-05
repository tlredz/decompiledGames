local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(frame)
	local v

	if typeof(frame) == "Instance" then
		v = frame:IsA("Frame")
	else
		v = false
	end

	assert(v, "Argument 1 invalid, expected a Frame, got " .. tostring(frame))
	local object = setmetatable({}, ColorPicker)
	object.Frame = frame
	object.RedFrame = object.Frame:WaitForChild("Red")
	object.RedTextBox = object.RedFrame:WaitForChild("Box")
	object.GreenFrame = object.Frame:WaitForChild("Green")
	object.GreenTextBox = object.GreenFrame:WaitForChild("Box")
	object.BlueFrame = object.Frame:WaitForChild("Blue")
	object.BlueTextBox = object.BlueFrame:WaitForChild("Box")
	object.HexFrame = object.Frame:WaitForChild("Hex")
	object.HexTextBox = object.HexFrame:WaitForChild("Box")
	object.HexOutline = object.HexFrame:WaitForChild("Outline")
	object.Value = nil
	object.Updated = Signal.new()
	object.Changed = Signal.new()
	object:_Init()
	return object
end

function ColorPicker:SetColor(p, p2)
	self.Value = p
	self.Updated:Fire(self.Value, p2 or false)
	self:_ValueChanged()
end

function ColorPicker:SetStartingColor(p)
	self.Value = p
	self.Changed:Fire(self.Value)
	self:_ValueChanged()
end

function ColorPicker:Destroy()
	self.Updated:Destroy()
	self.Changed:Destroy()
end

function ColorPicker:_ClampColorChannel(p)
	return (math.clamp(math.floor(tonumber(p) or 0), 0, 255))
end

function ColorPicker:_ValueChanged()
	local text = self.Value
	local color3FromHex = Utility:Color3FromHex(text)
	local _ClampColorChannel = self:_ClampColorChannel(color3FromHex.R * 255)
	local _ClampColorChannel2 = self:_ClampColorChannel(color3FromHex.G * 255)
	local _ClampColorChannel3 = self:_ClampColorChannel(color3FromHex.B * 255)
	self.RedTextBox.Text = _ClampColorChannel
	self.GreenTextBox.Text = _ClampColorChannel2
	self.BlueTextBox.Text = _ClampColorChannel3
	self.HexTextBox.Text = text
	self.HexOutline.ImageColor3 = color3FromHex
end

function ColorPicker:_UpdateFromRGB()
	local _ClampColorChannel = self:_ClampColorChannel(self.RedTextBox.Text)
	local _ClampColorChannel2 = self:_ClampColorChannel(self.GreenTextBox.Text)
	local _ClampColorChannel3 = self:_ClampColorChannel(self.BlueTextBox.Text)
	self:SetColor((Utility:HexFromColor3((Color3.fromRGB(_ClampColorChannel, _ClampColorChannel2, _ClampColorChannel3)))))
end

function ColorPicker:_UpdateFromHex()
	local text = string.lower(self.HexTextBox.Text)
	self:SetColor(Utility:IsValidHex(text) and text or "#000000")
end

function ColorPicker:_Init()
	self.RedTextBox.FocusLost:Connect(function()
		self:_UpdateFromRGB()
	end)
	self.GreenTextBox.FocusLost:Connect(function()
		self:_UpdateFromRGB()
	end)
	self.BlueTextBox.FocusLost:Connect(function()
		self:_UpdateFromRGB()
	end)
	self.HexTextBox.FocusLost:Connect(function()
		self:_UpdateFromHex()
	end)
	self:SetStartingColor("#ffffff")
end

return ColorPicker