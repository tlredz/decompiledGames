local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
require(GameSdkShared.Modules.ABTest)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ChatBubbleController = require(ReplicatedStorage.Modules.Client.Player.ChatBubbleController)
local QuickChatController = {}
local rBXSystem = nil
local v = {
	Color3.new(0.9921568627450981, 0.1607843137254902, 0.2627450980392157),
	Color3.new(0.00392156862745098, 0.6352941176470588, 1),
	Color3.new(0.00784313725490196, 0.7215686274509804, 0.3411764705882353),
	BrickColor.new("Bright violet").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.new("Bright yellow").Color,
	BrickColor.new("Light reddish violet").Color,
	BrickColor.new("Brick yellow").Color
}

local function GetNameValue(value)
	local total = 0

	for i = 1, #value do
		local v2 = string.byte((string.sub(value, i, i)))
		local v3 = #value - i + 1

		if #value % 2 == 1 then
			v3 -= 1
		end

		if v3 % 4 >= 2 then
			v2 = -v2
		end

		total += v2
	end

	return total
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNameColor(name)
	return v[(GetNameValue(name) + 0) % #v + 1]
end

local function onSystemBroadcast(player, p: string)
	if rBXSystem == nil then
		return
	end

	for _, v2 in StarterGui:GetCore("GetBlockedUserIds") do
		if v2 == player.UserId then
			return
		end
	end

	local translated = QuickChatController.Translate(game, "Quick Chat")
	local translated2 = QuickChatController.Translate(game, p)
	local nameColor = getNameColor(player.Name) -- equivalent call inferred; original call site unknown
	rBXSystem:DisplaySystemMessage((`<font color="#eba0e0">[{translated}] </font><font color="#{nameColor:ToHex()}">{player.DisplayName}</font>: {translated2}`))
end

local function onBroadcast(p, p2: string)
	for _, v2 in StarterGui:GetCore("GetBlockedUserIds") do
		if v2 == p.UserId then
			return
		end
	end

	local translated = QuickChatController.Translate(game, p2)
	ChatBubbleController.Show(p, {
		Text = translated,
		Color = Color3.fromRGB(0, 0, 0)
	}, 10)
end

function QuickChatController.FrameworkInit()
	Remotes.connect("QuickChat:Broadcast", onBroadcast)
	Remotes.connect("QuickChat:SystemBroadcast", onSystemBroadcast)
end

function QuickChatController.FrameworkStart()
	rBXSystem = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")

	function QuickChatController.Translate(_, p)
		return p
	end

	pcall(function()
		local translatorForPlayerAsync = LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer)

		function QuickChatController.Translate(p, p2)
			return translatorForPlayerAsync:Translate(p, p2)
		end
	end)
	task.spawn(function()
		if not TextChatService:CanUserChatAsync(Players.LocalPlayer.UserId) then
			local translated = QuickChatController.Translate(game, "Try using quick chat (⚡) to talk with others!")
			rBXSystem:DisplaySystemMessage(translated)
		end
	end)
end

function QuickChatController.Message(p: string, p2: string?)
	return Remotes.invokeServer("QuickChat:Request", p, p2) and true or false
end

return QuickChatController