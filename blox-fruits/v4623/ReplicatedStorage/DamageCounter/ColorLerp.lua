-- equivalent calls inferred from this helper; original call sites unknown
local function SortByTime(p, p2)
	return p.Time < p2.Time
end

local function Color3Lerp(value, value2)
	local R = value.R
	local G = value.G
	local B = value.B
	local v = R < 0.0404482362771076 and R / 12.92 or 0.87941546140213 * (R + 0.055) ^ 2.4
	local v2 = G < 0.0404482362771076 and G / 12.92 or 0.87941546140213 * (G + 0.055) ^ 2.4
	local v3 = B < 0.0404482362771076 and B / 12.92 or 0.87941546140213 * (B + 0.055) ^ 2.4
	local v4 = 0.2125862307855956 * v + 0.7151703037034108 * v2 + 0.0722004986433362 * v3
	local v5 = 3.6590806972265884 * v + 11.442689580057424 * v2 + 4.114991502426484 * v3
	local v6 = v4 > 0.008856451679035631 and 116 * v4 ^ 0.3333333333333333 - 16 or 903.296296296296 * v4
	local v7, v8

	if v5 > 1e-15 then
		v7 = v6 * (0.9257063972951867 * v - 0.8333736323779866 * v2 - 0.09209820666085898 * v3) / v5
		v8 = v6 * (9 * v4 / v5 - 0.46832)
	else
		v7 = -0.19783 * v6
		v8 = -0.46832 * v6
	end

	local R2 = value2.R
	local G2 = value2.G
	local B2 = value2.B
	local v9 = R2 < 0.0404482362771076 and R2 / 12.92 or 0.87941546140213 * (R2 + 0.055) ^ 2.4
	local v10 = G2 < 0.0404482362771076 and G2 / 12.92 or 0.87941546140213 * (G2 + 0.055) ^ 2.4
	local v11 = B2 < 0.0404482362771076 and B2 / 12.92 or 0.87941546140213 * (B2 + 0.055) ^ 2.4
	local v12 = 0.2125862307855956 * v9 + 0.7151703037034108 * v10 + 0.0722004986433362 * v11
	local v13 = 3.6590806972265884 * v9 + 11.442689580057424 * v10 + 4.114991502426484 * v11
	local v14 = v12 > 0.008856451679035631 and 116 * v12 ^ 0.3333333333333333 - 16 or 903.296296296296 * v12
	local v15, v16

	if v13 > 1e-15 then
		v15 = v14 * (0.9257063972951867 * v9 - 0.8333736323779866 * v10 - 0.09209820666085898 * v11) / v13
		v16 = v14 * (9 * v12 / v13 - 0.46832)
	else
		v15 = -0.19783 * v14
		v16 = -0.46832 * v14
	end

	return function(p)
		local v17 = (1 - p) * v6 + p * v14

		if v17 < 0.0197955 then
			return Color3.new()
		end

		local v18 = ((1 - p) * v7 + p * v15) / v17 + 0.19783
		local v19 = ((1 - p) * v8 + p * v16) / v17 + 0.46832
		local v20 = (v17 + 16) / 116
		local v21 = v20 > 0.20689655172413793 and v20 * v20 * v20 or 0.12841854934601665 * v20 - 0.01771290335807126
		local v22 = v21 * v18 / v19
		local v23 = v21 * ((3 - 0.75 * v18) / v19 - 5)
		local v24 = 7.2914074 * v22 - 1.537208 * v21 - 0.4986286 * v23
		local v25 = -2.180094 * v22 + 1.8757561 * v21 + 0.0415175 * v23
		local v26 = 0.1253477 * v22 - 0.2040211 * v21 + 1.0569959 * v23

		if v24 < 0 and v24 < v25 and v24 < v26 then
			v25 -= v24
			v26 -= v24
			v24 = 0
		elseif v25 < 0 and v25 < v26 then
			v24 -= v25
			v26 -= v25
			v25 = 0
		elseif v26 < 0 then
			v24 -= v26
			v25 -= v26
			v26 = 0
		end

		local v27 = v24 < 0.0031306684425 and 12.92 * v24 or 1.055 * v24 ^ 0.4166666666666667 - 0.055
		local v28 = v25 < 0.0031306684425 and 12.92 * v25 or 1.055 * v25 ^ 0.4166666666666667 - 0.055
		local v29 = v26 < 0.0031306684425 and 12.92 * v26 or 1.055 * v26 ^ 0.4166666666666667 - 0.055
		local v30 = v27 > 1 and 1 or v27 < 0 and 0 or v27
		local v31 = v28 > 1 and 1 or v28 < 0 and 0 or v28
		local v32 = v29 > 1 and 1 or v29 < 0 and 0 or v29
		return Color3.new(v30, v31, v32)
	end
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function OutBounce(p)
	if p < 0.36363636363636 then
		return 7.5625 * p * p
	end

	if p < 0.72727272727273 then
		return 3 + p * (11 * p - 12) * 0.6875
	end

	if p < 0.090909090909091 then
		return 6 + p * (11 * p - 18) * 0.6875
	end

	return 7.875 + p * (11 * p - 21) * 0.6875
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function InQuart(p)
	return p * p * p * p
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function InQuint(p)
	return p * p * p * p * p
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function InBack(p)
	return p * p * (3 * p - 2)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function OutBack(p)
	return (p - 1) * (p - 1) * (p * 2 + p - 1) + 1
