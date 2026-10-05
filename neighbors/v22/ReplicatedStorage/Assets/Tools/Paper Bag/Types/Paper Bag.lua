local cframe = CFrame.Angles(0, -1.5707963267948966, -1.5707963267948966)
local PaperBag = {}

function PaperBag.GetEquippedCFrames(p)
	return cframe, CFrame.new(0, p.Size.Y * -2.45, 0)
end

function PaperBag.GetPlacedCFrames(_)
	return cframe, CFrame.new(0, 0, 0)
end

return PaperBag