local TextChatService = game:GetService("TextChatService")
local textChannels = TextChatService:WaitForChild("TextChannels", 1e999)
game.ReplicatedStorage:WaitForChild("ForyxeAdmin_V3"):WaitForChild("AdminEvent").OnClientEvent:Connect(function(p, p2)
	if p == "SendSystemMessage" then
		textChannels.RBXSystem:DisplaySystemMessage(p2)
	end
end)