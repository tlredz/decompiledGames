local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local object = luaupolyfill.Object
local Tracing = require(script.Parent:WaitForChild("Tracing"))
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local enableSchedulerTracing = shared.ReactFeatureFlags.enableSchedulerTracing
local __subscriberRef = Tracing.__subscriberRef
local v = {}

function onInteractionTraced(p)
	local flag = false
	local v2 = nil

	for k, _ in v do
		local success, result = pcall(k.onInteractionTraced, p)

		if success or flag then
			continue
		end

		v2 = result
		flag = true
	end

	if flag then
		error(v2)
	end
end

function onInteractionScheduledWorkCompleted(p)
	local flag = false
	local v2 = nil

	for k, _ in v do
		local success, result = pcall(k.onInteractionScheduledWorkCompleted, p)

		if success or flag then
			continue
		end

		v2 = result
		flag = true
	end

	if flag then
		error(v2)
	end
end

function onWorkScheduled(p, p2: number)
	local flag = false
	local v2 = nil

	for k, _ in v do
		local success, result = pcall(k.onWorkScheduled, p, p2)

		if success or flag then
			continue
		end

		v2 = result
		flag = true
	end

	if flag then
		error(v2)
	end
end

function onWorkStarted(p, p2: number)
	local flag = false
	local v2 = nil

	for k, _ in v do
		local success, result = pcall(k.onWorkStarted, p, p2)

		if success or flag then
			continue
		end

		v2 = result
		flag = true
	end

	if flag then
		error(v2)
	end
end

function onWorkStopped(p, p2: number)
	local flag = false
	local v2 = nil

	for k, _ in v do
		local success, result = pcall(k.onWorkStopped, p, p2)

		if success or flag then
			continue
		end

		v2 = result
		flag = true
	end

	if flag then
		error(v2)
	end
end

function onWorkCanceled(p, p2: number)
	local flag = false
	local v2 = nil

	for k, _ in v do
		local success, result = pcall(k.onWorkCanceled, p, p2)

		if success or flag then
			continue
		end

		v2 = result
		flag = true
	end

	if flag then
		error(v2)
	end
end

local TracingSubscriptions = {}

function TracingSubscriptions.unstable_subscribe(p)
	if enableSchedulerTracing then
		v[p] = true

		if #object.keys(v) == 1 then
			__subscriberRef.current = {
				onInteractionScheduledWorkCompleted = onInteractionScheduledWorkCompleted,
				onInteractionTraced = onInteractionTraced,
				onWorkCanceled = onWorkCanceled,
				onWorkScheduled = onWorkScheduled,
				onWorkStarted = onWorkStarted,
				onWorkStopped = onWorkStopped
			}
		end
	end
end

function TracingSubscriptions.unstable_unsubscribe(p)
	if enableSchedulerTracing then
		v[p] = nil

		if #object.keys(v) == 0 then
			__subscriberRef.current = nil
		end
	end
end

return TracingSubscriptions