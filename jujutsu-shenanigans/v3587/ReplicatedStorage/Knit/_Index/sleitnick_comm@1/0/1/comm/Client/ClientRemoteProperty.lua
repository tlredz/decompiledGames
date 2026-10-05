local Promise = require(script.Parent.Parent.Parent.Promise)
local Signal = require(script.Parent.Parent.Parent.Signal)
local ClientRemoteSignal = require(script.Parent.ClientRemoteSignal)
require(script.Parent.Parent.Types)
local ClientRemoteProperty = {}
ClientRemoteProperty.__index = ClientRemoteProperty

function ClientRemoteProperty.new(p, p2, p3)
	local object = setmetatable({}, ClientRemoteProperty)
	object._rs = ClientRemoteSignal.new(p, p2, p3)
	object._ready = false
	object._value = nil
	object.Changed = Signal.new()
	object._rs:Fire()
	local v = nil
	object._readyPromise = Promise.new(function(p4)
		v = p4
	end)
	object._changed = object._rs:Connect(function(p4)
		local v2 = p4 ~= object._value
		object._value = p4

		if not object._ready then
			object._ready = true
			v(p4)
		end

		if v2 then
			object.Changed:Fire(p4)
		end
	end)
	return object
end

function ClientRemoteProperty:Get()
	return self._value
end

function ClientRemoteProperty:OnReady()
	return self._readyPromise
end

function ClientRemoteProperty:IsReady()
	return self._ready
end

function ClientRemoteProperty:Observe(onChanged)
	if self._ready then
		task.defer(onChanged, self._value)
	end

	return self.Changed:Connect(onChanged)
end

function ClientRemoteProperty:Destroy()
	self._rs:Destroy()

	if self._readyPromise then
		self._readyPromise:cancel()
	end

	if self._changed then
		self._changed:Disconnect()
	end

	self.Changed:Destroy()
end

return ClientRemoteProperty