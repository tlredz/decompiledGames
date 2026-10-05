game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers.DuelController)
local v = {
	{
		Result = "GG ❤️",
		Words = { "ggez" },
		Messages = {}
	},
	{
		Result = "you played well",
		Words = {
			"ur bad",
			"ur so bad",
			"you are so bad",
			"you are bad",
			"horrible"
		},
		Messages = {}
	},
	{
		Result = "W update ❤️",
		Words = { "l update" },
		Messages = {}
	},
	{
		Result = "well played 👍",
		Words = { "gg ez" },
		Messages = { "ez" }
	},
	{
		Result = "nice loadout",
		Words = { "p2w", "pay to win", "pay 2 win" },
		Messages = {}
	}
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._muted_user_ids = {}
	self:_Init()
	return self
end

function class:_UpdateChatBubblesEnabled()
	local bubbleChatConfiguration = TextChatService:WaitForChild("BubbleChatConfiguration")
	bubbleChatConfiguration.Enabled = not (SpectateController.CurrentDuelSubject and SpectateController.CurrentDuelSubject.IsRanked)
end

function class:_DuelInterfaceBubble(p2, p3)
	if not p2 or table.find(self._muted_user_ids, p2.UserId) then
		return
	end

	local v2 = {}

	for _, object in pairs(DuelController.Objects) do
		if object:GetDueler(p2) then
			table.insert(v2, object)
		end
	end

	if #v2 == 0 then
		return
	end

	for _, v3 in pairs(v2) do
		v3.DuelInterface.Scores:NewChatMessage(p2, p3)
	end
end

function class:_SetupOnIncomingMessage()
	local function get_text_chat_message_properties(data)
		if not data.TextSource then
			return
		end

		local text = data.Text
		local v2 = false

		for _, v4 in pairs(v) do
			if not table.find(v4.Messages, string.lower(text)) then
				continue
			end

			text = v4.Result
			v2 = true
			break
		end

		if not v2 then
			repeat
				local v4 = false

				for _, v5 in pairs(v) do
					for _, word in pairs(v5.Words) do
						local v6 = string.find(string.lower(text), word)

						if not v6 then
							continue
						end

						text = string.sub(text, 1, v6 - 1) .. v5.Result .. string.sub(text, v6 + #word)
						v4 = true
					end
				end
			until not v4
		end

		if text == data.Text then
			return
		end

		local textChatMessageProperties = Instance.new("TextChatMessageProperties")
		textChatMessageProperties.Text = text
		return textChatMessageProperties
	end

	TextChatService.OnIncomingMessage = function(data)
		local v2 = get_text_chat_message_properties(data)

		if data.Status ~= Enum.TextChatMessageStatus.Success then
			return v2
		end

		local playerByUserId = data.TextSource and data.TextSource.UserId and Players:GetPlayerByUserId(data.TextSource.UserId)
		local translation = v2 and v2.Translation ~= "" and v2.Translation

		if not translation then
			if data.Translation == "" then
				translation = nil
			else
				translation = data.Translation or nil
			end
		end

		local text = v2 and v2.Text or data.Text
		task.defer(self._DuelInterfaceBubble, self, playerByUserId, translation or text)
		return v2
	end
end

function class:_Init()
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_UpdateChatBubblesEnabled()
	end)
	task.spawn(function()
		StarterGui:GetCore("PlayerMutedEvent").Event:Connect(function(p)
			if not table.find(self._muted_user_ids, p.UserId) then
				table.insert(self._muted_user_ids, p.UserId)
			end
		end)
		StarterGui:GetCore("PlayerUnmutedEvent").Event:Connect(function(p)
			if table.find(self._muted_user_ids, p.UserId) then
				table.remove(self._muted_user_ids, p.UserId)
			end
		end)
	end)
	task.defer(self._SetupOnIncomingMessage, self)
	task.defer(self._UpdateChatBubblesEnabled, self)
end

return class._new()