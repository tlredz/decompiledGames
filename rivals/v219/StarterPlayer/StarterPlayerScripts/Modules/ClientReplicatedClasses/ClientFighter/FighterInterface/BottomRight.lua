local BottomRight = {}
BottomRight.__index = BottomRight

function BottomRight.new(fighterInterface)
	local self = setmetatable({}, BottomRight)
	self.FighterInterface = fighterInterface
	self.Frame = self.FighterInterface.Frame:WaitForChild("BottomRight")
	self.Container = self.Frame:WaitForChild("Container")
	self:_Init()
	return self
end

function BottomRight.SetVisible(p, visible)
	p.Frame.Visible = visible
end

function BottomRight.Destroy(_) end

function BottomRight:_Init() end

return BottomRight