local Util = require(script.Parent:WaitForChild("Util"))
local ChatSettings = require(script.Parent.Parent:WaitForChild("ChatSettings"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

while localPlayer == nil do
	Players.ChildAdded:wait()
	localPlayer = Players.LocalPlayer
end

local class = {}
class.__index = class
local v = {}

function class:TrimWhisperCommand(value)
	if string.sub(value, 1, 3):lower() == "/w " then
		return (string.sub(value, 4))
	end

	if string.sub(value, 1, 9):lower() == "/whisper " then
		return (string.sub(value, 10))
	end

	return nil
end

function class:TrimWhiteSpace(value)
	return string.gsub(value, "%s+", ""), value[#value] == " "
end

function class:ShouldAutoCompleteNames()
	if ChatSettings.WhisperCommandAutoCompletePlayerNames == nil then
		return true
	end

	return ChatSettings.WhisperCommandAutoCompletePlayerNames
end

function class:GetWhisperingPlayer(value)
	local trimWhisperCommand = self:TrimWhisperCommand((value:lower()))

	if not trimWhisperCommand then
		return nil
	end

	local trimWhiteSpace, v2 = self:TrimWhiteSpace(trimWhisperCommand)
	local players = Players:GetPlayers()
	local names = {}

	for i = 1, #players do
		if not (players[i] ~= localPlayer and string.sub(players[i].Name:lower(), 1, (string.len(trimWhiteSpace))) == trimWhiteSpace) then
			continue
		end

		names[players[i]] = players[i].Name:lower()
	end

	local count = 0
	local v3 = nil
	local v4 = nil

	for k, v5 in pairs(names) do
		count += 1

		if v5 == trimWhiteSpace and v2 then
			return k
		end

		v4 = v5
		v3 = k
	end

	if count == 1 then
		if self:ShouldAutoCompleteNames() or v4 == trimWhiteSpace then
			return v3
		end
	end

	return nil
end

function class:GetWhisperChanneNameColor()
	if self.ChatSettings.WhisperChannelNameColor then
		return self.ChatSettings.WhisperChannelNameColor
	end

	return Color3.fromRGB(102, 14, 102)
end

function class:TextUpdated()
	local text = self.TextBox.Text

	if self.PlayerNameEntered then
		if text == "" then
			self.MessageModeButton.Text = ""
			self.MessageModeButton.Size = UDim2.new(0, 0, 0, 0)
			self.TextBox.Size = UDim2.new(1, 0, 1, 0)
			self.TextBox.Position = UDim2.new(0, 0, 0, 0)
			self.TextBox.Text = ""
			self.PlayerNameEntered = false
			self.ChatBar:ResetCustomState()
			self.ChatBar:CaptureFocus()
		end
	else
		local whisperingPlayer = self:GetWhisperingPlayer(text)

		if whisperingPlayer then
			self.PlayerNameEntered = true
			self.PlayerName = whisperingPlayer.Name
			self.MessageModeButton.Size = UDim2.new(0, 1000, 1, 0)
			self.MessageModeButton.Text = string.format("[To %s]", whisperingPlayer.Name)
			self.MessageModeButton.TextColor3 = self:GetWhisperChanneNameColor()
			local X = self.MessageModeButton.TextBounds.X
			self.MessageModeButton.Size = UDim2.new(0, X, 1, 0)
			self.TextBox.Size = UDim2.new(1, -X, 1, 0)
			self.TextBox.Position = UDim2.new(0, X, 0, 0)
			self.TextBox.Text = " "
		end
	end
end

function class.GetMessage(data)
	if data.PlayerNameEntered then
		return "/w " .. data.PlayerName .. " " .. data.TextBox.Text
	end

	return data.TextBox.Text
end

function class.ProcessCompletedMessage(_)
	return false
end

function class:Destroy()
	self.MessageModeConnection:disconnect()
	self.Destroyed = true
end

function v.new(chatWindow, chatBar, chatSettings)
	local object = setmetatable({}, class)
	object.Destroyed = false
	object.ChatWindow = chatWindow
	object.ChatBar = chatBar
	object.ChatSettings = chatSettings
	object.TextBox = chatBar:GetTextBox()
	object.MessageModeButton = chatBar:GetMessageModeTextButton()
	object.OriginalWhisperText = ""
	object.PlayerNameEntered = false
	object.MessageModeConnection = object.MessageModeButton.MouseButton1Click:connect(function()
		local text = object.TextBox.Text

		if string.sub(text, 1, 1) == " " then
			text = string.sub(text, 2)
		end

		object.ChatBar:ResetCustomState()
		object.ChatBar:SetTextBoxText(text)
		object.ChatBar:CaptureFocus()
	end)
	object:TextUpdated()
	return object
end

function ProcessMessage(value, p, p2, p3)
	if string.sub(value, 1, 3):lower() == "/w " or string.sub(value, 1, 9):lower() == "/whisper " then
		return v.new(p, p2, p3)
	end

	return nil
end

return {
	[Util.KEY_COMMAND_PROCESSOR_TYPE] = Util.IN_PROGRESS_MESSAGE_PROCESSOR,
	[Util.KEY_PROCESSOR_FUNCTION] = ProcessMessage
}