local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local Promise = require(script.Parent.Promise)
local clientActor = script.ClientActor
local serverActor = script.ServerActor
local parallelWorkers = nil

local function getOrFindWorkerFolder()
	if parallelWorkers ~= nil then
		return parallelWorkers
	end

	if RunService:IsServer() then
		parallelWorkers = ServerScriptService:FindFirstChild("ParallelWorkers") or Instance.new("Folder")
		parallelWorkers.Name = "ParallelWorkers"
		parallelWorkers.Parent = ServerScriptService
	else
		local playerScripts = Players.LocalPlayer:FindFirstChild("PlayerScripts")
		parallelWorkers = playerScripts:FindFirstChild("ParallelWorkers") or Instance.new("Folder")
		parallelWorkers.Name = "ParallelWorkers"
		parallelWorkers.Parent = playerScripts
	end

	return parallelWorkers
end

local function createTemplatedActor(instance)
	local clone

	if RunService:IsServer() then
		clone = serverActor:Clone()
	else
		clone = clientActor:Clone()
	end

	local clone2 = instance:Clone()
	clone2.Name = "Runnable"
	clone2.Parent = clone
	return clone, clone:FindFirstChild("Worker")
end

local function waitForActorInit(instance)
	return Promise.new(function(callback)
		while instance:GetAttribute("Initialized") == nil do
			task.wait()
		end

		callback(instance)
	end)
end

local Parallel = {}
Parallel.__index = Parallel

function Parallel.of(moduleScript)
	local v

	if typeof(moduleScript) == "Instance" then
		v = moduleScript:IsA("ModuleScript")
	else
		v = false
	end

	assert(v, "Runnable must be a ModuleScript reference")
	local object = setmetatable({
		_runnable = moduleScript,
		_name = "ParallelWorker",
		_actorCount = 1,
		_bindableEvent = Instance.new("BindableEvent"),
		_folder = Instance.new("Folder"),
		_actors = {},
		_actorState = {},
		_results = {},
		_actorIndex = 1,
		_connection = nil,
		_destroyed = false
	}, Parallel)
	object._connection = object._bindableEvent.Event:Connect(function(p: string, ...)
		object._results[p] = { ... }
	end)
	object._bindableEvent.Parent = object._folder
	object._folder.Parent = getOrFindWorkerFolder()
	object:_createActors()
	return object
end

function Parallel:withName(name: string)
	assert(not self._destroyed, "Parallel destroyed")
	assert(type(name) == "string", "Name must be a string")
	assert(#name > 0, "Name must be non-empty")
	self._name = name
	self._folder.Name = name
	return self
end

function Parallel:withActors(actorCount: number)
	assert(not self._destroyed, "Parallel destroyed")
	assert(type(actorCount) == "number", "Actor count must be a number")
	assert(actorCount > 0, "Actor count must be greater than 0")
	self._actorCount = actorCount
	self._actorIndex = math.min(self._actorIndex, actorCount)
	self:_createActors()
	return self
end

function Parallel:run(...)
	assert(not self._destroyed, "Parallel destroyed")
	local v = { ... }
	return Promise.promisify(self._findActor)(self):andThen(waitForActorInit):andThen(function(object)
		object:SendMessage("Parallel:Run", table.unpack(v))
	end)
end

function Parallel:submit(...)
	assert(not self._destroyed, "Parallel destroyed")
	local v = { ... }
	local _findActor = self:_findActor()
	local GUID = HttpService:GenerateGUID(false)
	local v2 = nil

	local function cleanup(p: string)
		if p == "Cancelled" or p == "Rejected" then
			_findActor:SendMessage("Parallel:CancelTask", GUID)
		end

		self._results[GUID] = nil
		self._actorState[_findActor].count -= 1
		self._actorState[_findActor].running[v2] = nil
	end

	v2 = Promise.new(function(callback)
		while _findActor:GetAttribute("Initialized") == nil do
			task.wait()
		end

		callback(_findActor)
	end):andThen(function()
		_findActor:SendMessage("Parallel:SubmitTask", GUID, table.unpack(v))
	end):andThen(function()
		while self._results[GUID] == nil do
			task.wait()
		end

		return table.unpack(self._results[GUID])
	end):finally(cleanup)
	self._actorState[_findActor].count += 1
	self._actorState[_findActor].running[v2] = true
	return v2
end

function Parallel:destroy()
	assert(not self._destroyed, "Parallel already destroyed")
	self._destroyed = true
	self._connection:Disconnect()
	self._connection = nil

	for _, _actor in self._actors do
		for k, _ in self._actorState[_actor].running do
			k:cancel()
		end

		_actor:SendMessage("Parallel:Destroy")
	end

	self._actors = {}
	self._actorState = {}
	self._results = {}
	self._bindableEvent:Destroy()
	self._bindableEvent = nil
	self._folder:Destroy()
	self._folder = nil
end

function Parallel:_findActor()
	assert(#self._actors > 0, "No actors")
	local _actor = self._actors[self._actorIndex]
	self._actorIndex += 1

	if self._actorIndex > #self._actors then
		self._actorIndex = 1
	end

	return _actor
end

function Parallel:_createActors()
	for _ = 1, self._actorCount - #self._actors do
		local _runnable = self._runnable
		local clone

		if RunService:IsServer() then
			clone = serverActor:Clone()
		else
			clone = clientActor:Clone()
		end

		local clone2 = _runnable:Clone()
		clone2.Name = "Runnable"
		clone2.Parent = clone
		local worker = clone:FindFirstChild("Worker")
		clone.Parent = self._folder
		worker.Disabled = false
		self._actorState[clone] = {
			count = 0,
			running = {}
		}
		table.insert(self._actors, clone)
	end
end

function Parallel:__tostring()
	return string.format("Parallel<%s>", self._name)
end

return Parallel