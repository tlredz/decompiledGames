local Players = game:GetService("Players")
local Signal = require(script.Parent.Parent.Parent.Signal)
require(script.Parent.Parent.Types)
local RemoteSignal = {}
RemoteSignal.__index = RemoteSignal

function RemoteSignal.new(parent, name: string, flag: boolean?, list, outbound)
	local object = setmetatable({}, RemoteSignal)
	local re

	if flag == true then
		re = Instance.new("UnreliableRemoteEvent")
	else
		re = Instance.new("RemoteEvent")
	end

	object._re = re
	object._re.Name = name
	object._re.Parent = parent

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
	object._re.OnServerEvent:Connect(function(p, ...)
		local v2 = table.pack(...)

		for _, v3 in list do
			if not table.pack(v3(p, v2))[1] then
				return
			end

			v2.n = #v2
		end

		object._signal:Fire(p, table.unpack(v2, 1, v2.n))
	end)
	return object
end

function RemoteSignal:IsUnreliable()
	return self._re:IsA("UnreliableRemoteEvent")
end

function RemoteSignal:Connect(p)
	if self._directConnect then
		return self._re.OnServerEvent:Connect(p)
	end

	return self._signal:Connect(p)
end

function RemoteSignal:_processOutboundMiddleware(p2, ...)
	if not self._hasOutbound then
		return ...
	end

	local v = table.pack(...)

	for _, v2 in self._outbound do
		local v3 = table.pack(v2(p2, v))

		if not v3[1] then
			return table.unpack(v3, 2, v3.n)
		end

		v.n = #v
	end

	return table.unpack(v, 1, v.n)
end

function RemoteSignal:Fire(player, ...)
	self._re:FireClient(player, self:_processOutboundMiddleware(player, ...))
end

function RemoteSignal:FireAll(...)
	self._re:FireAllClients(self:_processOutboundMiddleware(nil, ...))
end

function RemoteSignal:FireExcept(p, ...)
	self:FireFilter(function(p2)
		return p2 ~= p
	end, ...)
end

function RemoteSignal:FireFilter(callback, ...)
	for _, player in Players:GetPlayers() do
		if callback(player, ...) then
			self._re:FireClient(player, self:_processOutboundMiddleware(nil, ...))
		end
	end
end

function RemoteSignal:FireFor(items, ...)
	for _, player in items do
		self._re:FireClient(player, self:_processOutboundMiddleware(nil, ...))
	end
end

function RemoteSignal:Destroy()
	self._re:Destroy()

	if self._signal then
		self._signal:Destroy()
	end
end

return RemoteSignal