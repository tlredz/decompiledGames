local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Utilities.Signal)
require(script.Parent.Parent.types.Marker)
require(script.Parent.Parent.types.Save)
require(script.Parent.Parent.types.Sequence)
require(script.Parent.Parent.types.Strip)
local ActorResolver = require(script.Parent.ActorResolver)
local Markers = require(script.Parent.Markers)
local PropertyRegistry = require(script.Parent.Parent.strips.PropertyRegistry)
local StripRegistry = require(script.Parent.Parent.strips.StripRegistry)

local function protectVoid(callback)
	return pcall(function()
		callback()
		return nil
	end)
end

local Sequence = {}
Sequence.__index = Sequence

function Sequence.new(p, root, executionContext: string)
	local object = setmetatable({
		_data = p,
		_root = root,
		_executionContext = executionContext,
		_state = "ready",
		_isPaused = false,
		_timeSeconds = 0,
		_completedOnce = false,
		_runtimeRecords = {},
		_recordsByActorId = {},
		_markerSignals = {},
		_markers = Markers.new(p.markers),
		_actorResolver = nil,
		started = Signal.new(),
		updated = Signal.new(),
		completed = Signal.new(),
		stopped = Signal.new(),
		errored = Signal.new(),
		markerReached = Signal.new(),
		actorResolved = Signal.new(),
		actorUnresolved = Signal.new()
	}, Sequence)
	object._actorResolver = ActorResolver.new(root, p.actors, function(p4: string, p5)
		object:_onActorResolved(p4, p5)
	end, function(p4: string, p5)
		object:_onActorUnresolved(p4, p5)
	end)
	return object
end

function Sequence:_reportError(p2: string)
	self.errored:FireImmediate(p2)
end

function Sequence:_makeContext(p, actor, previousTimeSeconds: number, isCatchUp: boolean, flag2: boolean)
	return {
		executionContext = self._executionContext,
		actor = actor,
		root = self._root,
		isGlobal = p.strip.actorId == "__sequence",
		timeSeconds = self._timeSeconds,
		previousTimeSeconds = previousTimeSeconds,
		isCatchUp = isCatchUp,
		isSeeking = flag2
	}
end

function Sequence:_reportStripFailure(p, p2)
	self:_reportError(string.format("Strip '%s' failed: %s", p.strip.id, (tostring(p2))))
end

function Sequence:_setRecordPaused(p, flag: boolean)
	if p.actor ~= nil then
		local pause

		if flag then
			pause = p.runtime.pause
		else
			pause = p.runtime.resume
		end

		if pause ~= nil then
			local function fn()
				pause(p.runtime)
			end

			local success, result = pcall(function()
				fn()
				return nil
			end)

			if not success then
				self:_reportStripFailure(p, result)
			end
		end
	end
end

function Sequence:_setRuntimesPaused(flag: boolean)
	for _, _runtimeRecord in self._runtimeRecords do
		self:_setRecordPaused(_runtimeRecord, flag)
	end
end

function Sequence:_attachRecord(state, actor, p: number, flag: boolean, flag2: boolean)
	if state.actor == nil then
		local _makeContext = self:_makeContext(state, actor, p, flag, flag2)
		local success, result = pcall(state.runtime.attach, state.runtime, actor, _makeContext)

		if success then
			if result then
				state.actor = actor

				if self._isPaused then
					self:_setRecordPaused(state, true)
				end
			end
		else
			self:_reportStripFailure(state, result)
		end
	end
end

function Sequence:_detachRecord(state, p: string, flag: boolean)
	if state.actor ~= nil then
		local function fn()
			state.runtime:detach(p, flag)
		end

		local success, result = pcall(function()
			fn()
			return nil
		end)

		if not success then
			self:_reportStripFailure(state, result)
		end

		state.actor = nil
	end
end

function Sequence:_onActorResolved(p: string, p2)
	local v = self._recordsByActorId[p]

	if v ~= nil then
		for _, v2 in v do
			self:_attachRecord(v2, p2, self._timeSeconds, true, false)
		end
	end

	self.actorResolved:FireImmediate(p, p2)
end

