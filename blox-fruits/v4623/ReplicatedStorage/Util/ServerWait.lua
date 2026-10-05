local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local waitFrame

if not RunService:IsRunning() or GlobalUtil.FFlags.IsUnitTest ~= false then
	return waitFrame
end

local RunService2 = game:GetService("RunService")

if RunService2:IsClient() then
	return function(...)
		warn("Cannot use ServerWait in client!")
	end
end

local bindableEvent = Instance.new("BindableEvent")

waitFrame = function(value)
	local lastTime = tick()
	pcall(function()
		value = value or 0.03333333333333333

		for _ = 1, 0.001 + value / 0.03333333333333333 do
			bindableEvent.Event:Wait()
		end
	end)
	return tick() - lastTime
end

local v = 0
local now = tick()

-- equivalent calls inferred from this helper; original call sites unknown
local function start()
	return (task.spawn(function()
		local lastTime = tick()

		while wait() do
			local v2 = tick() - lastTime

			if v2 > 1.5 then
				break
			end

			v += v2

			if v > 0.03333333333333333 then
				local v3 = math.floor(v / 0.03333333333333333)

				for _ = 1, v3 do
					bindableEvent:Fire()
				end

				v -= v3 * 0.03333333333333333
			end

			lastTime = tick()
			now = lastTime
		end
	end))
end

local thread = start() -- equivalent call inferred; original call site unknown
local bindableEvent2 = Instance.new("BindableEvent", game.ServerStorage)
bindableEvent2.Name = "ServerWaitHasDiedSignal"
task.spawn(function()
	while true do
		if tick() - now > 1.5 then
			bindableEvent2:Fire()
			pcall(function()
				task.cancel(thread)
			end)
			v = 0
			local v2 = bindableEvent
			bindableEvent = Instance.new("BindableEvent")
			v2:Fire()
			v2:Destroy()
			thread = task.spawn(function()
				local lastTime = tick()

				while wait() do
					local v3 = tick() - lastTime

					if v3 > 1.5 then
						break
					end

					v += v3

					if v > 0.03333333333333333 then
						local v4 = math.floor(v / 0.03333333333333333)

						for _ = 1, v4 do
							bindableEvent:Fire()
						end

						v -= v4 * 0.03333333333333333
					end

					lastTime = tick()
					now = lastTime
				end
			end)
		end

		wait(0.1)
	end
end)
return waitFrame