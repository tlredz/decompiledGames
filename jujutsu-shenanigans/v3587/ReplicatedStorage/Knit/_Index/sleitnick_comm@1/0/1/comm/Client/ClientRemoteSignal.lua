local Signal = require(script.Parent.Parent.Parent.Signal)
require(script.Parent.Parent.Types)
local ClientRemoteSignal = {}
ClientRemoteSignal.__index = ClientRemoteSignal

function ClientRemoteSignal.new(re, list, outbound)
	local object = setmetatable({}, ClientRemoteSignal)
	object._re = re

	if outbound and #outbound > 0 then
		object._hasOutbound = true
		object._outbound = outbound
	else
		object._hasOutbound = false
	end

	if not (list and #list > 0) then
		object._directConnect = true
		return object
	end

	object._directConnect = false
	object._signal = Signal.new()
	object._reConn = object._re.OnClientEvent:Connect(function(...)
		local v = table.pack(...)

		for _, v2 in list do
			if not table.pack(v2(v))[1] then
				return
			end

			v.n = #v
		end

		object._signal:Fire(table.unpack(v, 1, v.n))
	end)
	return object
end

function ClientRemoteSignal:_processOutboundMiddleware(...)
	local v = table.pack(...)

	for _, v2 in self._outbound do
		local v3 = table.pack(v2(v))

		if not v3[1] then
			return table.unpack(v3, 2, v3.n)
		end

		v.n = #v
	end

	return table.unpack(v, 1, v.n)
end

function ClientRemoteSignal:Connect(callback)
	if self._directConnect then
		return self._re.OnClientEvent:Connect(callback)
	end

	return self._signal:Connect(callback)
end

function ClientRemoteSignal:Fire(...)
	if self._hasOutbound then
		self._re:FireServer(self:_processOutboundMiddleware(...))
	else
		self._re:FireServer(...)
	end
end

function ClientRemoteSignal:Destroy()
	if self._signal then
		self._signal:Destroy()
	end
end

return ClientRemoteSignal