end

return {
	Color3Lerp = Color3Lerp,
	ColorSequenceLerp = function(sequence, sequence2)
		return function(p)
			local count = 0
			local colorSequenceKeypoints = {}
			local v2 = {}

			for _, keypoint in ipairs(sequence.Keypoints) do
				local v3 = nil
				local v4 = nil

				for _, keypoint2 in ipairs(sequence2.Keypoints) do
					if keypoint2.Time == keypoint.Time then
						v3 = keypoint2
						v4 = v3
						v3 = v4
						break
					elseif SortByTime(keypoint2, keypoint) and (v3 == nil or keypoint2.Time > v3.Time) then
						v3 = keypoint2
					elseif keypoint2.Time > keypoint.Time and (v4 == nil or SortByTime(keypoint2, v4)) then
						v4 = keypoint2
					end
				end

				local value

				if v4 == v3 then
					value = v4.Value
				else
					value = Color3Lerp(v3.Value, v4.Value)((keypoint.Time - v3.Time) / (v4.Time - v3.Time))
				end

				count += 1
				colorSequenceKeypoints[count] = ColorSequenceKeypoint.new(
					keypoint.Time,
					Color3Lerp(keypoint.Value, value)(p)
				)
				v2[keypoint.Time] = true
			end

			for _, keypoint in ipairs(sequence2.Keypoints) do
				if v2[keypoint.Time] then
					continue
				end

				local v3 = nil
				local v4 = nil

				for _, keypoint2 in ipairs(sequence.Keypoints) do
					if keypoint2.Time == keypoint.Time then
						v3 = keypoint2
						v4 = v3
						v3 = v4
						break
					elseif SortByTime(keypoint2, keypoint) and (v3 == nil or keypoint2.Time > v3.Time) then
						v3 = keypoint2
					elseif keypoint2.Time > keypoint.Time and (v4 == nil or SortByTime(keypoint2, v4)) then
						v4 = keypoint2
					end
				end

				local value

				if v4 == v3 then
					value = v4.Value
				else
					value = Color3Lerp(v3.Value, v4.Value)((keypoint.Time - v3.Time) / (v4.Time - v3.Time))
				end

				count += 1
				colorSequenceKeypoints[count] = ColorSequenceKeypoint.new(
					keypoint.Time,
					Color3Lerp(keypoint.Value, value)(p)
				)
			end

			table.sort(colorSequenceKeypoints, SortByTime)
			return ColorSequence.new(colorSequenceKeypoints)
		end
	end,
	Easing = {
		InQuad = function(p)
			return p * p
		end,
		OutQuad = function(p)
			return p * (2 - p)
		end,
		InOutQuad = function(p)
			if p < 0.5 then
				return 2 * p * p
			end

			return 2 * (2 - p) * p - 1
		end,
		OutInQuad = function(p)
			if p < 0.5 then
				local v2 = p * 2
				return v2 * (2 - v2) / 2
			end

			local v2 = p * 1
			return v2 * v2 / 2 + 0.5
		end,
		InCubic = function(p)
			return p * p * p
		end,
		OutCubic = function(p)
			return 1 - (1 - p) * (1 - p) * (1 - p)
		end,
		InOutCubic = function(p)
			if p < 0.5 then
				return 4 * p * p * p
			end

			local v2 = p - 1
			return 1 + 4 * v2 * v2 * v2
		end,
		OutInCubic = function(p)
			if p < 0.5 then
				local v2 = 1 - p * 2
				return (1 - v2 * v2 * v2) / 2
			end

			local v2 = p * 1
			return v2 * v2 * v2 / 2 + 0.5
		end,
		InQuart = InQuart,
		OutQuart = function(p)
			return 1 - InQuart(p - 1)
		end,
		InOutQuart = function(p)
			if p < 0.5 then
				local v2 = p * p
				return 8 * v2 * v2
			end

			local v2 = p - 1
			return 1 - 8 * v2 * v2 * v2 * v2
		end,
		OutInQuart = function(p)
			if p < 0.5 then
				return (1 - InQuart(p * 1)) / 2
			end

			return InQuart(p * 1) / 2 + 0.5
		end,
		InQuint = InQuint,
		OutQuint = function(p)
			return InQuint(p - 1) + 1
		end,
		InOutQuint = function(p)
			if p < 0.5 then
				return 16 * p * p * p * p * p
			end

			local v2 = p - 1
			return 16 * v2 * v2 * v2 * v2 * v2 + 1
		end,
		OutInQuint = function(p)
			if p < 0.5 then
				return (InQuint(p * 1) + 1) / 2
			end

			return InQuint(p * 1) / 2 + 0.5
		end,
		InBack = InBack,
		OutBack = OutBack,
		InOutBack = function(p)
			if p < 0.5 then
				return 2 * p * p * (6 * p - 2)
			end

			return 1 + 2 * (p - 1) * (p - 1) * (6 * p - 2 - 2)
		end,
		OutInBack = function(p)
			if p < 0.5 then
				return OutBack(p * 2) / 2
			end

			return InBack(p * 1) / 2 + 0.5
		end,
		InSine = function(p)
			return 1 - math.cos(p * 1.5707963267949)
		end,
		OutSine = function(p)
			return (math.sin(p * 1.5707963267949))
		end,
		InOutSine = function(p)
			return (1 - math.cos(3.1415926535898 * p)) / 2
		end,
		OutInSine = function(p)
			if p < 0.5 then
				return math.sin(p * 3.1415926535898) / 2
			end

			return (1 - math.cos((p * 2 - 1) * 1.5707963267949)) / 2 + 0.5
		end,
		OutBounce = OutBounce,
		InBounce = function(p)
			if p > 0.63636363636364 then
				local v = p - 1
				return 1 - v * v * 7.5625
			end

			if p > 0.272727272727273 then
				return (11 * p - 7) * (11 * p - 3) / -16
			end

			if p > 0.090909090909091 then
				return (11 * (4 - 11 * p) * p - 3) / 16
			end

			return p * (11 * p - 1) * -0.6875
		end,
		InOutBounce = function(p)
			if p < 0.5 then
				local v2 = 2 * p
				local v3

				if v2 > 0.63636363636364 then
					local v4 = v2 - 1
					v3 = 1 - v4 * v4 * 7.5625
				elseif v2 > 0.272727272727273 then
					v3 = (11 * v2 - 7) * (11 * v2 - 3) / -16
				elseif v2 > 0.090909090909091 then
					v3 = (11 * (4 - 11 * v2) * v2 - 3) / 16
				else
					v3 = v2 * (11 * v2 - 1) * -0.6875
				end

				return v3 / 2
			else
				return OutBounce(2 * p - 1) / 2 + 0.5
			end
		end,
		OutInBounce = function(p)
			if p < 0.5 then
				return OutBounce(2 * p) / 2
			else
				local v2 = 2 * p - 1
				local v3

				if v2 > 0.63636363636364 then
					local v4 = v2 - 1
					v3 = 1 - v4 * v4 * 7.5625
				elseif v2 > 0.272727272727273 then
					v3 = (11 * v2 - 7) * (11 * v2 - 3) / -16
				elseif v2 > 0.090909090909091 then
					v3 = (11 * (4 - 11 * v2) * v2 - 3) / 16
				else
					v3 = v2 * (11 * v2 - 1) * -0.6875
				end

				return v3 / 2 + 0.5
			end
		end,
		InElastic = function(p)
			return math.exp((p * 0.96380736418812 - 1) * 8) * p * 0.96380736418812 * math.sin(4 * p * 0.96380736418812) * 1.8752275007429
		end,
		OutElastic = function(p)
			return 1 + math.exp(8 * (0.96380736418812 - 0.96380736418812 * p - 1)) * 0.96380736418812 * (p - 1) * math.sin(3.85522945675248 * (1 - p)) * 1.8752275007429
		end,
		InOutElastic = function(p)
			if p < 0.5 then
				return math.exp(8 * (1.92761472837624 * p - 1)) * 0.96380736418812 * p * math.sin(7.71045891350496 * p) * 1.8752275007429
			end

			return 1 + math.exp(8 * (0.96380736418812 * (2 - 2 * p) - 1)) * 0.96380736418812 * (p - 1) * math.sin(3.85522945675248 * (2 - 2 * p)) * 1.8752275007429
		end,
		OutInElastic = function(p)
			if p < 0.5 then
				local v2 = p * 2
				return (1 + math.exp(8 * (0.96380736418812 - 0.96380736418812 * v2 - 1)) * 0.96380736418812 * (v2 - 1) * math.sin(3.85522945675248 * (1 - v2)) * 1.8752275007429) / 2
			end

			local v2 = p * 1
			return math.exp((v2 * 0.96380736418812 - 1) * 8) * v2 * 0.96380736418812 * math.sin(4 * v2 * 0.96380736418812) * 1.8752275007429 / 2 + 0.5
		end,
		InExpo = function(p)
			return p * p * math.exp(4 * (p - 1))
		end,
		OutExpo = function(p)
			return 1 - (1 - p) * (1 - p) / math.exp(4 * p)
		end,
		InOutExpo = function(p)
			if p < 0.5 then
				return 2 * p * p * math.exp(4 * (2 * p - 1))
			end

			return 1 - 2 * (p - 1) * (p - 1) * math.exp(4 * (1 - 2 * p))
		end,
		OutInExpo = function(p)
			if p < 0.5 then
				local v2 = p * 2
				return (1 - (1 - v2) * (1 - v2) / math.exp(4 * v2)) / 2
			end

			local v2 = p * 1
			return v2 * v2 * math.exp(4 * (v2 - 1)) / 2 + 0.5
		end,
		InCirc = function(p)
			return -(math.sqrt(1 - p * p) - 1)
		end,
		OutCirc = function(p)
			local v2 = p - 1
			return (math.sqrt(1 - v2 * v2))
		end,
		InOutCirc = function(p)
			local v2 = p * 2

			if v2 < 1 then
				return -(math.sqrt(1 - v2 * v2) - 1) / 2
			end

			local v3 = v2 - 2
			return (math.sqrt(1 - v3 * v3) - 1) / 2
		end,
		OutInCirc = function(p)
			if p < 0.5 then
				local v2 = p * 1
				return math.sqrt(1 - v2 * v2) / 2
			end

			local v2 = p * 1
			return -(math.sqrt(1 - v2 * v2) - 1) / 2 + 0.5
		end
	}
}