local v = {}
local task2 = task
local coroutine2 = coroutine
local clock = os.clock
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
debug.setmemorycategory("tasklib")
local object = setmetatable({}, {
	__mode = "k"
})
debug.resetmemorycategory("tasklib")

local function fn(...) end

local function try_coroutine(p, ...)
	local v2, v3 = coroutine2.resume(p, ...)

	if not v2 then
		warn(v3)
	end
end

function v:wait(p)
	self:connect()
	local now = clock()
	task2.wait(p)
	self:step()
	return clock() - now
end

function v:yieldto_unthrottled(p)
	self:connect()

	if self.THROTTLING then
		return
	end

	self.last_active = 0
	self:yieldto(p)
	self.last_active = 0
end

function v:yieldto(callback)
	self:connect()
	assert(typeof(callback) == "function", "did not pass function")
	local running = coroutine2.running()
	local v2 = not object[running]
	local v3 = false
	self.last_active = 0
	table.insert(self.function_queue, 1, function()
		self.last_active = 0
		local success, result = pcall(callback)

		if not success then
			for i = 1, 10 do
				warn(i, result)
			end
		end

		v3 = true

		if v2 then
			self:step()

			if coroutine2.status(running) == "suspended" then
				try_coroutine(running)
			end
		else
			self:step()
			try_coroutine(running)
		end

		self.last_active = 0
	end)

	if v2 then
		self:pop_run()

		if not v3 then
			coroutine2.yield()
		end
	else
		coroutine2.yield()
	end
end

function v:spawn(callback)
	self:connect()
	assert(typeof(callback) == "function", "did not pass function")
	table.insert(self.function_queue, 1, callback)

	if self.time_spent_this_frame < self.max_time_in_frame then
		self:pop_run()
	else
		self:step()
	end
end

function v:defer(callback)
	self:connect()
	assert(typeof(callback) == "function", "did not pass function")
	table.insert(self.function_queue, callback)
end

function v:run_thread(callback)
	self:connect()
	assert(typeof(callback) == "function", (`did not pass function: {callback}`))
	local container = self.pool:container()

	if not container then
		return
	end

	local lastTime = os.clock()
	try_coroutine(container.thread, callback)
	self.last_active = 0
	self.time_spent_this_frame += os.clock() - lastTime
	return container
end

function v:step()
	self.last_active = 0

	if self.time_spent_this_frame > self.max_time_in_frame then
		local running = coroutine2.running()
		self:defer(function()
			try_coroutine(running)
		end)
		coroutine2.yield()
	end
end

local remove = table.remove

function v:pop_run()
	local v2 = remove(self.function_queue, 1)

	if not v2 then
		return false
	end

	self.last_active = 0
	return self:run_thread(v2)
end

local function getContainerConstructor()
	local v2 = {}
	local v3 = {
		__index = v2
	}

	function v2.await(p)
		assert(p.busy, "attempted to await on closed coroutine")
		table.insert(p.awaiting, coroutine2.running())
		coroutine2.yield()
	end

	local function resume_awaiting(p)
		local awaiting = p.awaiting

		while true do
			local v4 = table.maxn(awaiting) > 0 and table.remove(awaiting, 1)

			if not v4 then
				break
			end

			try_coroutine(v4)
		end
	end

	function v2.new(p)
		debug.setmemorycategory("tasklib")
		local object2 = setmetatable({
			busy = false,
			thread = nil,
			awaiting = {},
			last = tick()
		}, v3)
		object2.thread = coroutine2.create(function(callback)
			local v4 = object2
			local v5 = p

			repeat
				v4.busy = true
				callback()
				resume_awaiting(v4)
				v4.busy = false
				v4.last = tick()
				table.insert(v5.free, v4)
				callback = coroutine2.yield()
			until not callback
		end)
		object[object2.thread] = object2
		debug.resetmemorycategory()
		return object2
	end

	return v2.new
end

local v2 = {}
local v3 = {
	__index = v2
}
local containerConstructor = getContainerConstructor()

function v2:container(p)
	if p then
		return {
			thread = coroutine2.running()
		}
	end

	return self:alloc()
end

function v2:alloc()
	local v4 = remove(self.free, 1)
	return v4 or containerConstructor(self)
