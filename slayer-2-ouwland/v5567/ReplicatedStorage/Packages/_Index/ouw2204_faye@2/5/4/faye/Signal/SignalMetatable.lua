local FayeUtility = require(script.Parent.Parent.Misc.FayeUtility)
local SignalMetatable = {}
SignalMetatable.__index = SignalMetatable

function SignalMetatable.Destroy(p)
	if p.Connections ~= nil then
		FayeUtility.ClearAllConnections(p.Connections, p.Connections.Count)
	end
end

function SignalMetatable:Connect(object)
	if object == nil then
		return
	end

	if self.Connections == nil then
		self.Connections = {
			Count = 0
		}
	end

	self.Connections[self.Connections.Count + 1] = object:Connect(self.receiverFunc, self.Connections)
	self.Connections.Count += 1
	return self
end

function SignalMetatable.Call(p, ...)
	if p.Entries == nil then
		task.defer(p.receiverFunc, ...)
		return p
	end

	p.receiverFunc(...)
	return p
end

local name = script.Parent.Name

function SignalMetatable.__tostring()
	return name
end

return SignalMetatable