local foryxeAdmin_V3 = game.ReplicatedStorage:WaitForChild("ForyxeAdmin_V3")
local filteredPhrases = foryxeAdmin_V3:WaitForChild("FilteredPhrases")
local mutedPlayers = foryxeAdmin_V3:WaitForChild("MutedPlayers")
local TextChatService = game:GetService("TextChatService")

TextChatService.OnIncomingMessage = function(self)
	for _, child in pairs(filteredPhrases:GetChildren()) do
		local value = child.Value

		if not string.find(string.lower(self.Text), value) then
			continue
		end

		self.Text = ""
		return
	end

	local userId = self.TextSource and self.TextSource.UserId

	if userId and mutedPlayers:FindFirstChild("User" .. userId) then
		self.Text = ""
	end
end