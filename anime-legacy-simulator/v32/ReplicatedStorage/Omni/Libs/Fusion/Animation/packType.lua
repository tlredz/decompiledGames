local parent = script.Parent.Parent
require(parent.Types)
local Oklab = require(parent.Colour.Oklab)

local function packType(list, p: string)
	if p == "number" then
		return list[1]
	elseif p == "CFrame" then
		return CFrame.new(list[1], list[2], list[3]) * CFrame.fromAxisAngle(
			Vector3.new(list[4], list[5], list[6]).Unit,
			list[7]
		)
	elseif p == "Color3" then
		return Oklab.toSRGB(Vector3.new(list[1], list[2], list[3]), false)
	elseif p == "ColorSequenceKeypoint" then
		return ColorSequenceKeypoint.new(list[4], Oklab.toSRGB(Vector3.new(list[1], list[2], list[3]), false))
	elseif p == "DateTime" then
		return DateTime.fromUnixTimestampMillis(list[1])
	elseif p == "NumberRange" then
		return NumberRange.new(list[1], list[2])
	elseif p == "NumberSequenceKeypoint" then
		return NumberSequenceKeypoint.new(list[2], list[1], list[3])
	elseif p == "PhysicalProperties" then
		return PhysicalProperties.new(list[1], list[2], list[3], list[4], list[5])
	elseif p == "Ray" then
		return Ray.new(Vector3.new(list[1], list[2], list[3]), (Vector3.new(list[4], list[5], list[6])))
	elseif p == "Rect" then
		return Rect.new(list[1], list[2], list[3], list[4])
	end

	if p == "Region3" then
		local vector = Vector3.new(list[1], list[2], list[3])
		local vector2 = Vector3.new(list[4] / 2, list[5] / 2, list[6] / 2)
		return Region3.new(vector - vector2, vector + vector2)
	else
		if p == "Region3int16" then
			return Region3int16.new(
				Vector3int16.new(list[1], list[2], list[3]),
				Vector3int16.new(list[4], list[5], list[6])
			)
		elseif p == "UDim" then
			return UDim.new(list[1], list[2])
		elseif p == "UDim2" then
			return UDim2.new(list[1], list[2], list[3], list[4])
		elseif p == "Vector2" then
			return Vector2.new(list[1], list[2])
		elseif p == "Vector2int16" then
			return Vector2int16.new(list[1], list[2])
		elseif p == "Vector3" then
			return (Vector3.new(list[1], list[2], list[3]))
		elseif p == "Vector3int16" then
			return Vector3int16.new(list[1], list[2], list[3])
		end

		return nil
	end
end

return packType