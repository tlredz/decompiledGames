local parent = script.Parent.Parent
local Oklab = require(parent.Colour.Oklab)

local function lerpType(instance, instance2, p: number)
	local typeName = typeof(instance)

	if typeof(instance2) == typeName then
		if typeName == "number" then
			return (instance2 - instance) * p + instance
		elseif typeName == "CFrame" then
			return instance:Lerp(instance2, p)
		end

		if typeName == "Color3" then
			local v = Oklab.fromSRGB(instance)
			local v2 = Oklab.fromSRGB(instance2)
			return Oklab.toSRGB(v:Lerp(v2, p), false)
		elseif typeName == "ColorSequenceKeypoint" then
			local v = Oklab.fromSRGB(instance.Value)
			local v2 = Oklab.fromSRGB(instance2.Value)
			return ColorSequenceKeypoint.new(
				(instance2.Time - instance.Time) * p + instance.Time,
				Oklab.toSRGB(v:Lerp(v2, p), false)
			)
		else
			if typeName == "DateTime" then
				return DateTime.fromUnixTimestampMillis((instance2.UnixTimestampMillis - instance.UnixTimestampMillis) * p + instance.UnixTimestampMillis)
			elseif typeName == "NumberRange" then
				return NumberRange.new(
					(instance2.Min - instance.Min) * p + instance.Min,
					(instance2.Max - instance.Max) * p + instance.Max
				)
			elseif typeName == "NumberSequenceKeypoint" then
				return NumberSequenceKeypoint.new(
					(instance2.Time - instance.Time) * p + instance.Time,
					(instance2.Value - instance.Value) * p + instance.Value,
					(instance2.Envelope - instance.Envelope) * p + instance.Envelope
				)
			elseif typeName == "PhysicalProperties" then
				return PhysicalProperties.new(
					(instance2.Density - instance.Density) * p + instance.Density,
					(instance2.Friction - instance.Friction) * p + instance.Friction,
					(instance2.Elasticity - instance.Elasticity) * p + instance.Elasticity,
					(instance2.FrictionWeight - instance.FrictionWeight) * p + instance.FrictionWeight,
					(instance2.ElasticityWeight - instance.ElasticityWeight) * p + instance.ElasticityWeight
				)
			elseif typeName == "Ray" then
				return Ray.new(
					instance.Origin:Lerp(instance2.Origin, p),
					instance.Direction:Lerp(instance2.Direction, p)
				)
			elseif typeName == "Rect" then
				return Rect.new(instance.Min:Lerp(instance2.Min, p), instance.Max:Lerp(instance2.Max, p))
			end

			if typeName == "Region3" then
				local lerped = instance.CFrame.Position:Lerp(instance2.CFrame.Position, p)
				local v = instance.Size:Lerp(instance2.Size, p) / 2
				return Region3.new(lerped - v, lerped + v)
			elseif typeName == "Region3int16" then
				return Region3int16.new(
					Vector3int16.new(
						(instance2.Min.X - instance.Min.X) * p + instance.Min.X,
						(instance2.Min.Y - instance.Min.Y) * p + instance.Min.Y,
						(instance2.Min.Z - instance.Min.Z) * p + instance.Min.Z
					),
					Vector3int16.new(
						(instance2.Max.X - instance.Max.X) * p + instance.Max.X,
						(instance2.Max.Y - instance.Max.Y) * p + instance.Max.Y,
						(instance2.Max.Z - instance.Max.Z) * p + instance.Max.Z
					)
				)
			elseif typeName == "UDim" then
				return UDim.new(
					(instance2.Scale - instance.Scale) * p + instance.Scale,
					(instance2.Offset - instance.Offset) * p + instance.Offset
				)
			elseif typeName == "UDim2" then
				return instance:Lerp(instance2, p)
			elseif typeName == "Vector2" then
				return instance:Lerp(instance2, p)
			elseif typeName == "Vector2int16" then
				return Vector2int16.new(
					(instance2.X - instance.X) * p + instance.X,
					(instance2.Y - instance.Y) * p + instance.Y
				)
			elseif typeName == "Vector3" then
				return instance:Lerp(instance2, p)
			elseif typeName == "Vector3int16" then
				return Vector3int16.new(
					(instance2.X - instance.X) * p + instance.X,
					(instance2.Y - instance.Y) * p + instance.Y,
					(instance2.Z - instance.Z) * p + instance.Z
				)
			end
		end
	end

	if p < 0.5 then
		return instance
	end

	return instance2
end

return lerpType