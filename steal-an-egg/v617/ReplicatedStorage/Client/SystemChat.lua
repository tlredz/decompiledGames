local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local v = {}
local textChannel = Instance.new("TextChannel")
textChannel.Name = "GameSystem"
textChannel.Parent = TextChatService

-- equivalent calls inferred from this helper; original call sites unknown
local function markup(p)
	local color = p.Color

	if color == nil then
		return p.Text
	end

	return (`<font color="#{color:ToHex()}">{p.Text}</font>`)
end

local function metadata(p)
	local rarity = p.Rarity

	if rarity == nil then
		return ""
	end

	return HttpService:JSONEncode({
		rarity = rarity
	})
end

local function accept(data)
	if typeof(data) ~= "table" or typeof(data.Text) ~= "string" then
		return nil
	end

	local color = data.Color
	local rarity = data.Rarity
	local v2 = {
		Text = data.Text,
		Color = 0,
		Rarity = 0
	}

	if typeof(color) ~= "Color3" then
		color = nil
	end

	v2.Color = color

	if typeof(rarity) ~= "string" then
		rarity = nil
	end

	v2.Rarity = rarity
	return v2
end

function v.Post(p)
	local v3 = markup(p) -- equivalent call inferred; original call site unknown
	textChannel:DisplaySystemMessage(v3, metadata(p))
end

Remotes.ChatFeed.Post.OnClientEvent:Connect(function(p)
	local v2 = accept(p)

	if v2 ~= nil then
		v.Post(v2)
	end
end)
return table.freeze(v)