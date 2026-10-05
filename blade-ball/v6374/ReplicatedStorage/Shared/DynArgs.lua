local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.Shared.Statable)
local DynArgs = {
	Update = function(self)
		self:_updateState()

		if self.State then
			self.State:Set(self.CurrentState)
		end
	end,
	SetTag = function(self, p, p2)
		self._tags[p] = p2
		self:Update()
	end,
	GetTag = function(self, p2)
		return self._tags[p2]
	end,
	AddStatable = function(self, object2)
		self._tags[object2] = object2:Connect(function()
			self:Update()
		end)
		self:Update()
	end,
	RemoveStatable = function(self, p)
		local _tag = self._tags[p]

		if _tag then
			_tag:Disconnect()
			self._tags[p] = nil
			self:Update()
		end
	end,
	LinkState = function(p, state)
		p.State = state
		state:Set(p.CurrentState)
	end,
	InsertDynArgs = function(self, p)
		local stateChangedConnection = p.StateChanged:Connect(function()
			self:_updateState()
		end)

		local function disconnect()
			stateChangedConnection:Disconnect()
		end

		self:SetTag(p, disconnect)
		return disconnect
	end,
	RemoveDynArgs = function(self, p)
		local tag = self:GetTag(p)

		if not tag then
			warn("DynArgs wasn't even inserted... ignoring")
			return
		end

		tag()
		self:SetTag(p, nil)
	end,
	Foreach = function(self, callback)
		for k, _tag in self._tags do
			if type(k) == "table" then
				if k.Get then
					callback(k, k:Get())
				elseif k.CurrentState == nil then
					error("Invalid tag", k)
				else
					callback(k, k.CurrentState)
				end
			else
				callback(k, _tag)
			end
		end
	end,
	Destroy = function(self)
		for k, _tag in self._tags do
			if type(_tag) == "function" then
				_tag()
			end

			self._tags[k] = nil
		end

		table.clear(self._tags)
		self.StateChanged:Destroy()
		table.clear(self)
	end
}
local clone = table.clone(DynArgs)
clone.__index = clone

function clone:_updateState()
	local currentState = self.CurrentState
	local currentState2 = false
	self:Foreach(function(_, p)
		if p then
			currentState2 = true
		end
	end)
	self.CurrentState = currentState2

	if currentState ~= currentState2 then
		self.StateChanged:Fire(currentState2)
	end

	return currentState2
end

function DynArgs.Or()
	return (setmetatable({
		CurrentState = false,
		_tags = {},
		StateChanged = v.new()
	}, clone))
end

local clone2 = table.clone(DynArgs)
clone2.__index = clone2

function clone2:_updateState()
	local currentState = self.CurrentState
	local currentState2 = next(self._tags) and true or false
	self:Foreach(function(_, p)
		if not p then
			currentState2 = false
		end
	end)
	self.CurrentState = currentState2

	if currentState ~= currentState2 then
		self.StateChanged:Fire(currentState2)
	end

	return currentState2
end

function DynArgs.And()
	return (setmetatable({
		CurrentState = false,
		_tags = {},
		StateChanged = v.new()
	}, clone2))
end

local clone3 = table.clone(DynArgs)
clone3.__index = clone3

function clone3:_updateState()
	local currentState = self.CurrentState
	local total = 0
	self:Foreach(function(_, p)
		total += p
	end)
	self.CurrentState = total

	if currentState ~= total then
		self.StateChanged:Fire(total)
	end

	return total
end

function DynArgs.Sum()
	return (setmetatable({
		CurrentState = 0,
		_tags = {},
		StateChanged = v.new()
	}, clone3))
end

local clone4 = table.clone(DynArgs)
clone4.__index = clone4

function clone4:_updateState()
	local currentState = self.CurrentState
	local currentState2 = 0
	self:Foreach(function(_, p)
		currentState2 = math.min(currentState2, p)
	end)
	self.CurrentState = currentState2

	if currentState ~= currentState2 then
		self.StateChanged:Fire(currentState2)
	end

	return currentState2
end

function DynArgs.Min()
	return (setmetatable({
		CurrentState = 0,
		_tags = {},
		StateChanged = v.new()
	}, clone4))
end

local clone5 = table.clone(DynArgs)
clone5.__index = clone5

function clone5:_updateState()
	local currentState = self.CurrentState
	local currentState2 = 0
	self:Foreach(function(_, p)
		currentState2 = math.max(currentState2, p)
	end)
	self.CurrentState = currentState2

	if currentState ~= currentState2 then
		self.StateChanged:Fire(currentState2)
	end

	return currentState2
end

function DynArgs.Max()
	return (setmetatable({
		CurrentState = 0,
		_tags = {},
		StateChanged = v.new()
	}, clone5))
end

return DynArgs