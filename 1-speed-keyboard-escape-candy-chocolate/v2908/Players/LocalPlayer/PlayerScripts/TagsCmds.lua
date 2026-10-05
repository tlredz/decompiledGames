local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adminTagToggle = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AdminTagToggle", 10)

local function makeCmd(name, primaryAlias, p)
	local textChatCommand = Instance.new("TextChatCommand")
	textChatCommand.Name = name
	textChatCommand.PrimaryAlias = primaryAlias
	textChatCommand.AutocompleteVisible = false
	textChatCommand.Enabled = true
	textChatCommand.Parent = TextChatService
	textChatCommand.Triggered:Connect(function()
		if adminTagToggle then
			adminTagToggle:FireServer(p)
		end
	end)
end

local textChatCommand = Instance.new("TextChatCommand")
textChatCommand.Name = "HeadTagCommand"
textChatCommand.PrimaryAlias = "/headtag"
textChatCommand.AutocompleteVisible = false
textChatCommand.Enabled = true
textChatCommand.Parent = TextChatService
local v = "Head"
textChatCommand.Triggered:Connect(function()
	if adminTagToggle then
		adminTagToggle:FireServer(v)
	end
end)
local textChatCommand2 = Instance.new("TextChatCommand")
textChatCommand2.Name = "ChatTagCommand"
textChatCommand2.PrimaryAlias = "/chattag"
textChatCommand2.AutocompleteVisible = false
textChatCommand2.Enabled = true
textChatCommand2.Parent = TextChatService
local v2 = "Chat"
textChatCommand2.Triggered:Connect(function()
	if adminTagToggle then
		adminTagToggle:FireServer(v2)
	end
end)