local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local playerGui = Players.LocalPlayer.PlayerGui
local v2 = require3(script.ForceVariant)
local v3 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Promise)
require3(ReplicatedStorage2.Controllers.AnalyticsController)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v7 = require3(ReplicatedStorage2.Shared.Statable)
local v8 = require3(ReplicatedStorage2.Shared.CustomMode.CustomModeUtils)
require3(ReplicatedStorage2.Controllers.AbilityController)
require3(ReplicatedStorage2.Common.MarketplaceService)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v9 = require3(ReplicatedStorage2.Shared.DynArgs)
local v10 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v11 = require3(ReplicatedStorage2.ServerInfo)
local isSinglePlayerMode = v8.IsCustomModeServer() and v8.IsMultiplayerCustomMode() == false and true or v11.isHuntPrivateServer()
local newShop = playerGui.NewShop
local _ = newShop.Holder
local remoteFunction = v5:RemoteFunction("RequestEquipAbility")
local remoteFunction2 = v5:RemoteFunction("RequestEquipSword")
local remoteFunction3 = v5:RemoteFunction("RequestEquipExplosion")
local remoteFunction4 = v5:RemoteFunction("RequestEquipFinisher")
local remoteFunction5 = v5:RemoteFunction("RequestAbilityUpgrade")
local remoteFunction6 = v5:RemoteFunction("RequestBuyAbility")
local v13 = {}

local function getReplionArrayPresenceState(object, list, name)
	local joined

	if type(list) == "table" then
		joined = table.concat(list, ".")
	else
		joined = list
	end

	local v14 = v13[joined]

	if not v14 then
		v14 = {}
		v13[joined] = v14
	end

	local v15 = v14[name]

	if v15 then
		return v15, v15._conn
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finds()
		return table.find(object:Get(list), name) and true or false
	end

	v15 = v7.State(finds())
	v15._conn = object:OnChange(list, function()
		v15:Set(finds())
	end)
	v14[name] = v15
	return v15, v15._conn
end

