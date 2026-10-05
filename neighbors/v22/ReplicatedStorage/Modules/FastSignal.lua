local bindableEvent = Instance.new("BindableEvent")
local v = false
bindableEvent.Event:Connect(function()
	v = true
end)
bindableEvent:Fire()
bindableEvent:Destroy()
return (v == false or false) and require(script.Deferred) or require(script.Immediate)