local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupTags = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GroupTags"))
local v = {
	Creator = {
		Color = "#ff0000",
		Prefix = "👑 [CREATOR]"
	},
	HeadManager = {
		Color = "#a855f7",
		Prefix = "[COO]"
	},
	Admin = {
		Color = "#1de5ff",
		Prefix = "[ADMIN]"
	},
	MarketingLead = {
		Color = "#ff8c00",
		Prefix = "[MARKETING LEAD]"
	},
	Scripter = {
		Color = "#3b82f6",
		Prefix = "[DEV]"
	},
	Builder = {
		Color = "#dd994b",
		Prefix = "[BUILDER]"
	},
	QAManager = {
		Color = "#ffa500",
		Prefix = "[QA MANAGER]"
	},
	AssistantBoard = {
		Color = "#ffffff",
		Prefix = "[ASSISTANT BOARD]"
	},
	Moderator = {
		Color = "#51b94d",
		Prefix = "[MODERATOR]"
	},
	JuniorModerator = {
		Color = "#51b94d",
		Prefix = "[MODERATOR]"
	},
	TradingLead = {
		Color = "#3471eb",
		Prefix = "[TRADING LEAD]"
	},
	Youtuber = {
		Color = "#ff42aa",
		Prefix = "[CC]"
	}
}

TextChatService.OnIncomingMessage = function(p)
	local textChatMessageProperties = Instance.new("TextChatMessageProperties")
	local textSource = p.TextSource

	if not textSource then
		return textChatMessageProperties
	end

	local playerByUserId = Players:GetPlayerByUserId(textSource.UserId)

	if not playerByUserId then
		return textChatMessageProperties
	end

	local v2 = {}
	local color = nil

	if playerByUserId:GetAttribute("AdminChatTagEnabled") == true then
		local adminRole = playerByUserId:GetAttribute("AdminRole")
		local v3 = adminRole and v[adminRole]

		if v3 then
			table.insert(v2, string.format("<font color='%s'>%s</font>", v3.Color, v3.Prefix))
			color = v3.Color
		end
	end

	local groupTagKey = playerByUserId:GetAttribute("GroupTagKey")

	if groupTagKey then
		local groupTag = GroupTags[groupTagKey]

		if groupTag and groupTag.chatColor and groupTag.chatPrefix then
			table.insert(v2, string.format("<font color='%s'>%s</font>", groupTag.chatColor, groupTag.chatPrefix))
		end
	end

	if #v2 == 0 then
		return textChatMessageProperties
	end

	local v3 = color and string.format("<font color='%s'>%s</font>", color, playerByUserId.Name) or playerByUserId.Name
	textChatMessageProperties.PrefixText = string.format("<b>%s %s</b>:", table.concat(v2, " "), v3)
	return textChatMessageProperties
end