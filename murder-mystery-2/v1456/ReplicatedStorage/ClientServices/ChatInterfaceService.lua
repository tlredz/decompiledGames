local ChatInterfaceService = {}
local RunService = game:GetService("RunService")
ChatInterfaceService.IsChatActive = false
ChatInterfaceService.ChatWindowToggled = Instance.new("BindableEvent")

function ChatInterfaceService.SetChatWindowVisible(_, p)
	game.StarterGui:SetCore("ChatActive", p)
end

function ChatInterfaceService.SetWindowTransparent(_)
	local TextChatService = game:GetService("TextChatService")
	TextChatService.ChatWindowConfiguration.BackgroundTransparency = 0.3
end

function ChatInterfaceService.SetWindowOpaque(_)
	local TextChatService = game:GetService("TextChatService")
	TextChatService.ChatWindowConfiguration.BackgroundTransparency = 0
end

RunService.PreSimulation:Connect(function()
	local isChatActive = ChatInterfaceService.IsChatActive
	local isChatActive2 = game.StarterGui:GetCore("ChatActive") == true

	if isChatActive ~= isChatActive2 then
		ChatInterfaceService.ChatWindowToggled:Fire(isChatActive2)
	end

	ChatInterfaceService.IsChatActive = isChatActive2
end)
return ChatInterfaceService