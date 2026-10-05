local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local chatWindowConfiguration = TextChatService:WaitForChild("ChatWindowConfiguration")

local function tag(value, p)
	if type(value) ~= "string" or value == "" then
		return ""
	end

	local v = value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
	return "<font color=\"#" .. (typeof(p) ~= "Color3" and "E4CB89" or p:ToHex() or "E4CB89") .. "\">[" .. v .. "]</font> "
end

function TextChatService.OnChatWindowAdded(p)
	local textSource = p.TextSource
	local playerByUserId = textSource and Players:GetPlayerByUserId(textSource.UserId)

	if not playerByUserId then
		return nil
	end

	local overheadTitle = playerByUserId:GetAttribute("OverheadTitle")
	local overheadTitleColor = playerByUserId:GetAttribute("OverheadTitleColor")

	if playerByUserId:GetAttribute("IsTopWins") == true then
		overheadTitleColor = Color3.fromRGB(255, 222, 112)
		overheadTitle = "#1 WINS"
	end

	local v = tag(overheadTitle, overheadTitleColor)
	local journeyTitle = playerByUserId:GetAttribute("JourneyTitle")

	if journeyTitle ~= overheadTitle then
		v ..= tag(journeyTitle, playerByUserId:GetAttribute("JourneyTitleColor"))
	end

	if v == "" then
		return nil
	end

	local newMessageProperties = chatWindowConfiguration:DeriveNewMessageProperties()
	newMessageProperties.PrefixText = v .. p.PrefixText
	return newMessageProperties
end