local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.Signal)
local class = {}
class.__index = class

function class.__tostring()
	return "<State>"
end

function class:Get()
	return self._value
end

function class:Connect(on_signal)
	return self._signal:Connect(on_signal)
end

function class:Wait()
	return self._signal:Wait()
end

function class:Set(p)
	if self._value == p then
		return p
	end

	self._value = p
	self._signal:Fire(p)

	for k in table.clone(self._dependents) do
		task.spawn(k.Update, k)
	end

	return p
end

function class:Destroy()
	assert(
		next(self._dependents) == nil,
		(`Attempted to destroy State with dependents\n{debug.info(2, "s")}:{debug.info(2, "l")}`)
	)
	self._signal:Destroy()
	table.clear(self)
end

function class.new(p)
	return (setmetatable({
		_dependents = {},
		_value = p,
		_signal = v.new()
	}, class))
end

local class2 = {}
class2.__index = class2

function class2.__tostring()
	return "<Computed>"
end

function class2:Get()
	return self._value
end

function class2:Connect(on_signal)
	return self._signal:Connect(on_signal)
end

function class2:Wait()
	return self._signal:Wait()
end

function class2:Update()
	local _dependencies = self._dependencies

	for k in _dependencies do
		_dependencies[k] = nil
		k._dependents[self] = nil
	end

	local _fn = self._fn(self._useState)

	if self._value == _fn then
		return
	end

	self._value = _fn
	self._signal:Fire(_fn)

	for k in table.clone(self._dependents) do
		task.spawn(k.Update, k)
	end

	return _fn
end

function class2:Destroy()
	assert(
		next(self._dependents) == nil,
		(`Attempted to destroy Computed with dependents\n{debug.info(2, "s")}:{debug.info(2, "l")}`)
	)
	table.clear(self._dependents)
	local _dependencies = self._dependencies

	for k in _dependencies do
		k._dependents[self] = nil
	end

	table.clear(_dependencies)
	self._signal:Destroy()
	table.clear(self)
end

function class2.new(fn)
	local object = setmetatable({
		_dependents = {},
		_signal = v.new(),
		_fn = fn,
		_dependencies = {}
	}, class2)

	function object:_useState()
		assert(self, "Attempted to call UseStatable a non-statable")
		object._dependencies[self] = true
		self._dependents[object] = true
		return self:Get()
	end

	object:Update()
	return object
end

local class3 = {}
class3.__index = class3

function class3.__tostring()
	return "<Condition>"
end

function class3:Update()
	local _dependencies = self._dependencies

	for k in _dependencies do
		_dependencies[k] = nil
		k._dependents[self] = nil
	end

	local _fn = self._fn(self._useState)

	if not _fn then
		return _fn
	end

	if typeof(self._callback) == "thread" then
		if coroutine.status(self._callback) == "suspended" then
			task.spawn(self._callback)
		else
			warn("[Statable.Condition] Can't resume non-suspended coroutine")
		end
	else
		task.spawn(self._callback)
	end

	self:Destroy()
	return _fn
end

function class3:Destroy()
	local _dependencies = self._dependencies

	for k in _dependencies do
		k._dependents[self] = nil
	end

	table.clear(_dependencies)
	table.clear(self)
end

function class3.async(fn, callback)
	local object = setmetatable({
		_fn = fn,
		_callback = callback,
		_dependencies = {}
	}, class3)

	function object:_useState()
		assert(self, "Attempted to call UseStatable a non-statable")
		object._dependencies[self] = true
		self._dependents[object] = true
		return self:Get()
	end

	task.spawn(object.Update, object)
	return object
end

function class3.sync(callback)
	local thread = nil
	local v2 = nil
	class3.async(callback, function(p)
		v2 = p

		if thread then
			task.spawn(thread, v2)
		end
	end)

	if v2 then
		return v2
	end

	thread = coroutine.running()
	return coroutine.yield()
end

local Statable = {
	State = class.new,
	Computed = class2.new,
	ConditionAsync = class3.async,
	ConditionSync = class3.sync
}
local v2 = {}

function Statable.getPropertyState(instance, propertyName: string)
	local v3 = v2[instance]

	if not v3 then
		v3 = {}
		v2[instance] = v3
	end

	local v4 = v3[propertyName]

	if not v4 then
		local success, result = pcall(function()
			return instance[propertyName]
		end)
		local new = class.new

		if not success then
			result = nil
		end

		v4 = new(result)
		v4.__conn = instance:GetPropertyChangedSignal(propertyName):Connect(function()
			v4:Set(instance[propertyName])
		end)
		v3[propertyName] = v4
	end

	local __conn = v4.__conn
	return v4, __conn
end

local v3 = {}

function Statable.getAttributeState(instance, attributeName: string)
	local v4 = v3[instance]

	if not v4 then
		v4 = {}
		v3[instance] = v4
	end

	local v5 = v4[attributeName]

	if v5 then
		return v5, v5.__cleaner
	end

	v5 = class.new(instance:GetAttribute(attributeName))
	local connection = instance:GetAttributeChangedSignal(attributeName):Connect(function()
		v5:Set(instance:GetAttribute(attributeName))
	end)

	function v5.__cleaner()
		connection:Disconnect()
		v4[attributeName] = nil
	end

	v4[attributeName] = v5
	return v5, v5.__cleaner
end

local v4 = {}
setmetatable(v4, {
	__mode = "k"
})

function Statable.getReplionPathState(object, list)
	local joined

	if type(list) == "table" then
		joined = table.concat(list, ".")
	else
		joined = list
	end

	local v5 = v4[object]

	if not v5 then
		v5 = {}
		v4[object] = v5
	end

	local v6 = v5[joined]

	if not v6 then
		v6 = class.new(object:Get(list))
		v6.__conn = object:OnChange(list, function(p)
			v6:Set(p)
		end)
		v5[joined] = v6
	end

	return v6, v6.__conn
end

function Statable:setPropertyState(p2: string, p3)
	return class2.new(function(callback)
		local v5 = callback(p3)
		self[p2] = v5
		return v5
	end)
end

function Statable:setPropertyComputed(p2: string, callback)
	return class2.new(function(p3)
		local v5 = callback(p3)
		self[p2] = v5
		return v5
	end)
end

local v5 = {}

function Statable.getChildrenState(instance)
	local v6 = v5[instance]

	if not v6 then
		v6 = class.new()

		local function update()
			v6:Set(instance:GetChildren())
		end

		local childAddedConnection = instance.ChildAdded:Connect(update)
		local childRemovedConnection = instance.ChildRemoved:Connect(update)
		update()

		local function clean()
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
			childAddedConnection = nil
			childRemovedConnection = nil
			update = nil
			v5[instance] = nil
		end

		v6.__cleaner = clean
		v5[instance] = v6
	end

	local __cleaner = v6.__cleaner
	return v6, __cleaner
end

return Statable