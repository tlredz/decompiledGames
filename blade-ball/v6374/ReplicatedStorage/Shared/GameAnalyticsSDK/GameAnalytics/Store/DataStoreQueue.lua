local DataStoreQueue = {
	QR = true,
	Queue = {},
	Process = 0
}
local v = {}
task.spawn(function()
	while DataStoreQueue.QR do
		task.wait()

		if not (#DataStoreQueue.Queue > 0) then
			continue
		end

		local v2 = DataStoreQueue.Queue[1]
		table.remove(DataStoreQueue.Queue, 1)

		if not v[v2.Key] then
			v[v2.Key] = 0
		end

		DataStoreQueue.Process += 1
		local v4 = v2.Delay + v[v2.Key] - DateTime.now().UnixTimestamp
		local v5 = v4 <= 0 and 0 or v4
		task.delay(v5, function()
			while true do
				v[v2.Key] = DateTime.now().UnixTimestamp
				local success, result, v7 = pcall(v2.Func)

				if not success then
					warn(result)
				end

				if not (success and result) and v2.Delay then
					task.wait(v2.Delay)

					if not (success and result) then
						continue
					end
				end

				v2.Event:Fire(success, result, v7)
				DataStoreQueue.Process -= 1
				v[v2.Key] = DateTime.now().UnixTimestamp
				break
			end
		end)
	end
end)

function DataStoreQueue.AddRequest(p, func, delay)
	local bindableEvent = Instance.new("BindableEvent")
	table.insert(DataStoreQueue.Queue, {
		Key = p,
		Delay = delay,
		Func = func,
		Event = bindableEvent
	})
	local v2, v3, v4 = bindableEvent.Event:Wait()
	return v2, v3, v4
end

function DataStoreQueue.RemoveKey(p)
	v[p] = nil
end

return DataStoreQueue