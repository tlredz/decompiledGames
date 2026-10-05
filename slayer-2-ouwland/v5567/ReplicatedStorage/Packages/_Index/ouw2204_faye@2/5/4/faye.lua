local class = {}
class.__index = class
local insert = table.insert
local find = table.find
local remove = table.remove
require(script.FayeTypes)
local Create = require(script.Create)

function class.Create(p, p2: string)
	return Create(p2, p)
end

local Configure = require(script.Configure)

function class.Configure(p, p2)
	return Configure(p2, p)
end

function class:Extend(flag: boolean?)
	local v = {
		IsActive = true
	}
	setmetatable(v, class)

	if flag == nil then
		v._isCleanAncestor = self._isCleanAncestor
		table.insert(self, v)
	end

	v.ParentThread = self
	return v
end

function class:Spawn(callback, ...)
	if callback == nil then
		return
	end

	local v = false
	local thread = nil
	thread = task.spawn(function(...)
		callback(...)
		v = true

		if thread ~= nil and self.Remove ~= nil then
			self:Remove(thread)
		end
	end, ...)

	if v == false then
		self:Add(thread)
	end
end

function class:Defer(callback, ...)
	if callback == nil then
		return
	end

	local v = false
	local thread = nil
	thread = task.defer(function(...)
		callback(...)
		v = true

		if thread ~= nil and self.Remove ~= nil then
			self:Remove(thread)
		end
	end, ...)

	if v == false then
		self:Add(thread)
	end
end

function class:Delay(duration: number, callback, ...)
	if callback == nil or duration == nil then
		return
	end

	local v = false
	local thread = nil
	thread = task.delay(duration, function(...)
		callback(...)
		v = true

		if thread ~= nil and self.Remove ~= nil then
			self:Remove(thread)
		end
	end, ...)

	if v == false then
		self:Add(thread)
	end
end

function class:Debris(p, p2: number)
	if p == nil or p2 == nil or p.Destroy == nil then
		return
	end

	self:Delay(p2, p.Destroy, p)
end

local Clean = require(script.Clean)

function class:Destroy()
	if self.ParentThread ~= nil then
		if self.ParentThread.Remove ~= nil then
			self.ParentThread:Remove(self)
		end

		self.ParentThread = nil
	end

	Clean(self)
end

local Value = require(script.Value)

function class.Value(p, p2)
	return Value(p2, p)
end

local Animation = require(script.Animation)

function class.Animation(p, p2, p3, p4)
	return Animation(p2, p3, p4, p)
end

local Lerp = require(script.Lerp)

function class.Lerp(p, p2, p3: number?, p4)
	return Lerp(p2, p3, p4, p)
end

local ModifyAnimation = require(script.ModifyAnimation)

function class.ModifyAnimation(p, p2)
	return ModifyAnimation(p, p2)
end

local CloneAnimation = require(script.CloneAnimation)

function class.CloneAnimation(p, p2, p3)
	return CloneAnimation(p2, p3, p)
end

local Info = require(script.Info)

function class.Info(p: number, p2, p3, p4: number, flag: boolean, p5: number)
	return (Info(p, p2, p3, p4, flag, p5))
end

local SpringInfo = require(script.SpringInfo)

function class.SpringInfo(p: number, p2: number, p3: number, p4: number, flag: boolean, p5: number)
	return (SpringInfo(p, p2, p3, p4, flag, p5))
end

function class:Connect(object, callback)
	return self:Add(object:Connect(callback), true)
end

local typeof2 = typeof

function class:Add(state, flag: boolean?)
	if state == nil then
		return
	end

	if not flag then
		insert(self, state)
		return state
	end

	if self.Priority == nil then
		self.Priority = {}
	end

	if typeof2(state) == "table" and state.__simplesignalconnection and state.lists == nil then
		state.lists = self.Priority
	end

	insert(self.Priority, state)
	return state
end

function class:Remove(p2)
	if p2 == nil then
		return
	end

	local index = find(self, p2)

	if index ~= nil then
		remove(self, index)
		return true
	end

	if self.Priority ~= nil then
		local index2 = find(self.Priority, p2)

		if index2 ~= nil then
			remove(self.Priority, index2)
		end
	end
end

local Do = require(script.Do)

function class.Do(_, callback)
	return Do(callback)
end

local YieldSafe = require(script.YieldSafe)

function class.YieldSafe(p, callback, p2: number?)
	return YieldSafe(callback, p2, p)
