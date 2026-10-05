local result = require(script.Parent.Parent:WaitForChild("result"))
local option = require(script.Parent.Parent:WaitForChild("option"))

function getNumberType(value)
	if typeof(value) == "number" then
		if value ~= value then
			return "NaN"
		end

		if math.abs(value) == 1e999 then
			return "Inf"
		end

		return "number"
	else
		if value.NaN then
			return "NaN"
		end

		if value.Inf then
			return "Inf"
		end

		if value.Int32 or value.Int64 or value.Float32 or value.Float64 then
			return "number"
		end

		error((`Invalid number type: {value}`))
	end
end

function getIfComplex(list)
	for _, v in ipairs(list) do
		if getNumberType(v) ~= "number" then
			return true
		end
	end

	return false
end

local ser = {}
local deser = {}

function ser.NaN(_: number)
	return table.freeze({
		NaN = true
	})
end

function deser.NaN(_)
	return 1e999
end

function ser.Inf(_: number)
	return table.freeze({
		Inf = true
	})
end

function deser.Inf(p)
	if p.Inf then
		return 1e999
	end

	return -1e999
end

function ser.Float32(float: number)
	local numberType = getNumberType(float)

	if numberType == "NaN" then
		return {
			Float32 = ser.NaN(float)
		}
	elseif numberType == "Inf" then
		return {
			Float32 = ser.Inf(float)
		}
	elseif numberType == "number" then
		return {
			Float32 = float
		}
	end

	error((`Unsupported number type: {numberType}`))
end

function deser.Float32(p)
	local float32 = p.Float32
	local numberType = getNumberType(float32)

	if numberType == "number" then
		return float32
	elseif numberType == "NaN" then
		return deser.NaN(float32)
	elseif numberType == "Inf" then
		return deser.Inf(float32)
	end

	error((`Unsupported number type: {numberType}`))
end

local function ezFromF32(value)
	if typeof(value) == "number" then
		return value
	end

	return deser.Float32(value)
end

function ser.Float64(float: number)
	local numberType = getNumberType(float)

	if numberType == "NaN" then
		return {
			Float64 = ser.NaN(float)
		}
	elseif numberType == "Inf" then
		return {
			Float64 = ser.Inf(float)
		}
	elseif numberType == "number" then
		return {
			Float64 = float
		}
	end

	error((`Unsupported number type: {numberType}`))
end

function deser.Float64(p)
	local float64 = p.Float64
	local numberType = getNumberType(float64)

	if numberType == "number" then
		return float64
	elseif numberType == "NaN" then
		return deser.NaN(float64)
	elseif numberType == "Inf" then
		return deser.Inf(float64)
	end

	error((`Unsupported number type: {numberType}`))
end

function ser.Int32(p: number)
	local numberType = getNumberType(p)

	if numberType == "NaN" then
		return {
			Int32 = ser.NaN(p)
		}
	elseif numberType == "Inf" then
		return {
			Int32 = ser.Inf(p)
		}
	elseif numberType == "number" then
		return {
			Int32 = math.round(p)
		}
	end

	error((`Unsupported number type: {numberType}`))
end

function deser.Int32(p)
	local int32 = p.Int32
	local numberType = getNumberType(int32)

	if numberType == "number" then
		return (math.round(int32))
	elseif numberType == "NaN" then
		return deser.NaN(int32)
	elseif numberType == "Inf" then
		return deser.Inf(int32)
	end

	error((`Unsupported number type: {numberType}`))
end

function ser.Int64(p: number)
	local numberType = getNumberType(p)

	if numberType == "NaN" then
		return {
			Int64 = ser.NaN(p)
		}
	elseif numberType == "Inf" then
		return {
			Int64 = ser.Inf(p)
		}
	elseif numberType == "number" then
		return {
			Int64 = math.round(p)
		}
	end

	error((`Unsupported number type: {numberType}`))
end

function deser.Int64(p)
	local int64 = p.Int64
	local numberType = getNumberType(int64)

	if numberType == "number" then
		return (math.round(int64))
	elseif numberType == "NaN" then
		return deser.NaN(int64)
	elseif numberType == "Inf" then
		return deser.Inf(int64)
	end

	error((`Unsupported number type: {numberType}`))
end

function ser.Bool(bool: boolean)
	return {
		Bool = bool
	}
end

function deser.Bool(p)
	return p.Bool
end

function ser.String(string: string)
	return {
		String = string
	}
end

function deser.String(p)
	return p.String
end

