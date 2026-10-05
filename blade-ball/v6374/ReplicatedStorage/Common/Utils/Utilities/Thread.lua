local Thread = {}
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
Thread.Heartbeat = heartbeat

function Thread.SpawnConnection(callback, ...)
	local v = table.pack(...)
	local connection = nil
	connection = heartbeat:Connect(function()
		if callback(connection, unpack(v)) then
			connection:Disconnect()
		end
	end)
	return connection
end

function Thread.SpawnConnectionTimer(p, callback, ...)
	local v = table.pack(...)
	local connection = nil
	local lastTime = tick()
	connection = heartbeat:Connect(function()
		local v2 = (tick() - lastTime) / p

		if v2 > 1 then
			connection:Disconnect()
		end

		if callback(math.min(1, v2), unpack(v)) then
			connection:Disconnect()
		end
	end)
	return connection
end

function Thread.Delay(duration, callback, ...)
	local v = table.pack(...)
	local flag = false
	task.delay(duration, function()
		if flag then
			return
		end

		callback(table.unpack(v, 1, v.n))
	end)
	return {
		Disconnect = function()
			flag = true
		end
	}
end

function Thread.RepeatUntil(p, callback)
	local v = 0
	local connection = nil
	local flag = nil
	connection = heartbeat:Connect(function()
		if flag then
			return
		end

		local now = os.clock()

		if v <= now then
			flag = true
			v = os.clock() + p

			if callback() then
				connection:Disconnect()
			else
				flag = false
			end
		end
	end)
	return connection
end

function Thread.Every(p, callback, ...)
	local v

	if debug.info(2, "s") and debug.info(2, "l") then
		v = string.reverse(string.split(string.reverse(debug.info(2, "s")), ".")[1]) .. "_" .. debug.info(2, "l")
	else
		v = nil
	end

	local v2 = table.pack(...)
	local v3 = 0
	return (heartbeat:Connect(function()
		if v then
			debug.setmemorycategory(v)
		end

		local now = os.clock()

		if v3 <= now then
			v3 = os.clock() + p
			debug.profilebegin((`Thread.Every - {v}`))
			task.spawn(callback, table.unpack(v2, 1, v2.n))
			debug.profileend()
		end
	end))
end

function Thread.Condition(p, callback, ...)
	local v = table.pack(...)
	local lastTime = tick()
	local v2 = lastTime + p

	while tick() < v2 or callback(table.unpack(v, 1, v.n)) == true do
		task.wait()
	end

	return tick() - lastTime
end

function Thread.Loop(callback)
	local v

	if debug.info(2, "s") and debug.info(2, "l") then
		v = string.reverse(string.split(string.reverse(debug.info(2, "s")), ".")[1]) .. "_" .. debug.info(2, "l")
	else
		v = nil
	end

	local flag = true
	local total = 0
	local connection = heartbeat:Connect(function(p)
		if v then
			debug.setmemorycategory(v)
		end

		total += p

		if flag then
			flag = false
			local v2 = total
			total = 0
			callback(p, v2)
			flag = true
		end
	end)
	return {
		Disconnect = function()
			connection:Disconnect()
		end,
		Skip = function(_, p)
			total += p
		end
	}
end

function Thread.LoopFor(max: number, callback)
	local flag = true
	local connection = nil
	local total = 0
	local v = 0
	local v2 = {}
	connection = heartbeat:Connect(function(p)
		total += p

		if flag then
			flag = false
			local v3 = total
			total = 0
			v = math.clamp(v + v3, 0, max)
			local v4 = v / max
			callback(v4, v3, p)

			if v == max then
				connection:Disconnect()

				for _, v5 in pairs(v2) do
					v5(true, v4)
				end
			else
				flag = true
			end
		end
	end)
	return {
		Disconnect = function()
			connection:Disconnect()

			for _, v3 in pairs(v2) do
				v3(false)
			end
		end,
		Ended = {
			Wait = function(self)
				local v3 = false
				self:Connect(function()
					v3 = true
				end)

				while not v3 do
					task.wait()
				end

				return self
			end,
			Connect = function(self, p2)
				v2[#v2 + 1] = p2
				return self
			end
		},
		Skip = function(_, p)
			total += p
		end
	}
end

function Thread.RepeatLoopFor(max: number, callback)
	local flag = true
	local total = 0
	local v = 0
	local v2 = {}
	local connection = heartbeat:Connect(function(p)
		total += p

		if flag then
			flag = false
			local v3 = total
			total = 0
			v = math.clamp(v + v3, 0, max)
			callback(v / max, v3, p)

			if v == max then
				for _, v4 in pairs(v2) do
					v4(true)
				end

				v = 0
				flag = true
			else
				flag = true
			end
		end
	end)
	return {
		Disconnect = function()
			connection:Disconnect()

			for _, v3 in pairs(v2) do
				v3(false)
			end
		end,
		Ended = {
			Wait = function(self)
				local v3 = false
				self:Connect(function()
					v3 = true
				end)

				while not v3 do
					task.wait()
				end

				return self
			end,
			Connect = function(self, p2)
				v2[#v2 + 1] = p2
				return self
			end
		},
		Skip = function(_, p)
			total += p
		end
	}
end

function Thread:Run()
	local runner = self and self.Runner
	assert(runner, "First argument is not valid / missing Runner function")
	local flag = true
	local time = self.Time or 1
	local v = 0
	local connection = nil
	connection = heartbeat:Connect(function(p)
		v = math.clamp(v + p * (self.Speed or 1), 0, time)

		if flag then
			flag = false

			if v == time then
				connection:Disconnect()
			end

			runner(p, v / time)
			flag = true
		end
	end)

	function self.Destroy(_)
		connection:Disconnect()
	end

	return self
end

function Thread.WaitDelay(p, callback, ...)
	local v = true
	local v2 = table.pack(...)
	coroutine.wrap(function()
		wait(p)

		if not v then
			return
		end

		coroutine.wrap(callback)(table.unpack(v2, 1, v2.n))
	end)()
	return {
		Destroy = function()
			v = false
		end
	}
end

function Thread.Coro(callback, ...)
	return coroutine.wrap(callback)(...)
end

function Thread.Wait(duration)
	return task.wait(duration)
end

function Thread.IsSuspendend(thread: thread)
	return coroutine.status(thread) == "suspended"
end

function Thread.SafeResume(thread: thread, ...)
	if Thread.IsSuspendend(thread) then
		pcall(task.spawn, thread, ...)
	end
end

function Thread.SafeResumeDefer(thread: thread, ...)
	if Thread.IsSuspendend(thread) then
		pcall(task.defer, thread, ...)
	end
end

function Thread.SafeCancel(thread: thread)
	if Thread.IsSuspendend(thread) then
		pcall(task.cancel, thread)
	end
end

function Thread.WaitForThreads(p)
	local clone = table.clone(p)

	while true do
		local v, v2 = next(clone)

		if not (v and v2) then
			break
		end

		if coroutine.status(v2) == "dead" then
			clone[v] = nil

			if not next(clone) then
				break
			end
		end

		task.wait()
	end
end

return Thread