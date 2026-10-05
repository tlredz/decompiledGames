local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
return function(object, p)
	local filterStringAsync = TextService:FilterStringAsync(
		p,
		object.Executor.UserId,
		Enum.TextFilterContext.PublicChat
	)

	for _, v in ipairs(Players:GetPlayers()) do
		if Chat:CanUsersChatAsync(object.Executor.UserId, v.UserId) then
			object:SendEvent(v, "Message", filterStringAsync:GetChatForUserAsync(v.UserId), object.Executor)
		end
	end

	return "Created announcement."
end