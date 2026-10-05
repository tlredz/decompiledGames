local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local finishers = ReplicatedStorage.Modules.Finishers
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self._finishers = {}
	self:_Init()
	return self
end

function object:PlayServer()
	local bindableEvent = Instance.new("BindableEvent")
	local count = 0
	local count2 = 0

	for _, _finisher in pairs(self._finishers) do
		count += 1
		local v = _finisher
		self:_InternalThread(task.spawn, function()
			pcall(v.PlayServer, v)
			count2 += 1
			bindableEvent:Fire()
		end)
	end

	while count2 < count do
		bindableEvent.Event:Wait()
	end
end

function object:PlayClient()
	local bindableEvent = Instance.new("BindableEvent")
	local count = 0
	local count2 = 0

	for _, _finisher in pairs(self._finishers) do
		count += 1
		local v = _finisher
		self:_InternalThread(task.spawn, function()
			pcall(v.PlayClient, v)
			count2 += 1
			bindableEvent:Fire()
		end)
	end

	while count2 < count do
		bindableEvent.Event:Wait()
	end
end

function object:Destroy()
	for _, _finisher in pairs(self._finishers) do
		_finisher:Destroy()
	end

	Finisher.Destroy(self)
end

function object:_Setup()
	for _, moduleScript in pairs(finishers:GetChildren()) do
		if moduleScript == script then
			continue
		end

		local _finishers = self._finishers
		local module = require(moduleScript)
		table.insert(_finishers, module.new(self._subject, self._is_final_finisher, self._eliminator))
	end
end

function object:_Init()
	self:_Setup()
end

return object