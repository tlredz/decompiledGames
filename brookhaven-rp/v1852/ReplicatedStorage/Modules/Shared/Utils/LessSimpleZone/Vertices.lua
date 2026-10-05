local Vertices = {}

function Vertices.Block(instance)
	local position = instance.Position
	local cFrame = instance.CFrame
	local halfSize = instance.Size / 2
	local v2 = cFrame.XVector.Unit * halfSize.X
	local v3 = cFrame.YVector.Unit * halfSize.Y
	local v4 = cFrame.ZVector.Unit * halfSize.Z
	return {
		position + v2 + v3 + v4,
		position + v2 + v3 - v4,
		position + v2 - v3 + v4,
		position + v2 - v3 - v4,
		position - v2 + v3 + v4,
		position - v2 + v3 - v4,
		position - v2 - v3 + v4,
		position - v2 - v3 - v4
	}
end

function Vertices.Wedge(instance)
	local position = instance.Position
	local cFrame = instance.CFrame
	local halfSize = instance.Size / 2
	local v2 = cFrame.XVector.Unit * halfSize.X
	local v3 = cFrame.YVector.Unit * halfSize.Y
	local v4 = cFrame.ZVector.Unit * halfSize.Z
	return {
		position + v2 + v4 + v3,
		position - v2 + v4 + v3,
		position + v2 + v4 - v3,
		position - v2 + v4 - v3,
		position + v2 - v4 - v3,
		position - v2 - v4 - v3
	}
end

function Vertices.CornerWedge(instance)
	local position = instance.Position
	local cFrame = instance.CFrame
	local halfSize = instance.Size / 2
	local v2 = cFrame.XVector.Unit * halfSize.X
	local v3 = cFrame.YVector.Unit * halfSize.Y
	local v4 = cFrame.ZVector.Unit * halfSize.Z
	return {
		position + v2 - v4 + v3,
		position + v2 - v4 - v3,
		position - v2 - v4 - v3,
		position + v2 + v4 - v3,
		position - v2 + v4 - v3
	}
end

function Vertices.Cylinder(instance)
	local position = instance.Position
	local cFrame = instance.CFrame
	local extentsSize = instance.ExtentsSize
	local X = extentsSize.X
	local v = extentsSize.Y / 2
	local v2 = position + cFrame.XVector * X / 2
	local v3 = position - cFrame.XVector * X / 2
	local result = {}

	for i = 0, 7 do
		local v4 = i / 8 * 3.141592653589793 * 2
		local v5 = math.cos(v4) * v
		local v6 = math.sin(v4) * v
		table.insert(result, v2 + cFrame.ZVector * v6 + cFrame.YVector * v5)
	end

	for i = 0, 7 do
		local v4 = i / 8 * 3.141592653589793 * 2
		local v5 = math.cos(v4) * v
		local v6 = math.sin(v4) * v
		table.insert(result, v3 + cFrame.ZVector * v6 + cFrame.YVector * v5)
	end

	return result
end

function Vertices.Ball(instance)
	local position = instance.Position
	local cFrame = instance.CFrame
	local v = instance.ExtentsSize.X / 2
	local result = {}

	for i = 0, 4 do
		local v2 = 3.141592653589793 * (i / 4)
		local v3 = math.cos(v2) * v
		local v4 = math.sin(v2) * v

		for i2 = 0, 7 do
			local v5 = 6.283185307179586 * (i2 / 8)
			local v6 = math.cos(v5) * v4
			local v7 = math.sin(v5) * v4
			table.insert(result, position + cFrame.XVector * v6 + cFrame.YVector * v3 + cFrame.ZVector * v7)
		end
	end

	return result
end

return Vertices