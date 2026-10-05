local function GradientRichText(p: string, sequence)
	if typeof(sequence) == "Color3" then
		return (`<font color="#{sequence:ToHex()}">{p}</font>`)
	end

	if typeof(sequence) ~= "ColorSequence" then
		return p
	end

	local v = utf8.len(p)

	if not v then
		warn((`text "{p}" contains invalid utf-8 sequences, skipping GradientRichText`))
		return p
	end

	local v2 = table.create(v * 5)
	local keypoints = sequence.Keypoints
	local keypoint = keypoints[1]
	local keypoint2 = keypoints[2]
	local v3 = 2

	for k, v4 in utf8.codes(p) do
		local v5 = (k - 1) / math.max(v - 1, 1)
		local v6

		while true do
			if not (keypoint2.Time < v5) then
				v6 = keypoint2
				break
			end

			v3 += 1
			local keypoint3 = keypoints[v3]

			if keypoint3 then
				keypoint = keypoint2
				keypoint2 = keypoint3
			else
				warn("bad gradient!!!")
				v6 = keypoints[#keypoints]
				keypoint = keypoint2
				break
			end
		end

		local v7 = (v5 - keypoint.Time) / (v6.Time - keypoint.Time)
		local lerped = keypoint.Value:Lerp(v6.Value, v7)
		table.insert(v2, "<font color='#")
		table.insert(v2, lerped:ToHex())
		table.insert(v2, "'>")
		table.insert(v2, utf8.char(v4))
		table.insert(v2, "</font>")
		keypoint2 = v6
	end

	return table.concat(v2)
end

return GradientRichText