end

local State = require(script.State)

function class.State(_, callback)
	return State(callback)
end

local Iterate = require(script.Iterate)

function class.Iterate(p, p2, callback)
	return Iterate(p2, callback, p)
end

local AdvancedIterate = require(script.AdvancedIterate)

function class.AdvancedIterate(_, p, callback)
	return AdvancedIterate(p, callback)
end

local DelayValue = require(script.DelayValue)

function class.DelayValue(p, p2, p3: number)
	return DelayValue(p2, p3, p)
end

local DelayProperty = require(script.DelayProperty)

function class.DelayProperty(p, p2, p3: number, p4)
	return DelayProperty(p2, p3, p4, p)
end

local InstancePropertySync = require(script.InstancePropertySync)

function class.InstancePropertySync(p, p2, p3: string)
	return InstancePropertySync(p2, p3, p)
end

local InstanceAttributeSync = require(script.InstanceAttributeSync)

function class.InstanceAttributeSync(p, p2, p3: string)
	return InstanceAttributeSync(p2, p3, p)
end

local SetTo = require(script.SetTo)

function class.SetTo(p, p2)
	return SetTo(p2, p)
end

local Listener = require(script.Listener)

function class.Listener(p, p2, p3, callback)
	return Listener(p2, p3, callback, p)
end

local Space = require(script.Space)

function class.Space(p, callback)
	return Space(callback, p)
end

local Signal = require(script.Signal)

function class.Signal(p, p2, callback)
	return Signal(p2, callback, p)
end

local SignalState = require(script.SignalState)

function class.SignalState(p, p2, callback)
	return SignalState(p2, callback, p)
end

local GetSignal = require(script.GetSignal)

function class.GetSignal(p, p2: string, p3: string, flag: boolean?)
	return GetSignal(p2, p3, flag, p)
end

local LoadAnimation = require(script.LoadAnimation)

function class.LoadAnimation(p, p2, p3, p4)
	return LoadAnimation(p2, p3, p4, p)
end

local Reactive = require(script.Reactive)

function class.Reactive(p, callback)
	return Reactive(callback, p)
end

local CloneTable = require(script.CloneTable)

function class.CloneTable(p, callback)
	return CloneTable(p, callback)
end

local SpecialThread = require(script.SpecialThread)

function class.SpecialThread(_, callback, p)
	return SpecialThread(callback, p)
end

local clear = table.clear

function class:Schedule(duration: number?, connection, ...)
	if connection == nil then
		return
	end

	local thread = nil

	local function fn(...)
		local typeName = typeof2(connection)

		if typeName == "table" then
			if connection.Destroy == nil and connection.Clean == nil then
				clear(connection)
			elseif connection.Destroy then
				connection:Destroy()
			elseif connection.Clean then
				connection:Clean()
			end
		elseif typeName == "Instance" then
			connection:Destroy()
		elseif typeName == "function" then
			connection(...)
		elseif typeName == "RBXScriptConnection" then
			connection:Disconnect()
		elseif typeName == "thread" then
			task.cancel(connection)
		end

		if thread ~= nil then
			self:Remove(thread)
			thread = nil
		end
	end

	if duration == nil or not (duration > 0) then
		task.spawn(fn, ...)
	else
		thread = task.delay(duration, fn, ...)
		self:Add(thread)
	end

	return connection
end

local name = script.Name

function class.__tostring()
	return name
end

return {
	new = function()
		local v = {
			IsActive = true
		}
		setmetatable(v, class)
		return v
	end,
	Animation = Animation,
	Create = Create,
	Configure = Configure,
	Value = Value,
	Info = Info,
	SpringInfo = SpringInfo,
	Do = Do,
	State = State,
	Iterate = Iterate,
	InstancePropertySync = InstancePropertySync,
	InstanceAttributeSync = InstanceAttributeSync,
	DelayValue = DelayValue,
	DelayProperty = DelayProperty,
	SetTo = SetTo,
	Listener = Listener,
	Space = Space,
	YieldSafe = YieldSafe,
	Signal = Signal,
	SignalState = SignalState,
	GetSignal = GetSignal,
	LoadAnimation = LoadAnimation,
	ModifyAnimation = ModifyAnimation,
	CloneAnimation = CloneAnimation,
	Reactive = Reactive,
	CloneTable = CloneTable,
	AdvancedIterate = AdvancedIterate,
	Lerp = Lerp
}