local MathUtil = {
	bezier3D = function(p, p2, p3, p4, p5)
		return (1 - p) ^ 3 * p2 + 3 * (1 - p) ^ 2 * p * p3 + 3 * (1 - p) * p ^ 2 * p4 + p ^ 3 * p5
	end,
	bezier2D = function(p, p2, p3, p4)
		return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
	end,
	randomSet = function(list)
		return list[math.random(1, #list)]
	end,
	randomShuffle = function(p)
		local clone = table.clone(p)

		for i = #clone, 2, -1 do
			local v = math.random(1, i)
			local v2 = clone[v]
			local v3 = clone[i]
			clone[i] = v2
			clone[v] = v3
		end

		return clone
	end,
	decay = function(p, p2)
		if p2 < p then
			return 0
		end

		return 1 - 3 * (p / p2) ^ 2 + 2 * (p / p2) ^ 3
	end,
	chance = function(p)
		return math.random(1, 1000) <= p * 1000
	end,
	rollingUniqueRandomSet = function(p)
		local clone = table.clone(p)
		local v = nil
		return function()
			local v2 = v
			v = table.remove(clone, math.random(1, #clone))
			table.insert(clone, v2)
			return v
		end
	end,
	uniqueRandomSet = function(p)
		local clone = table.clone(p)
		return function()
			return table.remove(clone, math.random(1, #clone))
		end
	end,
	round = function(p, p2)
		return math.round(p * 10 ^ p2) / 10 ^ p2
	end,
	backIn = function(p)
		return 2.70158 * p ^ 3 - 1.70158 * p ^ 2
	end,
	backOut = function(p)
		return 1 + 2.70158 * (p - 1) ^ 3 + 1.70158 * (p - 1) ^ 2
	end,
	scale = function(p, p2)
		return (math.min(1, p * p2))
	end,
	cubicInOut = function(p)
		return p < 0.5 and 4 * p * p * p or 1 - (-2 * p + 2) ^ 3 / 2
	end,
	cubicOut = function(p)
		return 1 - (1 - p) ^ 3
	end,
	quadOut = function(p)
		return 1 - (1 - p) ^ 2
	end,
	cubicIn = function(p)
		return p ^ 3
	end,
	quadIn = function(p)
		return p ^ 2
	end,
	linearInOut = function(p)
		return p
	end,
	invExp = function(p)
		return 1 / math.exp(p * 3)
	end
}

function MathUtil.hill3D(p, p2, p3)
	local cframe = CFrame.new(p, p2)
	local magnitude = (p2 - p).magnitude
	local v = cframe * CFrame.new(0, magnitude * p3, -magnitude / 3)
	local v2 = cframe * CFrame.new(0, magnitude * p3, -2 * magnitude / 3)
	local v3 = cframe * CFrame.new(0, 0, -magnitude)
	local p4 = cframe.p
	local p5 = v.p
	local p6 = v2.p
	local p7 = v3.p
	return function(p8)
		return MathUtil.bezier3D(p8, p4, p5, p6, p7)
	end
end

function MathUtil.linear(p, p2)
	local cframe = CFrame.new(p, p2)
	local magnitude = (p2 - p).magnitude
	return function(p3)
		return (cframe * CFrame.new(0, 0, -magnitude * p3)).p
	end
end

function MathUtil.summate(p, callback)
	local total = 0

	for i = 1, p do
		total += callback(i)
	end

	return total
end

function MathUtil.linearPeriodic(p, p2, p3)
	return p2 - 4 * p2 / (2 * p3) * math.abs(p % p3 - p3 / 2)
end

function MathUtil.operateNumberSequence(sequence, sequence2, callback)
	local numberSequenceKeypoints = {}

	for k, keypoint in pairs(sequence.Keypoints) do
		local keypoint2 = sequence2.Keypoints[k]
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, callback(keypoint.Value, keypoint2.Value))
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function MathUtil.addNumberSequence(p, p2)
	return MathUtil.operateNumberSequence(p, p2, function(p3, p4)
		return p3 + p4
	end)
end

function MathUtil.subNumberSequence(p, p2)
	return MathUtil.operateNumberSequence(p, p2, function(p3, p4)
		return p3 - p4
	end)
end

function MathUtil.mulNumberSequence(p, p2)
	return MathUtil.operateNumberSequence(p, p, function(p3)
		return p3 * p2
	end)
end

function MathUtil.selectWeightedItem(items)
	local v = {}
	local total = 0

	for k, item in pairs(items) do
		if item <= 0 then
			continue
		end

		table.insert(v, {
			id = k,
			weight = item
		})
		total += item
	end

	if total <= 0 then
		return
	end

	local v2 = math.random() * total
	local total2 = 0

	for _, v3 in ipairs(v) do
		total2 += v3.weight

		if not (total2 < v2) then
			return v3.id
		end
	end

	return v[#v].id
end

function MathUtil.multUDim2(p, p2)
	return UDim2.new(p.X.Scale * p2, p.X.Offset * p2, p.Y.Scale * p2, p.Y.Offset * p2)
end

local v = {
	"",
	"K",
	"M",
	"B"
}

function MathUtil.formatNumber(p)
	if p <= 0 then
		return 0
	end

	local v2 = math.floor(math.floor((math.log10(p))) / 3)
	local v3 = v[v2 + 1]
	local v4 = v2 > 2 and 2 or 1
	return MathUtil.round(p / 10 ^ (v2 * 3), v4) .. v3
end

function MathUtil.xpToLevel(value, max, p)
	return (math.clamp(math.floor(1 + 99 * (math.clamp(value, 0, max) / max) ^ p), 1, 100))
end

function MathUtil.xpToRatio(value, max, p)
	local v2 = math.clamp(value, 0, max)
	local xpToLevel = MathUtil.xpToLevel(v2, max, p)
	local v3 = xpToLevel <= 1 and 0 or math.ceil(max * ((xpToLevel - 1) / 99) ^ (1 / p))
	local v4 = xpToLevel >= 100 and max or math.ceil(max * (xpToLevel / 99) ^ (1 / p))
	local v5 = math.max(v4 - v3, 1)
	return math.clamp(v2 - v3, 0, v5) / v5, v3, v4
end

function MathUtil.levelToXp(p, p2, p3)
	local v2 = math.clamp(math.floor(p), 1, 100)

	if v2 <= 1 then
		return 0
	end

	return (math.ceil(p2 * ((v2 - 1) / 99) ^ (1 / p3)))
end

function MathUtil.formatTime(p)
	local v2 = math.floor(p)
	local v3 = {}

	for _, v4 in ipairs({
		{ 31536000, "year" },
		{ 2592000, "month" },
		{ 86400, "day" },
		{ 3600, "hour" },
		{ 60, "min" },
		{ 1, "sec" }
	}) do
		local v5 = math.floor(v2 / v4[1])

		if not (v5 > 0) then
			continue
		end

		v2 -= v5 * v4[1]
		table.insert(v3, v5 .. " " .. v4[2] .. (v5 == 1 and "" or "s"))

		if #v3 >= 2 then
			break
		end
	end

	return #v3 > 0 and table.concat(v3, " ") or "0 secs"
end

return MathUtil