function ser.Axes(data)
	local v3 = {}

	if data.X then
		table.insert(v3, "X")
	end

	if data.Y then
		table.insert(v3, "Y")
	end

	if data.Z then
		table.insert(v3, "Z")
	end

	return v3
end

function deser.Axes(list)
	local v3 = {}

	for _, v4 in ipairs(list) do
		if v4 == "X" then
			table.insert(v3, Enum.Axis.X)
		elseif v4 == "Y" then
			table.insert(v3, Enum.Axis.Y)
		elseif v4 == "Z" then
			table.insert(v3, Enum.Axis.Z)
		end
	end

	return Axes.new(table.unpack(v3))
end

function ser.BrickColor(p)
	return {
		BrickColor = p.Number
	}
end

function deser.BrickColor(p)
	return BrickColor.new(p.BrickColor)
end

function ser.CFrame(cframe: CFrame)
	local components, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13 = cframe:GetComponents()

	if getIfComplex({
		components,
		v3,
		v4,
		v5,
		v6,
		v7,
		v8,
		v9,
		v10,
		v11,
		v12,
		v13
	}) then
		return {
			position = { ser.Float32(components), ser.Float32(v3), ser.Float32(v4) },
			orientation = {
				{ ser.Float32(v5), ser.Float32(v6), ser.Float32(v7) },
				{ ser.Float32(v8), ser.Float32(v9), ser.Float32(v10) },
				{ ser.Float32(v11), ser.Float32(v12), ser.Float32(v13) }
			}
		}
	end

	return {
		position = { components, v3, v4 },
		orientation = {
			{ v5, v6, v7 },
			{ v8, v9, v10 },
			{ v11, v12, v13 }
		}
	}
end

