local BindableEventInstanced = {}

function BindableEventInstanced.new(_)
	local v = {
		BindableEvent = Instance.new("BindableEvent")
	}
	setmetatable(v, {
		__index = BindableEventInstanced
	})
	return v
end

function BindableEventInstanced:Wait(...)
	return self.BindableEvent.Event:Wait(...)
end

function BindableEventInstanced:Connect(...)
	return self.BindableEvent.Event:Connect(...)
end

function BindableEventInstanced:Fire(...)
	if self.Destroyed then
		return
	else
		return self.BindableEvent:Fire(...)
	end
end

function BindableEventInstanced:Destroy()
	self.Destroyed = true
	self.BindableEvent:Destroy()
	self.BindableEvent = nil
end

return BindableEventInstanced