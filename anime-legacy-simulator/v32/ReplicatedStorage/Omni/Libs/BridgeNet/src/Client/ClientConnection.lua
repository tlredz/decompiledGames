local ClientProcess = require(script.Parent.ClientProcess)
local v = {}
local v2 = {
	__index = v,
	__tostring = function(_)
		return "ClientConnection"
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
	self._disconnectCallback = ClientProcess.connect(p, p2)
	return self
end