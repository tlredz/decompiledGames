local ipairs2 = ipairs
local new = Color3.new
local new2 = NumberRange.new
local new3 = NumberSequenceKeypoint.new
local new4 = PhysicalProperties.new
local new5 = Ray.new
local new6 = UDim.new
local new7 = Rect.new
local new8 = Region3.new
local new9 = NumberSequence.new
local new10 = ColorSequenceKeypoint.new
local new11 = ColorSequence.new
new()

local function RobloxLerp(p, p2)
	return function(p3)
		return p:Lerp(p2, p3)
	end
end

local function Lerp(p, p2, p3)
	return p + p3 * (p2 - p)
end

local clamp = math.clamp

local function Color3Lerp(p, p2)
	return function(p3)
		return p:Lerp(p2, (clamp(p3, 0, 1)))
	end
end

function GetNumberSequenceValueAtTime(p, list, p2)
	local v = clamp(p, 0, 1)

	for i = 2, p2 do
		local v2 = list[i - 1]
		local v3 = list[i]

		if not (v <= v3.Time) then
			continue
		end

		local v4 = (v - v2.Time) / (v3.Time - v2.Time)
		return v2.Value + (v3.Value - v2.Value) * v4, v2.Envelope + (v3.Envelope - v2.Envelope) * v4
	end

	local v2 = list[p2]
	return v2.Value, v2.Envelope
end

