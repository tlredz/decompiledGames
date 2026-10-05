local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local set = luaupolyfill.Set
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local enableSchedulerTracing = shared.ReactFeatureFlags.enableSchedulerTracing
local count = 0
local count2 = 0
local interactionsRef, subscriberRef

if enableSchedulerTracing then
	interactionsRef = {
		current = set.new()
	}
	subscriberRef = {
		current = nil
	}
else
	interactionsRef = nil
	subscriberRef = nil
end

local Tracing = {}
Tracing.__interactionsRef = interactionsRef
Tracing.__subscriberRef = subscriberRef

function Tracing.unstable_clear(callback)
	if not enableSchedulerTracing then
		return callback()
	end

	local current = interactionsRef.current
	interactionsRef.current = set.new()
	local success, result = pcall(callback)
	interactionsRef.current = current

	if not success then
		error(result)
	end

	return result
end

function Tracing.unstable_getCurrent()
	if enableSchedulerTracing then
		return interactionsRef.current
	end

	return nil
end

function Tracing.unstable_getThreadID()
	count2 += 1
	return count2
end

function Tracing.unstable_trace(name: string, timestamp: number, callback, p3: number?)
	local v3 = p3 == nil and 0 or p3

	if not enableSchedulerTracing then
		return callback()
	end

	local v4 = {
		__count = 1,
		id = count,
		name = name,
		timestamp = timestamp
	}
	count += 1
	local current = interactionsRef.current
	local current3 = set.new(current)
	current3:add(v4)
	interactionsRef.current = current3
	local current2 = subscriberRef.current
	local v6 = nil
	local success, result = pcall(function()
		if current2 ~= nil then
			current2.onInteractionTraced(v4)
		end
	end)
	local success2, result2 = pcall(function()
		if current2 ~= nil then
			current2.onWorkStarted(current3, v3)
		end
	end)
	local success3, result3 = pcall(function()
		v6 = callback()
	end)
	interactionsRef.current = current
	local success4, result4 = pcall(function()
		if current2 ~= nil then
			current2.onWorkStopped(current3, v3)
		end
	end)
	v4.__count -= 1

	if current2 ~= nil and v4.__count == 0 then
		current2.onInteractionScheduledWorkCompleted(v4)
	end

	if not success4 then
		error(result4)
	end

	if not success3 then
		error(result3)
	end

	if not success2 then
		error(result2)
	end

	if not success then
		error(result)
	end

	return v6
end

function Tracing.unstable_wrap(callback, p: number)
	local v3 = p == nil and 0 or p

	if not enableSchedulerTracing then
		return callback
	end

	local current = interactionsRef.current
	local current2 = subscriberRef.current

	if current2 ~= nil then
		current2.onWorkScheduled(current, v3)
	end

	for _, v4 in current do
		v4.__count += 1
	end

	local v4 = false

	local function _wrapped(_, ...)
		local current3 = interactionsRef.current
		interactionsRef.current = current
		current2 = subscriberRef.current
		local success, result = pcall(function(...)
			local v5 = nil
			local success2, result2 = pcall(function()
				if current2 ~= nil then
					current2.onWorkStarted(current, v3)
				end
			end)
			local success3, result3 = pcall(function(...)
				v5 = callback(...)
			end, ...)
			interactionsRef.current = current3

			if current2 ~= nil then
				current2.onWorkStopped(current, v3)
			end

			if not success3 then
				error(result3)
			end

			if not success2 then
				error(result2)
			end

			return v5
		end, ...)

		if not v4 then
			v4 = true

			for _, v5 in current do
				v5.__count -= 1

				if current2 ~= nil and v5.__count == 0 then
					current2.onInteractionScheduledWorkCompleted(v5)
				end
			end
		end

		if not success then
			error(result)
		end

		return result
	end

	local function fn()
		current2 = subscriberRef.current
		local success, result = pcall(function()
			if current2 ~= nil then
				current2.onWorkCanceled(current, v3)
			end
		end)

		for _, v5 in current do
			v5.__count -= 1

			if current2 ~= nil and v5.__count == 0 then
				current2.onInteractionScheduledWorkCompleted(v5)
			end
		end

		if not success then
			error(result)
		end
	end

	local v5 = {}
	setmetatable(v5, {
		__call = _wrapped
	})
	v5.cancel = fn
	return v5
end

return Tracing