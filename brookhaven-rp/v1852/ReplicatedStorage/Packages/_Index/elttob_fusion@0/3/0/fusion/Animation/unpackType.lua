local parent = script.Parent.Parent
local Oklab = require(parent.Colour.Oklab)

local function unpackType(cframe, p: string)
	if p == "number" then
		return { cframe }
	elseif p == "CFrame" then
		local axisAngle, v = cframe:ToAxisAngle()
		return {
			cframe.X,
			cframe.Y,
			cframe.Z,
			axisAngle.X,
			axisAngle.Y,
			axisAngle.Z,
			v
		}
	elseif p == "Color3" then
		local v = Oklab.fromSRGB(cframe)
		return { v.X, v.Y, v.Z }
	elseif p == "ColorSequenceKeypoint" then
		local v = Oklab.fromSRGB(cframe.Value)
		return {
			v.X,
			v.Y,
			v.Z,
			cframe.Time
		}
	elseif p == "DateTime" then
		return { cframe.UnixTimestampMillis }
	elseif p == "NumberRange" then
		return { cframe.Min, cframe.Max }
	elseif p == "NumberSequenceKeypoint" then
		return { cframe.Value, cframe.Time, cframe.Envelope }
	elseif p == "PhysicalProperties" then
		return {
			cframe.Density,
			cframe.Friction,
			cframe.Elasticity,
			cframe.FrictionWeight,
			cframe.ElasticityWeight
		}
	elseif p == "Ray" then
		return {
			cframe.Origin.X,
			cframe.Origin.Y,
			cframe.Origin.Z,
			cframe.Direction.X,
			cframe.Direction.Y,
			cframe.Direction.Z
		}
	elseif p == "Rect" then
		return {
			cframe.Min.X,
			cframe.Min.Y,
			cframe.Max.X,
			cframe.Max.Y
		}
	elseif p == "Region3" then
		return {
			cframe.CFrame.X,
			cframe.CFrame.Y,
			cframe.CFrame.Z,
			cframe.Size.X,
			cframe.Size.Y,
			cframe.Size.Z
		}
	elseif p == "Region3int16" then
		return {
			cframe.Min.X,
			cframe.Min.Y,
			cframe.Min.Z,
			cframe.Max.X,
			cframe.Max.Y,
			cframe.Max.Z
		}
	elseif p == "UDim" then
		return { cframe.Scale, cframe.Offset }
	elseif p == "UDim2" then
		return {
			cframe.X.Scale,
			cframe.X.Offset,
			cframe.Y.Scale,
			cframe.Y.Offset
		}
	elseif p == "Vector2" then
		return { cframe.X, cframe.Y }
	elseif p == "Vector2int16" then
		return { cframe.X, cframe.Y }
	elseif p == "Vector3" then
		return { cframe.X, cframe.Y, cframe.Z }
	elseif p == "Vector3int16" then
		return { cframe.X, cframe.Y, cframe.Z }
	end

	return {}
end

return unpackType