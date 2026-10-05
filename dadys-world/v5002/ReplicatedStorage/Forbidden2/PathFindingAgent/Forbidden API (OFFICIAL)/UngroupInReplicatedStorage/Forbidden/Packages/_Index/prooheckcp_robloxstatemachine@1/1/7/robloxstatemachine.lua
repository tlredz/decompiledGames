local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local State = require(script.Classes.State)
local Transition = require(script.Classes.Transition)
local Signal = require(script.Vendor.Signal)
local Trove = require(script.Vendor.Trove)
local deepCopy = require(script.Functions.deepCopy)
local v = {}
local class = {}
class.__index = class
class.Data = {}
class.StateChanged = nil
class.DataChanged = nil
class.State = State
class.Transition = Transition
class._States = {}
class._trove = newproxy()
class._stateTrove = newproxy()
class._CurrentState = ""
class._PreviousState = ""
class._Destroyed = false

function class.new(p: string, items, options)
	local object = setmetatable({}, class)
	object._States = {}
	object._trove = Trove.new()
	object._stateTrove = Trove.new()
	object._Destroyed = false
	object.Data = options or {}
	object.StateChanged = Signal.new()
	object.DataChanged = Signal.new()

	for _, item in items do
		if object._States[item.Name] then
			error("There cannot be more than 1 state by the same name" .. " \"" .. item.Name .. "\"", 2)
		end

		local v2 = deepCopy(item)
		v2.Data = object.Data

		function v2._changeState(p2: string)
			object:ChangeState(p2)
		end

		function v2._changeData(p2: string, p3)
			object:ChangeData(p2, p3)
		end

		function v2._getState()
			return object:GetCurrentState()
		end

		function v2._getPreviousState()
			return object:GetPreviousState()
		end

		v2._transitions = {}

		for _, transition in v2.Transitions do
			if #transition.Name == 0 then
				transition.Name = HttpService:GenerateGUID(false)
			end

			local v3 = deepCopy(transition)

			function v3._changeData(p2: string, p3)
				object:ChangeData(p2, p3)
			end

			function v3._getState()
				return object:GetCurrentState()
			end

			function v3._getPreviousState()
				return object:GetPreviousState()
			end

			if v3.Type ~= Transition.Type then
				error("Attempt to add a transition that is not a transition", 2)
			end

			v3.Data = v2.Data

			function v3._changeState(p2: string)
				object:ChangeState(p2)
			end

			v2._transitions[v3.Name] = v3
			task.spawn(v3.OnInit, v3, object.Data)
			object._trove:Add(v3, "OnDestroy")
		end

		object._States[item.Name] = v2
		task.spawn(v2.OnInit, v2, object.Data)
		object._trove:Add(v2, "OnDestroy")
	end

	if not object._States[p] then
		error(("Attempt to %s, but there is no state by the name of %s"):format("create a state machine", p), 2)
	end

	local v2 = nil
	object._trove:Add(RunService.Heartbeat:Connect(function(dt: number)
		if object._Destroyed then
			return
		end

		object:_CheckTransitions()
		local _GetCurrentStateObject = object:_GetCurrentStateObject()
		local v3 = _GetCurrentStateObject ~= v2
		v2 = _GetCurrentStateObject

		if v3 or (not _GetCurrentStateObject or getmetatable(_GetCurrentStateObject).OnHeartbeat == _GetCurrentStateObject.OnHeartbeat) then
			return
		end

		task.spawn(_GetCurrentStateObject.OnHeartbeat, _GetCurrentStateObject, object:GetData(), dt)
	end))
	object._trove:Add(object.StateChanged)
	object._trove:Add(object.DataChanged)
	object:_ChangeState(p)
	return object
end

function class:GetCurrentState()
	return self._CurrentState
end

function class:GetPreviousState()
	return self._PreviousState
end

function class:ChangeData(p: string, p2)
	if self._Destroyed or self.Data[p] == p2 then
		return
	end

	local v2 = self.Data[p]
	self.Data[p] = p2
	local _State = self._States[self:GetCurrentState()]
	task.spawn(_State.OnDataChanged, _State, self.Data, p, p2, v2)
	self.DataChanged:Fire(self.Data, p, p2, v2)
end

function class:GetData()
	if typeof(self.Data) ~= "table" then
		warn("[Warning]: The data of this state machine is not a table. It will be converted to a table. Please do not set data to a non table object")
		self.Data = {}
	end

	return self.Data
end

function class.LoadDirectory(_, folder, list)
	if not v[folder] then
		v[folder] = {}

		for _, moduleScript in folder:GetDescendants() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local v2 = moduleScript
			local success, result = pcall(function()
				return require(v2)
			end)

			if not (success and typeof(result) == "table" and (result.Type == State.Type or result.Type == Transition.Type)) then
				continue
			end

			if not result.Name or result.Name == "" then
				result.Name = moduleScript.Name
			end

			table.insert(v[folder], result)
		end
	end

	if not list then
		return v[folder]
	end

	local result = {}

	for _, v2 in v[folder] do
		if table.find(list, v2.Name) then
			table.insert(result, v2)
		end
	end

	return result
end

function class:Destroy()
	if self._Destroyed then
		return
	end

	self._Destroyed = true
	local _GetCurrentStateObject = self:_GetCurrentStateObject()

	if _GetCurrentStateObject then
		task.spawn(_GetCurrentStateObject.OnLeave, _GetCurrentStateObject, self:GetData())
	end

	self._trove:Destroy()
	self._stateTrove:Destroy()
end

function class:ChangeState(p: string)
	local _GetCurrentStateObject = self:_GetCurrentStateObject()

	if _GetCurrentStateObject and not _GetCurrentStateObject:CanChangeState(p) then
		return
	end

	self:_ChangeState(p)
end

function class:_StateExists(p2: string)
	return self._States[p2] ~= nil
end

function class:_ChangeState(currentState: string)
	if self._Destroyed then
		return
	end

	assert(
		self:_StateExists(currentState),
		("Attempt to %s, but there is no state by the name of %s"):format(`change to {currentState}`, currentState)
	)

	if self._CurrentState == currentState then
		return
	end

	local _GetCurrentStateObject = self:_GetCurrentStateObject()
	local _State = self._States[currentState]

	if not _State then
		return
	end

	self._stateTrove:Clean()

	if _GetCurrentStateObject then
		task.spawn(_GetCurrentStateObject.OnLeave, _GetCurrentStateObject, self:GetData())
		self:_CallTransitions(_GetCurrentStateObject, "OnLeave", self:GetData())
	end

	task.defer(function()
		self:_CallTransitions(_State, "OnEnter", self:GetData())
	end)
	self._stateTrove:Add(task.defer(_State.OnEnter, _State, self:GetData()))
	self._CurrentState = currentState

	if _GetCurrentStateObject then
		self._PreviousState = _GetCurrentStateObject.Name
		self.StateChanged:Fire(currentState, _GetCurrentStateObject.Name or "")
	end
end

function class:_GetCurrentStateObject()
	return self._States[self:GetCurrentState()]
end

function class:_CheckTransitions()
	for _, _transition in self:_GetCurrentStateObject()._transitions do
		if not (_transition:CanChangeState(self:GetData()) and _transition:OnDataChanged(self:GetData())) then
			continue
		end

		self:ChangeState(_transition.TargetState)
		break
	end
end

function class:_CallTransitions(p, p2: string, ...)
	for _, _transition in p._transitions do
		task.spawn(_transition[p2], _transition, ...)
	end
end

return (setmetatable(class, {
	__call = function(_, p: string, p2, p3)
		return class.new(p, p2, p3)
	end
}))