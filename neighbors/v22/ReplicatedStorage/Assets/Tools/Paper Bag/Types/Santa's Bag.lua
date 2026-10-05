local cframe = CFrame.Angles(0, 1.5707963267948966, 0)
local SantaSBag = {}

function SantaSBag.GetEquippedCFrames(p)
	return cframe, CFrame.new(0, p.Size.Y * -2.45, 0)
end

function SantaSBag.GetPlacedCFrames(_)
	return cframe, CFrame.new(0, 0, 0)
end

return SantaSBag