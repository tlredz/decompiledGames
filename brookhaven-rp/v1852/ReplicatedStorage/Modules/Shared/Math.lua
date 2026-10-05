game:GetService("ReplicatedStorage")
local Math = {}
local random = Random.new(os.time())

function Math.normalize(p: number, p2: number, p3: number, flag: boolean)
	local v = (p - p2) / (p3 - p2)

	if flag then
		return (math.min(1, (math.max(0, v))))
	end

	return v
end

function Math.map(p: number, p2: number, p3: number, p4: number, p5: number, flag: boolean?)
	local v = p4 + (p - p2) * (p5 - p4) / (p3 - p2)

	if flag then
		return (math.clamp(v, math.min(p4, p5), (math.max(p4, p5))))
	end

	return v
end

function Math.lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

function Math.round(p: number, value: number)
	local v = 10 ^ (value or 0)
	return math.round(p * v) / v
end

function Math.significantFigures(p: number, p2: number, flag: boolean?)
	if p == 0 then
		return 0, "0"
	end

	local v = p2 - math.floor((math.log10((math.abs(p)))))
	local v2 = math.round(p * 10 ^ v) / 10 ^ v

	if flag then
		v2 = math.round(v2) or v2
	end

	local v3 = tostring(v2)

	if math.floor((math.log10((math.abs(p))))) <= v then
		v3 = (("%%.%df"):format(v - 1)):format(v2)
	end

	return v2, v3
end

function Math.weightedChoice(items, p)
	local total = 0

	for _, item in pairs(items) do
		if item.Weight < 0 then
			warn(items)
			error("[Math.weightedChoice] Weight value cannot be less than zero.")
		end

		total += item.Weight
	end

	if total <= 0 then
		warn(items)
		error(("[Math.weightedChoice] The sum of all weights is not greater than 0 (%d)"):format(total))
	end

	local number = Math.nextNumber(0, total, p)
	local v = nil

	for _, item in pairs(items) do
		if number < item.Weight then
			return item.Value
		end

		number -= item.Weight
		v = item
	end

	return v.Value
end

function Math.weightedChoiceKeyByWeightValue(items, p)
	local v = {}

	for k, item in pairs(items) do
		table.insert(v, {
			Weight = item,
			Value = k
		})
	end

	return Math.weightedChoice(v, p)
end

function Math.wrapAround(p: number, p2: number)
	return (p - 1) % p2 + 1
end

function Math.encodeLargeNumber(value: number, flag: boolean?)
	local v = value or 0
	local v2, v3 = math.frexp(v)
	local v4 = math.floor((math.abs(v3 * 10000000000000)))
	local v5 = math.floor((math.abs(v2 * 1000000000000)))
	local v6 = v3 > 0 and 1e16 or 0
	local v7 = v2 > 0 and 1000000000000 or 0
	local v8 = 1e17 + v6 + v4 + v7 + v5

	if not flag then
		return v8
	end

	print("\tEncoding number:", v)
	print(("\t%f -> %s"):format(v2, "mantissa"))
	print(("\t%f -> %s"):format(v3, "exponent"))
	print(("\t%018.0f -> %s"):format(1e17, "encodedVersion"))
	print(("\t%018.0f -> %s"):format(v6, "encodedExponentSign"))
	print(("\t%018.0f -> %s"):format(v4, "encodedExponent"))
	print(("\t%018.0f -> %s"):format(v7, "encodedMantissaSign"))
	print(("\t%018.0f -> %s"):format(v5, "encodedMantissa"))
	print(("\t%018.0f -> %s"):format(v8, "encodedNumber"))
	return v8
end

function Math.decodeLargeNumber(p: number, flag: boolean?)
	local v = math.floor(p / 1e17)

	if v == 1 then
		local v2 = math.floor(p / 1e16 % 10) == 1 and 1 or -1
		local v3 = math.floor(p / 10000000000000 % 1000) * v2
		local v4 = math.floor(p / 1000000000000 % 10) == 1 and 1 or -1
		local v5 = p % 1000000000000 / 1000000000000 * v4
		local v6 = math.ldexp(v5, v3)

		if not flag then
			return v6
		end

		print(("\tDecoding number: %018.0f"):format(p))
		print(("\t%f -> %s"):format(v, "version"))
		print(("\t%f -> %s"):format(v2, "exponentSign"))
		print(("\t%f -> %s"):format(v3, "exponent"))
		print(("\t%f -> %s"):format(v4, "mantissaSign"))
		print(("\t%f -> %s"):format(v5, "mantissa"))
		print(("\t%f -> %s"):format(v6, "decodedNumber"))
		return v6
	else
		if v ~= 0 then
			return
		end

		local v2 = math.max(10000000, p)
		local v3 = math.floor((v2 - 10000000) / 10000)
		local v4 = (v2 - math.floor(v2 / 10000) * 10000) / 1000
		local v5 = v4 * math.pow(10, v3)

		if not flag then
			return v5
		end

		print(("\tDecoding number: %018.0f"):format(v2))
		print(("\t%f -> %s"):format(v, "version"))
		print(("\t%f -> %s"):format(v3, "exponent"))
		print(("\t%f -> %s"):format(v4, "significant"))
		print(("\t%f -> %s"):format(v5, "decoded"))
		return v5
	end
