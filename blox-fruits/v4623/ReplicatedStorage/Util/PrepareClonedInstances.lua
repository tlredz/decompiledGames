local RunService = game:GetService("RunService")
local class = {}
class.__index = class
local v = {}
local v2 = 1
local heartbeatConnection = nil

local function compactPendingPools()
	if v2 <= 64 or v2 <= #v / 2 then
		return
	end

	local v3 = table.create(#v - v2 + 1)

	for i = v2, #v do
		table.insert(v3, v[i])
	end

	v = v3
	v2 = 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopSchedulerIfEmpty()
	if v2 <= #v then
		return
	end

	table.clear(v)
	v2 = 1

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function stepScheduler()
	while v2 <= #v do
		local v3 = v[v2]
		v2 += 1
		v3._queued = false

		if v3._destroyed or not (v3._nextToPrepare <= #v3._requests) then
			continue
		end

		v3:_prepareNext()

		if v3._nextToPrepare <= #v3._requests then
			v3._queued = true
			table.insert(v, v3)
		end

		break
	end

	compactPendingPools()
	stopSchedulerIfEmpty() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startScheduler()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(stepScheduler)
end

local function queuePool(state)
	if state._queued or state._destroyed or state._nextToPrepare > #state._requests then
		return
	end

	state._queued = true
	table.insert(v, state)
	startScheduler() -- equivalent call inferred; original call site unknown
end

local function normalizeRequest(instance)
	if typeof(instance) == "Instance" then
		return {
			Template = instance
		}
	end

	assert(typeof(instance.Template) == "Instance", "PrepareClonedInstances requests need an Instance Template")
	assert(
		instance.Prepare == nil or type(instance.Prepare) == "function",
		"PrepareClonedInstances Prepare must be a function"
	)
	return {
		Template = instance.Template,
		Prepare = instance.Prepare
	}
end

function class:_prepareNext()
	if self._destroyed then
		return nil
	end

	local _nextToPrepare = self._nextToPrepare
	local _request = self._requests[_nextToPrepare]

	if not _request then
		return nil
	end

	local clone = _request.Template:Clone()
	local prepare = _request.Prepare

	if prepare and not pcall(prepare, clone) then
		clone:Destroy()
		self:Destroy()
		error(`PrepareClonedInstances failed to prepare {_request.Template:GetFullName()}`, 0)
	end

	self._prepared[_nextToPrepare] = clone
	self._nextToPrepare += 1
	return clone
end

function class:Take()
	assert(not self._destroyed, "Cannot take from a destroyed PrepareClonedInstances pool")
	local _nextToTake = self._nextToTake
	assert(_nextToTake <= #self._requests, "PrepareClonedInstances pool is empty")
	local v3 = self._prepared[_nextToTake]

	if not v3 then
		assert(_nextToTake == self._nextToPrepare, "PrepareClonedInstances pool order is invalid")
		v3 = self:_prepareNext()
		assert(v3, "PrepareClonedInstances could not clone the next instance")
	end

	self._prepared[_nextToTake] = nil
	self._nextToTake += 1
	return v3
end

function class:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, v3 in self._prepared do
		v3:Destroy()
	end

	table.clear(self._prepared)
	table.clear(self._requests)
end

return {
	new = function(list)
		local requests = table.create(#list)

		for i = 1, #list do
			local request = normalizeRequest(list[i])
			assert(
				request.Template.Archivable,
				(`Cannot clone non-archivable instance {request.Template:GetFullName()}`)
			)
			requests[i] = request
		end

		local self = setmetatable({
			_requests = requests,
			_prepared = table.create(#requests),
			_nextToPrepare = 1,
			_nextToTake = 1,
			_queued = false,
			_destroyed = false
		}, class)

		if self._queued or self._destroyed or self._nextToPrepare > #self._requests then
			return self
		end

		self._queued = true
		table.insert(v, self)
		startScheduler() -- equivalent call inferred; original call site unknown
		return self
	end
}