local BottomCenter = {}
BottomCenter.__index = BottomCenter

function BottomCenter.new(fighterInterface)
	local self = setmetatable({}, BottomCenter)
	self.FighterInterface = fighterInterface
	self.Frame = self.FighterInterface.Frame:WaitForChild("BottomCenter")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self:_Init()
	return self
end

function BottomCenter.SetVisible(p, visible)
	p.Frame.Visible = visible
end

function BottomCenter.Destroy(_) end

function BottomCenter:_Init() end

return BottomCenter