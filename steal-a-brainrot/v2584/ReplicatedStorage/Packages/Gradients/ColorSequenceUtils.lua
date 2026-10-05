local function evalColorSequence(list, p: number)
	local v = p + 1
	local v2 = {}

	for i = 0, 2 do
		for i2 = 1, #list do
			table.insert(v2, {
				Time = list[i2].Time + i,
				Value = list[i2].Value
			})
		end
	end

	for i = 1, #v2 - 1 do
		local v3 = v2[i]
		local v4 = v2[i + 1]

		if not (v3.Time <= v and v < v4.Time) then
			continue
		end

		local v5 = (v - v3.Time) / (v4.Time - v3.Time)
		return Color3.new(
			(v4.Value.R - v3.Value.R) * v5 + v3.Value.R,
			(v4.Value.G - v3.Value.G) * v5 + v3.Value.G,
			(v4.Value.B - v3.Value.B) * v5 + v3.Value.B
		)
	end
end

return {
	calculateColorSequence = function(sequence, p: number)
		local time = 100
		local v = 5
		local colorSequenceKeypoints = {}

		for _, keypoint in sequence.Keypoints do
			local v2 = keypoint.Time + p

			if v2 > 1 or v2 < 0 then
				v2 %= 1
			end

			local colorSequenceKeypoint = ColorSequenceKeypoint.new(v2, keypoint.Value)

			if colorSequenceKeypoint.Time <= time then
				colorSequenceKeypoints[v - 1] = colorSequenceKeypoint
				v -= 1
				time = colorSequenceKeypoint.Time
			else
				colorSequenceKeypoints[#colorSequenceKeypoints + 1] = colorSequenceKeypoint
			end
		end

		local v2 = {}

		for _, v3 in colorSequenceKeypoints do
			table.insert(v2, v3)
		end

		table.sort(v2, function(a, b)
			return a.Time < b.Time
		end)

		if v2[1].Time ~= 0 then
			table.insert(v2, 1, (ColorSequenceKeypoint.new(0, evalColorSequence(v2, 0))))
		end

		if v2[#v2].Time ~= 1 then
			table.insert(v2, (ColorSequenceKeypoint.new(1, evalColorSequence(v2, 1))))
		end

		return ColorSequence.new(v2)
	end
}