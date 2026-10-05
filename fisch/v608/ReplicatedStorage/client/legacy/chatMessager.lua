local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local v = {
	Event = "chatEvent",
	Catch = "chatCatch",
	Enchant = "chatEnchant",
	Others = "chatOther"
}
local chat = ReplicatedStorage:WaitForChild("events"):WaitForChild("chat")
local _ = Players.LocalPlayer
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)

-- equivalent calls inferred from this helper; original call sites unknown
local function generateMessage(data)
	if data.Prefix then
		return "<font color='#" .. data.Color .. "'> [" .. data.Prefix .. "] " .. data.Text .. "</font>"
	end

	return "<font color='#" .. data.Color .. "'>" .. data.Text .. "</font>"
end

local function printDebug(...)
	if ReplicatedStorage:GetAttribute("DebugChat") then
		print(`[{script.Name}]`, ...)
	end
end

chat.OnClientEvent:Connect(function(data)
	local message = generateMessage(data) -- equivalent call inferred; original call site unknown

	if SettingsController:GetSettingValue("systemMessages") then
		local v4 = v[not data.MessageType and "Others" or data.MessageType] or "chatOther"
		printDebug("received:", message)

		if SettingsController:GetSettingValue(v4) then
			printDebug("displaying:", message)
			TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(message, "CatchMessage")
		end
	end

	if SettingsController:GetSettingValue("splitTabs") then
		if data.MessageType == "Catch" then
			TextChatService.TextChannels.Catches:DisplaySystemMessage(message, "CatchMessage")
		elseif data.MessageType == "Event" then
			TextChatService.TextChannels.Events:DisplaySystemMessage(message, "CatchMessage")
		end
	end
end)
local chatInputBarConfiguration = TextChatService:WaitForChild("ChatInputBarConfiguration")
chatInputBarConfiguration:GetPropertyChangedSignal("TargetTextChannel"):Connect(function()
	local v2 = chatInputBarConfiguration
	local targetTextChannel = chatInputBarConfiguration.TargetTextChannel

	if targetTextChannel then
		if chatInputBarConfiguration.TargetTextChannel.Name == "Events" then
			targetTextChannel = false
		else
			targetTextChannel = chatInputBarConfiguration.TargetTextChannel.Name ~= "Catches"
		end
	end

	v2.Enabled = targetTextChannel
end)