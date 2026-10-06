local Signal = {}
Signal.__index = Signal
local v = {
	_Connections = {}
}

function Signal.new(p: string)
	local v2 = v._Connections[p]

	if not v2 then
		v2 = Instance.new("BindableEvent")
		v._Connections[p] = v2
	end

	return v2.Event
end

function Signal:Fire(p: string, ...)
	if not v._Connections[p] then
		return
	end

	v._Connections[p]:Fire(...)
end

return Signal