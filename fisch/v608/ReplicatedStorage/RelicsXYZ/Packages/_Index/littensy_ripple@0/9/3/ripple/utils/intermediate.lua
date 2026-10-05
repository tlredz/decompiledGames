local v = {
	number = {
		to = function(p: number)
			return { p }
		end,
		from = function(list)
			return list[1]
		end
	},
	table = {
		to = function(p)
			return p
		end,
		from = function(p)
			return p
		end
	},
	UDim2 = {
		to = function(udim: UDim2)
			return {
				udim.X.Scale,
				udim.X.Offset,
				udim.Y.Scale,
				udim.Y.Offset
			}
		end,
		from = function(list)
			return UDim2.new(list[1], math.round(list[2]), list[3], (math.round(list[4])))
		end
	},
	UDim = {
		to = function(udim: UDim)
			return { udim.Scale, udim.Offset }
		end,
		from = function(list)
			return UDim.new(list[1], (math.round(list[2])))
		end
	},
	Vector2 = {
		to = function(point: Vector2)
			return { point.X, point.Y }
		end,
		from = function(list)
			return Vector2.new(table.unpack(list, 1, 2))
		end
	},
	Vector3 = {
		to = function(vector: Vector3)
			return { vector.X, vector.Y, vector.Z }
		end,
		from = function(list)
			return (Vector3.new(table.unpack(list, 1, 3)))
		end
	},
	Color3 = {
		to = function(color: Color3)
			return { color.R, color.G, color.B }
		end,
		from = function(list)
			return Color3.new(math.clamp(list[1], 0, 1), math.clamp(list[2], 0, 1), (math.clamp(list[3], 0, 1)))
		end
	},
	CFrame = {
		to = function(cframe: CFrame)
			return { cframe:GetComponents() }
		end,
		from = function(list)
			return CFrame.new(table.unpack(list))
		end
	}
}
local Intermediate = {}

function Intermediate.to(p)
	local typeName = typeof(p)

	if v[typeName] then
		return v[typeName].to(p)
	end

	error((`Ripple received an unsupported value '{p}' of type '{typeName}'`))
end

function Intermediate.from(p, p2: string)
	if v[p2] then
		return v[p2].from(p)
	end

	error((`Ripple received an unsupported value '{p}' of type '{p2}'`))
end

function Intermediate.index(list, p)
	return list[p] or list[1]
end

return Intermediate