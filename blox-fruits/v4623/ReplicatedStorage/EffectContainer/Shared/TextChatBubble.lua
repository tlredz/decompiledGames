return function(list)
	local TextChatService = game:GetService("TextChatService")
	TextChatService:DisplayBubble(list[1], list[2])
end