local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local bindableFunction = Instance.new("BindableFunction", script)
bindableFunction.Name = "RunFunction"

function bindableFunction.OnInvoke(callback, duration: number)
	if not duration then
		return callback()
	end

	local thread = nil
	local v = nil
	task.spawn(function()
		v = { callback() }

		if thread then
			task.spawn(thread)
		end
	end)

	if v then
		return unpack(v)
	end

	thread = coroutine.running()
	task.delay(duration, function()
		if thread then
			v = v or {}
			task.spawn(thread)
		end
	end)
	coroutine.yield()
	thread = nil
	return unpack(v)
end

local bindableEvent = Instance.new("BindableEvent", script)
bindableEvent.Name = "RunFunctionProtected"
bindableEvent.Event:Connect(function(callback, callback2)
	warn("--blah 1")
	local thread = coroutine.running()
	local thread2 = task.spawn(function()
		for i = 1, 20 do
			print("huh", i, coroutine.status(thread), coroutine.status(callback()))
			task.wait(0.5)
		end
	end)
	return (function(p, ...)
		warn("--got return", p, ...)

		if not p then
			warn("protected RunFunction error", ...)
		end

		task.spawn(callback(), ...)
		warn("--blah 2")
		task.cancel(thread2)
	end)(pcall(callback2))
end)
local RunService = game:GetService("RunService")

if not RunService:IsRunning() or GlobalUtil.FFlags.IsUnitTest ~= false then
	return function() end
end

local Global = require(game.ReplicatedStorage.Global)

function Global.RunFunction(p, p2: number)
	return bindableFunction:Invoke(p, p2)
end

local Global2 = require(game.ReplicatedStorage.Global)
return Global2.RunFunction