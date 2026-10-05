local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Maid = require(script.Parent.Maid)
local Signal = require(script.Parent.Signal)
local Binder = {}
Binder.__index = Binder
Binder.ClassName = "Binder"

function Binder.new(p, p2)
	local object = setmetatable({}, Binder)
	object._maid = Maid.new()
	object._tagName = p or error("Bad argument 'tagName', expected string")
	object._constructor = p2 or error("Bad argument 'constructor', expected table or function: " .. p)
	object._instToClass = {}
	object._allClassSet = {}
	object._pendingInstSet = {}
	object._listeners = {}
	task.delay(5, function()
		if not object._loaded then
			warn(("Binder %q is not loaded. Call :Start() on it!"):format(object._tagName))
		end
	end)
	return object
end

function Binder.isBinder(instance)
	return type(instance) == "table" and instance.ClassName == "Binder"
end

function Binder:Start(...)
	if self._loaded then
		return
	end

	self._loaded = true
	local v = Signal.new()

	for _, v2 in pairs(CollectionService:GetTagged(self._tagName)) do
		local v3 = v2
		local connection = v:Connect(function()
			self:_add(v3)
		end)
		v:Fire()
		connection:Disconnect()
	end

	v:Destroy()
	self._maid:GiveTask(CollectionService:GetInstanceAddedSignal(self._tagName):Connect(function(p)
		self:_add(p)
	end))
	self._maid:GiveTask(CollectionService:GetInstanceRemovedSignal(self._tagName):Connect(function(p)
		self:_remove(p)
	end))
end

function Binder:GetTag()
	return self._tagName
end

function Binder:GetConstructor()
	return self._constructor
end

function Binder:ObserveInstance(p2, p3)
	self._listeners[p2] = self._listeners[p2] or {}
	self._listeners[p2][p3] = true
	return function()
		if not self._listeners[p2] then
			return
		end

		self._listeners[p2][p3] = nil

		if not next(self._listeners[p2]) then
			self._listeners[p2] = nil
		end
	end
end

function Binder:GetClassAddedSignal()
	if self._classAddedSignal then
		return self._classAddedSignal
	end

	self._classAddedSignal = Signal.new()
	self._maid:GiveTask(self._classAddedSignal)
	return self._classAddedSignal
end

function Binder:GetClassRemovingSignal()
	if self._classRemovingSignal then
		return self._classRemovingSignal
	end

	self._classRemovingSignal = Signal.new()
	self._maid:GiveTask(self._classRemovingSignal)
	return self._classRemovingSignal
end

function Binder:GetAll()
	local result = {}

	for k, _ in pairs(self._allClassSet) do
		result[#result + 1] = k
	end

	return result
end

function Binder:GetAllSet()
	return self._allClassSet
end

function Binder:Bind(instance)
	if RunService:IsClient() then
		warn(("[Binder.Bind] - Bindings '%s' done on the client! Will be disrupted upon server replication! %s"):format(
			self._tagName,
			debug.traceback()
		))
	end

	CollectionService:AddTag(instance, self._tagName)
	return self:Get(instance)
end

function Binder:Unbind(instance)
	assert(typeof(instance) == "Instance")

	if RunService:IsClient() then
		warn(("[Binder.Bind] - Unbinding '%s' done on the client! Might be disrupted upon server replication! %s"):format(
			self._tagName,
			debug.traceback()
		))
	end

	CollectionService:RemoveTag(instance, self._tagName)
end

function Binder:BindClient(instance)
	if not RunService:IsClient() then
		warn(("[Binder.BindClient] - Bindings '%s' done on the server! Will be replicated!"):format(self._tagName))
	end

	CollectionService:AddTag(instance, self._tagName)
	return self:Get(instance)
end

function Binder:UnbindClient(instance)
	assert(typeof(instance) == "Instance")
	CollectionService:RemoveTag(instance, self._tagName)
end

function Binder:Get(instance)
	assert(typeof(instance) == "Instance", "Argument 'inst' is not an Instance")
	return self._instToClass[instance]
end

function Binder.Promise(_, instance, _)
	assert(typeof(instance) == "Instance", "Argument 'inst' is not an Instance")
end

function Binder:_add(instance)
	assert(typeof(instance) == "Instance", "Argument 'inst' is not an Instance")

	if self._instToClass[instance] then
		return
	end

	if self._pendingInstSet[instance] == true then
		warn("[Binder._add] - Reentered add. Still loading, probably caused by error in constructor.")
		return
	end

	self._pendingInstSet[instance] = true
	local _constructor

	if type(self._constructor) == "function" then
		_constructor = self._constructor(instance)
	elseif self._constructor.Create then
		_constructor = self._constructor:Create(instance)
	elseif self._constructor.new then
		_constructor = self._constructor.new(instance)
	else
		warn(("[Binder._add] - No contructor given for tag %s"):format(self._tagName))
		return
	end

	local destroy = _constructor or {}
	local v2 = typeof(destroy) == "function" and {
		Destroy = destroy
	} or destroy
	local _ = self._pendingInstSet[instance] == true
	self._pendingInstSet[instance] = nil
	self._allClassSet[v2] = true
	self._instToClass[instance] = v2
	local _listener = self._listeners[instance]

	if _listener then
		local v3 = Signal.new()

		for k, _ in pairs(_listener) do
			local eventConnection = nil
			local v4 = k
			eventConnection = v3.Event:Connect(function()
				eventConnection:Disconnect()
				v4(v2)
			end)
			v3:Fire()
		end

		v3:Destroy()
	end

	if self._classAddedSignal then
		self._classAddedSignal:Fire(v2, instance)
	end
end

function Binder:_remove(p)
	self._pendingInstSet[p] = nil
	local v = self._instToClass[p]

	if v == nil then
		return
	end

	if self._classRemovingSignal then
		self._classRemovingSignal:Fire(v, p)
	end

	self._instToClass[p] = nil
	self._allClassSet[v] = nil
	local _listener = self._listeners[p]

	if _listener then
		local v2 = Signal.new()

		for k, _ in pairs(_listener) do
			local v3 = k
			local eventConnection = v2.Event:Connect(function()
				v3(nil)
			end)
			v2:Fire()
			eventConnection:Disconnect()
		end

		v2:Destroy()
	end

	if not v.Destroy then
		return
	end

	v:Destroy()
end

function Binder:Destroy()
	local v, v2 = next(self._instToClass)

	while v2 ~= nil do
		self:_remove(v2)

		if self._instToClass[v] ~= nil then
			self._instToClass[v] = nil
		end

		v, v2 = next(self._instToClass)
	end

	self._maid:Destroy()
end

return Binder