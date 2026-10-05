local BufferedRemoteEventReceiver = {}
BufferedRemoteEventReceiver.__index = BufferedRemoteEventReceiver

function BufferedRemoteEventReceiver.new(remoteEvent, deserializeMessages)
	return (setmetatable({
		RemoteEvent = remoteEvent,
		DeserializeMessages = deserializeMessages,
		OnDataReceivedCallbacks = {},
		EventConnections = {}
	}, BufferedRemoteEventReceiver))
end

function BufferedRemoteEventReceiver.OnDataReceived(data, callback)
	table.insert(data.OnDataReceivedCallbacks, callback)

	if #data.OnDataReceivedCallbacks > 1 then
		return
	end

	table.insert(data.EventConnections, data.RemoteEvent.OnClientEvent:Connect(function(buf: buffer)
		for k, v in data.DeserializeMessages(buf) do
			for _, callback2 in data.OnDataReceivedCallbacks do
				task.spawn(callback2, k, v)
			end
		end
	end))
end

function BufferedRemoteEventReceiver:Destroy()
	for _, eventConnection in self.EventConnections do
		eventConnection:Disconnect()
	end

	self.EventConnections = {}
	self.OnDataReceivedCallbacks = {}
end

return BufferedRemoteEventReceiver