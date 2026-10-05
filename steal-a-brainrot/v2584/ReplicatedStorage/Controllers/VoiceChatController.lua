local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoiceChatService = game:GetService("VoiceChatService")
local Players = game:GetService("Players")
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("TeleportService/RequestVoiceServer")
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = nil
local v2 = TopbarPlus.new():setLabel("VC Servers"):setOrder(3)
local voiceChat = playerGui:WaitForChild("VoiceChat").VoiceChat
local close = voiceChat.Close
local yes = voiceChat.Yes
local cancel = voiceChat.Cancel
return {
	Start = function(_)
		if game.PlaceId == ServerData.VoiceServersPlaceId or ServerData.IsDuelsServer() or ServerData.IsJumpLTMServer() then
			v2:setEnabled(false)
		end

		v = InterfaceController:Register("VoiceChat", voiceChat, "TopQuint")
		v:AttachCloseButton(close)
		v:AttachCloseButton(cancel)
		v:Close()
		v2.selected:Connect(function()
			InterfaceController:SetState("VoiceChat", true)
		end)
		v2.deselected:Connect(function()
			InterfaceController:SetState("VoiceChat", false)
		end)
		v.OnOpen:Connect(function()
			v2:select()
		end)
		v.OnClose:Connect(function()
			v2:deselect()
		end)
		local v3 = AnimatedButton.new(yes)
		v3:Animate()
		v3.OnActivated:Connect(function()
			local success, result = pcall(function()
				return VoiceChatService:IsVoiceEnabledForUserIdAsync(localPlayer.UserId)
			end)

			if success and result then
				remoteEvent:FireServer()
			else
				NotificationController:Error("You must have Voice Chat enabled to join this experience.")
			end
		end)
		local success, result = pcall(function()
			return VoiceChatService:IsVoiceEnabledForUserIdAsync(localPlayer.UserId)
		end)

		if success and not result then
			v2:setEnabled(false)
		end
	end
}