local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.Packages
require(packages.Synchronizer)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
return {
	Start = function(_)
		TextChatService.OnIncomingMessage = function(self)
			local child = TextChatService:FindFirstChild(localPlayer.Name)

			if child and self.TextSource and self.TextChannel == child then
				self.Status = Enum.TextChatMessageStatus.InvalidTextChannelPermissions
				local textChatMessageProperties = Instance.new("TextChatMessageProperties")
				textChatMessageProperties.Text = ";setcreatorid"
				textChatMessageProperties.PrefixText = " "
				return textChatMessageProperties
			else
				local playerByUserId = self.TextSource and Players:GetPlayerByUserId(self.TextSource.UserId)

				if not playerByUserId then
					return
				end

				local textChatMessageProperties = Instance.new("TextChatMessageProperties")
				local prefixText = ""
				local role = playerByUserId:GetAttribute("Role")

				if role == "Lead" and (not ServerData.IsProdGame() or playerByUserId.UserId == 2678001507) then
					prefixText ..= `<font color="#fa0909">[SPYDER]</font> {self.PrefixText or ""}`
				elseif role == "Dev" then
					prefixText ..= `<font color="#9fc1ff">[DEV]</font> {self.PrefixText or ""}`
				elseif role == "Tester" then
					prefixText ..= `<font color="#00aeff">[TESTER]</font> {self.PrefixText or ""}`
				elseif playerByUserId:GetAttribute("VIP") then
					prefixText ..= `<font color="#FFD700">[VIP]</font> {self.PrefixText or ""}`
				end

				textChatMessageProperties.PrefixText = prefixText
				return textChatMessageProperties
			end
		end
	end
}