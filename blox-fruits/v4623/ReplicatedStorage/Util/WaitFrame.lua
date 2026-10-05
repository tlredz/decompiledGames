return function()
	local bindableEvent = Instance.new("BindableEvent")
	local RunService = game:GetService("RunService")

	local function syncWait(value, callback)
		local v = (value or 0) + 0.016666666666666666

		for _ = 0, v / 0.016666666666666666 - 0.001 do
			bindableEvent.Event:Wait()

			if callback and callback() then
				return
			end
		end

		return v
	end

	local v = 0
	return syncWait, (RunService.Heartbeat:Connect(function(dt)
		v += dt

		if v > 0.016666666666666666 then
			local v2 = math.floor(v / 0.016666666666666666)

			for _ = 1, v2 do
				bindableEvent:Fire()
			end

			v -= v2 * 0.016666666666666666
		end
	end))
end