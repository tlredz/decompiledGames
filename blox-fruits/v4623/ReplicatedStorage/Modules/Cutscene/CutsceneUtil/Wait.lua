local RunService = game:GetService("RunService")
return table.freeze({
	duration = function(duration: number, object)
		assert(duration >= 0, "Cutscene wait duration must be non-negative")

		if duration == 0 then
			return true
		end

		local bindableEvent = Instance.new("BindableEvent")
		local v = false
		local connection = object:Connect(function()
			if not v then
				v = true
				bindableEvent:Fire(false)
			end
		end)
		local thread = task.delay(duration, function()
			if not v then
				v = true
				bindableEvent:Fire(true)
			end
		end)
		local v2 = bindableEvent.Event:Wait()
		connection:Disconnect()
		pcall(task.cancel, thread)
		bindableEvent:Destroy()
		return v2
	end,
	untilCondition = function(callback, object)
		local bindableEvent = Instance.new("BindableEvent")
		local flag = false
		local v = nil
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function evaluate()
			if flag then
				return
			end

			local success, result = pcall(callback)

			if success then
				if result then
					flag = true
					v = true
					bindableEvent:Fire(true)
				end
			else
				v2 = result
				flag = true
				v = false
				bindableEvent:Fire(false)
			end
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(evaluate)
		local connection = object:Connect(function()
			if not flag then
				flag = true
				v = false
				bindableEvent:Fire(false)
			end
		end)
		evaluate() -- equivalent call inferred; original call site unknown
		local v3 = v

		if v3 == nil then
			v3 = bindableEvent.Event:Wait()
		end

		heartbeatConnection:Disconnect()
		connection:Disconnect()
		bindableEvent:Destroy()

		if v2 ~= nil then
			error(v2, 0)
		end

		return v3
	end
})