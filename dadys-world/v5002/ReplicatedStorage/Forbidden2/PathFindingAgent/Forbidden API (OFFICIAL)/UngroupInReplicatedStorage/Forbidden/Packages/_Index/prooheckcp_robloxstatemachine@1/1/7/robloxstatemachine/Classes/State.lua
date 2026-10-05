require(script.Parent.Transition)
local mergeTables = require(script.Parent.Parent.Functions.mergeTables)
local class = {}
class.__index = class
class.Type = "State"
class.Name = ""
class.Transitions = {}
class.Data = {}
class._transitions = {}
class._changeState = nil
class._changeData = nil
class._getState = nil
class._getPreviousState = nil

function class.new(value: string?)
	local self = setmetatable({}, class)
	self.Name = value or ""
	self.Transitions = {}
	return self
end

function class.Extend(p, p2: string)
	return mergeTables(class.new(p2), p)
end

function class:ChangeState(p2: string)
	if not self._changeState then
		return
	end

	self._changeState(p2)
end

function class:GetState()
	if self._getState then
		return self._getState()
	end

	return ""
end

function class:GetPreviousState()
	if self._getPreviousState then
		return self._getPreviousState()
	end

	return ""
end

function class:ChangeData(p2: string, p3)
	if not self._changeData then
		return
	end

	self._changeData(p2, p3)
end

function class.OnInit(_, _) end

function class.CanChangeState(_, _: string)
	return true
end

function class.OnDataChanged(_, _, _, _, _) end

function class.OnEnter(_, _) end

function class.OnHeartbeat(_, _, _: number) end

function class.OnLeave(_, _) end

function class.OnDestroy(_) end

return (setmetatable(class, {
	__call = function(_, p)
		return class.new(p)
	end
}))