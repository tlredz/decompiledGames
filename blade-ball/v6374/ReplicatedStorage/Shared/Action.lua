local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3(script.Parent.Signal)
local v2 = require3(script.Parent.Binder)
local Action = {
	CANCEL = v2.CANCEL
}
Action.__index = Action

local function CANCEL()
	return v2.CANCEL
end

function Action:_logSignal(...)
	self.Signal:Fire(...)
	return ...
end

function Action:_postPosPhase(...)
	if select(1, ...) == v2.CANCEL then
		return v2.CANCEL
	end

	return self:_logSignal(...)
end

function Action:_postMidPhase(...)
	if select(1, ...) == v2.CANCEL then
		return v2.CANCEL
	end

	return self:_postPosPhase(self.PostBinds:Call(...))
end

function Action:_postPrePhase(...)
	if select(1, ...) == v2.CANCEL then
		return v2.CANCEL
	end

	return self:_postMidPhase(self._fn(...))
end

function Action:Call(...)
	assert(self._fn, "Tried to call action without function")
	return self:_postPrePhase(self.PreBinds:Call(...))
end

function Action:SetFunction(fn)
	self._fn = fn
end

function Action:Destroy()
	self.PreBinds:Destroy()
	self.PostBinds:Destroy()
	self.Signal:Destroy()
	self._fn = nil
end

function Action.new(fn)
	return (setmetatable({
		PreBinds = v2.new(),
		PostBinds = v2.new(),
		Signal = v.new(),
		_fn = fn
	}, Action))
end

return Action