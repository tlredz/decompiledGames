local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local PlayerTitleService = {
	server = {},
	client = {},
	NO_TITLE_TEXT = "[No Title]",
	NO_TITLE_COLOR = Color3.new(1, 1, 1)
}
local remoteEvent = Net:RemoteEvent("PlayerTitleService/Equip")

function PlayerTitleService.getConfig(value: string?)
	if typeof(value) == "string" and value ~= "" then
		return Config.playerTitle.byCnId[value]
	end

	return nil
end

function PlayerTitleService.getText(p)
	return "[" .. tostring(p.displayName) .. "]"
end

function PlayerTitleService.getColor(p)
	local success, result = pcall(Color3.fromHex, p.colorHex)

	if success then
		return result
	end

	warn((`[PlayerTitleService] 头衔 {p.cnId} 的 colorHex 无效：{p.colorHex}`))
	return PlayerTitleService.NO_TITLE_COLOR
end

function PlayerTitleService.getOwnedList(p)
	local result = {}

	for _, v in Config.playerTitle.list do
		if p[v.cnId] then
			table.insert(result, v)
		end
	end

	return result
end

function PlayerTitleService.server.grant(p, p2: string)
	if not PlayerTitleService.getConfig(p2) then
		warn((`[PlayerTitleService] 未知头衔：{p2}`))
		return false
	end

	PlayerData.server[p].titles[p2](true)
	PlayerData.server[p].equippedTitle(p2)
	return true
end

function PlayerTitleService.server.grantAll(p)
	local count = 0

	for _, v in Config.playerTitle.list do
		if PlayerTitleService.server.grant(p, v.cnId) then
			count += 1
		end
	end

	return count
end

function PlayerTitleService.server.clearAll(p)
	PlayerData.server[p].equippedTitle("")
	PlayerData.server[p].titles({})
end

function PlayerTitleService.server.init()
	remoteEvent.OnServerEvent:Connect(function(p, value)
		if typeof(value) ~= "string" or value ~= "" and not (PlayerTitleService.getConfig(value) and PlayerData.server[p].titles()[value]) then
			return
		end

		PlayerData.server[p].equippedTitle(value)
	end)
end

function PlayerTitleService.client.equip(p: string)
	remoteEvent:FireServer(p)
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function escapeRichText(value: string)
	return (value:gsub("[&<>\"]", {
		["&"] = "&amp;",
		["<"] = "&lt;",
		[">"] = "&gt;",
		["\""] = "&quot;"
	}))
end

local function initChatWindow()
	if flag then
		return
	end

	flag = true
	local Players = game:GetService("Players")
	local TextChatService = game:GetService("TextChatService")

	TextChatService.OnIncomingMessage = function(p)
		local textSource = p.TextSource

		if not textSource then
			return nil
		end

		local playerByUserId = Players:GetPlayerByUserId(textSource.UserId)

		if not playerByUserId then
			return nil
		end

		local config = PlayerTitleService.getConfig(playerByUserId:GetAttribute("PlayerListTitle"))

		if not config then
			return nil
		end

		local textChatMessageProperties = Instance.new("TextChatMessageProperties")
		local v = escapeRichText(PlayerTitleService.getText(config)) -- equivalent call inferred; original call site unknown
		local hex = PlayerTitleService.getColor(config):ToHex()
		textChatMessageProperties.PrefixText = string.format("<font color=\"#%s\">%s</font> %s", hex, v, p.PrefixText)
		return textChatMessageProperties
	end
end

PlayerTitleService.client.initChatWindow = initChatWindow
return PlayerTitleService