local MessagingServiceUtils = {}
local MessagingService = game:GetService("MessagingService")

function MessagingServiceUtils.YieldSubscribeWithTimeout(p: string, callback, value: number?)
	local function AttemptSubscription(callback2)
		task.spawn(function()
			local success, result = pcall(function()
				return MessagingService:SubscribeAsync(p, callback)
			end)
			callback2(success, result)
		end)
	end

	local v = nil
	local v2 = value or 10

	while v == nil do
		local function fn(p2, connection)
			if p2 then
				if v then
					connection:Disconnect()
				else
					v = connection
				end
			end
		end

		task.spawn(function()
			local success, result = pcall(function()
				return MessagingService:SubscribeAsync(p, callback)
			end)
			fn(success, result)
		end)
		local v4 = v2

		while v4 > 0 and v == nil do
			v4 -= task.wait()
		end
	end

	return v
end

function MessagingServiceUtils.SubscribeWithTimeoutAsync(p: string, callback, callback2, p2: number?)
	task.spawn(function()
		local v = MessagingServiceUtils.YieldSubscribeWithTimeout(p, callback, p2)

		if callback2 then
			callback2(v)
		end
	end)
end

return MessagingServiceUtils