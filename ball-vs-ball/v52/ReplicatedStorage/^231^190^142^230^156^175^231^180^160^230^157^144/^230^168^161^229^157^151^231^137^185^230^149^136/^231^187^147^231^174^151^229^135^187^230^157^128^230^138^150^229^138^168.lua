local RunService = game:GetService("RunService")
return function(data)
	local pivot = data.model:GetPivot()
	local position = pivot.Position
	local v = data.minFrequency + math.random() * (data.maxFrequency - data.minFrequency)
	local v2 = data.minFrequency + math.random() * (data.maxFrequency - data.minFrequency)
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

		if flag2 and data.model.Parent then
			data.model:PivotTo(pivot)
			data.onComplete(position)
		end
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if data.model.Parent then
			local v3 = os.clock() - lastTime

			if data.duration <= v3 then
				finish(true) -- equivalent call inferred; original call site unknown
			else
				local v4 = data.amplitude * (1 - v3 / data.duration)
				local v5 = math.sin(v3 * v * 6.283185307179586) * v4
				local v6 = math.sin(v3 * v2 * 6.283185307179586 + 1.5707963267948966) * v4
				local vectorToWorldSpace = data.arenaCFrame:VectorToWorldSpace((Vector3.new(v5, v6, 0)))
				data.model:PivotTo(pivot.Rotation + (position + vectorToWorldSpace))
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