function Sequence:_onActorUnresolved(p: string, p2)
	local v = self._recordsByActorId[p]

	if v ~= nil then
		for _, v2 in v do
			self:_detachRecord(v2, "actorUnresolved", true)
		end
	end

	self.actorUnresolved:FireImmediate(p, p2)
end

function Sequence:_buildRuntimes()
	for _, strip in self._data.strips do
		local v = PropertyRegistry.get(strip.propertyName)
		local v2 = v == nil and "both" or v.context

		if not (v2 == "both" or v2 == self._executionContext) then
			continue
		end

		local v3 = StripRegistry.get(strip.type)

		if v3 == nil then
			error("A validated strip has no runtime definition.")
		else
			local v4 = strip
			local v5 = {
				strip = strip,
				actor = nil,
				runtime = v3.createRuntime(strip, function(p: string)
					self:_reportError(string.format("Strip '%s' failed: %s", v4.id, p))
				end)
			}
			table.insert(self._runtimeRecords, v5)
			local v6 = self._recordsByActorId[strip.actorId]

			if v6 == nil then
				v6 = {}
				self._recordsByActorId[strip.actorId] = v6
			end

			table.insert(v6, v5)
		end
	end
end

function Sequence:_evaluate(p: number, flag: boolean, flag2: boolean)
	for _, _runtimeRecord in self._runtimeRecords do
		local actor = _runtimeRecord.actor

		if actor == nil then
			continue
		end

		local v = _runtimeRecord
		local v2 = self:_makeContext(_runtimeRecord, actor, p, flag, flag2)

		local function fn()
			v.runtime:update(v2)
		end

		local success, result = pcall(function()
			fn()
			return nil
		end)

		if not success then
			self:_reportStripFailure(_runtimeRecord, result)
		end
	end
end

function Sequence:_reconstruct(p: number)
	for _, _runtimeRecord in self._runtimeRecords do
		self:_detachRecord(_runtimeRecord, "seeking", true)
	end

	local _actorResolver = self._actorResolver

	if _actorResolver ~= nil then
		for k, v in self._recordsByActorId do
			local v2 = _actorResolver:get(k)

			if v2 == nil then
				continue
			end

			for _, v3 in v do
				self:_attachRecord(v3, v2, p, true, true)
			end
		end
	end
end

function Sequence:_fireMarker(p2: string, p3: string, p4: number, flag: boolean)
	if not flag then
		self.markerReached:FireImmediate(p2, p3, p4)
	end

	local _markerSignal = self._markerSignals[p2]

	if _markerSignal ~= nil then
		_markerSignal:FireImmediate(p3, p4, flag)
	end
end

function Sequence:_setTime(value: number, flag: boolean)
	if value ~= value or math.abs(value) == 1e999 then
		error("Sequence time must be a finite number.")
	end

	local _timeSeconds = self._timeSeconds
	local timeSeconds = math.clamp(value, 0, self._data.durationSeconds)
	self._timeSeconds = timeSeconds

	if timeSeconds < _timeSeconds then
		self:_reconstruct(_timeSeconds)
	else
		self:_evaluate(_timeSeconds, false, flag)
	end

	if flag then
		self._markers:seek(timeSeconds)
	else
		self._markers:advance(_timeSeconds, timeSeconds, function(p: string, p2: string, p3: number, flag2: boolean)
			self:_fireMarker(p, p2, p3, flag2)
		end)
	end

	if self._data.durationSeconds <= timeSeconds then
		self._state = "complete"

		if not self._completedOnce then
			self._completedOnce = true
			self.completed:FireImmediate(timeSeconds)
		end
	else
		self._state = "playing"
	end

	self.updated:FireImmediate(timeSeconds, _timeSeconds, flag)
end

