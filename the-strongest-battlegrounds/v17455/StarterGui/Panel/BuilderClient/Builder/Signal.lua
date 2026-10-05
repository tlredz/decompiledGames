return function()
	local bindableEvent = Instance.new("BindableEvent")
	local v = {
		Connect = function(self, onEvent)
			bindableEvent.Event:Connect(onEvent)
		end,
		Fire = function(self, ...)
			bindableEvent:Fire(...)
		end,
		Wait = function(self, ...)
			return bindableEvent.Event:Wait()
		end,
		Object = bindableEvent
	}
	local connect = v.Connect
	local fire = v.Fire
	local wait = v.Wait
	v.connect = connect
	v.fire = fire
	v.wait = wait
	return v
end