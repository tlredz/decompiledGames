local Players = game:GetService("Players")
local duelScoresChatBubble = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DuelScoresChatBubble")
local ChatBubbles = {}
ChatBubbles.__index = ChatBubbles

function ChatBubbles.new(scores)
	local self = setmetatable({}, ChatBubbles)
	self.Scores = scores
	self._chat_bubble_layout_order = 0
	self._chat_messages = {}
	self:_Init()
	return self
end

function ChatBubbles:NewChatMessage(player, text)
	self._chat_bubble_layout_order += 1
	local clone = duelScoresChatBubble:Clone()
	clone.ZIndex = -self._chat_bubble_layout_order
	clone.LayoutOrder = self._chat_bubble_layout_order
	clone.Title.Text = text

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		clone.Background.Size = UDim2.new(0.0375, clone.Title.TextBounds.X, 1, 0)
	end

	clone.Title:GetPropertyChangedSignal("TextBounds"):Connect(update)
	clone.AncestryChanged:Connect(update)
	update() -- equivalent call inferred; original call site unknown
	local v = {
		Player = player,
		Frame = clone
	}
	table.insert(self._chat_messages, 1, v)
	self:_UpdateParent(v)
	local count = 0

	for k, _chat_message in pairs(self._chat_messages) do
		if _chat_message.Player ~= player then
			continue
		end

		count += 1

		if not (count > 4) then
			continue
		end

		_chat_message.Frame:Destroy()
		table.remove(self._chat_messages, k)
		break
	end

	task.delay(7, function()
		clone:Destroy()
		local index = table.find(self._chat_messages, v)

		if index then
			table.remove(self._chat_messages, index)
		end
	end)
end

function ChatBubbles:Hide()
	for _, _chat_message in pairs(self._chat_messages) do
		_chat_message.Frame.Parent = nil
	end
end

function ChatBubbles:Show()
	for _, _chat_message in pairs(self._chat_messages) do
		self:_UpdateParent(_chat_message)
	end
end

function ChatBubbles:Destroy()
	for _, _chat_message in pairs(self._chat_messages) do
		_chat_message.Frame:Destroy()
	end

	self._chat_messages = {}
end

function ChatBubbles:_UpdateParent(p2)
	p2.Frame.Parent = self.Scores:GetChatBubbleContainer(p2.Player)
end

function ChatBubbles:_Init() end

return ChatBubbles