local function getReplionDictionaryPresenceState(object, value, name)
	if typeof(value) == "table" then
		table.insert(value, name)
	elseif typeof(value) == "string" then
		value ..= "." .. name
	end

	local function getValue()
		return object:Get(value)
	end

	local state = v7.State(getValue())
	return state, (object:OnChange(value, function()
		state:Set(getValue())
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function parseItemKey(p: string, p2)
	local clone = table.clone(p2)
	clone.Id = nil
	clone.ItemType = nil
	return client:ItemToKey(p, clone)
end

local ownedBases = {
	Sword = {},
	Explosion = {},
	Ability = {}
}
local v15 = {}
local v16 = {}
local v17 = {}

for k, v18 in ownedBases do
	for k2 in v3[k] do
		local v19 = v9.Or()
		v19:LinkState(v7.State())
		v18[k2] = v19
	end
end

local v18 = {}

for _, v19 in {
	"Sword",
	"Explosion",
	"Ability",
	"Booth"
} do
	v18[v19] = v7.State(nil)
end

local v19 = {}

for _, v20 in { "Emote" } do
	v19[v20] = v7.State({})
end

local ShopControllerAPI = {
	OwnedBases = ownedBases,
	IsSinglePlayerMode = isSinglePlayerMode,
	RarityOrder = {
		Normal = 0,
		Common = 0,
		Duo = 1,
		Rare = 2,
		Legendary = 3,
		Limited = 4,
		LimitedU = 5,
		Unique = 6,
		Secret = 7
	},
	ParseItemKey = function(self, p: string, value, flag: boolean?)
		if type(value) == "string" then
			value = client:KeyToItem(value)
		end

		local clone2 = table.clone(value)

		if not flag then
			clone2.Id = nil
			clone2.ItemType = nil
		end

		return client:ItemToKey(p, clone2)
	end,
	GetItemBaseOwnedState = function(self, p: string, p2: string)
		return ownedBases[p][p2]
	end,
	GetEquippedItem = function(_, p: string)
		local equipped = client:GetEquipped(p)

		if not equipped then
			return nil
		end

		local item = client:GetItem(p, equipped.Id)
		return item or nil
	end,
	GetSwordData = function(self, parsedItemKey: string)
		local v20 = v15[parsedItemKey]

		if v20 then
			return v20
		end

		local keyToItem = client:KeyToItem(parsedItemKey)
		local state = v7.State()
		local itemBaseOwnedState = self:GetItemBaseOwnedState("Sword", keyToItem.Name)
		local count = #client:FindItemsWithKey("Sword", parsedItemKey)
		state:Set(count)
		itemBaseOwnedState:SetTag(parsedItemKey, count > 0)
		local isEquipped = v7.Computed(function(callback)
			local v21 = callback(v18.Sword)

			if v21 then
				v21 = parseItemKey("Sword", v21) == parsedItemKey
			end

			return v21 and true or false
		end)
		local v21 = v4.Client:WaitReplion("Data")
		local v22 = { client:GetLegacyInventoryPath("Sword"), "Favorites", keyToItem.Name }
		local state2 = v7.State()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateFavorited()
			state2:Set(v21:Get(v22) and true or false)
		end

		v21:OnChange(v22, updateFavorited)
		updateFavorited() -- equivalent call inferred; original call site unknown
		local replionDictionaryPresenceState = getReplionDictionaryPresenceState(
			v21,
			"Finishers.Equipped",
			keyToItem.Name
		)
		local filteredItemKey = v10:GetFilteredItemKey("Sword", keyToItem)
		local state3 = v7.State(0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateRAP()
			state3:Set(v10:IsEnabled() and v10:FastGetRAP("Sword", keyToItem, filteredItemKey) or v10:ShouldShowRAP(
				"Sword",
				keyToItem.Name
			) and 0 or -1)
		end

		v10:OnRAPUpdated("Sword", filteredItemKey, updateRAP)
		updateRAP() -- equivalent call inferred; original call site unknown
		local itemInfo = v3.Sword[keyToItem.Name]
		v20 = {
			ItemInfo = itemInfo,
			ParsedItemKey = parsedItemKey,
			RAP = state3,
			OwnedCopies = state,
			IsEquipped = isEquipped,
			IsFavorited = state2,
			IsFinisherEquipped = v7.Computed(function(callback)
				return keyToItem.Finisher and callback(isEquipped) and callback(replionDictionaryPresenceState) and true or false
			end),
			HasAccessory = v7.State(not itemInfo.AccessoryUnlockable or keyToItem.Accessory == true)
		}
		v15[parsedItemKey] = v20
		return v20
	end,
	GetExplosionData = function(self, parsedItemKey: string)
		local v20 = v16[parsedItemKey]

		if v20 then
			return v20
		end

		local keyToItem = client:KeyToItem(parsedItemKey)
		local state = v7.State()
		local itemBaseOwnedState = self:GetItemBaseOwnedState("Explosion", keyToItem.Name)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateCopies()
			local count = #client:FindItemsWithKey("Explosion", parsedItemKey)
			state:Set(count)
			itemBaseOwnedState:SetTag(parsedItemKey, count > 0)
		end

		client:OnInventoryChange("Explosion", updateCopies)
		updateCopies() -- equivalent call inferred; original call site unknown
		local isEquipped = v7.Computed(function(callback)
			local v21 = callback(v18.Explosion)

			if v21 then
				v21 = parseItemKey("Explosion", v21) == parsedItemKey
			end

			return v21 and true or false
		end)
		local v21 = v4.Client:WaitReplion("Data")
		local v22 = { client:GetLegacyInventoryPath("Explosion"), "Favorites", keyToItem.Name }
		local state2 = v7.State()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateFavorited()
			state2:Set(v21:Get(v22) and true or false)
		end

		v21:OnChange(v22, updateFavorited)
		updateFavorited() -- equivalent call inferred; original call site unknown
		local filteredItemKey = v10:GetFilteredItemKey("Explosion", keyToItem)
		local state3 = v7.State(0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateRAP()
			state3:Set(v10:IsEnabled() and v10:FastGetRAP("Explosion", keyToItem, filteredItemKey) or v10:ShouldShowRAP(
				"Explosion",
				keyToItem.Name
			) and 0 or -1)
		end

		v10:OnRAPUpdated("Explosion", filteredItemKey, updateRAP)
		updateRAP() -- equivalent call inferred; original call site unknown
		v20 = {
			ItemInfo = v3.Explosion[keyToItem.Name],
			ParsedItemKey = parsedItemKey,
			RAP = state3,
			OwnedCopies = state,
			IsEquipped = isEquipped,
			IsFavorited = state2
		}
		v16[parsedItemKey] = v20
		return v20
	end,
	GetAbilityData = function(self, parsedItemKey: string)
		local v20 = v17[parsedItemKey]

		if v20 then
			return v20
		end

		local keyToItem = client:KeyToItem(parsedItemKey)
		local itemInfo = v3.Ability[keyToItem.Name]
		local state = v7.State()
		local itemBaseOwnedState = self:GetItemBaseOwnedState("Ability", keyToItem.Name)

		local function updateCopies()
			local v22

			if isSinglePlayerMode then
				v22 = parsedItemKey == self:ParseItemKey("Ability", {
					Name = keyToItem.Name,
					Upgrade = itemInfo.Upgrade.MaxUpgrade
				}) and 1 or 0
			else
				v22 = #client:FindItemsWithKey("Ability", parsedItemKey)
			end

			state:Set(v22)
			itemBaseOwnedState:SetTag(parsedItemKey, v22 > 0)
		end

		client:OnInventoryChange("Ability", updateCopies)
		updateCopies()
		local isEquipped = v7.Computed(function(callback)
			local v22 = callback(v18.Ability)

			if v22 then
				v22 = parseItemKey("Ability", v22) == parsedItemKey
			end

			return v22 and true or false
		end)
		local v22 = v4.Client:WaitReplion("Data")
		local v23 = { client:GetLegacyInventoryPath("Ability"), "Favorites", keyToItem.Name }
		local state2 = v7.State()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateFavorited()
			state2:Set(v22:Get(v23) and true or false)
		end

		v22:OnChange(v23, updateFavorited)
		updateFavorited() -- equivalent call inferred; original call site unknown
		v20 = {
			ItemInfo = itemInfo,
			ParsedItemKey = parsedItemKey,
			OwnedCopies = state,
			IsEquipped = isEquipped,
			IsFavorited = state2
		}
		v17[parsedItemKey] = v20
		return v20
	end
}
local v20 = {}

function ShopControllerAPI:GetEmoteData(parsedItemKey: string)
	local v21 = v20[parsedItemKey]

	if v21 then
		return v21
	end

	local keyToItem = client:KeyToItem(parsedItemKey)
	local state = v7.State()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCopies()
		state:Set(#client:FindItemsWithKey("Emote", parsedItemKey))
	end

	client:OnInventoryChange("Emote", updateCopies)
	updateCopies() -- equivalent call inferred; original call site unknown
	local isEquipped = v7.Computed(function(callback)
		local v22 = callback(v19.Emote)

		for _, v23 in v22 do
			if parseItemKey("Emote", v23) == parsedItemKey then
				return true
			end
		end

		return false
	end)
	local v22 = v4.Client:WaitReplion("Data")
	local v23 = { client:GetLegacyInventoryPath("Emote"), "Favorites", keyToItem.Name }
	local state2 = v7.State()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFavorited()
		state2:Set(v22:Get(v23) and true or false)
	end

	v22:OnChange(v23, updateFavorited)
	updateFavorited() -- equivalent call inferred; original call site unknown
	local filteredItemKey = v10:GetFilteredItemKey("Emote", keyToItem)
	local state3 = v7.State(0)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateRAP()
		state3:Set(v10:IsEnabled() and v10:FastGetRAP("Emote", keyToItem, filteredItemKey) or v10:ShouldShowRAP(
			"Emote",
			keyToItem.Name
		) and 0 or -1)
	end

	v10:OnRAPUpdated("Emote", filteredItemKey, updateRAP)
	updateRAP() -- equivalent call inferred; original call site unknown
	v21 = {
		ItemInfo = v3.Emote[keyToItem.Name],
		ParsedItemKey = parsedItemKey,
		RAP = state3,
		OwnedCopies = state,
		IsEquipped = isEquipped,
		IsFavorited = state2
	}
	v20[parsedItemKey] = v21
	return v21
end

local v21 = {}

function ShopControllerAPI.GetBoothData(_, parsedItemKey: string)
	local v22 = v21[parsedItemKey]

	if v22 then
		return v22
	end

	local keyToItem = client:KeyToItem(parsedItemKey)
	local state = v7.State()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCopies()
		state:Set(#client:FindItems("Booth", keyToItem.Name))
	end

	client:OnInventoryChange("Booth", updateCopies)
	updateCopies() -- equivalent call inferred; original call site unknown
	local isEquipped = v7.Computed(function(callback)
		local v23 = callback(v18.Booth)

		if v23 then
			v23 = parseItemKey("Booth", {
				Name = v23.Name
			}) == parsedItemKey
		end

		return v23 and true or false
	end)
	v22 = {
		ItemInfo = v3.Booth[keyToItem.Name],
		ParsedItemKey = parsedItemKey,
		OwnedCopies = state,
		IsEquipped = isEquipped
	}
	v21[parsedItemKey] = v22
	return v22
end

function ShopControllerAPI.ObserveItemsStates(_, p: string, callback)
	local connection = client:OnChange(p, function(p2, p3: string, p4)
		if not v3[p][p2.Name] then
			return
		end

		if p3 == "Insert" then
			callback(p2)
		elseif p3 == "Remove" then
			callback(p2)
		elseif p3 == "Change" then
			callback(p2)

			if p4 then
				callback(p4)
			end
		end
	end)
	local v22 = client:Get(p)

	if v22 then
		for _, v23 in v22 do
			if v3[p][v23.Name] then
				callback(v23)
			end
		end
	end

	return function()
		connection:Disconnect()
		connection = nil
	end
end

function ShopControllerAPI.GetAbilityUpgradePrice(_, p)
	local keyToItem = client:KeyToItem(p.ParsedItemKey)
	local itemInfo = p.ItemInfo
	local upgrade = keyToItem.Upgrade or 0
	local v22 = 0
	local attributes = itemInfo.Attributes
	local price = itemInfo.Price or attributes.MaxUpgradePrice

	if not upgrade then
		return v22
	end

	if upgrade == 0 and price then
		v22 = price / 2
	elseif upgrade == 1 then
		v22 = price or v22
	end

	return attributes[`UpgradePrice{upgrade + 1}`] or v22
end

local v22 = {}

function ShopControllerAPI:GetDevProductData(p: string)
	local v23 = v22[p]

	if not v23 then
		local keyToItem = client:KeyToItem(p)
		v23 = {
			ItemInfo = v3.DevProduct[keyToItem.Name],
			ParsedItemKey = self:ParseItemKey("DevProduct", keyToItem),
			ProductInfo = v7.State()
		}
		v22[p] = v23
	end

	return v23
end

local v23 = {}

function ShopControllerAPI:GetGamePassData(p: string)
	local v24 = v23[p]

	if v24 then
		return v24
	end

	local keyToItem = client:KeyToItem(p)
	local itemInfo = v3.GamePass[keyToItem.Name]
	local v26 = v4.Client:WaitReplion("Data")
	v24 = {
		ItemInfo = itemInfo,
		ParsedItemKey = self:ParseItemKey("GamePass", keyToItem),
		Owns = getReplionArrayPresenceState(v26, "GamePasses", itemInfo.Name)
	}
	v23[p] = v24
	return v24
end

function ShopControllerAPI:GetItemData(p: string, p2: string)
	if p == "Sword" then
		return self:GetSwordData(p2)
	elseif p == "Explosion" then
		return self:GetExplosionData(p2)
	elseif p == "Ability" then
		return self:GetAbilityData(p2)
	elseif p == "Emote" then
		return self:GetEmoteData(p2)
	elseif p == "DevProduct" then
		return self:GetDevProductData(p2)
	elseif p == "GamePass" then
		return self:GetGamePassData(p2)
	end

	return nil
end

function ShopControllerAPI:GetItemsList(callback)
	local itemInfos = {}

	for _, itemInfo in v3.ItemInfos do
		local success, result = pcall(callback, itemInfo)

		if success then
			if result then
				table.insert(itemInfos, itemInfo)
			end
		else
			warn((`Failed to whitelistFilter\n{result}`))
		end
	end

	return itemInfos
end

function ShopControllerAPI:GetItemInfo(p: string, p2: string)
	return self:GetItemsList(function(p3)
		return p3.ItemType == p and p3.Name == p2
	end)[1]
end

function ShopControllerAPI.RequestAbilityUpgrade(_, p: string)
	return remoteFunction5:InvokeServer(p) and true or false
end

function ShopControllerAPI.RequestAbilityPurchase(_, p: string)
	return remoteFunction6:InvokeServer(p) and true or false
end

function ShopControllerAPI.RequestFinisherEquip(_, p)
	return remoteFunction4:InvokeServer(p.Name) and true or false
end

function ShopControllerAPI.SetEquipped(_, p: string, p2: string)
	if not (p2 and (client:GetItem(p, p2) or isSinglePlayerMode)) then
		return false
	end

	if p == "Sword" then
		return remoteFunction2:InvokeServer(p2) and true or false
	elseif p == "Explosion" then
		return remoteFunction3:InvokeServer(p2) and true or false
	end

	return p == "Ability" and (remoteFunction:InvokeServer(p2) and true or false)
end

function ShopControllerAPI.ToggleFavorited(_, p)
	local itemType = p.ItemInfo.ItemType

	if itemType ~= "Sword" and itemType ~= "Explosion" and itemType ~= "Ability" then
		return false
	end

	v5:RemoteEvent("RequestFavoriteItem"):FireServer(itemType, client:FindItemsWithKey(itemType, p.ParsedItemKey)[1])
	return true
end

function ShopControllerAPI.ToggleSwordAccessory(_)
	v5:RemoteEvent("EquipSwordAccessory"):FireServer()
end

function ShopControllerAPI.ToggleSwordStyle(_)
	v5:RemoteEvent("RequestChangeAnimationStyle"):FireServer()
end

function ShopControllerAPI:Load(p2)
	if p2 ~= "Default" then
		local activeVariant = require3(script.Variants[p2])
		self.ActiveVariant = activeVariant
		activeVariant:Start()
		local v25 = false
		v6:OnGuiOpen("Shop", function(p3)
			v25 = true
			p3.Enabled = false
			activeVariant:Open()
		end)
		v6:OnGuiClose("Shop", function(_)
			activeVariant:Close()
		end)
		newShop:GetPropertyChangedSignal("Enabled"):Connect(function()
			if not v25 then
				activeVariant.Enabled = false
			end

			v25 = false
		end)
	end
end

function ShopControllerAPI:OpenRobuxPage()
	if self.ActiveVariant and self.ActiveVariant.OpenRobuxPage then
		self.ActiveVariant:OpenRobuxPage()
	end
end

function ShopControllerAPI:Start()
	v4.Client:WaitReplion("Data")
	v4.Client:WaitReplion("Inventory")
	client:OnInventoryChange("Sword", function(items, _)
		local v24 = {}

		for _, item in items do
			local itemKey = self:ParseItemKey("Sword", item)
			v24[itemKey] = (v24[itemKey] or 0) + 1
		end

		for k, v25 in v24 do
			if not v15[k] then
				continue
			end

			v15[k].OwnedCopies:Set(v25)
			self:GetItemBaseOwnedState("Sword", client:KeyToItem(k).Name):SetTag(k, v25 > 0)
		end
	end)

	for _, v24 in {
		"Sword",
		"Explosion",
		"Ability",
		"Booth"
	} do
		local v26 = v24
		local v27 = v18[v24]

		local function updateEquipped()
			local equipped = client:GetEquipped(v26)

			if not equipped then
				v27:Set(nil)
				return
			end

			local item = client:GetItem(v26, equipped.Id)

			if isSinglePlayerMode then
				item = v26 == "Ability" and {
					Id = equipped.Id,
					Name = equipped.Name,
					Upgrade = v3.Ability[equipped.Name].Upgrade.MaxUpgrade
				} or item
			end

			if item then
				v27:Set(item)
			else
				v27:Set(nil)
			end
		end

		client:OnEquip(v24, updateEquipped)
		client:OnInventoryChange(v24, updateEquipped)
		updateEquipped()
	end

	for _, v24 in { "Emote" } do
		local v26 = v24
		local v27 = v19[v24]

		local function updateEquipped()
			local equippedList = client:GetEquippedList(v26)

			if not equippedList then
				v27:Set({})
				return
			end

			local v28 = {}

			for k, v29 in equippedList do
				local item = client:GetItem(v26, v29.Id)

				if item then
					table.insert(v28, item)
				end
			end

			v27:Set(v28)
		end

		client:OnEquip(v24, updateEquipped)
		updateEquipped()
	end

	local _ = GuiService:IsTenFootInterface() or v:GetGamepadConnected(Enum.UserInputType[RunService:IsStudio() and "Gamepad2" or "Gamepad1"])

	if v2 and script.Variants:FindFirstChild(v2) and (game.GameId ~= 4777817887 or RunService:IsStudio()) then
		self:Load(v2)
		return
	end

	local v24 = "Console"
	local _ = v.TouchEnabled
	self:Load(v24 == "Console" and not GuiService:IsTenFootInterface() and not v:GetGamepadConnected(Enum.UserInputType[RunService:IsStudio() and "Gamepad2" or "Gamepad1"]) and "Default" or v24 == "Mobile" and "Default" or v24)
end

return ShopControllerAPI