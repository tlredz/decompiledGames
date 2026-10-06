local RunService = game:GetService("RunService")
local v = {
	Lerp = function(p, p2, p3)
		return p + (p2 - p) * p3
	end,
	QuadraticBezier = function(vector: Vector3, vector2: Vector3, vector3: Vector3, p: number)
		return vector:Lerp(vector3, p):Lerp(vector2:Lerp(vector3, p), p)
	end,
	CubicBezier = function(vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
		local lerped = vector:Lerp(vector2, p)
		local lerped2 = vector2:Lerp(vector3, p)
		local lerped3 = vector3:Lerp(vector4, p)
		return lerped:Lerp(lerped2, p):Lerp(lerped2:Lerp(lerped3, p), p)
	end
}

function v.QuadraticBezierTween(p: number, list, callback)
	if #list < 3 then
		return
	end

	local heartbeatConnection = nil
	local lastTime = tick()
	local v2 = math.floor((#list - 1) / 2)
	local v3 = p / v2
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v4 = tick() - lastTime

		if p <= v4 then
			local v5 = list[#list]
			callback(v5, v5, true)
			heartbeatConnection:Disconnect()
		else
			local v5 = math.min(math.floor(v4 / v3), v2 - 1)
			local v6 = (v4 - v5 * v3) / v3
			local v7 = v5 * 2 + 1
			local v8 = list[v7]
			local v9 = list[v7 + 1]
			local v10 = list[v7 + 2]
			callback(v.QuadraticBezier(v8, v9, v10, v6), v10)
		end
	end)
end

function v.Distance(p, p2)
	return (p - p2).Magnitude
end

function v.Falloff(p: number, p2: number, value: number?)
	if p2 <= 0 then
		return 0
	end

	return (1 - math.clamp(p / p2, 0, 1)) ^ (value or 1)
end

function v.Direction(p, p2)
	return (p - p2).Unit
end

function v.Angle(vector, p)
	return (math.deg((math.acos((vector:Dot(p))))))
end

function v.Create3DGrid(p: number, vector: Vector3, value: number, value2: number)
	local v2 = math.floor((math.sqrt(p)))
	local v3 = math.ceil(p / v2)
	local v4 = vector.Y / v2
	local v5 = vector.X / v3
	local v6 = value2 or 1
	local v7 = value or 10
	local result = {}

	for i = 1, p do
		local v8 = math.floor((i - 1) / v3)
		local v9 = (i - 1) % v3
		local elementsInRow = math.min(v3, p - v8 * v3)
		local positionInRow = i - v8 * v3
		local v12 = (v9 - (elementsInRow - 1) / 2) * v5
		local v13 = (v8 - (v2 - 1) / 2) * v4
		result[i] = {
			Size = Vector3.new(v5, v4, v6),
			CFrame = CFrame.new(v12, v13, -v7),
			PositionInRow = positionInRow,
			ElementsInRow = elementsInRow
		}
	end

	return result
end

return table.freeze(v)