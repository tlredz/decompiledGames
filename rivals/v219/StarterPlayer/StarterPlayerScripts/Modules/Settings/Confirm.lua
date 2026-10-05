local Players = game:GetService("Players")
local SettingSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SettingSlot"))
local object = setmetatable({}, SettingSlot)
object.__index = object

function object.new(...)
	local self = setmetatable(SettingSlot.new(...), object)
	self.GreenFrame = self.ControlsConfirmButton:WaitForChild("Green")
	self.RedFrame = self.ControlsConfirmButton:WaitForChild("Red")
	self:_Init()
	return self
end

function object.SetConfirmColor(p, p2)
	p.GreenFrame.Visible = p2 == "Green"
	p.RedFrame.Visible = p2 == "Red"
end

function object._Confirm(object2)
	object2:SetValue(not object2.Value, nil, true)
end

function object:_Setup()
	self.ControlsConfirmButton.Size = UDim2.new(1.538, 0, 0.625, 0)
	self.ControlsConfirmButton.Position = UDim2.new(-0.03, 0, 0.5, 0)
end

function object:_Init()
	self:_Setup()
end

return object