local Destructor = {}
Destructor.__index = Destructor
local v = {
	thread = task.cancel,
	["function"] = task.spawn,
	Instance = game.Destroy,
	RBXScriptConnection = Instance.new("BindableEvent").Event:Connect(function() end).Disconnect
}

function Destructor.new()
	return (setmetatable({}, Destructor))
end

function Destructor:Add(data)
	local typeName = typeof(data)
	local destroy = v[typeName]

	if not destroy and typeof(data) == "table" then
		destroy = data.Destroy or data.destroy or data.Disconnect or data.DisconnectAll
	end

	if not destroy then
		error(`cannot destruct item of type '{typeName}'`, 2)
	end

	self[data] = v[typeof(data)]
	return data
end

function Destructor:Remove(p2)
	self[p2] = nil
	return p2
end

function Destructor:Destroy()
	assert(self)
	assert(self.destroyed == nil, (`already called destroy m8 {debug.traceback()}`))

	for k, v2 in self do
		v2(k)
	end

	table.clear(self)
	self.destroyed = true
end

return Destructor