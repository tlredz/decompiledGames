local function IsSequenceNotConstant(sequence)
	return #sequence.Keypoints > 2 or sequence.Keypoints[1].Value ~= sequence.Keypoints[2].Value
end

return IsSequenceNotConstant