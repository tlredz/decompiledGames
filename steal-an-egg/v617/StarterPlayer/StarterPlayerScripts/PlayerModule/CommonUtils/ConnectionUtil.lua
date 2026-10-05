local ConnectionUtil = {}
ConnectionUtil.__index = ConnectionUtil

function ConnectionUtil.new()
	local self = setmetatable({}, ConnectionUtil)
	self._connections = {}
	return self
end

function ConnectionUtil:trackConnection(p2, connection)
	if self._connections[p2] then
		self._connections[p2]()
	end

	self._connections[p2] = function()
		connection:Disconnect()
	end
end

function ConnectionUtil:trackBoundFunction(p2, p3)
	if self._connections[p2] then
		self._connections[p2]()
	end

	self._connections[p2] = p3
end

function ConnectionUtil:disconnect(p2)
	if self._connections[p2] then
		self._connections[p2]()
		self._connections[p2] = nil
	end
end

function ConnectionUtil:disconnectAll()
	for _, _connection in pairs(self._connections) do
		_connection()
	end

	self._connections = {}
end

return ConnectionUtil