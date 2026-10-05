local function clamp(p, p2, p3)
	if p < p2 then
		return p2
	end

	if p3 < p then
		return p3
	end

	return p
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local Graph = {
	GenerateSeed = function(sequence)
		local keypoints = sequence.Keypoints
		local v = math.random()
		local v2 = math.random() >= 0.5
		local result = {}

		for i = 1, #keypoints do
			if not (keypoints[i].Envelope > 0) then
				continue
			end

			if v2 == true then
				result[i] = v * keypoints[i].Envelope
			else
				result[i] = -v * keypoints[i].Envelope
			end
		end

		return result
	end
}

function Graph.GenerateSeeds(p, p2: number)
	local result = {}

	for i = 1, p2 do
		result[i] = Graph.GenerateSeed(p)
	end

	return result
end

function Graph.QueryPointsWithTime(value: number, sequence, list)
	local v = math.clamp(value, 0, 1)
	local keypoints = sequence.Keypoints

	if #keypoints == 1 then
		return keypoints[1].Value + (list[1] or 0)
	end

	for i = 1, #keypoints - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (keypoint.Time <= v and v <= keypoint2.Time) then
			continue
		end

		local v2 = (v - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		local v3 = keypoint.Value + (list[i] or 0)
		return v3 + (keypoint2.Value + (list[i + 1] or 0) - v3) * v2
	end

	return keypoints[#keypoints].Value + (list[#keypoints] or 0)
end

function Graph.QueryColorPointWithTime(p: number, sequence)
	local keypoints = sequence.Keypoints

	if #keypoints == 0 then
		return Color3.new(1, 1, 1)
	end

	if #keypoints == 1 or p <= keypoints[1].Time then
		return keypoints[1].Value
	end

	for i = 1, #keypoints - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (keypoint.Time <= p and p <= keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value:Lerp(keypoint2.Value, v)
	end

	return keypoints[#keypoints].Value
end

function Graph.BlendGraphWithTime(sequence, sequence2, p, value: number)
	local v = value or 1
	local v2 = v < 0 and 0 or v > 1 and 1 or v
	local v3 = {}
	local times = {}

	for _, v4 in ipairs({ sequence, sequence2 }) do
		for _, keypoint in ipairs(v4.Keypoints) do
			if v3[keypoint.Time] then
				continue
			end

			v3[keypoint.Time] = true
			table.insert(times, keypoint.Time)
		end
	end

	table.sort(times)
	local numberSequenceKeypoints = {}
	local numberSequenceKeypoints2 = {}

	for _, v4 in ipairs(times) do
		local v5 = Graph.QueryPointsWithTime(v4, sequence, {}) or sequence.Keypoints[#sequence.Keypoints].Value
		local v6 = Graph.QueryPointsWithTime(v4, sequence2, {}) or sequence2.Keypoints[#sequence2.Keypoints].Value
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v4, v5))
		table.insert(numberSequenceKeypoints2, NumberSequenceKeypoint.new(v4, v6))
	end

	local v4 = Graph.QueryPointsWithTime(v2, p, {}) or 1
	local numberSequenceKeypoints3 = {}

	for i, v5 in ipairs(numberSequenceKeypoints) do
		local time = v5.Time
		local value2 = v5.Value
		local v6 = value2 + (numberSequenceKeypoints2[i].Value - value2) * v4
		table.insert(numberSequenceKeypoints3, NumberSequenceKeypoint.new(time, v6))
	end

	return NumberSequence.new(numberSequenceKeypoints3)
end

function Graph.BlendColorGraphWithTime(p, p2, p3, value: number)
	local v = value or 1
	local v2 = v < 0 and 0 or v > 1 and 1 or v
	local v3 = {}
	local times = {}

	for _, v4 in ipairs({ p, p2 }) do
		for _, keypoint in ipairs(v4.Keypoints) do
			if v3[keypoint.Time] then
				continue
			end

			v3[keypoint.Time] = true
			table.insert(times, keypoint.Time)
		end
	end

	table.sort(times)
	local v4 = Graph.QueryPointsWithTime(v2, p3, {}) or 1
	local colorSequenceKeypoints = {}

	for _, v5 in ipairs(times) do
		local lerped = Graph.QueryColorPointWithTime(v5, p):Lerp(Graph.QueryColorPointWithTime(v5, p2), v4)
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v5, lerped))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

return Graph