local cframe = CFrame.Angles(0, -3.141592653589793, 0)
local Pot = {}

function Pot.GetEquippedCFrames(p)
	return cframe, CFrame.new(0, p.Size.Y * 1.15, p.Size.Z * -1.95)
end

function Pot.GetPlacedCFrames(_)
	return cframe, CFrame.new(0, 0, 0)
end

return Pot