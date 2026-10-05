local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("Chat/ToggleShakeChat", -1)
return {
	Start = function()
		local chatInputBarConfiguration = TextChatService:WaitForChild("ChatInputBarConfiguration")
		remoteEvent.OnClientEvent:Connect(function(enabled: boolean?)
			TextChatService.ChatWindowConfiguration.Enabled = enabled
			local v = chatInputBarConfiguration

			if enabled then
				if chatInputBarConfiguration.TargetTextChannel.Name == "Events" then
					enabled = false
				else
					enabled = chatInputBarConfiguration.TargetTextChannel.Name ~= "Catches"
				end
			end

			v.Enabled = enabled
		end)
	end
}