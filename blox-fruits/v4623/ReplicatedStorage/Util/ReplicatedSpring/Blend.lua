local createVector = vector.create
local v = {
	number = 0,
	boolean = false,
	NumberRange = NumberRange.new(0, 0),
	UDim = UDim.new(0, 0),
	UDim2 = UDim2.new(0, 0, 0, 0),
	Vector2 = Vector2.zero,
	Vector3 = createVector(0, 0, 0),
	Color3 = Color3.new(0, 0, 0),
	CFrame = CFrame.identity
}
local v2 = {
	number = 1,
	boolean = true,
	NumberRange = NumberRange.new(1, 1),
	UDim = UDim.new(1, 1),
	UDim2 = UDim2.new(1, 1, 1, 1),
	Vector2 = Vector2.one,
	Vector3 = createVector(1, 1, 1),
	Color3 = Color3.new(1, 1, 1)
}

local function clampUnit(value: number)
	return (math.clamp(value, 0, 1))
end

local Blend = {
	neutral = function(p: string, p2)
		if p == "Set" then
			return p2
		end

		local typeName = typeof(p2)
		local v3

		if p == "Multiply" then
			v3 = v2[typeName]
		else
			v3 = v[typeName]
		end

		assert(v3 ~= nil, (`ReplicatedSpring: blend mode "{p}" is not supported for type "{typeName}"`))
		return v3
	end,
	add = function(data, data2)
		local typeName = typeof(data)

		if typeName == "number" then
			return data + data2
		elseif typeName == "boolean" then
			return data or data2
		elseif typeName == "CFrame" then
			return data * data2
		elseif typeName == "Color3" then
			return Color3.new(
				math.clamp(data.R + data2.R, 0, 1),
				math.clamp(data.G + data2.G, 0, 1),
				(math.clamp(data.B + data2.B, 0, 1))
			)
		elseif typeName == "NumberRange" then
			return NumberRange.new(data.Min + data2.Min, data.Max + data2.Max)
		end

		if typeName == "UDim" or typeName == "UDim2" or typeName == "Vector2" or typeName == "Vector3" then
			return data + data2
		end

		error((`ReplicatedSpring: blend mode "Add" is not supported for type "{typeName}"`))
	end,
	multiply = function(data, data2)
		local typeName = typeof(data)

		if typeName == "number" then
			return data * data2
		elseif typeName == "boolean" then
			return data and data2
		elseif typeName == "Color3" then
			return Color3.new(
				math.clamp(data.R * data2.R, 0, 1),
				math.clamp(data.G * data2.G, 0, 1),
				(math.clamp(data.B * data2.B, 0, 1))
			)
		elseif typeName == "NumberRange" then
			return NumberRange.new(data.Min * data2.Min, data.Max * data2.Max)
		end

		if typeName == "Vector2" or typeName == "Vector3" then
			return data * data2
		end

		if typeName == "UDim" then
			return UDim.new(data.Scale * data2.Scale, (math.round(data.Offset * data2.Offset)))
		elseif typeName == "UDim2" then
			return UDim2.new(
				data.X.Scale * data2.X.Scale,
				math.round(data.X.Offset * data2.X.Offset),
				data.Y.Scale * data2.Y.Scale,
				(math.round(data.Y.Offset * data2.Y.Offset))
			)
		end

		error((`ReplicatedSpring: blend mode "Multiply" is not supported for type "{typeName}"`))
	end,
	scale = function(cframe, p: number)
		local typeName = typeof(cframe)

		if typeName == "number" then
			return cframe * p
		elseif typeName == "boolean" then
			return cframe
		end

		if typeName == "CFrame" then
			local axisAngle, v3 = cframe:ToAxisAngle()
			local v4

			if v3 == 0 or not (axisAngle.Magnitude > 1e-6) then
				v4 = CFrame.identity
			else
				v4 = CFrame.fromAxisAngle(axisAngle.Unit, v3 * p)
			end

			return v4 + cframe.Position * p
		else
			if typeName == "Color3" then
				return Color3.new(
					math.clamp(cframe.R * p, 0, 1),
					math.clamp(cframe.G * p, 0, 1),
					(math.clamp(cframe.B * p, 0, 1))
				)
			end

			if typeName == "NumberRange" then
				local v3 = cframe.Min * p
				local v4 = cframe.Max * p
				return NumberRange.new(math.min(v3, v4), (math.max(v3, v4)))
			else
				if typeName == "Vector2" or typeName == "Vector3" then
					return cframe * p
				end

				if typeName == "UDim" then
					return UDim.new(cframe.Scale * p, cframe.Offset * p)
				end

				if typeName ~= "UDim2" then
					error((`ReplicatedSpring: motion kind "Motor" is not supported for type "{typeName}"`))
					return
				end

				local X = cframe.X
				local Y = cframe.Y
				return UDim2.new(X.Scale * p, X.Offset * p, Y.Scale * p, Y.Offset * p)
			end
		end
	end
}

function Blend.apply(p: string, p2, p3)
	if p == "Set" or p2 == nil then
		return p3
	end

	if p == "Add" then
		return Blend.add(p2, p3)
	elseif p == "Multiply" then
		return Blend.multiply(p2, p3)
	end

	error((`ReplicatedSpring: unknown blend mode "{p}"`))
end

function Blend.lerp(sequence, sequence2, p: number)
	local typeName = typeof(sequence)

	if typeName == "number" then
		return sequence + (sequence2 - sequence) * p
	end

	if typeName == "boolean" then
		if p >= 0.5 then
			return sequence2
		end

		return sequence
	else
		if typeName == "CFrame" then
			return sequence:Lerp(sequence2, p)
		elseif typeName == "Color3" then
			return sequence:Lerp(sequence2, p)
		end

		if typeName == "Vector2" or typeName == "Vector3" then
			return sequence:Lerp(sequence2, p)
		end

		if typeName == "NumberRange" then
			return NumberRange.new(
				sequence.Min + (sequence2.Min - sequence.Min) * p,
				sequence.Max + (sequence2.Max - sequence.Max) * p
			)
		elseif typeName == "UDim" then
			return UDim.new(
				sequence.Scale + (sequence2.Scale - sequence.Scale) * p,
				(math.round(sequence.Offset + (sequence2.Offset - sequence.Offset) * p))
			)
		elseif typeName == "UDim2" then
			return sequence:Lerp(sequence2, p)
		end

		if typeName == "ColorSequence" then
			local keypoints = sequence.Keypoints
			local keypoints2 = sequence2.Keypoints
			return ColorSequence.new(
				keypoints[1].Value:Lerp(keypoints2[1].Value, p),
				keypoints[#keypoints].Value:Lerp(keypoints2[#keypoints2].Value, p)
			)
		elseif p >= 1 then
			return sequence2
		else
			return sequence
		end
	end
end

return Blend