local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local folder = nil
local State = {}
State.__index = State

function State.visualize(name)
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "_VisualizedState"
		folder.Parent = workspace
	end

	local v = folder:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = folder
	end

	return v, folder
end

function State.new(items)
	assert(items)
	local v = {
		_update = nil,
		_state = {},
		_changed = {},
		_destroyed = false,
		_typeMap = {}
	}

	for k, item in pairs(items) do
		v._typeMap[k] = assert((typeof(item)))
	end

	return (setmetatable(v, State))
end

function State:DumpState()
	return self._state
end

function State:Set(p: string, p2)
	local v = self:Get(p)
	local v2 = assert(self._typeMap[p], (`State wasn't initialized! {p}`))

	if v == p2 then
		return false
	end

	if v and p2 then
		assert(v2 == assert((typeof(p2))), (`Types don't match: {v2} - {typeof(p2)}`))
	end

	self._state[p] = p2
	local v3 = self._changed[p]

	if v3 then
		v3:Fire(p2, v)
	end

	return true
end

function State:Get(p2: string)
	assert(p2, "State:Get == nil")
	return self._state[p2]
end

function State:Increment(p: string, p2: number)
	local v = self:Get(p)
	assert(v, "State:Increment > currentValue is nil")
	assert(typeof(v) == "number", "State:Increment > can't increment non number type")
	return self:Set(p, v + p2)
end

function State:GetPropertyChangedSignal(p2, p3)
	self._changed[p2] = self._changed[p2] or Signal.new()
	return self._changed[p2]:Connect(p3)
end

function State:Destroy()
	for k, v in pairs(self._changed) do
		v:Destroy()
		self._changed[k] = nil
	end

	if not self._destroyed then
		table.clear(self)
		self._destroyed = true
	end
end

return State