function GetColorSequenceValueAtTime(p, list)
	local v = clamp(p, 0, 1)

	for i = 2, #list do
		local v2 = list[i - 1]
		local v3 = list[i]

		if not (v <= v3.Time) then
			continue
		end

		local v4 = (v - v2.Time) / (v3.Time - v2.Time)
		return v2.Value:Lerp(v3.Value, v4)
	end

	return list[#list].Value
end

return (setmetatable({
	boolean = function(p, p2)
		return function(p3)
			if p3 < 0.5 then
				return p
			end

			return p2
		end
	end,
	number = function(p, p2)
		local v = p2 - p
		return function(p3)
			return p + v * p3
		end
	end,
	string = function(value, value2)
		local v = false
		local v2, v3, v4, v5 = string.match(value, "^([+-]?)(%d*):[+-]?(%d*):[+-]?(%d*)$")
		local v6, v7, v8, v9 = string.match(value2, "^([+-]?)(%d*):[+-]?(%d*):[+-]?(%d*)$")
		local v10, v11

		if v2 and v6 then
			v10 = 3600 * (tonumber(v3) or 0) + 60 * (tonumber(v4) or 0) + (tonumber(v5) or 0)
			local v12 = 3600 * (tonumber(v7) or 0) + 60 * (tonumber(v8) or 0) + (tonumber(v9) or 0)

			if v2 == "-" then
				v10 = -v10
			end

			if v6 == "-" or not v12 then
				v12 = -v12
			end

			v11 = (43200 + v12 - v10) % 86400 - 43200
		else
			v = true
			v10 = nil
			v11 = nil
		end

		if not v then
			return function(p)
				local v12 = (v10 + v11 * p) % 86400
				local v13 = math.abs(v12)
				return string.format(
					v12 < 0 and "-%.2u:%.2u:%.2u" or "%.2u:%.2u:%.2u",
					(v13 - v13 % 3600) / 3600,
					(v13 % 3600 - v13 % 60) / 60,
					v13 % 60
				)
			end
		end

		local count = #value2
		return function(p)
			local v12 = 1 + count * p
			return (string.sub(value2, 1, v12 < count and v12 or count))
		end
	end,
	CFrame = RobloxLerp,
	Color3 = Color3Lerp,
	NumberRange = function(p, p2)
		local min = p.Min
		local max = p.Max
		local v = p2.Min - min
		local v2 = p2.Max - max
		return function(p3)
			return new2(min + p3 * v, max + p3 * v2)
		end
	end,
	NumberSequenceKeypoint = function(data, data2)
		local time = data.Time
		local value = data.Value
		local envelope = data.Envelope
		local v = data2.Time - time
		local v2 = data2.Value - value
		local v3 = data2.Envelope - envelope
		return function(p)
			return new3(time + p * v, value + p * v2, envelope + p * v3)
		end
	end,
	PhysicalProperties = function(data, data2)
		local density = data.Density
		local elasticity = data.Elasticity
		local elasticityWeight = data.ElasticityWeight
		local friction = data.Friction
		local frictionWeight = data.FrictionWeight
		local v = data2.Density - density
		local v2 = data2.Elasticity - elasticity
		local v3 = data2.ElasticityWeight - elasticityWeight
		local v4 = data2.Friction - friction
		local v5 = data2.FrictionWeight - frictionWeight
		return function(p)
			return new4(
				density + p * v,
				elasticity + p * v2,
				elasticityWeight + p * v3,
				friction + p * v4,
				frictionWeight + p * v5
			)
		end
	end,
	Ray = function(p, p2)
		local origin = p.Origin
		local direction = p.Direction
		local origin2 = p2.Origin
		local direction2 = p2.Direction
		local X = origin.X
		local Y = origin.Y
		local Z = origin.Z
		local X2 = direction.X
		local Y2 = direction.Y
		local Z2 = direction.Z
		local v = origin2.X - X
		local v2 = origin2.Y - Y
		local v3 = origin2.Z - Z
		local v4 = direction2.X - X2
		local v5 = direction2.Y - Y2
		local v6 = direction2.Z - Z2
		return function(p3)
			return new5(
				vector.Create(X + p3 * v, Y + p3 * v2, Z + p3 * v3),
				vector.Create(X2 + p3 * v4, Y2 + p3 * v5, Z2 + p3 * v6)
			)
		end
	end,
	UDim = function(p, p2)
		local scale = p.Scale
		local offset = p.Offset
		local v = p2.Scale - scale
		local v2 = p2.Offset - offset
		return function(p3)
			return new6(scale + p3 * v, offset + p3 * v2)
		end
	end,
	UDim2 = RobloxLerp,
	Vector2 = RobloxLerp,
	Vector3 = RobloxLerp,
	Rect = function(p, p2)
		return function(p3)
			return new7(
				p.Min.X + p3 * (p2.Min.X - p.Min.X),
				p.Min.Y + p3 * (p2.Min.Y - p.Min.Y),
				p.Max.X + p3 * (p2.Max.X - p.Max.X),
				p.Max.Y + p3 * (p2.Max.Y - p.Max.Y)
			)
		end
	end,
	Region3 = function(instance, instance2)
		return function(p)
			local v = instance.CFrame * (-instance.Size / 2)
			local v2 = v + p * (instance2.CFrame * (-instance2.Size / 2) - v)
			local v3 = instance.CFrame * (instance.Size / 2)
			local v4 = v3 + p * (instance2.CFrame * (instance2.Size / 2) - v3)
			local X = v2.X
			local X2 = v4.X
			local Y = v2.Y
			local Y2 = v4.Y
			local Z = v2.Z
			local Z2 = v4.Z
			local v6 = vector.Create(X < X2 and X or X2, Y < Y2 and Y or Y2, Z < Z2 and Z or Z2)

			if X2 < X then
				X2 = X or X2
			end

			if Y2 < Y then
				Y2 = Y or Y2
			end

			if Z2 < Z then
				Z2 = Z or Z2
			end

			return new8(v6, vector.Create(X2, Y2, Z2))
		end
	end,
	NumberSequence = function(sequence, sequence2)
		local keypoints = sequence.Keypoints
		local keypoints2 = sequence2.Keypoints
		local count = #keypoints
		local count2 = #keypoints2
		local v = {}

		for i = 1, count do
			v[keypoints[i].Time] = true
		end

		for i = 1, count2 do
			v[keypoints2[i].Time] = true
		end

		local v2 = {}

		for k in pairs(v) do
			table.insert(v2, k)
		end

		table.sort(v2)
		local v3 = {}
		local v4 = {}

		for k, time in ipairs2(v2) do
			local v6, envelope = GetNumberSequenceValueAtTime(time, keypoints, count)
			local v8, v9 = GetNumberSequenceValueAtTime(time, keypoints2, count2)
			v3[k] = {
				Time = time,
				Value = v6,
				Envelope = envelope
			}
			v4[k] = {
				Value = v8 - v6,
				Envelope = v9 - envelope
			}
		end

		return function(p)
			if p <= 0 then
				return sequence
			end

			if p >= 1 then
				return sequence2
			end

			local v5 = {}

			for i = 1, #v2 do
				local v6 = v3[i]
				local v7 = v4[i]
				v5[i] = new3(v6.Time, v6.Value + v7.Value * p, v6.Envelope + v7.Envelope * p)
			end

			return new9(v5)
		end
	end,
	ColorSequence = function(sequence, sequence2)
		local keypoints = sequence.Keypoints
		local keypoints2 = sequence2.Keypoints
		local v = #keypoints
		local v2 = #keypoints2
		local v3 = {}

		for i = 1, v do
			v3[keypoints[i].Time] = true
		end

		for i = 1, v2 do
			v3[keypoints2[i].Time] = true
		end

		local v4 = {}

		for k in pairs(v3) do
			table.insert(v4, k)
		end

		table.sort(v4)
		local v5 = {}
		local v6 = {}

		for k, time in ipairs2(v4) do
			local v8 = GetColorSequenceValueAtTime(time, keypoints)
			local v9 = GetColorSequenceValueAtTime(time, keypoints2)
			v5[k] = {
				Time = time,
				R = v8.R,
				G = v8.G,
				B = v8.B
			}
			v6[k] = {
				R = v9.R - v8.R,
				G = v9.G - v8.G,
				B = v9.B - v8.B
			}
		end

		return function(p)
			if p <= 0 then
				return sequence
			end

			if p >= 1 then
				return sequence2
			end

			local v7 = {}

			for i = 1, #v4 do
				local v8 = v5[i]
				local v9 = v6[i]
				v7[i] = new10(v8.Time, new(v8.R + v9.R * p, v8.G + v9.G * p, v8.B + v9.B * p))
			end

			return new11(v7)
		end
	end
}, {
	__index = function(_, p)
		error("No lerp function is defined for type " .. tostring(p) .. ".", 4)
	end,
	__newindex = function(_, p)
		error("No lerp function is defined for type " .. tostring(p) .. ".", 4)
	end
}))