local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local v = {
	Storage = {}
}

function v:Connect(state)
	if not state or typeof(state) ~= "table" or type(state.Callback) ~= "function" then
		return
	end

	if not state.Time then
		state.Time = 0
	end

	local identifier = typeof(state.Identifier) == "string" and state.Identifier or HttpService:GenerateGUID(false)

	if v.Storage[identifier] then
		return
	end

	local v2 = {
		ID = identifier,
		Time = state.Time,
		Callback = state.Callback,
		Running = false,
		CurrentDelta = 0
	}
	local condition

	if type(state.Condition) == "function" then
		condition = state.Condition
	end

	v2.Condition = condition

	function v2.Disconnect(_)
		v2.Ended = true

		if v.Storage[v2.ID] == v2 then
			v.Storage[v2.ID] = nil
		end
	end

	v.Storage[v2.ID] = v2
	return v2
end

RunService.Heartbeat:Connect(function(dt: number)
	for _, v2 in v.Storage do
		if v2.Running then
			continue
		end

		if v2.Time > 0 then
			if v2.FirstExecDone then
				v2.CurrentDelta += dt

				if v2.CurrentDelta < v2.Time or v2.Condition and not v2.Condition() then
					continue
				else
					v2.CurrentDelta = 0
				end
			else
				v2.FirstExecDone = true
			end
		end

		v2.Running = true
		local v3 = v2
		task.defer(function()
			if v3.Ended then
				v3.Running = false
				return
			end

			local v4, v5 = xpcall(v3.Callback, debug.traceback, v3)
			v3.Running = false

			if v4 then
				v3.Failing = nil
			elseif not v3.Failing then
				v3.Failing = true
				task.spawn(error, `[LOOP] {v3.ID}: {v5}`, 0)
			end
		end)
	end
end)
return table.freeze(v)