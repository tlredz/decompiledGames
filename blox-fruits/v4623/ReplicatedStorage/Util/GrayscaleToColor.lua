require(game.ReplicatedStorage.Util.AdjustObjectDescendantsColors)

local function evalColorSequence(sequence, p: number)
	if p == 0 then
		return sequence.Keypoints[1].Value
	elseif p == 1 then
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

	return sequence.Keypoints[#sequence.Keypoints].Value
end

local function GrayscaleToColor(color: Color3, p, p2: number)
	if typeof(p) ~= "ColorSequence" then
		return color
	end

	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local color2 = Color3.fromRGB(v2, v3, v4)
	local v5 = math.max(color2.R, color2.G, color2.B) - math.min(color2.R, color2.G, color2.B)
	local HSV, v7, v8 = color2:Lerp(
		evalColorSequence(p, 0.3 * color2.R + 0.59 * color2.G + 0.11 * color2.B),
		p2 * (1 - v5) ^ 2
	):ToHSV()
	return Color3.fromHSV(HSV, v7, v8 * v)
end

return GrayscaleToColor