local BottomLeft = {}
BottomLeft.__index = BottomLeft

function BottomLeft.new(fighterInterface)
	local self = setmetatable({}, BottomLeft)
	self.FighterInterface = fighterInterface
	self.Frame = self.FighterInterface.Frame:WaitForChild("BottomLeft")
	self.Container = self.Frame:WaitForChild("Container")
	self:_Init()
	return self
end

function BottomLeft.SetVisible(p, visible)
	p.Frame.Visible = visible
end

function BottomLeft.Destroy(_) end

function BottomLeft:_Init() end

return BottomLeft