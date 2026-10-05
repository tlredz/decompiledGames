local createVector = vector.create
local Math = {}
local random = Random.new()

function Math.lerp(p, p2, p3: number)
	return p + (p2 - p) * p3
end

function Math.cflerp(cframe: CFrame, cframe2: CFrame, p: number)
	return cframe:Lerp(cframe2, p)
end

function Math.slerp(vector2: Vector3, vector3: Vector3, p: number)
	local unit = vector2.Unit
	local unit2 = vector3.Unit
	local dot = unit:Dot(unit2)

	if dot > 0.9995 then
		return (unit + p * (unit2 - unit)).Unit
	end

	local v = math.clamp(dot, -1, 1)
	local v2 = math.acos(v) * p
	local unit3 = (unit2 - unit * v).Unit

	if v < -0.9995 then
		unit3 = CFrame.lookAlong(createVector(0, 0, 0), unit).RightVector
	end

	return (unit * math.cos(v2) + unit3 * math.sin(v2)).Unit
end

function Math.safeUnit(vector2: Vector3, vector3: Vector3?)
	if vector2.Magnitude > 0.001 then
		return vector2.Unit
	end

	if vector3 and vector3.Magnitude > 0.001 then
		return vector3.Unit
	end

	return createVector(-0, -0, -1)
end

function Math.roundUpToNearest(p: number, p2: number)
	return math.ceil(p / p2) * p2
end

function Math.randomVectorOffsetBetween(vector2: Vector3, p: number, p2: number, p3)
	local v = p3 or random
	return (CFrame.lookAt(createVector(0, 0, 0), vector2) * CFrame.Angles(0, 0, v:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((v:NextNumber(math.cos(p2), (math.cos(p))))),
		0,
		0
	)).LookVector
end

function Math.trajectory(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	return vector4 * 0.5 * p ^ 2 + vector3 * p + vector2
end

function Math.deepCopy(items)
	if type(items) ~= "table" then
		return items
	end

	local copies = {}

	for k, item in items do
		copies[k] = Math.deepCopy(item)
	end

	return copies
end

function Math.scaleSequence(sequence, p: number)
	local numberSequenceKeypoints = {}

	for k, keypoint in sequence.Keypoints do
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

return Math