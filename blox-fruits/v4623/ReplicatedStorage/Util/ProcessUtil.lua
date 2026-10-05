local RunService = game:GetService("RunService")
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)

function getDefaultEvent(p)
	if p then
		return p
	end

	if RunService:IsClient() then
		return RunService.RenderStepped
	end

	return RunService.Heartbeat
end

local ProcessUtil = {
	IS_DEBUG_WARN_ENABLED = true
}

function ProcessUtil.newIteratorRunner(items, callback, p: number)
	local v = {}

	for k in pairs(items) do
		table.insert(v, k)
	end

	return ProcessUtil.newRecursiveRunner(1, function(p2: number)
		if #v < p2 then
			return nil
		end

		local v2 = v[p2]
		local v3 = callback(v2, items[v2])

		if #v <= p2 or v3 == true then
			return nil
		end

		return p2 + 1
	end, p)
end

function ProcessUtil.newRecursiveRunner(p, callback, p2: number)
	local v = p
	local v2 = p2 / 1000
	local traceback = debug.traceback("process source", 2)
	local flag = false

	local function onStep()
		if flag then
			return
		end

		local success, result = pcall(function()
			local lastTime = tick()
			local _ = tick() - lastTime
			local count = 0

			while true do
				if v ~= nil then
					local thread = task.spawn(function()
						v = callback(v)
					end)

					if coroutine.status(thread) ~= "dead" then
						error((`process yielded instead of finishing: {traceback}`))
					end

					count += 1
				end

				local v3 = tick() - lastTime

				if v ~= nil and not (v2 < (count + 1) * (v3 / count)) then
					continue
				end

				if ProcessUtil.IS_DEBUG_WARN_ENABLED and count == 1 and v2 < v3 and v then
					warn((`runProcessAsync: a single process run took longer than ms budget, budget={p2}ms, actual={math.round((tick() - lastTime) * 1000 * 100) / 100}ms`))
					warn(traceback)
				end

				break
			end
		end)

		if not success then
			flag = true
			error((`{result}: {traceback}`))
		end
	end

	return function()
		if v == nil or flag then
			return v ~= nil, flag
		end

		local success, result = pcall(function()
			local lastTime = tick()
			local _ = tick() - lastTime
			local count = 0

			while true do
				if v ~= nil then
					local thread = task.spawn(function()
						v = callback(v)
					end)

					if coroutine.status(thread) ~= "dead" then
						error((`process yielded instead of finishing: {traceback}`))
					end

					count += 1
				end

				local v3 = tick() - lastTime

				if v ~= nil and not (v2 < (count + 1) * (v3 / count)) then
					continue
				end

				if ProcessUtil.IS_DEBUG_WARN_ENABLED and count == 1 and v2 < v3 and v then
					warn((`runProcessAsync: a single process run took longer than ms budget, budget={p2}ms, actual={math.round((tick() - lastTime) * 1000 * 100) / 100}ms`))
					warn(traceback)
				end

				break
			end
		end)

		if not success then
			flag = true
			error((`{result}: {traceback}`))
		end

		return v ~= nil, flag
	end
end

function ProcessUtil.run(callback, callback2, p, flag: boolean?)
	local defaultEvent = getDefaultEvent(p)
	assert(defaultEvent)
	local connection = nil
	local flag2 = false
	local flag3 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanUp()
		if not flag3 then
			return
		end

		flag3 = false

		if connection then
			connection:Disconnect()
		end

		if callback2 then
			callback2(flag2)
		end
	end

	local function onStep()
		local v, v2 = callback()
		flag2 = not v

		if flag2 or v2 then
			cleanUp() -- equivalent call inferred; original call site unknown
		end
	end

	local v, v2 = callback()
	flag2 = not v

	if (flag2 or v2) and flag3 then
		flag3 = false

		if connection then
			connection:Disconnect()
		end

		if callback2 then
			callback2(flag2)
		end
	end

	if flag2 or not flag3 then
		return cleanUp
	end

	if flag then
		connection = defaultEvent:ConnectParallel(onStep)
	else
		connection = defaultEvent:Connect(onStep)
	end

	return cleanUp
end

function ProcessUtil.runAsync(callback, callback2, p, flag: boolean?)
	local flag2 = false
	local v = Signal2.new()
	assert(v)
	local v2 = ProcessUtil.run(callback, function(flag3: boolean)
		if flag2 then
			return
		end

		flag2 = true
		v:Fire(flag3)

		if callback2 then
			callback2(flag3)
		end
	end, p, flag)
	local v3

	if not flag2 then
		v3 = v:Wait()
	end

	v2()
	v:Destroy()
	assert(v3 ~= nil)
	return v3
end

return ProcessUtil