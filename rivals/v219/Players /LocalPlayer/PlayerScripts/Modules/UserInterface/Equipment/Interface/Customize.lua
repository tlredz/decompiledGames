local NameDisplay = require(script:WaitForChild("NameDisplay"))
local Description = require(script:WaitForChild("Description"))
local Cosmetics = require(script:WaitForChild("Cosmetics"))
local Actions = require(script:WaitForChild("Actions"))
local Options = require(script:WaitForChild("Options"))
local Customize = {}
Customize.__index = Customize

function Customize.new(interface)
	local self = setmetatable({}, Customize)
	self.Interface = interface
	self.Frame = self.Interface.Frame:WaitForChild("Customize")
	self.TopFrame = self.Frame:WaitForChild("Top")
	self.BottomFrame = self.Frame:WaitForChild("Bottom")
	self.BottomContainer = self.BottomFrame:WaitForChild("Container")
	self.Options = Options.new(self)
	self.Actions = Actions.new(self)
	self.Cosmetics = Cosmetics.new(self)
	self.NameDisplay = NameDisplay.new(self)
	self.Description = Description.new(self)
	self:_Init()
	return self
end

function Customize.SetVisible(p, p2)
	p.BottomFrame:TweenPosition(p2 and UDim2.new(0.5, 0, 1, 0) or UDim2.new(0.5, 0, 1.5, 0), "Out", "Quint", 0.25, true)
	p.TopFrame:TweenPosition(p2 and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0.5, 0, -0.5, 0), "Out", "Quint", 0.25, true)
end

function Customize:OnCustomizingStateChanged(...)
	self.Options:OnCustomizingStateChanged(...)
	self.Actions:OnCustomizingStateChanged(...)
	self.Cosmetics:OnCustomizingStateChanged(...)
	self.Description:OnCustomizingStateChanged(...)
	self.NameDisplay:OnCustomizingStateChanged(...)
end

function Customize:OnStateChanged(...)
	self.Cosmetics:OnStateChanged(...)
	self.Actions:OnStateChanged(...)
	self.Options:OnStateChanged(...)
end

function Customize:_Setup()
	self.Frame.Visible = true
end

function Customize:_Init()
	self:_Setup()
end

return Customize