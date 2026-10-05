local StateStack = {}
local Maid = require(script.Parent.Maid)
local Signal = require(script.Parent.Signal)
local class = {}
class.__index = class

function class:Destroy()
	self.Removed:Fire()
	self.Maid:Destroy()
end

function StateStack.newState(focus)
	local self = setmetatable({}, class)
	local v = typeof(focus) == "function" and {
		Focus = focus
	} or focus

	for k, v2 in pairs(v) do
		self[k] = v2
	end

	self.Removed = Signal.new()
	self.Maid = Maid.new()
	return self
end

local class2 = {}
class2.__index = class2

function StateStack.new()
	local self = setmetatable({}, class2)
	self.Active = true
	self.States = {}
	self.Maid = Maid.new()
	return self
end

function class2.GetStacks(p)
	return p.States
end

function class2.AddStack(p, data, value)
	local v = math.clamp(value or 1, 1, #p.States + 1)
	table.insert(p.States, v, data)
	local maid = data.Maid
	local runState

	if data.Run then
		runState = data.Run(p) or nil
	end

	maid.RunState = runState

	if v == 1 then
		p.Maid.FocusState = data.Focus and data.Focus(p) or nil
	end
end

function class2.Clear(p)
	while next(p.States) do
		table.remove(p.States):Destroy()
	end

	p.Maid.FocusState = nil
	p.Maid.RunState = nil
end

function class2.RemoveStack(p, p2, ...)
	for k, state in pairs(p.States) do
		if state ~= p2 then
			continue
		end

		table.remove(p.States, k)
		state:Destroy()

		if k == 1 then
			local state2 = p.States[1]
			p.Maid.FocusState = state2 and state2.Focus and state2.Focus() or nil
		end

		break
	end
end

function class2:Destroy()
	self.Active = nil
	self.Maid:Destroy()

	while true do
		local v = table.remove(self.States, 1)

		if v then
			v:Destroy()
		end

		if v then
			continue
		end

		self.States = nil
		break
	end
end

return StateStack