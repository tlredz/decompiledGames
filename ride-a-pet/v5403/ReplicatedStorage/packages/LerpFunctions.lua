local ipairs2 = ipairs
local color = Color3.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function SortByTime(p, p2)
	return p.Time < p2.Time
end

local function Lerp(p, p2, p3)
	return p + p3 * (p2 - p)
end

local function Color3Lerp(value, value2, p)
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

	local v17 = (1 - p) * v6 + p * v14

	if v17 < 0.0197955 then
		return color
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

return (setmetatable({
	boolean = function(p, p2, p3)
		if p3 < 0.5 then
			return p
		end

		return p2
	end,
	number = function(p, p2, p3)
		return p + (p2 - p) * p3
	end,
	string = function(value, value2, p)
		local v2, v3, v4, v5 = string.match(value, "^([+-]?)(%d*):[+-]?(%d*):[+-]?(%d*)$")
		local v6, v7, v8, v9 = string.match(value2, "^([+-]?)(%d*):[+-]?(%d*):[+-]?(%d*)$")

		if v2 and v6 then
			local v10 = 3600 * (tonumber(v3) or 0) + 60 * (tonumber(v4) or 0) + (tonumber(v5) or 0)
			local v11 = 3600 * (tonumber(v7) or 0) + 60 * (tonumber(v8) or 0) + (tonumber(v9) or 0)

			if v2 == "-" then
				v10 = -v10
			end

			if v6 == "-" or not v11 then
				v11 = -v11
			end

			local v13 = (v10 + ((43200 + v11 - v10) % 86400 - 43200) * p) % 86400
			local v14 = math.abs(v13)
			return string.format(
				v13 < 0 and "-%.2u:%.2u:%.2u" or "%.2u:%.2u:%.2u",
				(v14 - v14 % 3600) / 3600,
				(v14 % 3600 - v14 % 60) / 60,
				v14 % 60
			)
		else
			local count = #value2
			local v10 = 1 + count * p

			if v10 < count then
				count = v10 or count
			end

			return (string.sub(value2, 1, count))
		end
	end,
	CFrame = function(p, p2, p3)
		return p:Lerp(p2, p3)
	end,
	Color3 = Color3Lerp,
	NumberRange = function(p, p2, p3)
		return NumberRange.new(p.Min + p3 * (p2.Min - p.Min), p.Max + p3 * (p2.Max - p.Max))
	end,
	NumberSequenceKeypoint = function(data, data2, p)
		return NumberSequenceKeypoint.new(
			data.Time + p * (data2.Time - data.Time),
			data.Value + p * (data2.Value - data.Value),
			data.Envelope + p * (data2.Envelope - data.Envelope)
		)
	end,
	PhysicalProperties = function(data, data2, p)
		return PhysicalProperties.new(
			data.Density + p * (data2.Density - data.Density),
			data.Elasticity + p * (data2.Elasticity - data.Elasticity),
			data.ElasticityWeight + p * (data2.ElasticityWeight - data.ElasticityWeight),
			data.Friction + p * (data2.Friction - data.Friction),
			data.FrictionWeight + p * (data2.FrictionWeight - data.FrictionWeight)
		)
	end,
	Ray = function(p, p2, p3)
		local origin = p.Origin
		local direction = p.Direction
		local origin2 = p2.Origin
		local direction2 = p2.Direction
		return Ray.new(
			Vector3.new(
				origin.X + p3 * (origin2.X - origin.X),
				origin.Y + p3 * (origin2.Y - origin.Y),
				origin.Z + p3 * (origin2.Z - origin.Z)
			),
			(Vector3.new(
				direction.X + p3 * (direction2.X - direction.X),
				direction.Y + p3 * (direction2.Y - direction.Y),
				direction.Z + p3 * (direction2.Z - direction.Z)
			))
		)
	end,
	UDim = function(p, p2, p3)
		return UDim.new(p.Scale + p3 * (p2.Scale - p.Scale), p.Offset + p3 * (p2.Offset - p.Offset))
	end,
	UDim2 = function(p, p2, p3)
		return p:Lerp(p2, p3)
	end,
	Vector2 = function(p, p2, p3)
		return p:Lerp(p2, p3)
	end,
	Vector3 = function(p, p2, p3)
		return p:Lerp(p2, p3)
	end,
	Rect = function(p, p2, p3)
		return Rect.new(
			p.Min.X + p3 * (p2.Min.X - p.Min.X),
			p.Min.Y + p3 * (p2.Min.Y - p.Min.Y),
			p.Max.X + p3 * (p2.Max.X - p.Max.X),
			p.Max.Y + p3 * (p2.Max.Y - p.Max.Y)
		)
	end,
	Region3 = function(instance, instance2, p)
		local v2 = instance.CFrame * (-instance.Size / 2)
		local v3 = v2 + p * (instance2.CFrame * (-instance2.Size / 2) - v2)
		local v4 = instance.CFrame * (instance.Size / 2)
		local v5 = v4 + p * (instance2.CFrame * (instance2.Size / 2) - v4)
		local X = v3.X
		local X2 = v5.X
		local Y = v3.Y
		local Y2 = v5.Y
		local Z = v3.Z
		local Z2 = v5.Z
		local vector = Vector3.new(X < X2 and X or X2, Y < Y2 and Y or Y2, Z < Z2 and Z or Z2)

		if X2 < X then
			X2 = X or X2
		end

		if Y2 < Y then
			Y2 = Y or Y2
		end

		if Z2 < Z then
			Z2 = Z or Z2
		end

		return Region3.new(vector, (Vector3.new(X2, Y2, Z2)))
	end,
	NumberSequence = function(sequence, sequence2, p)
		local count = 0
		local numberSequenceKeypoints = {}
		local v2 = {}

		for _, v3 in ipairs2(sequence.Keypoints) do
			local v4 = nil
			local v5 = nil

			for _, v7 in ipairs2(sequence2.Keypoints) do
				if v7.Time == v3.Time then
					v4 = v7
					v5 = v4
					v4 = v5
					break
				elseif SortByTime(v7, v3) and (v4 == nil or v7.Time > v4.Time) then
					v4 = v7
				elseif v7.Time > v3.Time and (v5 == nil or SortByTime(v7, v5)) then
					v5 = v7
				end
			end

			local value, envelope

			if v5 == v4 then
				value = v5.Value
				envelope = v5.Envelope
			else
				local v7 = (v3.Time - v4.Time) / (v5.Time - v4.Time)
				value = (v5.Value - v4.Value) * v7 + v4.Value
				envelope = (v5.Envelope - v4.Envelope) * v7 + v4.Envelope
			end

			count += 1
			numberSequenceKeypoints[count] = NumberSequenceKeypoint.new(
				v3.Time,
				(value - v3.Value) * p + v3.Value,
				(envelope - v3.Envelope) * p + v3.Envelope
			)
			v2[v3.Time] = true
		end

		for _, v3 in ipairs2(sequence2.Keypoints) do
			if v2[v3.Time] then
				continue
			end

			local v4 = nil
			local v5 = nil

			for _, v7 in ipairs2(sequence.Keypoints) do
				if v7.Time == v3.Time then
					v4 = v7
					v5 = v4
					v4 = v5
					break
				elseif SortByTime(v7, v3) and (v4 == nil or v7.Time > v4.Time) then
					v4 = v7
				elseif v7.Time > v3.Time and (v5 == nil or SortByTime(v7, v5)) then
					v5 = v7
				end
			end

			local value, envelope

			if v5 == v4 then
				value = v5.Value
				envelope = v5.Envelope
			else
				local v7 = (v3.Time - v4.Time) / (v5.Time - v4.Time)
				value = (v5.Value - v4.Value) * v7 + v4.Value
				envelope = (v5.Envelope - v4.Envelope) * v7 + v4.Envelope
			end

			count += 1
			numberSequenceKeypoints[count] = NumberSequenceKeypoint.new(
				v3.Time,
				(v3.Value - value) * p + value,
				(v3.Envelope - envelope) * p + envelope
			)
		end

		table.sort(numberSequenceKeypoints, SortByTime)
		return NumberSequence.new(numberSequenceKeypoints)
	end,
	ColorSequence = function(sequence, sequence2, p)
		local count = 0
		local colorSequenceKeypoints = {}
		local v2 = {}

		for _, v3 in ipairs2(sequence.Keypoints) do
			local v4 = nil
			local v5 = nil

			for _, v7 in ipairs2(sequence2.Keypoints) do
				if v7.Time == v3.Time then
					v4 = v7
					v5 = v4
					v4 = v5
					break
				elseif SortByTime(v7, v3) and (v4 == nil or v7.Time > v4.Time) then
					v4 = v7
				elseif v7.Time > v3.Time and (v5 == nil or SortByTime(v7, v5)) then
					v5 = v7
				end
			end

			local value

			if v5 == v4 then
				value = v5.Value
			else
				value = Color3Lerp(v4.Value, v5.Value, (v3.Time - v4.Time) / (v5.Time - v4.Time))
			end

			count += 1
			colorSequenceKeypoints[count] = ColorSequenceKeypoint.new(v3.Time, Color3Lerp(v3.Value, value, p))
			v2[v3.Time] = true
		end

		for _, v3 in ipairs2(sequence2.Keypoints) do
			if v2[v3.Time] then
				continue
			end

			local v4 = nil
			local v5 = nil

			for _, v7 in ipairs2(sequence.Keypoints) do
				if v7.Time == v3.Time then
					v4 = v7
					v5 = v4
					v4 = v5
					break
				elseif SortByTime(v7, v3) and (v4 == nil or v7.Time > v4.Time) then
					v4 = v7
				elseif v7.Time > v3.Time and (v5 == nil or SortByTime(v7, v5)) then
					v5 = v7
				end
			end

			local value

			if v5 == v4 then
				value = v5.Value
			else
				value = Color3Lerp(v4.Value, v5.Value, (v3.Time - v4.Time) / (v5.Time - v4.Time))
			end

			count += 1
			colorSequenceKeypoints[count] = ColorSequenceKeypoint.new(v3.Time, Color3Lerp(v3.Value, value, p))
		end

		table.sort(colorSequenceKeypoints, SortByTime)
		return ColorSequence.new(colorSequenceKeypoints)
	end
}, {
	__index = function(_, p)
		error("No lerp function is defined for type " .. tostring(p) .. ".", 4)
	end,
	__newindex = function(_, p)
		error("No lerp function is defined for type " .. tostring(p) .. ".", 4)
	end
}))