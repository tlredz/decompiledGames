local modules = {
	Maid = require(game.ReplicatedStorage.Util.Maid),
	Wait = require(script.Parent.CutsceneUtil.Wait)
}
require(script.Parent.Types)
local class = {}
class.__index = class
local v2 = {}
local object = setmetatable({}, {
	__mode = "k"
})

function v2.getContext(p, p2: string)
	local v3 = object[coroutine.running()]
	assert(v3 and v3.Transition == p, (`EnvironmentTransition:{p2}() requires an active transition`))
	return v3
end

function class.new()
	return (setmetatable({
		_runner = nil
	}, class))
end

function class.is(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

function class:Run(runner)
	assert(typeof(runner) == "function", "EnvironmentTransition:Run() requires a callback")
	assert(self._runner == nil, "EnvironmentTransition already has a runner")
	self._runner = runner
	return self
end

function class.SwapEnvironment(p)
	local context = v2.getContext(p, "SwapEnvironment")
	assert(not context.Cancelled, "Environment transition was cancelled")
	assert(not context.Swapped, "EnvironmentTransition:SwapEnvironment() can only be called once")
	context.Swapped = true
	local environment = context.ChangeEnvironment()
	context.Environment = environment
	return environment
end

function class.Wait(p, p2: number)
	local context = v2.getContext(p, "Wait")
	assert(p2 >= 0, "Environment transition wait duration must be non-negative")
	return not context.Cancelled and modules.Wait.duration(p2, context.CancelledEvent) and not context.Cancelled
end

function class:GiveTask(p2)
	local context = v2.getContext(self, "GiveTask")
	assert(not context.Cancelled, "Environment transition was cancelled")
	context.Maid:GiveTask(p2)
	return p2
end

function class:_execute(changeEnvironment, options, object2, maid)
	local _runner = self._runner
	assert(_runner, "EnvironmentTransition requires a Run() callback")
	assert(typeof(changeEnvironment) == "function", "Environment transition requires an environment callback")
	assert(options == nil or typeof(options) == "table", "Environment transition runtime data must be a table")
	local maid2 = modules.Maid.new()
	local _, v3 = maid:GiveTask(maid2)
	assert(v3, "Environment transition cleanup is unavailable")
	local v4 = {
		Transition = self,
		Maid = maid2,
		CancelledEvent = object2,
		ChangeEnvironment = changeEnvironment,
		Environment = nil,
		Swapped = false,
		Cancelled = false
	}
	maid2.Cancelled = object2:Connect(function()
		v4.Cancelled = true
	end)
	local thread = coroutine.running()
	assert(object[thread] == nil, "Environment transition is already active on this thread")
	object[thread] = v4
	local v5, v6 = xpcall(function()
		_runner(self, options or {})
	end, debug.traceback)
	object[thread] = nil
	maid[v3] = nil

	if not v5 then
		error(v6, 2)
	end

	if v4.Cancelled then
		return nil
	end

	assert(v4.Swapped and v4.Environment, "Environment transition did not swap the environment")
	return v4.Environment
end

return table.freeze(class)