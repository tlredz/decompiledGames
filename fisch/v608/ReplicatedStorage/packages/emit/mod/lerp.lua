local module = require("./color/Oklab")
local Lerp = {
	number = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	Vector3 = function(vector: Vector3, vector2: Vector3, p: number)
		return vector:Lerp(vector2, p)
	end,
	Vector2 = function(point: Vector2, point2: Vector2, p: number)
		return point:Lerp(point2, p)
	end,
	CFrame = function(cframe: CFrame, cframe2: CFrame, p: number)
		return cframe:Lerp(cframe2, p)
	end,
	UDim2 = function(udim: UDim2, udim2: UDim2, p: number)
		return udim:Lerp(udim2, p)
	end
}

function Lerp.UDim(udim: UDim, udim2: UDim, p: number)
	return UDim.new(Lerp.number(udim.Scale, udim2.Scale, p), Lerp.number(udim.Offset, udim2.Offset, p))
end

function Lerp.NumberRange(range: NumberRange, range2: NumberRange, p: number)
	return NumberRange.new(Lerp.number(range.Min, range2.Min, p), Lerp.number(range.Max, range2.Max, p))
end

function Lerp.Color3(color: Color3, color2: Color3, p: number)
	return module.toSRGB(module.fromSRGB(color):Lerp(module.fromSRGB(color2), p))
end

function Lerp.PhysicalProperties(data, data2, p: number)
	return PhysicalProperties.new(
		Lerp.number(data.Density, data2.Density, p),
		Lerp.number(data.Friction, data2.Friction, p),
		Lerp.number(data.Elasticity, data2.Elasticity, p),
		Lerp.number(data.FrictionWeight, data2.FrictionWeight, p),
		Lerp.number(data.ElasticityWeight, data2.ElasticityWeight, p)
	)
end

function Lerp.Rect(rect: Rect, rect2: Rect, p: number)
	return Rect.new(rect.Min:Lerp(rect2.Min, p), rect.Max:Lerp(rect2.Max, p))
end

function Lerp.NumberSequence(sequence, sequence2, p: number)
	local count = 0
	local numberSequenceKeypoints = {}
	local v = {}

	for _, keypoint in sequence.Keypoints do
		local v2 = nil
		local v3 = nil

		for _, keypoint2 in sequence2.Keypoints do
			if keypoint2.Time == keypoint.Time then
				v2 = keypoint2
				v3 = v2
				v2 = v3
				break
			elseif keypoint2.Time < keypoint.Time and (v2 == nil or keypoint2.Time > v2.Time) then
				v2 = keypoint2
			elseif keypoint2.Time > keypoint.Time and (v3 == nil or keypoint2.Time < v3.Time) then
				v3 = keypoint2
			end
		end

		local value, envelope

		if v3 == v2 then
			value = v3.Value
			envelope = v3.Envelope
		else
			local v5 = (keypoint.Time - v2.Time) / (v3.Time - v2.Time)
			value = (v3.Value - v2.Value) * v5 + v2.Value
			envelope = (v3.Envelope - v2.Envelope) * v5 + v2.Envelope
		end

		count += 1
		numberSequenceKeypoints[count] = NumberSequenceKeypoint.new(
			keypoint.Time,
			(value - keypoint.Value) * p + keypoint.Value,
			(envelope - keypoint.Envelope) * p + keypoint.Envelope
		)
		v[keypoint.Time] = true
	end

	for _, keypoint in sequence2.Keypoints do
		if v[keypoint.Time] then
			continue
		end

		local v2 = nil
		local v3 = nil

		for _, keypoint2 in sequence.Keypoints do
			if keypoint2.Time == keypoint.Time then
				v2 = keypoint2
				v3 = v2
				v2 = v3
				break
			elseif keypoint2.Time < keypoint.Time and (v2 == nil or keypoint2.Time > v2.Time) then
				v2 = keypoint2
			elseif keypoint2.Time > keypoint.Time and (v3 == nil or keypoint2.Time < v3.Time) then
				v3 = keypoint2
			end
		end

		local value, envelope

		if v3 == v2 then
			value = v3.Value
			envelope = v3.Envelope
		else
			local v5 = (keypoint.Time - v2.Time) / (v3.Time - v2.Time)
			value = (v3.Value - v2.Value) * v5 + v2.Value
			envelope = (v3.Envelope - v2.Envelope) * v5 + v2.Envelope
		end

		count += 1
		numberSequenceKeypoints[count] = NumberSequenceKeypoint.new(
			keypoint.Time,
			(keypoint.Value - value) * p + value,
			(keypoint.Envelope - envelope) * p + envelope
		)
	end

	table.sort(numberSequenceKeypoints, function(a, b)
		return a.Time < b.Time
	end)
	local v2

	if #numberSequenceKeypoints > 20 then
		local v3 = (#numberSequenceKeypoints - 1) / 19
		v2 = {}

		for i = 0, 19 do
			table.insert(v2, numberSequenceKeypoints[math.floor(i * v3 + 1)])
		end

		if v2[#v2].Time < numberSequenceKeypoints[#numberSequenceKeypoints].Time then
			v2[#v2] = numberSequenceKeypoints[#numberSequenceKeypoints]
		end
	else
		v2 = numberSequenceKeypoints
	end

	return NumberSequence.new(v2)
end

local function getColorAtTime(sequence, time: number)
	local keypoints = sequence.Keypoints

	if time <= keypoints[1].Time then
		return keypoints[1].Value
	end

	if keypoints[#keypoints].Time <= time then
		return keypoints[#keypoints].Value
	end

	local v = nil
	local v2 = nil

	for i = 1, #keypoints do
		local keypoint = keypoints[i]

		if keypoint.Time == time then
			return keypoint.Value
		end

		if keypoint.Time < time then
			v = keypoint
		elseif time < keypoint.Time then
			v2 = keypoint
			break
		end
	end

	local v3 = (time - v.Time) / (v2.Time - v.Time)
	return v.Value:Lerp(v2.Value, v3)
end

function Lerp.ColorSequence(p, sequence, p2: number)
	local colorSequenceKeypoints = {}

	for _, keypoint in ipairs(sequence.Keypoints) do
		local lerped = getColorAtTime(p, keypoint.Time):Lerp(keypoint.Value, p2)
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, lerped))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

function Lerp.Other(p, p2, p3: number)
	if p3 < 0.5 then
		p2 = p or p2
	end

	return p2
end

return Lerp