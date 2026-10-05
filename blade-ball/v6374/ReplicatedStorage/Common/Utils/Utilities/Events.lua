local Signal = require(script.Parent.Signal)
local v = {}
local Events = {}

function Events:Connect(p: string, callback)
	if not v[p] then
		v[p] = Signal.new()
	end

	return v[p]:Connect(callback)
end

function Events:Fire(p: string, ...)
	if v[p] then
		v[p]:Fire(...)
	end
end

return Events