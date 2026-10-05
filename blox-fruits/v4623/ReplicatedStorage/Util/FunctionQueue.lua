local function fn() end

local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local RunService2 = game:GetService("RunService")
local renderStepped = RunService2.RenderStepped
local remove = table.remove
local _ = task.wait
local _ = coroutine.resume
local status = coroutine.status
local spawn = task.spawn
local clock = os.clock
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local total = 0
local Signal22 = require(game.ReplicatedStorage.Util.Signal2)
local v = Signal22.new()
LimitationType = {
	OpsPerFrame = 1,
	ClockTime = 2
}
local v2 = {}
local v3 = {}
local v4 = {}
debug.profilebegin("FunctionQueue")

function v3:SetLimit(limitationType, limit: number)
	self.LimitationType = limitationType

	if limitationType ~= LimitationType.OpsPerFrame then
		limit /= 1000
	end

	self.Limit = limit
end

function v3.GetConnector(_, p: string)
	if p == "RenderStepped" then
		local RunService3 = game:GetService("RunService")
		return RunService3.RenderStepped
	end

	local RunService3 = game:GetService("RunService")
	return RunService3.Heartbeat
end

function v3:Wait(p)
	if not p then
		self.emptySignal:Wait()
		return true
	end

	while self.updateSignal:Wait() do
		local flag = true

		for _, v6 in ipairs(self.array) do
			if v6[1] ~= p then
				continue
			end

			fn(`still waiting array {p}`, self.array)
			flag = false
			break
		end

		if not flag then
			continue
		end

		for _, leftover in ipairs(self.leftovers) do
			if leftover[2] ~= p then
				continue
			end

			fn(`still waiting leftovers {p}`, self.leftovers)
			flag = false
			break
		end

		if flag then
			return true
		end
	end
end

function v3:LeftoversChecker(list)
	if self.checkingLeftovers then
		return
	end

	self.checkingLeftovers = true
	task.spawn(function()
		while task.wait() do
			local v5 = table.maxn(list)

			if v5 == 0 then
				break
			end

			local flag = false

			for i = v5, 1, -1 do
				local v6 = list[i]

				if status(v6[1]) ~= "dead" then
					continue
				end

				remove(list, i)
				v6[4].yielding -= 1
				flag = true
			end

			if flag then
				self.updateSignal:Fire(true)
			end
		end

		self.checkingLeftovers = false
	end)
end

function v3:Yield(p, callback)
	if not callback then
		callback = p
		p = "BudgetedMS" .. self.Limit
	end

	local thread = coroutine.running()
	self:Try(p, function()
		callback()
		coroutine.resume(thread)
	end)
	coroutine.yield()
end

function v3:FastSpawn(p, callback)
	if not callback then
		callback = p
		p = "BudgetedMS" .. self.Limit
	end

	local thread = coroutine.running()
	self:Try(p, function()
		task.spawn(callback)
		coroutine.resume(thread)
	end)
	coroutine.yield()
end

local v5 = {}

function v3:Try(p, p2)
	local array = self.array
	local limit = self.Limit
	local leftovers = self.leftovers

	if not p2 then
		p2 = p
		p = "BudgetedMS" .. limit
	end

	table.insert(array, 1, { p, p2 })

	if self.running or self.loopcoro then
		return
	end

	local function fn2(_)
		local now = clock()
		local v6 = {}

		while table.maxn(array) > 0 do
			local v7 = remove(array, 1)
			local now2 = clock()
			local now3

			if v7 then
				local v8 = `{self.name}:` .. p
				local v9 = v4[v8]

				if not v9 then
					v9 = {
						fin = 0,
						yielding = 0,
						cost = 0
					}
					v4[v8] = v9
				end

				local thread = spawn(v7[2])

				if coroutine.status(thread) ~= "dead" then
					v9.yielding += 1
					table.insert(leftovers, {
						thread,
						p,
						p2,
						v9
					})
					self:LeftoversChecker(leftovers)
				end

				v9.fin += 1
				v6[thread] = true
				now3 = clock()
				v9.cost += now3 - now2
			else
				now3 = clock()
			end

			if limit < now3 - now2 or limit < now3 - now then
				break
			end
		end

		local v7 = clock() - now
		total += v7
		local _ = limit * 1.5 < v7
		self.logtxt = ""
		self.running = false
		return 0
	end

	self.loopcoro = task.defer(function()
		if self.LimitationType == LimitationType.ClockTime then
			while table.maxn(array) > 0 do
				if not self.running then
					self.running = true
					self.updateSignal:Fire(true)
					table.insert(v5, fn2)
				end

				v:Wait()
			end

			self.emptySignal:Fire(true)
		end

		self.loopcoro = nil
	end)
end

local total2 = 0
local RunService3 = game:GetService("RunService")

if RunService3:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local RunService4 = game:GetService("RunService")
	RunService4.Heartbeat:Connect(function(dt)
		debug.profilebegin("FunctionQueue:run")
		local v6 = v5
		v5 = {}

		for _, v7 in ipairs(v6) do
			v7()
		end

		debug.profileend()
		v:Fire()
		local v7 = total

		if v7 > 0.09 then
			warn("long frame cost", v7)
		end

		total2 += dt

		if total2 > 20 then
			total2 = 0
			local v8 = v4
			v4 = {}

			for _, v9 in pairs(v8) do
				v9.normal = v9.cost / v9.fin
			end
		end

		total = 0
	end)
end

local v6 = {
	__index = v3
}

function v3.new(name: string, p2, value: number)
	local self = setmetatable({
		array = {},
		running = false,
		emptySignal = Signal2.new(),
		updateSignal = Signal2.new(),
		leftovers = {},
		logtxt = "",
		name = name
	}, v6)

	if v2[name] then
		warn("overwriting current queue in registry:", name)
	end

	v2[name] = self
	self:SetLimit(p2 or LimitationType.ClockTime, value or 1)
	return self
end

local FunctionQueue = {
	test = v3.new,
	new = function(p, value)
		if isServer then
			return function(callback)
				return callback()
			end
		end

		local v7 = {}
		local v8 = false
		local total3 = 0
		local count = 0
		local thread = coroutine.create(function()
			while true do
				v8 = true
				task.wait(0.05)

				while #v7 > 0 do
					renderStepped:Once(function()
						for _ = 1, p do
							local v9 = remove(v7, 1)

							if not v9 then
								break
							end

							debug.profilebegin("FunctionQueue" .. (value or "?"))
							local success, result = pcall(v9)
							debug.profileend()

							if not success then
								warn(result)
							end

							count += 1
						end
					end)
					renderStepped:Wait()
				end

				total3 += count
				count = 0
				v8 = false
				coroutine.yield()
			end
		end)

		local function queueOperation(p2)
			table.insert(v7, p2)

			if not v8 then
				coroutine.resume(thread)
			end
		end

		return queueOperation
	end
}
debug.profileend()
local RunService4 = game:GetService("RunService")

if RunService4:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	FunctionQueue.scriptQueue = FunctionQueue.new(1)
end

return FunctionQueue