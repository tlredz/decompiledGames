local function LerpColor(value: Color3, value2: Color3, p: number)
	local HSV, v, v2 = value:ToHSV()
	local HSV2, v3, v4 = value2:ToHSV()
	local v5 = (HSV + ((HSV2 - HSV + 0.5) % 1 - 0.5) * p) % 1
	return Color3.fromHSV(v5, v + (v3 - v) * p, v2 + (v4 - v2) * p)
end

local function EvalColorSequence(sequence, p: number)
	local keypoints = sequence.Keypoints

	if p <= 0 then
		return keypoints[1].Value
	end

	if p >= 1 then
		return keypoints[#keypoints].Value
	end

	for i = 1, #keypoints - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if keypoint.Time <= p and p < keypoint2.Time then
			return LerpColor(keypoint.Value, keypoint2.Value, (p - keypoint.Time) / (keypoint2.Time - keypoint.Time))
		end
	end

	return keypoints[#keypoints].Value
end

return EvalColorSequence