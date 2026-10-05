local MathUtil = {}
local random = Random.new()

function MathUtil.weightedRandom(items)
	local total = 0

	for _, item in items do
		total += item
	end

	local number = random:NextNumber(0, total)
	local total2 = 0

	for k, item in items do
		total2 += item

		if number <= total2 then
			return k
		end
	end

	task.spawn(error, (`WEIGHTED RANDOMIZATION FAILED: {debug.traceback()}`))
	return nil
end

function MathUtil.rolloff(p: number, p2: number, p3: number)
	return p * (1 / (p2 * (p3 - 1) + 1))
end

function MathUtil.round(p: number, value: number)
	local v = 10 ^ (value or 2)
	return math.floor(p * v) / v
end

function MathUtil.clamp(p: number, p2: number, p3: number)
	return (math.max(math.min(p, p3), p2))
end

function MathUtil.map(p: number, p2: number, p3: number, p4: number, p5: number, flag: boolean?)
	local v = (p - p2) / (p3 - p2) * (p5 - p4) + p4

	if not flag then
		return v
	end

	if p4 < p5 then
		return (math.max(math.min(v, p5), p4))
	end

	return (math.max(math.min(v, p4), p5))
end

function MathUtil.signum(p: number)
	if p < 0 then
		return -1
	end

	if p == 0 then
		return 0
	end

	return 1
end

function MathUtil.lerp(p: number, p2: number, p3: number)
	return (1 - p3) * p + p3 * p2
end

function MathUtil.clampInt(p: number, p2: number, p3: number)
	if p3 < p then
		return p
	end

	if p2 < p3 then
		return p2
	end

	return p3
end

function MathUtil.clampDouble(p: number, p2: number, p3: number)
	if p3 < p then
		return p
	end

	if p2 < p3 then
		return p2
	end

	return p3
end

function MathUtil.sanitizeDegreesInt(p: number)
	local v = p % 360

	if v < 0 then
		return v + 360
	end

	return v
end

function MathUtil.sanitizeDegreesDouble(p: number)
	local v = p % 360

	if v < 0 then
		return v + 360
	end

	return v
end

function MathUtil.rotationDirection(p: number, p2: number)
	if MathUtil.sanitizeDegreesDouble(p2 - p) <= 180 then
		return 1
	end

	return -1
end

function MathUtil.differenceDegrees(p: number, p2: number)
	return 180 - math.abs(math.abs(p - p2) - 180)
end

function MathUtil.matrixMultiply(list, list2)
	return {
		[0] = list[0] * list2[0][0] + list[1] * list2[0][1] + list[2] * list2[0][2],
		[1] = list[0] * list2[1][0] + list[1] * list2[1][1] + list[2] * list2[1][2],
		[2] = list[0] * list2[2][0] + list[1] * list2[2][1] + list[2] * list2[2][2]
	}
end

return MathUtil