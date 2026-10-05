local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local misc = ReplicatedStorage2:WaitForChild("Misc")
local v = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v2 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v3 = require3(ReplicatedStorage2.Shared.Statable)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.Statable)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Booths)
local v6 = require3(ReplicatedStorage2.Shared.TitleData)
local v7 = require3(ReplicatedStorage2.Shared.RNG.Emotes)
local v8 = require3(ReplicatedStorage2.ServerInfo)
local v9 = require3(ReplicatedStorage2.Shared.LTM)
local devProduct = require3(script.DevProducts)
local gamePass = require3(script.GamePasses)

local function observeChildren(instance, onChildAdded, value: string?)
	for _, child in instance:GetChildren() do
		local success, result = pcall(onChildAdded, child)

		if not success then
			warn((`Error while trying to handle {value or "instance"}: {child:GetFullName()}\n{result}`))
		end
	end

	instance.ChildAdded:Connect(onChildAdded)
end

local itemInfos = {}
local ItemInfo = {
	ItemInfos = itemInfos
}
local sword = {}
ItemInfo.Sword = sword

local function handleSword(attributes)
	local v14 = {
		ItemType = "Sword",
		IsInventorey = true,
		SwordType = attributes.SwordType,
		DisplayName = attributes.DisplayName or attributes.Name,
		Name = attributes.Name,
		Icon = attributes.Icon,
		HasFinisher = attributes.HasFinisher or false,
		HasAwaken = attributes.CanAwaken or false,
		Description = attributes.Description or "No description.",
		Rarity = attributes.Rarity,
		Attributes = attributes,
		DevOnly = attributes.DevOnly and true or false,
		AnimationStyles = attributes.AnimationStyles,
		AccessoryUnlockable = attributes.AccessoryUnlockable and true or false,
		AccessoryToggleable = attributes.AccessoryToggleable and true or false,
		RequiresFriendsWith = attributes.RequiresFriendsWith or nil,
		AlwaysVisible = attributes.AlwaysVisible and true or false,
		CreatedAt = attributes.CreatedAt
	}
	v14.Hidden = (attributes.Hidden or v14.Rarity == "Unique") and true or false
	v14.AlwaysShow = (not v14.Hidden or v14.AlwaysVisible) and true or false

	if attributes.UpgradeType then
		v14.Upgrade = {
			UpgradeType = attributes.UpgradeType,
			Upgrades = attributes.Upgrades,
			TargetPage = attributes.TargetPage
		}
	end

	sword[attributes.Name] = v14
	table.insert(itemInfos, v14)
	return v14
end

for _, v14 in v:GetCollection() do
	handleSword(v14)
end

function ItemInfo.findSwordInfo(p: string)
	return sword[p]
end

function ItemInfo.getSwords()
	return sword
end

local emote = {}
ItemInfo.Emote = emote

local function handleEmote(object)
	local attributes = object:GetAttributes()
	local v15 = {
		ItemType = "Emote",
		IsInventorey = true,
		DisplayName = attributes.EmoteName or object.Name,
		Name = object.Name,
		Icon = attributes.Icon or "rbxassetid://0",
		IsDuo = attributes.IsDuo,
		Rarity = attributes.Rarity or "Normal",
		CreatedAt = attributes.CreatedAt
	}
	local mappedId = v7.MappedIds[v15.Name]

	if mappedId then
		v15.Rarity = mappedId.Rarity or "Normal"
		v15.Chance = mappedId.Chance
	elseif v15.IsDuo then
		v15.Rarity = "Duo"
	else
		local emoteVFX = v2:GetEmoteVFX(v15.Name)
		local v16

		if emoteVFX and emoteVFX.Sword then
			v16 = ItemInfo.Sword[emoteVFX.Sword]
		end

		if v16 and (v16.Rarity == "Limited" or v16.Rarity == "LimitedU" or v16.Rarity == "Unique") then
			v15.Rarity = v16.Rarity
		end
	end

	emote[object.Name] = v15
	table.insert(itemInfos, v15)
	return v15
end

observeChildren(misc.Emotes, handleEmote, "emote data")
local explosion = {}
ItemInfo.Explosion = explosion

local function handleExplosion(config)
	local attributes = config:GetAttributes()
	local v16 = {
		ItemType = "Explosion",
		IsInventorey = true,
		Order = attributes.Order or 0,
		DisplayName = attributes.TitleText or config.Name,
		Title = {
			Text = attributes.TitleText,
			Color = attributes.TitleTextColor,
			StrokeColor = attributes.TitleTextStrokeColor
		},
		SubText = {
			Text = attributes.SubText,
			Color = attributes.SubTextColor,
			StrokeColor = attributes.SubTextStrokeColor
		},
		Name = config.Name,
		Icon = attributes.Icon,
		Rarity = attributes.Rarity,
		Config = config,
		Hidden = attributes.Hidden and true or false,
		Unobtainable = attributes.Unobtainable and true or false,
		AlwaysVisible = attributes.AlwaysVisible and true or false,
		CreatedAt = attributes.CreatedAt
	}
	v16.AlwaysShow = (not v16.Hidden or v16.AlwaysVisible) and true or false
	explosion[config.Name] = v16
	table.insert(itemInfos, v16)
	return v16
