local GuiService = game:GetService("GuiService")
local parent = script.Parent.Parent.Parent
local NexusInstance = require(parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local class = {}
class.__index = class

function class:__new(name: string)
	self.Name = name
	self.Destroyed = self:CreateEvent()
	self.Frame = Instance.new("Frame")
	self.Frame.Name = tostring(self.Name)
	self.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.Frame.BackgroundTransparency = 1
	self.Frame.Size = UDim2.new(1, 0, 1, 0)
	self.Frame.Visible = false
	self.Frame.SizeConstraint = Enum.SizeConstraint.RelativeXX
	self:GetPropertyChangedSignal("Name"):Connect(function()
		self.Frame.Name = tostring(self.Name)
	end)
	self:GetPropertyChangedSignal("Visible"):Connect(function()
		self.Frame.Visible = self.Visible
	end)
end

function class.GetContainer(p)
	return p.Frame
end

function class.AddBackground(p)
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.05, 0)
	uICorner.Parent = p.Frame
	p.Frame.BackgroundTransparency = 0.6 * GuiService.PreferredTransparency
	GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		p.Frame.BackgroundTransparency = 0.6 * GuiService.PreferredTransparency
	end)
end

function class:Destroy()
	self.Destroyed:Fire()
	self.Frame:Destroy()
end

return (NexusInstance.ToInstance(class))