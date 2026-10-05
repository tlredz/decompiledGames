local ThreadSeparation = {}
local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Event:Connect(function(callback)
	callback()
end)

function ThreadSeparation.spawn(...)
	bindableEvent:Fire(...)
end

return ThreadSeparation