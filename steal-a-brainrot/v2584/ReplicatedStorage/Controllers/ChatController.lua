local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Synchronizer = require(packages.Synchronizer)
local Timer = require(packages.Timer)
local Net = require(packages.Net)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Tips = require(datas.Tips)
local v = Timer.new(1)
local remoteEvent = Net:RemoteEvent("ChatService/ChatMessage")
local rBXSystem = nil
local ChatController = {
	SendMessage = function(self, p: string)
		if rBXSystem then
			rBXSystem:DisplaySystemMessage(p)
		end
	end
}

function ChatController:Start()
	rBXSystem = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")
	local v2 = Synchronizer:Wait(Players.LocalPlayer)
	remoteEvent.OnClientEvent:Connect(function(...)
		ChatController:SendMessage(...)
	end)
	local v3 = {}
	v.Tick:Connect(function()
		for i = 1, #Tips do
			local tip = Tips[i]
			local now = os.clock()
			v3[i] = v3[i] or now

			if not (now - v3[i] >= tip.ShowEvery and v2:Get("Settings.Chat Tips")) then
				continue
			end

			v3[i] = now
			ChatController:SendMessage(tip.ChatMessage)
		end
	end)
	v:Start()
end

return ChatController