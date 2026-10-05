local ColorSequenceUtil = {}

function ColorSequenceUtil.eval(sequence, p: number)
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

	return keypoints[#keypoints].Value
end

function ColorSequenceUtil.mergeKeypointTimes(sequence, list)
	local v = {}

	for _, keypoint in ipairs(sequence.Keypoints) do
		table.insert(v, keypoint.Time)
	end

	if list then
		for _, value in ipairs(list) do
			table.insert(v, (math.clamp(value, 0, 1)))
		end
	end

	table.sort(v)
	local result = { v[1] }

	for i = 2, #v do
		if v[i] - result[#result] > 0.00392156862745098 then
			table.insert(result, v[i])
		end
	end

	result[#result] = 1

	while #result > 20 do
		local v2 = 1e999
		local v3 = 2

		for i = 2, #result - 1 do
			local v4 = result[i + 1] - result[i - 1]

			if not (v4 < v2) then
				continue
			end

			v3 = i
			v2 = v4
		end

		table.remove(result, v3)
	end

	return result
end

return ColorSequenceUtil