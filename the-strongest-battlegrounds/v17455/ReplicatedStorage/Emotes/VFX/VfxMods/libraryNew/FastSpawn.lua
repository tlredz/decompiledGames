return function(callback, ...)
	assert(type(callback) == "function")
	local v = { ... }
	local v2 = select("#", ...)
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Event:Connect(function()
		callback(unpack(v, 1, v2))
	end)
	bindableEvent:Fire()
	bindableEvent:Destroy()
end