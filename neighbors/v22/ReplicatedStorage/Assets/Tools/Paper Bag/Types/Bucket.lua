local cframe = CFrame.Angles(0, 0, 0)
local Bucket = {}

function Bucket.GetEquippedCFrames(p)
	return cframe, CFrame.new(0, p.Size.Y * -2.45, 0)
end

function Bucket.GetPlacedCFrames(_)
	return cframe, CFrame.new(0, 0, 0)
end

return Bucket