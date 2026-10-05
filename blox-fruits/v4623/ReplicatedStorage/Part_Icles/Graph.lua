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
		local result = {}

		if not sequence or typeof(sequence) ~= "NumberSequence" then
			return result
		end

		local keypoints = sequence.Keypoints
		local v = math.random()
		local v2 = math.random() >= 0.5

		for i = 1, #keypoints do
			if not (keypoints[i].Envelope > 0) then
				continue
			end

			if v2 then
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
	local count = #keypoints

	if count == 1 then
		return keypoints[1].Value + (list[1] or 0)
	end

	local v2 = 1

	while v2 < count - 1 do
		local v3 = (v2 + count) // 2

		if keypoints[v3].Time <= v then
			v2 = v3
		else
			count = v3
		end
	end

	local keypoint = keypoints[v2]
	local keypoint2 = keypoints[v2 + 1]
	local v3 = keypoint2.Time - keypoint.Time
	local v4 = not (v3 > 0) and 0 or (v - keypoint.Time) / v3 or 0
	local v5 = keypoint.Value + (list[v2] or 0)
	return v5 + (keypoint2.Value + (list[v2 + 1] or 0) - v5) * v4
end

function Graph.QueryColorPointWithTime(value: number, sequence)
	local v = math.clamp(value, 0, 1)
	local keypoints = sequence.Keypoints
	local count = #keypoints

	if count == 0 then
		return Color3.new(1, 1, 1)
	elseif count == 1 then
		return keypoints[1].Value
	end

	if v <= keypoints[1].Time then
		return keypoints[1].Value
	end

	local v2 = 1

	while v2 < count - 1 do
		local v3 = (v2 + count) // 2

		if keypoints[v3].Time <= v then
			v2 = v3
		else
			count = v3
		end
	end

	local keypoint = keypoints[v2]
	local keypoint2 = keypoints[v2 + 1]
	local v3 = keypoint2.Time - keypoint.Time
	local v4 = not (v3 > 0) and 0 or (v - keypoint.Time) / v3 or 0
	return keypoint.Value:Lerp(keypoint2.Value, v4)
end

function Graph.IntegrateUpTo(value: number, sequence, list)
	local v = math.clamp(value, 0, 1)
	local keypoints = sequence.Keypoints
	local count = #keypoints

	if count == 0 then
		return 0
	elseif count == 1 then
		return (keypoints[1].Value + (list[1] or 0)) * v
	end

	local total = 0

	for i = 1, count - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if v <= keypoint.Time then
			break
		end

		local v2 = keypoint.Value + (list[i] or 0)
		local v3 = keypoint2.Value + (list[i + 1] or 0)
		local v4 = math.min(v, keypoint2.Time)
		local v5 = v4 - keypoint.Time
		local v6 = keypoint2.Time - keypoint.Time
		local v7 = v6 > 0 and (v4 - keypoint.Time) / v6 or 0
		total += (v2 + (v2 + (v3 - v2) * v7)) / 2 * v5

		if v <= keypoint2.Time then
			break
		end
	end

	return total
end

function Graph.IsStatic(sequence)
	if not sequence then
		return true
	end

	local keypoints = sequence.Keypoints

	if #keypoints == 1 then
		return keypoints[1].Envelope == 0
	end

	local value = keypoints[1].Value

	if keypoints[1].Envelope ~= 0 then
		return false
	end

	for i = 2, #keypoints do
		if keypoints[i].Value ~= value or keypoints[i].Envelope ~= 0 then
			return false
		end
	end

	return true
end

function Graph.GetStaticValue(sequence, p: number)
	if sequence and #sequence.Keypoints ~= 0 then
		return sequence.Keypoints[1].Value
	end

	return p
end

local function _mergeSequenceTimes(p, p2)
	local v = {}
	local times = {}

	for _, v2 in ipairs({ p, p2 }) do
		for _, keypoint in ipairs(v2.Keypoints) do
			if v[keypoint.Time] then
				continue
			end

			v[keypoint.Time] = true
			table.insert(times, keypoint.Time)
		end
	end

	table.sort(times)
	return times
end

