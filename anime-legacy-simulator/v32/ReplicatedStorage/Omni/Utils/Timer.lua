local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local v = {}
RunService.Heartbeat:Connect(function()
	local now = tick()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v2 in v do
		if v2.Type == "Local" then
			if v2.Last + v2.Interval <= now then
				if v2.Start == v2.Last and v2.SkipFirstExecution then
					v2.Last = now
				else
					v2.Executions += 1
					v2.Last = now
					v2.Callback()
				end
			end
		elseif v2.Type == "Global" then
			if math.floor(serverTimeNow / v2.Interval) > math.floor(v2.Last / v2.Interval) then
				if v2.Start == v2.Last and v2.SkipFirstExecution then
					v2.Last = serverTimeNow
				else
					v2.Executions += 1
					v2.Last = serverTimeNow
					v2.Callback()
				end
			end
		elseif v2.Type == "Minutes" then
			local lastMinute = math.floor(serverTimeNow / 60) % 60
			local lastSecond = math.floor(serverTimeNow % 60)

			if v2.LastSecond ~= lastSecond then
				v2.LastSecond = lastSecond
				local v5 = nil

				for _, v7 in ipairs(v2.MinutesList) do
					if not (lastMinute <= v7 and v2.LastMinute ~= v7) then
						continue
					end

					v5 = v7
					break
				end

				local v7 = v5 or v2.MinutesList[1]
				local v8 = (v7 - lastMinute + 60) % 60 * 60 - lastSecond

				if v8 < 0 then
					v8 += 3600
				end

				if v2.LastMinute == lastMinute then
					v2.Callback(v8, false)
				else
					v2.LastMinute = lastMinute
					v2.Callback(v8, lastMinute == v7)
				end
			end
		end

		if v2.MaxExecutions and v2.Executions >= v2.MaxExecutions then
			v[k] = nil
		end
	end
end)
return table.freeze({
	GetCurrentDate = function()
		return os.date("%d/%m/%Y")
	end,
	Local = function(interval: number, maxExecutions: number, callback, skipFirstExecution: boolean?)
		if not (type(interval) == "number" and type(callback) == "function") then
			return
		end

		local now = tick()
		local GUID = HttpService:GenerateGUID(false)

		if not GUID then
			return
		end

		local v2 = {
			Type = "Local",
			Id = GUID,
			Interval = interval,
			Callback = callback,
			Executions = 0,
			MaxExecutions = maxExecutions,
			Last = now,
			Start = now,
			SkipFirstExecution = skipFirstExecution,
			Stop = function(_)
				v[GUID] = nil
			end
		}
		v[GUID] = v2
		return v2
	end,
	Global = function(interval: number, maxExecutions: number, callback, skipFirstExecution: boolean?)
		if not (type(interval) == "number" and type(callback) == "function") then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local GUID = HttpService:GenerateGUID(false)

		if not GUID then
			return
		end

		local v2 = {
			Type = "Global",
			Id = GUID,
			Interval = interval,
			Callback = callback,
			Executions = 0,
			MaxExecutions = maxExecutions,
			Last = serverTimeNow,
			Start = serverTimeNow,
			SkipFirstExecution = skipFirstExecution,
			Stop = function(_)
				v[GUID] = nil
			end
		}
		v[GUID] = v2
		return v2
	end,
	AtMinutes = function(p, callback)
		if not (type(p) == "table" and type(callback) == "function") then
			return
		end

		local clone = table.clone(p)
		table.sort(clone)
		local GUID = HttpService:GenerateGUID(false)

		if not GUID then
			return
		end

		local v2 = {
			Type = "Minutes",
			Id = GUID,
			MinutesList = clone,
			Callback = callback,
			LastSecond = nil,
			LastMinute = nil,
			Stop = function(_)
				v[GUID] = nil
			end
		}
		v[GUID] = v2
		return v2
	end
})