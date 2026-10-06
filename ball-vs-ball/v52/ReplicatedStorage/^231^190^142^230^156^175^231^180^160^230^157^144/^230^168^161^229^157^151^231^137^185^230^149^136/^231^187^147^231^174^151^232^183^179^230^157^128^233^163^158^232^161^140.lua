local RunService = game:GetService("RunService")

local function bezierComponent(p: number, p2: number, p3: number)
	local v = p2 * 3 - p3 * 3 + 1
	local v2 = p3 * 3 - p2 * 6
	local v3 = p2 * 3
	return ((v * p + v2) * p + v3) * p, (v * 3 * p + v2 * 2) * p + v3
end

local function solveBezierT(p: number, bezierX1: number, bezierX2: number)
	local v = p

	for _ = 1, 8 do
		local v2 = bezierX1 * 3 - bezierX2 * 3 + 1
		local v3 = bezierX2 * 3 - bezierX1 * 6
		local v4 = bezierX1 * 3
		local v5 = ((v2 * v + v3) * v + v4) * v
		local v6 = (v2 * 3 * v + v3 * 2) * v + v4

		if math.abs(v6) < 1e-6 then
			break
		end

		v -= (v5 - p) / v6

		if v ~= v or v < 0 or v > 1 then
			break
		end

		if math.abs(v5 - p) < 1e-6 then
			return v
		end
	end

	local v2 = 0
	local v3 = 1

	for _ = 1, 24 do
		local v4 = (v2 + v3) * 0.5
		local v5 = bezierX1 * 3 - bezierX2 * 3 + 1
		local v6 = bezierX2 * 3 - bezierX1 * 6
		local v7 = bezierX1 * 3
		local v8 = ((v5 * v4 + v6) * v4 + v7) * v4
		local _ = (v5 * 3 * v4 + v6 * 2) * v4 + v7

		if v8 < p then
			v2 = v4
		else
			v3 = v4
		end
	end

	return (v2 + v3) * 0.5
end

return function(data)
	local pivot = data.model:GetPivot()
	local position = pivot.Position
	local rotation = pivot.Rotation
	local lastTime = os.clock()
	local flag = false
	local heartbeatConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finish(flag2: boolean)
		if flag then
			return
		end

		flag = true

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		if flag2 then
			data.onComplete()
		end
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if data.model.Parent then
			local v = math.clamp((os.clock() - lastTime) / data.duration, 0, 1)
			local v2 = solveBezierT(v, data.bezierX1, data.bezierX2)
			local bezierY1 = data.bezierY1
			local bezierY2 = data.bezierY2
			local v3 = bezierY1 * 3 - bezierY2 * 3 + 1
			local v4 = bezierY2 * 3 - bezierY1 * 6
			local v5 = bezierY1 * 3
			local v6 = ((v3 * v2 + v4) * v2 + v5) * v2
			local _ = (v3 * 3 * v2 + v4 * 2) * v2 + v5
			local v7 = math.sin(3.141592653589793 * v6)
			local v8 = position:Lerp(data.targetPosition, v6) + data.arcUpVector * (data.arcHeight * v7) + data.bulgeVector * (data.cameraBulge * v7)
			data.model:PivotTo(rotation + v8)

			if v >= 1 then
				finish(true) -- equivalent call inferred; original call site unknown
			end
		else
			finish(false) -- equivalent call inferred; original call site unknown
		end
	end)
	return {
		destroy = function()
			if flag then
				return
			end

			flag = true

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end
	}
end