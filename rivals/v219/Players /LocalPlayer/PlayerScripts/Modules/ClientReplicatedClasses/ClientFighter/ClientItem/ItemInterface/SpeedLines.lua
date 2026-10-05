local SpeedLines = {}
SpeedLines.__index = SpeedLines

function SpeedLines.new(itemInterface)
	local self = setmetatable({}, SpeedLines)
	self.ItemInterface = itemInterface
	self.SpeedLinesThin = self.ItemInterface.Frame:WaitForChild("SpeedLinesThin")
	self.SpeedLinesThick = self.ItemInterface.Frame:WaitForChild("SpeedLinesThick")
	self._destroyed = false
	self._speed_lines_end = 0
	self._next_speedlines_update = 0
	self:_Init()
	return self
end

function SpeedLines:Create(p2)
	self._speed_lines_end = p2 == -1 and 0 or math.max(self._speed_lines_end, tick() + p2)
end

function SpeedLines:Update(_, _, _)
	local visible = tick() < self._speed_lines_end
	self.SpeedLinesThin.Visible = visible
	self.SpeedLinesThick.Visible = visible

	if not visible or tick() < self._next_speedlines_update then
		return
	end

	self._next_speedlines_update = tick() + 0.03
	local v2 = self.ItemInterface.Frame.AbsoluteSize.X / self.ItemInterface.Frame.AbsoluteSize.Y
	self.SpeedLinesThin.Rotation = (self.SpeedLinesThin.Rotation + (math.random() - 0.5) * 72) % 360
	self.SpeedLinesThin.Size = UDim2.new(v2, 0, v2, 0)
	self.SpeedLinesThick.Rotation = (self.SpeedLinesThick.Rotation + (math.random() - 0.5) * 72) % 360
	self.SpeedLinesThick.Size = self.SpeedLinesThin.Size
end

function SpeedLines:Destroy()
	self._destroyed = true
end

function SpeedLines:_Init() end

return SpeedLines