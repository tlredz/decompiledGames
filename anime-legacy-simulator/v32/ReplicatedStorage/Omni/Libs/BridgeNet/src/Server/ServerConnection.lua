local ServerProcess = require(script.Parent.ServerProcess)
local v = {}
local v2 = {
	__index = v,
	__tostring = function(_)
		return "ServerConnection"
	end
}

function v:Disconnect()
	self.Connected = nil
	self._disconnectCallback()
	table.clear(self)
	setmetatable(self, nil)
end

return function(p, p2)
	local self = setmetatable({
		Connected = true,
		_disconnectCallback = function() end
	}, v2)
	self._disconnectCallback = ServerProcess.connect(p, p2)
	return self
end