end

function v2:clean(p2)
	local free = self.free
	local v4 = tick() + 5

	for i = table.maxn(free), 1, -1 do
		local v5 = free[i]

		if not (v5 and (v5.last < v4 or p2)) then
			continue
		end

		table.remove(free, i)
		try_coroutine(v5.thread, false)
		task2.cancel(v5.thread)
		object[v5.thread] = nil
	end
end

function v:make_pool()
	return (setmetatable({
		static_runners = {},
		free = {}
	}, v3))
end

function v:disconnect()
	if self.connection then
		self.pool:clean(true)
		fn("task:", self.name, "disconnected for inactivity")
		self.connection:Disconnect()
		self.connection = nil
	end
end

function v:connect()
	self.last_active = 0

	if self.connection then
		return
	end

	local v4 = 1
	local v5 = 0.03333333333333333
	local total = 0
	self.average_frame = 0.03333333333333333
	fn("connecting task:", self.name)
	self.connection = heartbeat:Connect(function(p)
		local v6 = v5 / v4 * 2
		local now = os.clock()
		local v7 = math.max(0, p - v6)
		self.last_active += p

		if self.last_active > 20 then
			self:disconnect()
		end

		self.time_spent_this_frame = v7 + 0
		self.breakat = now + self.max_time_in_frame - v7
		self.THROTTLING = math.max(0, p - v6) > 0
		local v9

		if now < self.breakat then
			v9 = true
		else
			v9 = false
		end

		while v9 and self:pop_run() do
			self.last_active = 0
			v9 = os.clock() < self.breakat
		end

		if v9 then
			for k, v10 in pairs(self.resumption) do
				if not (v10 <= os.clock()) then
					continue
				end

				self.last_active = 0
				self.resumption[k] = nil
				try_coroutine(k.thread)
			end

			local _ = os.clock() < self.breakat
		else
			self.last_active = 0
		end

		local bulkmovecf = self.bulkmovecf

		if table.maxn(bulkmovecf) > 0 then
			self.last_active = 0
			local bulkmoveparts = self.bulkmoveparts
			workspace:BulkMoveTo(bulkmoveparts, bulkmovecf, Enum.BulkMoveMode.FireCFrameChanged)
			table.clear(bulkmoveparts)
			table.clear(bulkmovecf)
		end

		if total > 5 then
			total = 0
			self.average_frame = v5 / v4 * 2
			self.pool:clean()
		elseif v5 > 60 then
			v5 /= v4
			v4 = 1
		else
			v4 += 1
			total += p
			v5 += p
		end
	end)
end

function v:bulkmoveto(p, p2)
	self:connect()
	table.insert(self.bulkmoveparts, p)
	table.insert(self.bulkmovecf, p2)
end

debug.setmemorycategory("tasklib")
local v4 = {
	__index = v
}
local v5 = {}
debug.resetmemorycategory()
return function(name, max_time_in_frame, p3)
	debug.setmemorycategory("tasklib")
	local v6 = v5[name]

	if not v5[name] then
		v6 = setmetatable({
			function_queue = {},
			threads = {},
			resumption = {},
			time_spent_this_frame = 0,
			max_time_in_frame = max_time_in_frame,
			running_spawner = false,
			breakat = 0,
			bulkmovecf = {},
			bulkmoveparts = {},
			name = name
		}, v4)
		v6.pool = v6:make_pool()
		v6:connect()
		v5[name] = v6
	end

	if p3 then
		local function wrap(callback)
			return function(...)
				return callback(v6, ...)
			end
		end

		local v7 = getfenv(2)
		local task3 = v7.task
		v7.task = {
			spawn = wrap(v6.spawn),
			wait = wrap(v6.wait),
			defer = wrap(v6.defer),
			delay = task2.delay
		}
		local ancestryChangedConnection = nil
		ancestryChangedConnection = v7.script.AncestryChanged:Connect(function(_, parent)
			if not parent then
				local Global = require(game.ReplicatedStorage.Global)
				Global.TestGamePrint("script is removing", v7.script)
				ancestryChangedConnection:Disconnect()
				v7.task = task3
			end
		end)
	end

	debug.resetmemorycategory()
	return v6
end