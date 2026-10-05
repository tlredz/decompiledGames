return function(sequence, sequence2, value, value2, p, value3, p2, p3)
	assert(sequence and typeof(sequence) == "NumberSequence", "Invalid numberSequence")
	assert(sequence2 and typeof(sequence2) == "NumberSequence", "Invalid targetSequence")
	local v

	if value then
		if type(value) == "number" then
			v = value > 0
		else
			v = false
		end
	else
		v = value
	end

	assert(v, "Invalid smoothness")
	local v2

	if value2 then
		if type(value2) == "number" then
			v2 = value2 > 0
		else
			v2 = false
		end
	else
		v2 = value2
	end

	assert(v2, "Invalid timeTaken")
	assert(type(p[value3]) == "userdata", "Invalid objectToUpdate")
	assert(value3 and type(value3) == "string", "Invalid propertyName")
	local keypoints = sequence.Keypoints
	local keypoints2 = sequence2.Keypoints
	local times = {}
	local v3 = {}
	local envelopes = {}

	for _, keypoint in ipairs(keypoints) do
		table.insert(times, keypoint.Time)
		table.insert(v3, keypoint.Value)
		table.insert(envelopes, keypoint.Envelope)
	end

	local function updateNumberSequence(value4)
		local numberSequenceKeypoints = {}

		for i, v4 in ipairs(times) do
			local v5 = math.abs(v4 - keypoints2[1].Time)
			local v6 = 1

			for i2, keypoint in ipairs(keypoints2) do
				local v7 = math.abs(v4 - keypoint.Time)

				if not (v7 < v5) then
					continue
				end

				v6 = i2
				v5 = v7
			end

			local value5 = keypoints2[v6].Value
			local envelope = keypoints2[v6].Envelope
			local v7 = v3[i]
			local v8 = v7 + (value5 - v7) * value4
			local v9 = envelopes[i]
			local v10 = v9 + (envelope - v9) * value4
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v4, v8, v10))
		end

		return NumberSequence.new(numberSequenceKeypoints)
	end

	for i = 0, 1, 1 / (value * value2) do
		p[value3] = updateNumberSequence(game.TweenService:GetValue(i, p2, p3))
		task.wait(1 / value)
	end

	local numberSequenceKeypoints = {}

	for _, v4 in ipairs(times) do
		local v5 = math.abs(v4 - keypoints2[1].Time)
		local v6 = 1

		for i, keypoint in ipairs(keypoints2) do
			local v7 = math.abs(v4 - keypoint.Time)

			if not (v7 < v5) then
				continue
			end

			v6 = i
			v5 = v7
		end

		local value4 = keypoints2[v6].Value
		local _ = keypoints2[v6].Envelope
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v4, value4, value4))
	end

	p[value3] = NumberSequence.new(numberSequenceKeypoints)
end