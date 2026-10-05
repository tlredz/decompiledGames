local function createSequence(list)
	local v = list[1]
	assert(v ~= nil, "cannot create a sequence without keypoints")

	if typeof(v[2]) == "number" then
		local numberSequenceKeypoints = {}

		for _, v2 in list do
			local v3 = v2[1]
			local v4 = v2[2]
			local v5

			if typeof(v3) == "number" then
				v5 = typeof(v4) == "number"
			else
				v5 = false
			end

			assert(v5, "all sequence values must be numbers")
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v3, v4))
		end

		return NumberSequence.new(numberSequenceKeypoints)
	else
		local colorSequenceKeypoints = {}

		for _, v2 in list do
			local v3 = v2[1]
			local v4 = v2[2]
			local v5

			if typeof(v3) == "number" then
				v5 = typeof(v4) == "Color3"
			else
				v5 = false
			end

			assert(v5, "all sequence values must be Color3 values")
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v3, v4))
		end

		return ColorSequence.new(colorSequenceKeypoints)
	end
end

local SequenceUtils = {}

function SequenceUtils.getSequenceValueAtTime(sequence, p: number)
	local count = #sequence.Keypoints
	assert(count > 0, "sequence must contain at least one keypoint")

	if p <= 0 then
		return sequence.Keypoints[1].Value
	end

	if p >= 1 then
		return sequence.Keypoints[count].Value
	end

	if typeof(sequence) == "NumberSequence" then
		local keypoints = sequence.Keypoints

		for i = 1, #keypoints - 1 do
			local keypoint = keypoints[i]
			local keypoint2 = keypoints[i + 1]

			if not (keypoint.Time <= p and p < keypoint2.Time) then
				continue
			end

			local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
			return (math.lerp(keypoint.Value, keypoint2.Value, v))
		end
	else
		local keypoints = sequence.Keypoints

		for i = 1, #keypoints - 1 do
			local keypoint = keypoints[i]
			local keypoint2 = keypoints[i + 1]

			if not (keypoint.Time <= p and p < keypoint2.Time) then
				continue
			end

			local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
			return keypoint.Value:Lerp(keypoint2.Value, v)
		end
	end

	error("time did not fall between the sequence keypoints")
end

function SequenceUtils.scaleNumberSequence(sequence, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in sequence.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * math.abs(p))
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

SequenceUtils.create = createSequence
return SequenceUtils