function Graph.BlendGraphWithTime(p, p2, p3, value: number)
	local v = value or 1
	local v2 = v < 0 and 0 or v > 1 and 1 or v
	local v3 = _mergeSequenceTimes(p, p2)
	local pointsWithTime = Graph.QueryPointsWithTime(v2, p3, {})
	local numberSequenceKeypoints = {}

	for _, v4 in ipairs(v3) do
		local pointsWithTime2 = Graph.QueryPointsWithTime(v4, p, {})
		local pointsWithTime3 = Graph.QueryPointsWithTime(v4, p2, {})
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(v4, pointsWithTime2 + (pointsWithTime3 - pointsWithTime2) * pointsWithTime)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function Graph.BlendColorGraphWithTime(p, p2, p3, value: number)
	local v = value or 1
	local v2 = v < 0 and 0 or v > 1 and 1 or v
	local v3 = _mergeSequenceTimes(p, p2)
	local pointsWithTime = Graph.QueryPointsWithTime(v2, p3, {})
	local colorSequenceKeypoints = {}

	for _, v4 in ipairs(v3) do
		local colorPointWithTime = Graph.QueryColorPointWithTime(v4, p)
		local colorPointWithTime2 = Graph.QueryColorPointWithTime(v4, p2)
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(v4, colorPointWithTime:Lerp(colorPointWithTime2, pointsWithTime))
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function Graph.LerpGraph(p, p2, value: number)
	local v = value or 0
	local v2 = v < 0 and 0 or v > 1 and 1 or v
	local v3 = _mergeSequenceTimes(p, p2)
	local numberSequenceKeypoints = {}

	for _, v4 in ipairs(v3) do
		local pointsWithTime = Graph.QueryPointsWithTime(v4, p, {})
		local pointsWithTime2 = Graph.QueryPointsWithTime(v4, p2, {})
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(v4, pointsWithTime + (pointsWithTime2 - pointsWithTime) * v2)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function Graph.LerpColorGraph(p, p2, value: number)
	local v = value or 0
	local v2 = v < 0 and 0 or v > 1 and 1 or v
	local v3 = _mergeSequenceTimes(p, p2)
	local colorSequenceKeypoints = {}

	for _, v4 in ipairs(v3) do
		local colorPointWithTime = Graph.QueryColorPointWithTime(v4, p)
		local colorPointWithTime2 = Graph.QueryColorPointWithTime(v4, p2)
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(v4, colorPointWithTime:Lerp(colorPointWithTime2, v2))
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function Graph.PrecomputeMergedTimes(p, p2)
	return (_mergeSequenceTimes(p, p2))
end

function Graph.PrecomputeMergedColorTimes(p, p2)
	return (_mergeSequenceTimes(p, p2))
end

function Graph.LerpGraphFast(p, p2, value: number, list)
	local v = value or 0
	local v2 = v < 0 and 0 or v > 1 and 1 or v

	if v2 == 0 then
		return p
	elseif v2 == 1 then
		return p2
	end

	local numberSequenceKeypoints = {}

	for _, v3 in ipairs(list) do
		local pointsWithTime = Graph.QueryPointsWithTime(v3, p, {})
		local pointsWithTime2 = Graph.QueryPointsWithTime(v3, p2, {})
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(v3, pointsWithTime + (pointsWithTime2 - pointsWithTime) * v2)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function Graph.LerpColorGraphFast(p, p2, value: number, list)
	local v = value or 0
	local v2 = v < 0 and 0 or v > 1 and 1 or v

	if v2 == 0 then
		return p
	elseif v2 == 1 then
		return p2
	end

	local colorSequenceKeypoints = {}

	for _, v3 in ipairs(list) do
		local colorPointWithTime = Graph.QueryColorPointWithTime(v3, p)
		local colorPointWithTime2 = Graph.QueryColorPointWithTime(v3, p2)
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(v3, colorPointWithTime:Lerp(colorPointWithTime2, v2))
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function Graph.CollectGraphStates(instance)
	local result = {}
	local result2 = {}

	if not instance then
		return result, result2
	end

	for _, configuration in pairs(instance:GetChildren()) do
		if not configuration:IsA("Configuration") then
			continue
		end

		local time = configuration:GetAttribute("Time")

		if time == nil then
			local v = tonumber(string.match(configuration.Name, "%d+"))
			time = v and v - 1 or 0
		end

		local transparency = configuration:GetAttribute("Transparency")

		if transparency and typeof(transparency) == "NumberSequence" then
			table.insert(result, {
				Time = time,
				Graph = transparency
			})
		end

		local color = configuration:GetAttribute("Color")

		if color and typeof(color) == "ColorSequence" then
			table.insert(result2, {
				Time = time,
				Graph = color
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(result2, function(a, b)
		return a.Time < b.Time
	end)

	for _, list in ipairs({ result, result2 }) do
		if not (#list > 1 and list[#list].Time > 1) then
			continue
		end

		local time = list[#list].Time

		if not (time > 0) then
			continue
		end

		for _, v in ipairs(list) do
			v.Time /= time
		end
	end

	return result, result2
end

function Graph.InitialEffectiveElapsed(p, options, p2)
	if p and typeof(p) == "NumberSequence" then
		return Graph.QueryPointsWithTime(0, p, options or {}) < 0 and p2 or 0
	end

	return 0
end

function Graph.ScaleSequence(sequence, p)
	if not sequence or typeof(sequence) ~= "NumberSequence" then
		return sequence
	end

	local keypoints = sequence.Keypoints
	local v = math.abs(p)
	local numberSequenceKeypoints = {}

	for _, keypoint in ipairs(keypoints) do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * v)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

return Graph