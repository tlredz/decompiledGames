local function evalColorSequence(sequence, p: number)
	if p <= 0 then
		return sequence.Keypoints[1].Value
	end

	if p >= 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local keypoint = sequence.Keypoints[i]
		local keypoint2 = sequence.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return Color3.new(
			(keypoint2.Value.R - keypoint.Value.R) * v + keypoint.Value.R,
			(keypoint2.Value.G - keypoint.Value.G) * v + keypoint.Value.G,
			(keypoint2.Value.B - keypoint.Value.B) * v + keypoint.Value.B
		)
	end

	return sequence.Keypoints[1].Value
end

return evalColorSequence