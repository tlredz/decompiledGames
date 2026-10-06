local v = {}
local v2 = {
	__index = v,
	__tostring = function(_)
		return "ClientConnection"
	end
}

function v:Disconnect()
	self.Connected = nil
	table.clear(self)
	setmetatable(self, nil)
end

return function()
	return (setmetatable({
		Connected = true,
		_disconnectCallback = function() end
	}, v2))
end