end

function Math.nextNumber(p: number, p2: number, object)
	return Math.lerp(p, p2, object and object:NextNumber() or random:NextNumber())
end

function Math.nextNumberInRange(range: NumberRange)
	return Math.nextNumber(range.Min, range.Max)
end

function Math.nextChance(value: number?)
	return random:NextNumber() <= (value or 0)
end

function Math.nextInteger(p: number, p2: number)
	return random:NextInteger(p, p2)
end

function Math.nextVariation(p: number, p2: number)
	return p + p2 * Math.nextNumber(-1, 1)
end

function Math.nextDegrees()
	return Math.nextNumber(0, 360)
end

function Math.nextRadians()
	return Math.nextNumber(0, 6.283185307179586)
end

function Math.nextBoolean()
	return random:NextNumber() >= 0.5
end

function Math.nextTriangular(min: number, max: number, p: number)
	local v = p or (min + max) / 2

	if max < min then
		min, max = max, min
	end

	local number = random:NextNumber()
	local v2 = max - min
	local v3

	if number <= (v - min) / v2 then
		v3 = min + math.sqrt(number * v2 * (v - min))
	else
		v3 = max - math.sqrt((1 - number) * v2 * (max - v))
	end

	return (math.clamp(v3, min, max))
end

function Math.nextCircumferencePoint(p: number)
	local v = math.rad((Math.nextDegrees()))
	return Vector2.new(p * math.sin(v), p * math.cos(v))
end

function Math.nextCirclePoint(p: number, value: number)
	Vector2.new(p, p)
	local v = value or 0
	local vector

	repeat
		vector = Vector2.new(Math.nextInteger(-p, p), Math.nextInteger(-p, p))
		local magnitude = vector.Magnitude
	until magnitude <= p and v <= magnitude

	return vector
end

function Math.getQuadraticBezierPoint(value: number, vector: Vector3, vector2: Vector3, vector3: Vector3)
	local v = math.clamp(value, 0, 1)
	return (1 - v) ^ 2 * vector + (1 - v) * 2 * v * vector2 + v ^ 2 * vector3
end

function Math.subtractModulo(p: number, p2: number, p3: number)
	local v = (p - p2) % p3
	local v2 = math.abs(v)

	if p3 / 2 < v2 then
		local v3 = math.sign(v)
		return (p3 - math.abs(v)) * -v3
	end

	return v
end

function Math.getSquaredSpiralPosition(p: number)
	local v = p - 2

	if v == -1 then
		return Vector2.new(0, 0)
	end

	local v2 = math.floor((math.sqrt(v + 1) - 1) / 2) + 1
	local v3 = v2 * 8 * (v2 - 1) / 2
	local v4 = v2 * 2
	local v5 = (v + 1 - v3) % (v2 * 8)
	local v6 = { 0, 0, v2 }
	local v7 = math.floor(v5 / (v2 * 2))

	if v7 == 0 then
		v6[1] = v5 - v2
		v6[2] = -v2
	elseif v7 == 1 then
		v6[1] = v2
		v6[2] = v5 % v4 - v2
	elseif v7 == 2 then
		v6[1] = v2 - v5 % v4
		v6[2] = v2
	elseif v7 == 3 then
		v6[1] = -v2
		v6[2] = v2 - v5 % v4
	end

	return Vector2.new(v6[1], v6[2])
end

function Math.getDigit(p: number, p2: number)
	local v = 10 ^ p2
	local v2 = math.floor(p % 10 ^ (p2 + 1) / v)
	return v2, v2 * v
end

function Math.scaleNumberSequence(sequence, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in ipairs(sequence.Keypoints) do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function Math.abbreviate(p: number)
	local v = math.abs(p)
	local v2 = {
		"",
		"K",
		"M",
		"B",
		"T"
	}
	local v3 = 1

	while v >= 1000 and v3 < #v2 do
		v /= 1000
		v3 += 1
	end

	if v3 > 1 then
		return string.format("%.1f%s", p / math.pow(1000, v3 - 1), v2[v3])
	end

	return (tostring(p))
end

return Math