local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")
Chat:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, function()
	return {
		BubbleChatEnabled = true,
		ClassicChatEnabled = game.GameId == 4253037040 or RunService:IsStudio()
	}
end)