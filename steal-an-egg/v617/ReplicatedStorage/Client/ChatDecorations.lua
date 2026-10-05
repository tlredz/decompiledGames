local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local Staff = require(ReplicatedStorage.Shared.Modules.Staff)
local color = Color3.fromHex("FFC700")
local color2 = Color3.new(1, 1, 1)
local v = {
	Divine = true,
	Eternal = true,
	Secret = true
}

local function tinted(p: string, color3: Color3)
	return (`<font color="#{color3:ToHex()}">{p}</font>`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function freshProperties()
	return TextChatService.ChatWindowConfiguration:DeriveNewMessageProperties()
end

local function badgesFor(textSource)
	local v2 = {}
	local playerByUserId

	if textSource ~= nil then
		playerByUserId = Players:GetPlayerByUserId(textSource.UserId)
	end

	if playerByUserId == nil then
		return v2
	end

	local creatorDisguiseUserId = playerByUserId:GetAttribute("CreatorDisguiseUserId")
	local chatTag = Staff.ChatTag
	local v3

	if typeof(creatorDisguiseUserId) == "number" then
		v3 = creatorDisguiseUserId
	else
		v3 = playerByUserId.UserId
	end

	local v4 = chatTag(v3)

	if v4 ~= nil then
		table.insert(v2, v4)
	end

	if creatorDisguiseUserId == nil and playerByUserId:GetAttribute("MonetizationVipProductOwned") == true then
		table.insert(v2, (`<font color="#{color:ToHex()}">[VIP-OG]</font>`))
	end

	return v2
end

local function speakerName(state)
	local textSource = state.TextSource
	local playerByUserId

	if textSource ~= nil then
		playerByUserId = Players:GetPlayerByUserId(textSource.UserId)
	end

	local creatorDisguiseName

	if playerByUserId ~= nil then
		creatorDisguiseName = playerByUserId:GetAttribute("CreatorDisguiseName")
	end

	if playerByUserId == nil or typeof(creatorDisguiseName) ~= "string" then
		return nil
	end

	local v2 = string.gsub(playerByUserId.DisplayName, "%p", "%%%0")
	local v3 = string.gsub(creatorDisguiseName, "%%", "%%%%")
	return (string.gsub(state.PrefixText, v2, v3, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rarityIn(p: string)
	if p == "" then
		return nil
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, p)

	if success and typeof(result) == "table" then
		return result.rarity
	end

	return nil
end

local function shineFor(p: string)
	local v2 = rarityIn(p) -- equivalent call inferred; original call site unknown
	local v3

	if not (v2 == nil or not v[v2]) then
		v3 = Rarity.Rarities[v2]
	end

	if v3 == nil then
		return nil
	end

	return v3.RarityGradient
end

local function decorate(state)
	local v2 = badgesFor(state.TextSource)
	local v3 = rarityIn(state.Metadata) -- equivalent call inferred; original call site unknown
	local v4

	if not (v3 == nil or not v[v3]) then
		v4 = Rarity.Rarities[v3]
	end

	local rarityGradient

	if v4 ~= nil then
		rarityGradient = v4.RarityGradient
	end

	if rarityGradient == nil then
		local v5 = speakerName(state)

		if #v2 == 0 and v5 == nil then
			return nil
		end

		local v6 = freshProperties() -- equivalent call inferred; original call site unknown
		local prefixText

		if #v2 > 0 then
			prefixText = `{table.concat(v2, " ")} {v5 or state.PrefixText}`
		else
			prefixText = v5 or state.PrefixText
		end

		v6.PrefixText = prefixText
		return v6
	else
		local prefixText = string.gsub(state.Text, "!", "")

		if #v2 > 0 then
			prefixText = `{table.concat(v2, " ")} {prefixText}`
		end

		local v6 = freshProperties() -- equivalent call inferred; original call site unknown
		v6.TextColor3 = color2
		local chatWindowMessageProperties = freshProperties() -- equivalent call inferred; original call site unknown
		chatWindowMessageProperties.PrefixText = prefixText
		chatWindowMessageProperties.PrefixTextProperties = v6
		chatWindowMessageProperties.Text = "!"
		chatWindowMessageProperties.TextColor3 = color2
		local clone = rarityGradient:Clone()
		clone.Parent = v6
		state.ChatWindowMessageProperties = chatWindowMessageProperties
		task.delay(10, function()
			clone.Enabled = false
		end)
		return chatWindowMessageProperties
	end
end

TextChatService.OnIncomingMessage = decorate
return table.freeze({})