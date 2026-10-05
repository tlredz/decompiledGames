local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local MessagingUtil = {}

function MessagingUtil.publishMessage(p, p2)
	local success, result = pcall(function()
		MessagingService:PublishAsync(p, HttpService:JSONEncode(p2))
	end)

	if not success then
		warn("Failed to publish " .. p .. " message: " .. (result or "unknown error"))
	end

	return success, result
end

function MessagingUtil.subscribeToMessage(p, callback)
	MessagingService:SubscribeAsync(p, function(p2)
		local success, result = pcall(function()
			return HttpService:JSONDecode(p2.Data)
		end)

		if not success then
			return
		end

		callback(result)
	end)
end

return MessagingUtil