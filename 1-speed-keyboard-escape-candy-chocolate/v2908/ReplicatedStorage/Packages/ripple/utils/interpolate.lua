local createVector = vector.create
local module = require("./oklab")
require("../types")

local function interpolate(data, p, p2: number)
	local typeName = typeof(data)

	if typeName == "number" or typeName == "vector" or typeName == "Vector3" or typeName == "Vector2" then
		return data + (p - data) * p2
	end

	if typeName == "Color3" then
		local v = module.fromSRGB((vector.create(data.R, data.G, data.B)))
		local v2 = module.fromSRGB((vector.create(p.R, p.G, p.B)))
		local v3 = vector.max(module.toSRGB(v + (v2 - v) * p2), createVector(0, 0, 0))
		return Color3.new(v3.x, v3.y, v3.z)
	else
		if typeName == "UDim2" or typeName == "CFrame" then
			return data:Lerp(p, p2)
		end

		if typeName == "UDim" then
			return UDim.new(math.lerp(data.Scale, p.Scale, p2), (math.lerp(data.Offset, p.Offset, p2)))
		elseif typeName == "Rect" then
			return Rect.new(
				math.lerp(data.Min.X, p.Min.X, p2),
				math.lerp(data.Min.Y, p.Min.Y, p2),
				math.lerp(data.Max.X, p.Max.X, p2),
				(math.lerp(data.Max.Y, p.Max.Y, p2))
			)
		end

		if typeName ~= "table" then
			error((`Unsupported type for interpolation: {typeName}`))
			return
		end

		local clone = data

		for k, v in p do
			local v2 = data[k]

			if not v2 then
				continue
			end

			local v3 = v2 + (v - v2) * p2

			if clone[k] == v3 then
				continue
			end

			if clone == data then
				clone = table.clone(data)
			end

			clone[k] = v3
		end

		return clone
	end
end

return interpolate