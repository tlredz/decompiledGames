local cframe = CFrame.Angles(0, 0, 3.141592653589793)
local _8BitPaperBag = {}

function _8BitPaperBag.GetEquippedCFrames(p)
	return cframe, CFrame.new(0, p.Size.Y * -2.45, 0)
end

function _8BitPaperBag.GetPlacedCFrames(_)
	return cframe, CFrame.new(0, 0, 0)
end

return _8BitPaperBag