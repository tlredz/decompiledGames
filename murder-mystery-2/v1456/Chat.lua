local localPlayer = game.Players.LocalPlayer
local parent = script.Parent.Parent
local _ = parent.Parent
local chat = parent.Chat
local container = parent.Chat.Container
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local _ = Sync.Item
local _ = Sync.Item
local fn
game:GetService("ContextActionService")
local _ = script.Parent.Parent

if not _G.ChatTable then
	_G.ChatTable = {}
end

local function Chatted(localPlayer2, message, p2)
	local _, _, v = game.ReplicatedStorage.Remotes.Extras.GetPlayerLevel:InvokeServer(localPlayer2)
	local chatTable = _G.ChatTable
	local v3 = {
		PlayerName = localPlayer2 == "Server" and "Server" or (v and "[ELITE] " or "") .. localPlayer2.Name,
		Message = message,
		Server = localPlayer2 == "Server"
	}
	local v4

	if p2 then
		v4 = p2.ItemName or nil
	end

	v3.Item = v4
	v3.Color = v and Color3.new(0.9098039215686274, 0.16470588235294117, 0.16470588235294117) or Color3.new(
		0.9019607843137255,
		0.9019607843137255,
		0.9019607843137255
	)
	v3.RarityColor = p2 and p2.RarityColor or nil
	table.insert(chatTable, 1, v3)
	table.remove(_G.ChatTable, 9)
	fn()
end

local v = nil
local v2 = nil
game.ReplicatedStorage.Remotes.Gameplay.RoleSelect.OnClientEvent:connect(function(_, p, p2)
	v = p
	v2 = p2
end)
localPlayer.Chatted:connect(function(p)
	Chatted(localPlayer, p, nil, v, v2)
end)
_G.Chatted = Chatted
local color = Color3.new(0.8, 0.8, 0.8)

fn = function()
	container:ClearAllChildren()

	for k, v3 in pairs(_G.ChatTable) do
		local clone = script:WaitForChild("ChatMessage"):Clone()
		clone.Parent = container

		if v3.Server then
			clone.PlayerName.Font = Enum.Font.SourceSansItalic
			clone.PlayerName.TextColor3 = color

			if v3.Item then
				clone.Message.Font = Enum.Font.SourceSansBold
				clone.PlayerName.Text = v3.Message .. " "
				clone.Message.Text = v3.Item
				clone.Message.TextColor3 = v3.RarityColor
			else
				clone.PlayerName.Text = v3.Message
				clone.Message.Text = ""
			end
		else
			clone.Message.Text = v3.Message
			clone.PlayerName.Text = v3.PlayerName .. ": "
			clone.PlayerName.TextColor3 = v3.Color
		end

		clone.Message.Position = UDim2.new(0, clone.PlayerName.TextBounds.X + 10, 0, 3)
		clone.Position = UDim2.new(0, 0, 0.125 * (8 - k), 0)
	end
end

fn()

local function OpenChat()
	chat.ChatBox:CaptureFocus()
end

local v3 = {
	"\n",
	"\r",
	"\t",
	"\11",
	"\f"
}

local function SendMessage(text)
	local v4 = string.sub(text, 1, 200)

	if v4 ~= "" then
		if v3 then
			for i = 1, #v3 do
				if v3[i] == "\t" then
					v4 = string.gsub(v4, v3[i], " ")
				else
					v4 = string.gsub(v4, v3[i], "")
				end
			end
		end

		local v5 = string.gsub(v4, "\n", "")
		local v6 = string.gsub(v5, "[ ]+", " ")
		game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(v6, "normalchat", true)
	end
end

chat.ChatBox.FocusLost:connect(function(p, p2)
	if p then
		SendMessage(chat.ChatBox.Text)
		Chatted(localPlayer, chat.ChatBox.Text)
	elseif p2.KeyCode ~= Enum.KeyCode.ButtonB then
		SendMessage(chat.ChatBox.Text)
		Chatted(localPlayer, chat.ChatBox.Text)
	end
end)