function Sequence:start(value: number?)
	if self._state ~= "ready" then
		error("Sequence can only be started from the ready state.")
	end

	local v = value or 0

	if v ~= v or math.abs(v) == 1e999 then
		error("Sequence time must be a finite number.")
	end

	self._state = "playing"
	self._timeSeconds = math.clamp(v, 0, self._data.durationSeconds)

	local function fn()
		self:_buildRuntimes()
		local _actorResolver = self._actorResolver

		if _actorResolver ~= nil then
			_actorResolver:start()
		end

		self.started:FireImmediate(self._timeSeconds)
		self._markers:start(self._timeSeconds, function(p: string, p2: string, p3: number, flag: boolean)
			self:_fireMarker(p, p2, p3, flag)
		end)

		if self._timeSeconds >= self._data.durationSeconds then
			self._state = "complete"
			self._completedOnce = true
			self.completed:FireImmediate(self._timeSeconds)
		end
	end

	local success, result = pcall(function()
		fn()
		return nil
	end)

	if not success then
		self:_reportError((tostring(result)))
		self:stop("startFailure")
		error(result)
	end
end

function Sequence:update(p: number)
	if self._state == "playing" or self._state == "complete" then
		self:_setTime(p, false)
	else
		error("Sequence must be started before it can be updated or sought.")
	end
end

function Sequence:seek(p: number)
	if self._state == "playing" or self._state == "complete" then
		self:_setTime(p, true)
	else
		error("Sequence must be started before it can be updated or sought.")
	end
end

function Sequence:pause()
	if self._state == "playing" or self._state == "complete" then
		if not self._isPaused then
			self._isPaused = true
			self:_setRuntimesPaused(true)
		end
	else
		error("Sequence must be started before it can be paused or resumed.")
	end
end

function Sequence:resume()
	if self._state == "playing" or self._state == "complete" then
		if self._isPaused then
			self._isPaused = false
			self:_setRuntimesPaused(false)
		end
	else
		error("Sequence must be started before it can be paused or resumed.")
	end
end

function Sequence:stop(value: string?, flag: boolean?)
	if self._state ~= "stopped" then
		self._state = "stopped"
		self._isPaused = false
		local v = flag ~= false
		local v2 = value or "stopped"

		for _, _runtimeRecord in self._runtimeRecords do
			self:_detachRecord(_runtimeRecord, v2, v)
		end

		local _actorResolver = self._actorResolver

		if _actorResolver ~= nil then
			_actorResolver:stop()
		end

		for _, _runtimeRecord in self._runtimeRecords do
			local v3 = _runtimeRecord

			local function fn()
				v3.runtime:destroy(v2, v)
			end

			local success, result = pcall(function()
				fn()
				return nil
			end)

			if not success then
				self:_reportStripFailure(_runtimeRecord, result)
			end

			_runtimeRecord.actor = nil
		end

		table.clear(self._runtimeRecords)
		table.clear(self._recordsByActorId)
		self.stopped:FireImmediate(v2)
		self:_destroySignals()
	end
end

function Sequence:_destroySignals()
	for _, _markerSignal in self._markerSignals do
		_markerSignal:Destroy()
	end

	table.clear(self._markerSignals)
	self.started:Destroy()
	self.updated:Destroy()
	self.completed:Destroy()
	self.stopped:Destroy()
	self.errored:Destroy()
	self.markerReached:Destroy()
	self.actorResolved:Destroy()
	self.actorUnresolved:Destroy()
end

function Sequence:onMarker(p: string, callback, p2)
	if self._state == "stopped" then
		error("Cannot connect a marker callback after the Sequence has stopped.")
	end

	local _markerSignal = self._markerSignals[p]

	if _markerSignal == nil then
		_markerSignal = Signal.new()
		self._markerSignals[p] = _markerSignal
	end

	return _markerSignal:Connect(function(p3: string, p4: number, flag: boolean)
		if flag and (p2 == nil or p2.runOnCatchUp ~= true) then
			return
		end

		local success, result = pcall(function()
			callback(p3, p4)
			return nil
		end)

		if not success then
			self:_reportError(string.format("Marker '%s' callback failed: %s", p, (tostring(result))))
		end
	end)
end

function Sequence:getDuration()
	return self._data.durationSeconds
end

function Sequence:getTimePosition()
	return self._timeSeconds
end

function Sequence:getState()
	return self._state
end

function Sequence:isPlaying()
	return self._state == "playing" and not self._isPaused
end

function Sequence:isPaused()
	return self._isPaused
end

function Sequence:isComplete()
	return self._state == "complete"
end

return Sequence