local function combinations(p, p2)
	if p2 == 0 or p2 == p then
		return 1
	end

	if p < p2 then
		return 0
	end

	local v = 1

	for i = p, p - p2 + 1, -1 do
		v *= i
	end

	local v2 = 1

	for i = 1, p2 do
		v2 *= i
	end

	return v / v2
end

local function BezierCurve(p, list)
	local v = #list - 1
	local vector = Vector3.new()

	for i = 0, v do
		local v2 = math.pow(1 - p, v - i) * math.pow(p, i)
		local v3

		if i == 0 or i == v then
			v3 = 1
		elseif v < i then
			v3 = 0
		else
			local v4 = 1

			for i2 = v, v - i + 1, -1 do
				v4 *= i2
			end

			local v5 = 1

			for i2 = 1, i do
				v5 *= i2
			end

			v3 = v4 / v5
		end

		local v4 = v2 * v3
		vector += list[i + 1] * v4
	end

	return vector
end

local function MoveObjectAlongBezierCurve(instance, p, p2)
	local lastTime = tick()
	local v = 0

	while v < p2 and instance:GetAttribute("HitboxHit") == nil do
		local v2 = math.min(1, (v + 0.01) / p2)
		local position = BezierCurve(math.min(1, v / p2), p)
		local bezierCurve = BezierCurve(v2, p)
		instance.Position = position
		instance.CFrame = CFrame.lookAt(instance.Position, bezierCurve)
		task.wait(0.01)
		v = tick() - lastTime
	end
end

local Bezier = {}

function Bezier.CreateBezier(p, p2: number, p3, callback)
	MoveObjectAlongBezierCurve(p, p3, p2)
	callback()
end

function Bezier.CreateRandomBezier(p, p2: string, vector: Vector3, vector2: Vector3, p3: number, p4: number, callback)
	local v = nil
	local cframe = CFrame.lookAt(vector, vector2)
	local v2 = cframe.RightVector * math.random(-p3, p3)
	local v3 = math.random(0, p3)
	local v4 = cframe.UpVector * v3
	local v5, v6

	if p2 == "Quadratic" then
		v5 = vector2
		v6 = vector:Lerp(v5, math.random(10, 90) * 0.01) + v2 + v4
	else
		v6 = nil
		v5 = nil
	end

	if p2 == "Cubic" then
		v = vector2
		local v7 = math.random(10, 35) * 0.01
		local v8 = math.random(40, 65) * 0.01
		local v9 = cframe.RightVector * math.random(-p3, p3)
		local v10 = cframe.UpVector * math.random(-v3, p3)
		v6 = vector:Lerp(v, v7) + v2 + v4
		v5 = vector:Lerp(v, v8) + v9 + v10
	end

	task.spawn(function()
		os.clock()
		local v7 = nil
		local v8

		if p2 == "Quadratic" then
			v8 = { vector, v6, v5 }
		else
			v8 = p2 == "Cubic" and {
				vector,
				v6,
				v5,
				v
			} or v7
		end

		MoveObjectAlongBezierCurve(p, v8, p4)
		callback()
	end)
end

return Bezier