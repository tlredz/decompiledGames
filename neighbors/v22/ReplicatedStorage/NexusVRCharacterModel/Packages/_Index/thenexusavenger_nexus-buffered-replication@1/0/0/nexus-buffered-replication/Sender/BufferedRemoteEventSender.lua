local BufferedRemoteEventSender = {}
BufferedRemoteEventSender.__index = BufferedRemoteEventSender

function BufferedRemoteEventSender.new(remoteEvent, serializeMessage)
	return (setmetatable({
		MaxRequestSize = 900,
		QueuedData = {},
		RemoteEvent = remoteEvent,
		SerializeMessage = serializeMessage,
		SendingActive = true
	}, BufferedRemoteEventSender))
end

function BufferedRemoteEventSender.WithPlayerKeys(p, callback)
	return BufferedRemoteEventSender.new(p, function(p2, p3)
		local v = callback(p3)
		local buf = buffer.create(8 + buffer.len(v))
		buffer.writef64(buf, 0, p2.UserId)
		buffer.copy(buf, 8, v)
		return buf
	end)
end

function BufferedRemoteEventSender.QueueData(p, p2, p3)
	p.QueuedData[p2] = p3
end

function BufferedRemoteEventSender:SendQueuedData()
	local queuedData = self.QueuedData
	self.QueuedData = {}
	local maxRequestSize = self.MaxRequestSize
	local v = {
		{
			Buffers = {},
			CurrentLength = 0
		}
	}

	for k, v2 in queuedData do
		local serializeMessage = self.SerializeMessage(k, v2)
		local currentLength = buffer.len(serializeMessage)

		if self.MaxRequestSize < currentLength then
			warn((`Data was serialzied for key {k} and was too long ({currentLength} > {maxRequestSize}). The data will be dropped.`))
		else
			local v4 = v[#v]
			local currentLength2 = v4.CurrentLength + currentLength

			if maxRequestSize < currentLength2 then
				table.insert(v, {
					Buffers = { serializeMessage },
					CurrentLength = currentLength
				})
			else
				table.insert(v4.Buffers, serializeMessage)
				v4.CurrentLength = currentLength2
			end
		end
	end

	for _, v2 in v do
		if v2.CurrentLength == 0 then
			break
		end

		local buf = buffer.create(v2.CurrentLength)
		local total = 0

		for _, buffer2 in v2.Buffers do
			buffer.copy(buf, total, buffer2)
			total += buffer.len(buffer2)
		end

		self.RemoteEvent:FireAllClients(buf)
	end
end

function BufferedRemoteEventSender:StartDataSending(callback)
	task.spawn(function()
		while self.SendingActive do
			self:SendQueuedData()
			callback()
		end
	end)
end

function BufferedRemoteEventSender:StartDataSendingWithDelay(duration: number)
	self:StartDataSending(function()
		task.wait(duration)
	end)
end

function BufferedRemoteEventSender:StartDataSendingWithEvent(object2)
	self:StartDataSending(function()
		object2:Wait()
	end)
end

function BufferedRemoteEventSender:Destroy()
	self.SendingActive = false
end

return BufferedRemoteEventSender