function deser.CFrame(p)
	local orientation = p.orientation
	local v3 = p.position[1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	local v4 = p.position[2]

	if typeof(v4) ~= "number" then
		v4 = deser.Float32(v4)
	end

	local v5 = p.position[3]

	if typeof(v5) ~= "number" then
		v5 = deser.Float32(v5)
	end

	local v6 = orientation[1][1]

	if typeof(v6) ~= "number" then
		v6 = deser.Float32(v6)
	end

	local v7 = orientation[1][2]

	if typeof(v7) ~= "number" then
		v7 = deser.Float32(v7)
	end

	local v8 = orientation[1][3]

	if typeof(v8) ~= "number" then
		v8 = deser.Float32(v8)
	end

	local v9 = orientation[2][1]

	if typeof(v9) ~= "number" then
		v9 = deser.Float32(v9)
	end

	local v10 = orientation[2][2]

	if typeof(v10) ~= "number" then
		v10 = deser.Float32(v10)
	end

	local v11 = orientation[2][3]

	if typeof(v11) ~= "number" then
		v11 = deser.Float32(v11)
	end

	local v12 = orientation[3][1]

	if typeof(v12) ~= "number" then
		v12 = deser.Float32(v12)
	end

	local v13 = orientation[3][2]

	if typeof(v13) ~= "number" then
		v13 = deser.Float32(v13)
	end

	return CFrame.new(v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, ezFromF32(orientation[3][3]))
end

function ser.Color3(color: Color3)
	if getIfComplex({ color.R, color.G, color.B }) then
		return {
			Color3 = { ser.Float32(color.R), ser.Float32(color.G), ser.Float32(color.B) }
		}
	end

	return {
		Color3 = { color.R, color.G, color.B }
	}
end

function deser.Color3(p)
	local v3 = p.Color3[1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	local v4 = p.Color3[2]

	if typeof(v4) ~= "number" then
		v4 = deser.Float32(v4)
	end

	return Color3.new(v3, v4, ezFromF32(p.Color3[3]))
end

function ser.ColorSequence(sequence)
	local keypoints = {}

	for _, keypoint in ipairs(sequence.Keypoints) do
		if getIfComplex({
			keypoint.Time,
			keypoint.Value.R,
			keypoint.Value.G,
			keypoint.Value.B
		}) then
			table.insert(keypoints, {
				time = ser.Float32(keypoint.Time),
				color = { ser.Float32(keypoint.Value.R), ser.Float32(keypoint.Value.G), ser.Float32(keypoint.Value.B) }
			})
		else
			table.insert(keypoints, {
				time = keypoint.Time,
				color = { keypoint.Value.R, keypoint.Value.G, keypoint.Value.B }
			})
		end
	end

	return {
		ColorSequence = {
			keypoints = keypoints
		}
	}
end

function deser.ColorSequence(p)
	local v3 = {}

	for _, keypoint in ipairs(p.ColorSequence.keypoints) do
		local time = keypoint.time

		if typeof(time) ~= "number" then
			time = deser.Float32(time)
		end

		local v4 = keypoint.color[1]

		if typeof(v4) ~= "number" then
			v4 = deser.Float32(v4)
		end

		local v5 = keypoint.color[2]

		if typeof(v5) ~= "number" then
			v5 = deser.Float32(v5)
		end

		table.insert(v3, ColorSequenceKeypoint.new(time, Color3.new(v4, v5, ezFromF32(keypoint.color[3]))))
	end

	return ColorSequence.new(v3)
end

function ser.EnumItem(p)
	return {
		EnumItem = {
			EnumType = tostring(p.EnumType),
			Value = p.Value
		}
	}
end

function deser.EnumItem(p)
	local v3 = Enum[tostring(p.EnumItem)]
	local v4 = nil

	for _, v6 in ipairs(v3:GetEnumItems()) do
		if v6.Value ~= p.EnumItem.Value then
			continue
		end

		v4 = v6
		break
	end

	assert(v4, (`EnumItem at value {p.EnumItem.Value} not found in enum {v3}`))
	return v4
end

function ser.Faces(data)
	local v3 = {}

	if data.Right then
		table.insert(v3, "Right")
	end

	if data.Top then
		table.insert(v3, "Top")
	end

	if data.Back then
		table.insert(v3, "Back")
	end

	if data.Left then
		table.insert(v3, "Left")
	end

	if data.Bottom then
		table.insert(v3, "Bottom")
	end

	if data.Front then
		table.insert(v3, "Front")
	end

	return v3
end

function deser.Faces(list)
	local v3 = {}

	for _, v4 in ipairs(list) do
		if v4 == "Right" then
			table.insert(v3, Enum.NormalId.Right)
		elseif v4 == "Top" then
			table.insert(v3, Enum.NormalId.Top)
		elseif v4 == "Back" then
			table.insert(v3, Enum.NormalId.Back)
		elseif v4 == "Left" then
			table.insert(v3, Enum.NormalId.Left)
		elseif v4 == "Bottom" then
			table.insert(v3, Enum.NormalId.Bottom)
		elseif v4 == "Front" then
			table.insert(v3, Enum.NormalId.Front)
		end
	end

	return Faces.new(table.unpack(v3))
end

function ser.Font(data)
	return {
		Font = {
			family = data.Family,
			weight = data.Weight.Name,
			style = data.Style.Name
		}
	}
end

function deser.Font(p)
	local v3 = Enum.FontWeight[p.Font.weight]
	local v4 = Enum.FontStyle[p.Font.style]
	return Font.new(p.Font.family, v3, v4)
end

function ser.NumberRange(range: NumberRange)
	if getIfComplex({ range.Min, range.Max }) then
		return {
			NumberRange = { ser.Float32(range.Min), ser.Float32(range.Max) }
		}
	end

	return {
		NumberRange = { range.Min, range.Max }
	}
end

function deser.NumberRange(p)
	local v3 = p.NumberRange[1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	return NumberRange.new(v3, ezFromF32(p.NumberRange[2]))
end

function ser.NumberSequence(sequence)
	local keypoints = {}

	for _, keypoint in ipairs(sequence.Keypoints) do
		if getIfComplex({ keypoint.Time, keypoint.Value, keypoint.Envelope }) then
			table.insert(keypoints, {
				time = ser.Float32(keypoint.Time),
				value = ser.Float32(keypoint.Value),
				envelope = ser.Float32(keypoint.Envelope)
			})
		else
			table.insert(keypoints, {
				time = keypoint.Time,
				value = keypoint.Value,
				envelope = keypoint.Envelope
			})
		end
	end

	return {
		NumberSequence = {
			keypoints = keypoints
		}
	}
end

function deser.NumberSequence(p)
	local v3 = {}

	for _, keypoint in ipairs(p.NumberSequence.keypoints) do
		local time = keypoint.time

		if typeof(time) ~= "number" then
			time = deser.Float32(time)
		end

		local value = keypoint.value

		if typeof(value) ~= "number" then
			value = deser.Float32(value)
		end

		table.insert(v3, NumberSequenceKeypoint.new(time, value, ezFromF32(keypoint.envelope)))
	end

	return NumberSequence.new(v3)
end

function ser.PhysicalProperties(data)
	assert(
		typeof(data) == "PhysicalProperties",
		(`PhysicalProperties must be a PhysicalProperties, got typeof "{typeof(data)}"`)
	)

	if getIfComplex({
		data.Density,
		data.Friction,
		data.Elasticity,
		data.FrictionWeight,
		data.ElasticityWeight
	}) then
		return {
			PhysicalProperties = {
				density = ser.Float32(data.Density),
				friction = ser.Float32(data.Friction),
				elasticity = ser.Float32(data.Elasticity),
				frictionWeight = ser.Float32(data.FrictionWeight),
				elasticityWeight = ser.Float32(data.ElasticityWeight)
			}
		}
	end

	return {
		PhysicalProperties = {
			density = data.Density,
			friction = data.Friction,
			elasticity = data.Elasticity,
			frictionWeight = data.FrictionWeight,
			elasticityWeight = data.ElasticityWeight
		}
	}
end

function deser.PhysicalProperties(p)
	local density = p.PhysicalProperties.density

	if typeof(density) ~= "number" then
		density = deser.Float32(density)
	end

	local friction = p.PhysicalProperties.friction

	if typeof(friction) ~= "number" then
		friction = deser.Float32(friction)
	end

	local elasticity = p.PhysicalProperties.elasticity

	if typeof(elasticity) ~= "number" then
		elasticity = deser.Float32(elasticity)
	end

	local frictionWeight = p.PhysicalProperties.frictionWeight

	if typeof(frictionWeight) ~= "number" then
		frictionWeight = deser.Float32(frictionWeight)
	end

	return PhysicalProperties.new(
		density,
		friction,
		elasticity,
		frictionWeight,
		ezFromF32(p.PhysicalProperties.elasticityWeight)
	)
end

function ser.Ray(ray: Ray)
	if getIfComplex({
		ray.Origin.X,
		ray.Origin.Y,
		ray.Origin.Z,
		ray.Direction.X,
		ray.Direction.Y,
		ray.Direction.Z
	}) then
		return {
			Ray = {
				origin = { ser.Float32(ray.Origin.X), ser.Float32(ray.Origin.Y), ser.Float32(ray.Origin.Z) },
				direction = { ser.Float32(ray.Direction.X), ser.Float32(ray.Direction.Y), ser.Float32(ray.Direction.Z) }
			}
		}
	end

	return {
		Ray = {
			origin = { ray.Origin.X, ray.Origin.Y, ray.Origin.Z },
			direction = { ray.Direction.X, ray.Direction.Y, ray.Direction.Z }
		}
	}
end

function deser.Ray(p)
	local v3 = p.Ray.origin[1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	local v4 = p.Ray.origin[2]

	if typeof(v4) ~= "number" then
		v4 = deser.Float32(v4)
	end

	local vector = Vector3.new(v3, v4, ezFromF32(p.Ray.origin[3]))
	local v5 = p.Ray.direction[1]

	if typeof(v5) ~= "number" then
		v5 = deser.Float32(v5)
	end

	local v6 = p.Ray.direction[2]

	if typeof(v6) ~= "number" then
		v6 = deser.Float32(v6)
	end

	return Ray.new(vector, (Vector3.new(v5, v6, ezFromF32(p.Ray.direction[3]))))
end

function ser.Rect(rect: Rect)
	if getIfComplex({
		rect.Min.X,
		rect.Min.Y,
		rect.Max.X,
		rect.Max.Y
	}) then
		return {
			Rect = {
				{ ser.Float32(rect.Min.X), ser.Float32(rect.Min.Y) },
				{ ser.Float32(rect.Max.X), ser.Float32(rect.Max.Y) }
			}
		}
	end

	return {
		Rect = {
			{ rect.Min.X, rect.Min.Y },
			{ rect.Max.X, rect.Max.Y }
		}
	}
end

function deser.Rect(p)
	local v3 = p.Rect[1][1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	local v4 = p.Rect[1][2]

	if typeof(v4) ~= "number" then
		v4 = deser.Float32(v4)
	end

	local v5 = p.Rect[2][1]

	if typeof(v5) ~= "number" then
		v5 = deser.Float32(v5)
	end

	return Rect.new(v3, v4, v5, ezFromF32(p.Rect[2][2]))
end

function ser.UDim(udim: UDim)
	if getIfComplex({ udim.Scale, udim.Offset }) then
		return {
			UDim = { ser.Float32(udim.Scale), ser.Float32(udim.Offset) }
		}
	end

	return {
		UDim = { udim.Scale, (math.round(udim.Offset)) }
	}
end

function deser.UDim(p)
	local v3 = p.UDim[1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	return UDim.new(v3, ezFromF32(p.UDim[2]))
end

function ser.UDim2(udim: UDim2)
	if getIfComplex({
		udim.X.Scale,
		udim.X.Offset,
		udim.Y.Scale,
		udim.Y.Offset
	}) then
		return {
			UDim2 = {
				{ ser.Float32(udim.X.Scale), ser.Float32(udim.X.Offset) },
				{ ser.Float32(udim.Y.Scale), ser.Float32(udim.Y.Offset) }
			}
		}
	end

	return {
		UDim2 = {
			{ udim.X.Scale, (math.round(udim.X.Offset)) },
			{ udim.Y.Scale, (math.round(udim.Y.Offset)) }
		}
	}
end

function deser.UDim2(p)
	local v3 = p.UDim2[1][1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	local uDim = UDim.new(v3, ezFromF32(p.UDim2[1][2]))
	local v4 = p.UDim2[2][1]

	if typeof(v4) ~= "number" then
		v4 = deser.Float32(v4)
	end

	return UDim2.new(uDim, UDim.new(v4, ezFromF32(p.UDim2[2][2])))
end

function ser.Vector2(point: Vector2)
	if getIfComplex({ point.X, point.Y }) then
		return {
			Vector2 = { ser.Float32(point.X), ser.Float32(point.Y) }
		}
	end

	return {
		Vector2 = { point.X, point.Y }
	}
end

function deser.Vector2(p)
	local v3 = p.Vector2[1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	return Vector2.new(v3, ezFromF32(p.Vector2[2]))
end

function ser.Vector3(vector: Vector3)
	if getIfComplex({ vector.X, vector.Y, vector.Z }) then
		return {
			Vector3 = { ser.Float32(vector.X), ser.Float32(vector.Y), ser.Float32(vector.Z) }
		}
	end

	return {
		Vector3 = { vector.X, vector.Y, vector.Z }
	}
end

function deser.Vector3(p)
	local v3 = p.Vector3[1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	local v4 = p.Vector3[2]

	if typeof(v4) ~= "number" then
		v4 = deser.Float32(v4)
	end

	return (Vector3.new(v3, v4, ezFromF32(p.Vector3[3])))
end

function ser.Region3(instance)
	local v3 = instance.CFrame.Position - instance.Size / 2
	local v4 = instance.CFrame.Position + instance.Size / 2

	if getIfComplex({
		v3.X,
		v3.Y,
		v3.Z,
		v4.X,
		v4.Y,
		v4.Z
	}) then
		return {
			Region3 = {
				Min = { ser.Float32(v3.X), ser.Float32(v3.Y), ser.Float32(v3.Z) },
				Max = { ser.Float32(v4.X), ser.Float32(v4.Y), ser.Float32(v4.Z) }
			}
		}
	end

	return {
		Region3 = {
			Min = { v3.X, v3.Y, v3.Z },
			Max = { v4.X, v4.Y, v4.Z }
		}
	}
end

function deser.Region3(p)
	local v3 = p.Region3.Min[1]

	if typeof(v3) ~= "number" then
		v3 = deser.Float32(v3)
	end

	local v4 = p.Region3.Min[2]

	if typeof(v4) ~= "number" then
		v4 = deser.Float32(v4)
	end

	local vector = Vector3.new(v3, v4, ezFromF32(p.Region3.Min[3]))
	local v5 = p.Region3.Max[1]

	if typeof(v5) ~= "number" then
		v5 = deser.Float32(v5)
	end

	local v6 = p.Region3.Max[2]

	if typeof(v6) ~= "number" then
		v6 = deser.Float32(v6)
	end

	return Region3.new(vector, (Vector3.new(v5, v6, ezFromF32(p.Region3.Max[3]))))
end

function ser.Option(value)
	return value:match(function(some)
		return {
			Some = some
		}
	end, function()
		return table.freeze({
			None = true
		})
	end)
end

function deser.Option(p)
	if p.None then
		return option.none()
	end

	return option.some(p.Some)
end

function ser.Result(value)
	return value:match(function(ok)
		return {
			Ok = ok
		}
	end, function(err)
		return {
			Err = err
		}
	end)
end

function deser.Result(p)
	if p.Err then
		return result.err(p.Err)
	end

	return result.ok(p.Ok)
end

return {
	ser = ser,
	deser = deser
}