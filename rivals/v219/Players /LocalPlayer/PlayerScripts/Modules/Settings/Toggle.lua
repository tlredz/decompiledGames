local Players = game:GetService("Players")
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local SettingSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SettingSlot"))
local color = Color3.fromRGB(0, 0, 0)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(100, 255, 50)
local object = setmetatable({}, SettingSlot)
object.__index = object

function object.new(...)
	local self = setmetatable(SettingSlot.new(...), object)
	self.ToggleContainer = self.ControlsSettingFrame:WaitForChild("Container")
	self.Background = self.ToggleContainer:WaitForChild("Background")
	self.Button = self.ToggleContainer:WaitForChild("Button")
	self.Slider = self.Button:WaitForChild("Slider")
	self._custom_value_set = false
	self:_Init()
	return self
end

function object:_Update()
	local uDim = self.Value and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)

	if self.Slider:IsDescendantOf(game) then
		self.Slider:TweenPosition(uDim, "Out", "Quint", 0.5, true)
	else
		self.Slider.Position = uDim
	end
end

function object:_Toggle()
	self:InputValue(not self.Value)
end

function object:_Init()
	self.Changed:Connect(function()
		self:_Update()
	end)
	self.Button.MouseButton1Click:Connect(function()
		self:_Toggle()
	end)
	self.Slider:GetPropertyChangedSignal("Position"):Connect(function()
		local v = (self.Slider.Position.X.Scale - 0.25) / 0.5
		self.Slider.ImageColor3 = color:Lerp(color, v)
		self.Background.ImageColor3 = color2:Lerp(color3, v)
	end)
	self:_Update()
	ButtonEffect:Add(self.Button, nil, {
		ReleaseRatio = 0.95,
		HoverRatio = 0.95
	})
end

return object