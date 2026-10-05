local SpeedLines = {}
SpeedLines.__index = SpeedLines

function SpeedLines.new(fighterInterface)
	local self = setmetatable({}, SpeedLines)
	self.FighterInterface = fighterInterface
	self.SpeedLinesThin = self.FighterInterface.Frame:WaitForChild("SpeedLinesThin")
	self.SpeedLinesThick = self.FighterInterface.Frame:WaitForChild("SpeedLinesThick")
	self._next_speedlines_update = 0
	self:_Init()
	return self
end

function SpeedLines:Update(_, p)
	local v = not self.FighterInterface.ClientFighter.Entity and 0 or self.FighterInterface.ClientFighter.Entity:GetBoost("Speed") or 0
	local visible = v > 0
	self.SpeedLinesThin.Visible = visible
	self.SpeedLinesThick.Visible = visible

	if not visible or tick() < self._next_speedlines_update then
		return
	end

	self._next_speedlines_update = tick() + 0.03
	local v3 = math.sqrt(self.FighterInterface.Frame.AbsoluteSize.X ^ 2 + self.FighterInterface.Frame.AbsoluteSize.Y ^ 2)
	local imageTransparency = math.min(0.9, p.MoveSpeed <= 1 and 1 or 1 - math.clamp(v, 0, 1) * 1)
	self.SpeedLinesThin.Rotation = (self.SpeedLinesThin.Rotation + (math.random() - 0.5) * 72) % 360
	self.SpeedLinesThin.Size = UDim2.new(0, v3, 0, v3)
	self.SpeedLinesThick.Rotation = (self.SpeedLinesThick.Rotation + (math.random() - 0.5) * 72) % 360
	self.SpeedLinesThick.Size = self.SpeedLinesThin.Size
	self.SpeedLinesThin.ImageTransparency = imageTransparency
	self.SpeedLinesThick.ImageTransparency = imageTransparency
end

function SpeedLines.Destroy(_) end

function SpeedLines:_Init() end

return SpeedLines