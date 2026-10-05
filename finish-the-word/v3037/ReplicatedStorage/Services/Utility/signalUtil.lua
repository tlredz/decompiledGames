local CollectionService = game:GetService("CollectionService")
local import = _G.import("event")
local SignalUtil = {
	connect = function(object, callback, ...)
		local connection = object:Connect(callback)
		callback(...)
		return connection
	end,
	event = function(p, callback, ...)
		local v = import.connect(p, callback)
		callback(...)
		return v
	end,
	remoteEvent = function(p, callback, ...)
		local remoteConnect = import.remoteConnect(p, callback)
		callback(...)
		return {
			Disconnect = function()
				import.disconnect(remoteConnect)
			end
		}
	end,
	onAdded = function(object, items, callback)
		local connection = object:Connect(callback)

		for _, item in pairs(items) do
			callback(item)
		end

		return connection
	end
}

function SignalUtil.onTag(tag, p)
	return SignalUtil.onAdded(CollectionService:GetInstanceAddedSignal(tag), CollectionService:GetTagged(tag), p)
end

return SignalUtil