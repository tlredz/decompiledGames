local TextChatService = game:GetService("TextChatService")

function TextChatService.OnBubbleAdded(p, _)
	if not (p.TextSource and game.Players:GetPlayerByUserId(p.TextSource.UserId):GetAttribute("Verified")) then
		return
	end

	local bubbleChatMessageProperties = Instance.new("BubbleChatMessageProperties")
	bubbleChatMessageProperties.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bubbleChatMessageProperties.TextColor3 = Color3.fromRGB(255, 255, 255)
	return bubbleChatMessageProperties
end