end

observeChildren(misc.DataExplosions, handleExplosion, "explosion data")
local character = {}
ItemInfo.Character = character

local function handleCharacter(config)
	local attributes = config:GetAttributes()
	local v17 = {
		ItemType = "Character",
		IsInventorey = true,
		Color = attributes.Color,
		Description = attributes.Description,
		Order = attributes.Order or 0,
		DisplayName = config.Name,
		Name = config.Name,
		Icon = attributes.Icon,
		Config = config,
		Price = attributes.Price,
		Attributes = attributes
	}
	character[config.Name] = v17
	table.insert(itemInfos, v17)
	return v17
end

local ability = {}
ItemInfo.Ability = ability

local function handleAbility(config)
	local attributes = config:GetAttributes()
	local name = config.Name
	local v18 = {
		ItemType = "Ability",
		IsInventorey = true,
		IsAllowed = v3.Computed(function(callback)
			if v8.isLTMServer() then
				local recentLTM = v9.getRecentLTM()
				return not recentLTM.AllAbilitiesDisabled and not table.find(recentLTM.getDisabledAbilities(), name)
			elseif v8.isDuelMatchServer() then
				local v19 = callback(v4.getReplionStatable("DuelMatch"))
				local v20

				if v19 then
					v20 = callback((v3.getReplionPathState(v19, "NoAbilities")))
				end

				return v20 == false
			else
				if v8.isNoAbilityRankedMatchServer() then
					return false
				end

				if not v8.isRankedMatchServer() then
					return true
				end

				local v19 = callback(v4.getReplionStatable("AbilityBanVoting"))

				if not v19 then
					return false
				end

				local v20 = callback((v3.getReplionPathState(v19, "BannedAbilities"))) or {}
				return not table.find(v20, name)
			end
		end),
		Color = attributes.Color,
		Description = attributes.Description,
		Order = attributes.Order or 0,
		Title = {
			Text = attributes.TitleText,
			Color = attributes.TitleTextColor,
			StrokeColor = attributes.TitleTextStrokeColor
		},
		DisplayName = attributes.DisplayName or name,
		Name = name,
		Icon = attributes.Icon,
		Rarity = attributes.Rarity,
		Config = config,
		Price = attributes.Price,
		Attributes = attributes,
		Upgrade = {
			CustomUpgrade = attributes.CustomUpgrade,
			NonUpgradable = attributes.NonUpgradable and true or false,
			MaxUpgrade = attributes.MaxUpgrade or 0,
			UpgradeInfo = {},
			KillRequirements = {}
		},
		CreatedAt = attributes.CreatedAt,
		AlwaysShow = true
	}

	if attributes.Pack and attributes.UnavailableReason then
		v18.Pack = {
			Menu = attributes.Pack,
			Text = attributes.UnavailableReason
		}
	end

	for k, attribute in attributes do
		local match, v19 = k:match("^(%a+)(%d+)$")
		local v20 = tonumber(v19 or "") or v19

		if match == "Description" then
			v18.Upgrade.UpgradeInfo[v20] = attribute
		elseif match == "KillRequirement" then
			v18.Upgrade.KillRequirements[v20] = attribute
		end
	end

	v18.Upgrade.MaxUpgrade = math.max(v18.Upgrade.MaxUpgrade, #v18.Upgrade.UpgradeInfo)
	ability[name] = v18
	table.insert(itemInfos, v18)
	return v18
end

observeChildren(misc.DataAbilities, handleAbility, "ability data")
ItemInfo.DevProduct = devProduct

for _, v18 in devProduct do
	table.insert(itemInfos, v18)
end

ItemInfo.GamePass = gamePass

for _, v18 in gamePass do
	table.insert(itemInfos, v18)
end

local booth = {}

for k, v19 in v5:GetCollection(), nil, nil do
	local v20 = {
		ItemType = "Booth",
		IsInventorey = true,
		DisplayName = v19.DisplayName or v19.Name,
		Name = k,
		Rarity = v19.Rarity,
		Order = v19.Order,
		Icon = v19.Icon,
		Description = v19.Description,
		Tradable = v19.Tradable,
		AlwaysShow = true,
		CoinsPrice = v19.Price,
		DevProductId = v19.ProductId,
		GamePassid = v19.GamePassId,
		TotalSold = v19.TotalSold
	}
	booth[k] = v20
	table.insert(itemInfos, v20)
end

ItemInfo.Booth = booth
local title = {}

for _, v20 in v6 do
	title[v20.Name] = v20
	table.insert(itemInfos, v20)
end

ItemInfo.Title = title
return ItemInfo