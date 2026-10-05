local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GlobalReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.GlobalReplicatedDataController)

if GlobalReplicatedDataController.WaitForReplica() then
	TextChatService.OnIncomingMessage = function(p)
		local textChatMessageProperties = Instance.new("TextChatMessageProperties")

		if not p.TextSource then
			return textChatMessageProperties
		end

		if GamepassController.IsPlayerOwned(p.TextSource.UserId, Gamepasses.VIP) then
			textChatMessageProperties.PrefixText = "<font color='#ddbc36'>[VIP]</font> " .. p.PrefixText
			return textChatMessageProperties
		end

		if GamepassController.IsPlayerOwned(p.TextSource.UserId, Gamepasses.PREMIUM) then
			textChatMessageProperties.PrefixText = "<font color='#00ffff'>[Premium]</font> " .. p.PrefixText
		end

		return textChatMessageProperties
	end
else
	warn("Failed to wait for replica in NewTextChatTesting, no tags will be shown for other players.")
end