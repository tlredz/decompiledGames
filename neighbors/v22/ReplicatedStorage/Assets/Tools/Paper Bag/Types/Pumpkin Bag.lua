local cframe = CFrame.Angles(0, 3.141592653589793, 0)
local PumpkinBag = {}

function PumpkinBag.GetEquippedCFrames(p)
	return cframe, CFrame.new(0, p.Size.Y * -2.45, 0)
end

function PumpkinBag.GetPlacedCFrames(_)
	return cframe, CFrame.new(0, 0, 0)
end

return PumpkinBag