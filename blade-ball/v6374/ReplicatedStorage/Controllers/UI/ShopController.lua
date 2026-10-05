local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
game:GetService("LocalizationService")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
local v4 = require3(ReplicatedStorage2.Shared.Subscriptions)
local v5 = require3(ReplicatedStorage2.Packages.Signal)
local v6 = require3(ReplicatedStorage2.ClientGameModules.TextUtility)
local v7 = require3(ReplicatedStorage2.Common.GeolocationWhitelist)
require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v8 = require3(ReplicatedStorage2.Common.Utils)
local icons = v8.Icons
local maid = v8.Maid
require3(ReplicatedStorage2.Shared.LimitedSwordEvent)
local v9 = require3(game.ReplicatedStorage.ClientGameModules.FFlagClient)
local v10 = require3(ReplicatedStorage2.ServerInfo)
local v11 = require3(ReplicatedStorage2.Shared.CustomMode.CustomModeUtils)
local v12 = require3(script.Parent.Parent.AbilityController)
local v13 = require3(script.Parent.Parent.GiftingController)
local v14 = require3(ReplicatedStorage2.Shared.ReducedAbilityPrices)
require3(ReplicatedStorage2.Controllers.AnalyticsController)
require3(ReplicatedStorage2.Controllers.HotbarController)
local v15 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local v16 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v17 = require3(ReplicatedStorage2.Common.MarketplaceService)
local v18 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v19 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v20 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
require3(ReplicatedStorage2.Common.GachaItemsData)
local v21 = require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassViewController)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v22 = require3(ReplicatedStorage2.Shared.Inventory.Internal.Limits)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v23 = require3(script.Parent.Parent.Trading.TradeTokensController)
local v24 = require3(ReplicatedStorage2.Shared.ProgressiveRewardsData)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local v25 = require3(ReplicatedStorage2.Packages.Trove)
local v26 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v27 = require3(ReplicatedStorage2.Controllers.Trading.RAPChartController)
local v28 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v29 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v30 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
require3(ReplicatedStorage2.Shared.Inventory.Internal.DefaultItems)
local v31 = require3(ReplicatedStorage2.Controllers.DeleteItemPromptController)
local v32 = require3(ReplicatedStorage2.Shared.DeleteItemUtils)
local v33 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v34 = require3(ReplicatedStorage2.Shared.Statable)
local v35 = require3(ReplicatedStorage2.Controllers.Trading.InventoryController)
local v36 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v37 = require3(ReplicatedStorage2.Controllers.Trading.ExistCounterController)
local v38 = require3(ReplicatedStorage2.Controllers.UI.GenericGachaController)
local v39 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
require3(ReplicatedStorage2.Controllers.ABTestController)
local v40 = require3(ReplicatedStorage2.Shared.SectionedVirtualScroll)
local v41 = require3(ReplicatedStorage2.Packages.Reliever)
local remoteEvent = v2:RemoteEvent("ConfigureRandomizerEvent")
v2:RemoteEvent("SecretAwaken")
local remoteFunction = v2:RemoteFunction("RequestEquipFinisher")
local remoteEvent2 = v2:RemoteEvent("EquipSwordAccessory")
local remoteEvent3 = v2:RemoteEvent("RequestChangeAnimationStyle")
local remoteFunction2 = v2:RemoteFunction("RequestEquipAbility")
local remoteFunction3 = v2:RemoteFunction("RequestEquipSword")
local remoteFunction4 = v2:RemoteFunction("RequestEquipExplosion")
local remoteFunction5 = v2:RemoteFunction("RequestAbilityUpgrade")
local remoteFunction6 = v2:RemoteFunction("RequestBuyAbility")
local remoteEvent4 = v2:RemoteEvent("OpenCoinsTab")
local v42 = {
	Normal = 0,
	Rare = 1,
	Legendary = 2,
	Limited = 3,
	LimitedU = 4,
	Unique = 5,
	Secret = 6
}
local v43 = {
	SmallCoins = 1599945740,
	MedCoins = 1599946040,
	BigCoins = 1599944759,
	HugeCoins = 1599946789,
	MassiveCoins = 1599946917
}
local v44 = {
	FastUnbox = 229765926,
	VIP = 223367086,
	["2xCoins"] = 226785981,
	TradingSign = 895596060
}
local remoteEvent5 = v2:RemoteEvent("SessionAnalyticsEvent")
local v45 = {
	[true] = {
		Image = "rbxassetid://15697987058",
		HoverImage = "rbxassetid://15697983062"
	},
	[false] = {
		Image = "rbxassetid://15697981750",
		HoverImage = "rbxassetid://15697987058"
	}
}
local v46 = v11.IsCustomModeServer() and v11.IsMultiplayerCustomMode() == false and true or v10.isHuntPrivateServer()
local color = Color3.fromRGB(255, 166, 0)
local v47 = { "Sword", "Explosion", "Ability" }
local v48 = { "Sword", "Explosion", "Emote" }
local v49 = { "Sword", "Explosion", "Ability" }
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local swordTemplates = script.SwordTemplates
local favoritedTemplate = script.FavoritedTemplate
playerGui:WaitForChild("Hotbar")
local secretUpgrade = playerGui:WaitForChild("SecretUpgrade")
local shop = playerGui:WaitForChild("Shop")
local holder = shop.Holder
local pages = holder.Pages
local infoBG = holder.InfoBG
local frameSelectionButtons = holder.FrameSelectionButtons
local extraBtns = holder.ExtraBtns
local extra = holder.Extra
local buyButton = infoBG.BuyButton
local favorite = holder.Favorite
local upgradeButton = infoBG.UpgradeButton
local killsProgressBar = infoBG.KillsProgressBar
local rapButton = infoBG.Rap.RapButton
local secretUpgrade2 = infoBG.SecretUpgrade
local randomizerInfo = infoBG.RandomizerInfo
local _ = randomizerInfo.ToggleRandom
local inviteRewardsHolder = holder.InviteRewardsHolder
local finisher = infoBG.Equips.Finisher
local equipAccessory = infoBG.Equips.EquipAccessory
local changeStyle = infoBG.Equips.ChangeStyle
local v50 = nil
local v51 = false
local state = v34.State("")
local state2 = v34.State("Default")
local state3 = v34.State("Most")
local remotes = ReplicatedStorage2.Remotes
local _ = {
	Sword = "SwordSkins",
	Explosion = "ExplosionSkins",
	Ability = "Abilities"
}
local v52 = {}
local v53 = {}
local v54 = nil

local function refreshFavoriteMap(p: string)
	v54 = v54 or v.Client:WaitReplion("Data")
	v53[p] = v54:Get({ client:GetLegacyInventoryPath(p), "Favorites" }) or {}
end

local ShopController = {
	_multiDelete = nil,
	_selectionMaid = maid.new(),
	itemSelected = v5.new(),
	_virtualItems = {
		Sword = {},
		Explosion = {},
		Ability = {},
		Characters = {}
	},
	_inventoryPages = {},
	CheckSearchVisibility = function(self)
		local isOpen = v16:IsOpen("Shop")

		if isOpen and self._page and self._page.Name == "Robux" then
			holder.SearchFrame.Visible = false
			v20.HideHotbar:SetTag("ShopSearch", not isOpen)
		else
			holder.SearchFrame.Visible = v9:GetKey("InventorySearchEnabled") and true or false
			isOpen = not isOpen
		end

		v20.HideHotbar:SetTag("ShopSearch", not isOpen)
	end
}
local v55 = {
	Most = -1,
	Least = 1
}
local _ = {
	Explosion = 0,
	Sword = 1,
	Emote = 2
}
local _ = { "Default", "Alphabetical", "RAP" }

local function isBaseItem(p: string, p2: string)
	if p == "Sword" and p2 == "Base Sword" then
		return true
	elseif p == "Explosion" then
		return p2 == "Explosion Normal"
	else
		return false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRarityOrder(rarity: string?)
	return rarity and v36.RarityOrder[rarity] or 0
end

local v56 = {}

local function prepareSlotTemplate(parent, p: string)
	if v56[parent] then
		return
	end

	v56[parent] = true

	if (p == "Sword" or p == "Explosion" or p == "Ability") and not parent:FindFirstChild("Favorited") then
		local clone = favoritedTemplate:Clone()
		clone.Name = "Favorited"
		clone.Visible = false
		clone.Parent = parent
	end

	if (p == "Sword" or p == "Explosion") and client:GetInventoryVersion() == "New" then
		if not parent:FindFirstChild("Stack") then
			local clone = script.NewInventory.Stack:Clone()
			clone.Visible = false
			clone.Label.Text = ""
			clone.Parent = parent
		end

		if not parent:FindFirstChild("Lock") then
			local clone = script.NewInventory.Lock:Clone()
			clone.Visible = false
			clone.Parent = parent
		end
	end

	if p == "Sword" and client:GetInventoryVersion() == "New" then
		if not parent:FindFirstChild("Finisher") then
			local clone = script.NewInventory.Finisher:Clone()
			clone.Visible = false
			clone.Parent = parent
		end

		if not parent:FindFirstChild("SwordAccessory") then
			local clone = script.NewInventory.SwordAccessory:Clone()
			clone.Visible = false
			clone.Parent = parent
		end
	end
end

local function applyItemNameLabel(p, p2: string, text: string)
	if p2 == "Sword" then
		p.NameOfWeapon.Text = text
	elseif p2 == "Ability" or p2 == "Characters" then
		p.NameOfAbility.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateIconsLayout(_, items, p)
	local v57 = 1

	for _, item in items do
		if not (item and item.Visible) then
			continue
		end

		item.Position = p[v57] or item.Position
		v57 += 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function invertName(name_: string)
	return string.gsub(name_, ".", function(value)
		return (string.char(255 - string.byte(value)))
	end)
end

local function updateVirtualItemSortValues(state4)
	local type2 = state4.Type
	local v57 = state2 and state2:Get() or "Default"
	local v58 = v55[state3 and state3:Get() or "Most"]
	local v59 = v53[type2]
	state4.IsFavorited = v59 ~= nil and v59[state4.Name] == true
	local invertedAlphabeticalName

	if v57 == "Alphabetical" then
		if v58 == 1 then
			invertedAlphabeticalName = state4.InvertedAlphabeticalName
		else
			invertedAlphabeticalName = state4.AlphabeticalName
		end
	elseif v58 == 1 then
		invertedAlphabeticalName = state4.InvertedName
	else
		invertedAlphabeticalName = state4.Name
	end

	local name = state4.Name
	local v61

	if type2 == "Sword" and name == "Base Sword" then
		v61 = true
	elseif type2 == "Explosion" then
		v61 = name == "Explosion Normal"
	else
		v61 = false
	end

	state4.Name_ = `{state4.IsFavorited and v57 == "Default" and "#" or ""}{state4.Item and state4.Item.TradeLock and not v61 and v57 == "Default" and "~" or ""}{v57 == "Alphabetical" and "" or tostring(state4.RarityOrder)}|{invertedAlphabeticalName}`

	if type2 == "Ability" or type2 == "Characters" then
		state4.LayoutOrder = state4.OriginalLayoutOrder - (state4.IsFavorited and 1000 or 0)
	elseif v57 == "RAP" then
		local v62

		if state4.RAPKey and v28:IsEnabled() then
			v62 = v28:FastGetRAP(type2, state4.Item, state4.RAPKey)
		end

		state4.LayoutOrder = (v62 or -1) * v58
	elseif v57 == "Exists" then
		local v62

		if v37:IsEnabled() then
			v62 = v37:Get(type2, state4.EffectiveKey, true)
		end

		state4.LayoutOrder = (v62 or -1) * v58
	elseif v57 == "Creation Date" then
		state4.LayoutOrder = (state4.CreatedAt or 0) * v58
	else
		state4.LayoutOrder = state4.OriginalLayoutOrder
	end
end

local function buildVirtualItem(p: string, name: string, inventoryKey: string?, data)
	local itemInfo = v29[p] and v29[p][name]
	local v58 = not inventoryKey and {
		Name = name
	} or client:KeyToItem(inventoryKey)
	local effectiveKey = inventoryKey or client:ItemToKey(p, v58)
	local rarity = itemInfo and itemInfo.Rarity
	local rarityOrder = getRarityOrder(rarity) -- equivalent call inferred; original call site unknown
	local v60

	if p == "Sword" and name == "Base Sword" then
		v60 = true
	elseif p == "Explosion" then
		v60 = name == "Explosion Normal"
	else
		v60 = false
	end

	if not v60 then
		rarityOrder += 1
	end

	local displayName

	if itemInfo then
		displayName = itemInfo.DisplayName or name
	else
		displayName = name
	end

	local v61 = invertName(name) -- equivalent call inferred; original call site unknown
	local v62 = {
		Type = p,
		Name = name,
		Key = inventoryKey or name,
		InventoryKey = inventoryKey,
		Sword = data.Sword,
		ExplosionConfig = data.ExplosionConfig,
		AbilityConfig = data.AbilityConfig,
		CharacterConfig = data.CharacterConfig,
		ItemInfo = itemInfo,
		Item = v58,
		Rarity = data.Rarity,
		RarityOrder = rarityOrder,
		OriginalLayoutOrder = data.OriginalLayoutOrder or 0,
		LowerSearchName = string.lower(displayName),
		Hidden = data.Hidden == true,
		AlwaysVisible = data.AlwaysVisible == true,
		NonPurchaseable = data.NonPurchaseable == true,
		OwnsItem = v34.State(false),
		ItemsMatching = v34.State({}),
		InDeleteMulti = v34.State(0),
		ForceHide = false,
		Section = "Unowned",
		IsFavorited = false,
		AlphabeticalName = displayName,
		InvertedName = v61,
		InvertedAlphabeticalName = 0,
		EffectiveKey = 0,
		RAPKey = 0,
		CreatedAt = 0,
		Name_ = 0,
		LayoutOrder = 0
	}

	if displayName ~= name then
		v61 = string.gsub(displayName, ".", function(value)
			return (string.char(255 - string.byte(value)))
		end)
	end

	v62.InvertedAlphabeticalName = v61
	v62.EffectiveKey = effectiveKey
	local rAPKey

	if not (p == "Characters" or p == "Ability") then
		rAPKey = v28:GetFilteredItemKey(p, v58)
	end

	v62.RAPKey = rAPKey
	v62.CreatedAt = itemInfo and itemInfo.CreatedAt
	v62.Name_ = name
	v62.LayoutOrder = data.OriginalLayoutOrder or 0
	updateVirtualItemSortValues(v62)
	v41.relieve()
	return v62
end

local function updateVirtualItemOwnership(p, state4)
	local type2 = state4.Type
	local name = state4.Name
	local inventoryKey = state4.InventoryKey
	local v57

	if inventoryKey then
		v57 = client:KeyToItem(inventoryKey)
	else
		v57 = state4.Item
	end

	state4.Item = v57 or state4.Item
	local v58, v59

	if type2 == "Characters" then
		v58 = v.Client:WaitReplion("Data"):Find({ "Characters", "Unlocked" }, name) ~= nil
		v59 = {}
	else
		local v60 = v52[type2]

		if v60 then
			local v61

			if inventoryKey then
				v61 = v60.ByKey[inventoryKey]
			else
				v61 = v60.ByName[name]
			end

			v59 = not v61 and {} or table.clone(v61)
		elseif inventoryKey then
			v59 = client:FindItemsWithKey(type2, inventoryKey)
		else
			v59 = client:FindItems(type2, name)
		end

		if #v59 > 0 then
			v58 = true
		else
			v58 = false
		end
	end

	local abilityConfig = state4.AbilityConfig
	local attributes = abilityConfig and abilityConfig:GetAttributes()
	local v60 = type2 == "Ability" and not v58 and v46 and attributes and not attributes.Hidden and true or v58

	if not v3.List.equals(state4.ItemsMatching:Get(), v59) then
		state4.ItemsMatching:Set(v59)
	end

	state4.OwnsItem:Set(v60)
	local v61 = v.Client:WaitReplion("Data")
	local v62 = v7[name]
	local country = v61:Get("Country") or "N/A"
	local forceHide

	if type2 == "Characters" then
		forceHide = false
	else
		local v64 = state4.Hidden and not v60

		if not v64 then
			v64 = not (state4.AlwaysVisible or v60)

			if v64 then
				v64 = v62 and not v62[country]

				if not v64 then
					if state4.Rarity == "Unique" and type2 ~= "Explosion" then
						v64 = true
					elseif state4.Rarity == "Secret" then
						v64 = type2 ~= "Explosion"
					else
						v64 = false
					end
				end
			end
		end

		if not inventoryKey and #v59 > 0 and (type2 == "Sword" or type2 == "Explosion" or type2 == "Ability") then
			v64 = client:GetInventoryVersion() == "New" or v64
		end

		local v65 = type2 == "Ability" and attributes and attributes.NonPurchaseable and not v60 and v61:Get("SessionCount") == 1 and true or v64
		forceHide = type2 == "Ability" and not v12:IsAbilityAllowed(name) and v10.isHuntPrivateServer() and true or v65

		if type2 == "Sword" or type2 == "Explosion" then
			forceHide = not inventoryKey and #v59 > 0 or forceHide
		end
	end

	if p._multiDelete then
		local v64 = p._multiDelete[type2]
		local v65 = v64 and inventoryKey and v64[inventoryKey]

		if v65 then
			local flag = true

			for _, v67 in v59 do
				if table.find(v65, v67) then
					continue
				end

				flag = false
				break
			end

			if flag then
				forceHide = true
			end
		end
	end

	state4.ForceHide = forceHide
	state4.Section = v60 and "Owned" or "Unowned"

	if p._multiDelete then
		local v64 = p._multiDelete[type2]
		local v65 = v64 and inventoryKey and v64[inventoryKey]
		state4.InDeleteMulti:Set(v65 and #v65 or 0)
	else
		state4.InDeleteMulti:Set(0)
	end

	local _inventoryPage = p._inventoryPages[type2]

	if _inventoryPage and _inventoryPage.MarkDirty then
		_inventoryPage.MarkDirty(state4, false, true)
	end
end

local function constructCommonBindings(_, data, instance, maid2)
	local type2 = data.Type
	local name = data.Name
	local item = data.Item or {
		Name = name
	}
	local inventoryKey = data.InventoryKey
	local favorited = instance:FindFirstChild("Favorited")

	if favorited then
		maid2:Add(v34.setPropertyComputed(favorited, "Visible", function(callback)
			return data.IsFavorited and callback(data.OwnsItem)
		end))
		maid2:Add(function()
			favorited.Visible = false
		end)
	end

	if type2 ~= "Characters" then
		if inventoryKey then
			v33:Add(instance, type2, item, inventoryKey)
		elseif type2 == "Explosion" or type2 == "Sword" then
			v33:Add(instance, type2, {
				Name = name
			})
		end

		maid2:Add(function()
			v33:Remove(instance)
		end)
	end

	if instance:FindFirstChild("Shadow") then
		maid2:Add(v34.setPropertyComputed(instance.Shadow, "Enabled", function(callback)
			return not callback(data.OwnsItem)
		end))
	end
end

local function constructSwordSlot(object, data, instance, maid2)
	local sword = data.Sword
	local name = data.Name
	local inventoryKey = data.InventoryKey
	instance:SetAttribute("Name", name)
	instance:SetAttribute("Rarity", sword.Rarity)
	instance:SetAttribute("AlwaysVisible", sword.AlwaysVisible)
	instance:SetAttribute("Hidden", sword.Hidden == true)
	instance:SetAttribute("OriginalLayoutOrder", data.OriginalLayoutOrder)
	instance.NameOfWeapon.Text = name
	local icon = sword.Icon

	if icon then
		instance.IconLabel.Image = icon
		instance.IconLabel.Visible = true
		instance.ViewportFrame.Visible = false
	else
		instance.IconLabel.Visible = false
		instance.ViewportFrame.Visible = true
		icons:SetSwordIconAsViewportByName(instance.ViewportFrame, name)
	end

	maid2:Add(function()
		if instance.ViewportFrame then
			instance.ViewportFrame:ClearAllChildren()
		end
	end)
	constructCommonBindings(object, data, instance, maid2)
	local stack = instance:FindFirstChild("Stack")
	local lock = instance:FindFirstChild("Lock")
	local finisher2 = instance:FindFirstChild("Finisher")
	local swordAccessory = instance:FindFirstChild("SwordAccessory")

	if client:GetInventoryVersion() == "New" then
		local child = finisher2 and ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(name)

		if child then
			finisher2.Icon.Image = child:GetAttribute("Icon") or v8.Icons:GetIcon("DEFAULT_MISSING")
		end

		local v57 = swordAccessory and v39:GetCollection()[name]

		if v57 then
			swordAccessory.Icon.Image = v57.Icon or v8.Icons:GetIcon("DEFAULT_MISSING")
		end

		local v58 = {
			stack,
			lock,
			finisher2,
			swordAccessory
		}

		for i = #v58, 1, -1 do
			if v58[i] == nil then
				table.remove(v58, i)
			end
		end

		local positions = {}

		for k, v59 in v58 do
			local position = v59:GetAttribute("Position")

			if not position then
				position = v59.Position
				v59:SetAttribute("Position", position)
			end

			positions[k] = position
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function relayoutIcons()
			updateIconsLayout(nil, v58, positions) -- equivalent call inferred; original call site unknown
		end

		if stack then
			maid2:Add(v34.Computed(function(callback)
				local v59 = callback(data.ItemsMatching)
				local v60 = callback(data.InDeleteMulti)
				local v61 = #v59 - v60
				stack.Visible = v61 >= 2
				stack.Label.Text = `x{v61}`
				relayoutIcons() -- equivalent call inferred; original call site unknown
				return nil
			end))
			maid2:Add(function()
				stack.Visible = false
			end)
		end

		if finisher2 then
			maid2:Add(v34.Computed(function(_)
				local item = data.Item
				finisher2.Visible = item ~= nil and item.Finisher ~= nil
				relayoutIcons() -- equivalent call inferred; original call site unknown
				return nil
			end))
			maid2:Add(function()
				finisher2.Visible = false
			end)
		end

		if swordAccessory then
			maid2:Add(v34.Computed(function(_)
				local item = data.Item
				swordAccessory.Visible = item ~= nil and item.Accessory == true
				relayoutIcons() -- equivalent call inferred; original call site unknown
				return nil
			end))
			maid2:Add(function()
				swordAccessory.Visible = false
			end)
		end

		if lock then
			local v59 = v.Client:WaitReplion("Data")

			local function updateLock()
				local hasInteractedWithTrading = v59:Get("HasInteractedWithTrading")
				local item = data.Item
				lock.Visible = item ~= nil and item.TradeLock ~= nil and hasInteractedWithTrading ~= nil
				relayoutIcons() -- equivalent call inferred; original call site unknown
			end

			local hasInteractedWithTrading = v59:Get("HasInteractedWithTrading")
			local item = data.Item
			local visible

			if item == nil or item.TradeLock == nil then
				visible = false
			else
				visible = hasInteractedWithTrading ~= nil
			end

			lock.Visible = visible
			updateIconsLayout(nil, v58, positions) -- equivalent call inferred; original call site unknown

			if not v59:Get("HasInteractedWithTrading") then
				maid2:Add(v59:OnChange("HasInteractedWithTrading", updateLock))
			end

			maid2:Add(function()
				lock.Visible = false
			end)
		end

		updateIconsLayout(nil, v58, positions) -- equivalent call inferred; original call site unknown
	end

	maid2:Add(instance.Activated:Connect(function()
		if not object._multiDelete then
			object:Select({
				type = "Sword",
				name = name,
				data = sword,
				key = inventoryKey
			})
			return
		end

		if not inventoryKey then
			return
		end

		object:_addToMultiDelete("Sword", inventoryKey)
	end))
end

local function constructExplosionSlot(object, data, instance, maid2)
	local explosionConfig = data.ExplosionConfig
	local attributes = explosionConfig:GetAttributes()
	local name = data.Name
	local inventoryKey = data.InventoryKey
	instance:SetAttribute("Name", name)
	instance:SetAttribute("Rarity", attributes.Rarity)
	instance:SetAttribute("AlwaysVisible", attributes.AlwaysVisible)
	instance:SetAttribute("Hidden", attributes.Hidden == true)
	instance:SetAttribute("OriginalLayoutOrder", data.OriginalLayoutOrder)
	local nameLabel = instance.NameLabel
	nameLabel.Text = string.upper(attributes.TitleText or nameLabel.Text)
	nameLabel.TextColor3 = attributes.TitleTextColor or nameLabel.TextColor3

	if explosionConfig:FindFirstChild("TitleTextColor") then
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.UIGradient.Color = explosionConfig.TitleTextColor.Color
	else
		nameLabel.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
	end

	nameLabel.TextStrokeColor3 = attributes.TitleTextStrokeColor or nameLabel.TextStrokeColor3
	instance.IconLabel.Image = attributes.Icon
	constructCommonBindings(object, data, instance, maid2)
	local stack = instance:FindFirstChild("Stack")
	local lock = instance:FindFirstChild("Lock")

	if client:GetInventoryVersion() == "New" then
		local v57 = { stack, lock }

		for i = #v57, 1, -1 do
			if v57[i] == nil then
				table.remove(v57, i)
			end
		end

		local positions = {}

		for k, v58 in v57 do
			local position = v58:GetAttribute("Position")

			if not position then
				position = v58.Position
				v58:SetAttribute("Position", position)
			end

			positions[k] = position
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function relayoutIcons()
			updateIconsLayout(nil, v57, positions) -- equivalent call inferred; original call site unknown
		end

		if stack then
			maid2:Add(v34.Computed(function(callback)
				local v58 = callback(data.ItemsMatching)
				local v59 = callback(data.InDeleteMulti)
				local v60 = #v58 - v59
				stack.Visible = v60 >= 2
				stack.Label.Text = `x{v60}`
				relayoutIcons() -- equivalent call inferred; original call site unknown
				return nil
			end))
			maid2:Add(function()
				stack.Visible = false
			end)
		end

		if lock then
			local v58 = v.Client:WaitReplion("Data")

			local function updateLock()
				local hasInteractedWithTrading = v58:Get("HasInteractedWithTrading")
				local item = data.Item
				lock.Visible = item ~= nil and item.TradeLock ~= nil and hasInteractedWithTrading ~= nil
				relayoutIcons() -- equivalent call inferred; original call site unknown
			end

			local hasInteractedWithTrading = v58:Get("HasInteractedWithTrading")
			local item = data.Item
			local visible

			if item == nil or item.TradeLock == nil then
				visible = false
			else
				visible = hasInteractedWithTrading ~= nil
			end

			lock.Visible = visible
			updateIconsLayout(nil, v57, positions) -- equivalent call inferred; original call site unknown

			if not v58:Get("HasInteractedWithTrading") then
				maid2:Add(v58:OnChange("HasInteractedWithTrading", updateLock))
			end

			maid2:Add(function()
				lock.Visible = false
			end)
		end

		updateIconsLayout(nil, v57, positions) -- equivalent call inferred; original call site unknown
	end

	local redirectGUI_If_Unowned = attributes.RedirectGUI_If_Unowned
	maid2:Add(instance.Activated:Connect(function()
		if object._multiDelete then
			if not inventoryKey then
				return
			end

			object:_addToMultiDelete("Explosion", inventoryKey)
		elseif data.OwnsItem:Get() or not redirectGUI_If_Unowned then
			object:Select({
				type = "Explosion",
				name = name,
				pack = attributes.Pack,
				configData = attributes,
				key = inventoryKey
			})
		else
			v16:Open(redirectGUI_If_Unowned)
		end
	end))
end

local function constructAbilitySlot(object, state4, instance, maid2)
	local abilityConfig = state4.AbilityConfig
	local attributes = abilityConfig:GetAttributes()
	local name = state4.Name
	local inventoryKey = state4.InventoryKey
	local v57 = (not inventoryKey or inventoryKey == name) and 0 or client:KeyToItem(inventoryKey).Upgrade or 0
	instance:SetAttribute("Name", name)
	instance:SetAttribute("AlwaysVisible", attributes.AlwaysVisible)
	instance:SetAttribute("Hidden", attributes.Hidden == true)
	instance:SetAttribute("OriginalLayoutOrder", state4.OriginalLayoutOrder)
	instance:SetAttribute("NonPurchaseable", attributes.UnavailableReason ~= nil or attributes.Price == nil)
	instance.ImageColor3 = attributes.Color or instance.ImageColor3
	instance.NameOfAbility.Text = attributes.TitleText or name
	instance.NameOfAbility.TextColor3 = attributes.TitleTextColor or instance.NameOfAbility.TextColor3
	instance.NameOfAbility.TextStrokeColor3 = attributes.TitleTextStrokeColor or instance.NameOfAbility.TextStrokeColor3
	local v58 = v.Client:WaitReplion("Data")

	local function getCurrentIcon()
		local icon = attributes.Icon
		local v59

		if client:GetInventoryVersion() == "New" then
			v59 = v57
		else
			v59 = v58:Get({ "AbilityUpgrades", name }) or 0
		end

		for i = 1, v59 or 0 do
			icon = attributes["Icon" .. i] or icon
		end

		return icon
	end

	instance.ImageLabel.Image = getCurrentIcon()

	if client:GetInventoryVersion() ~= "New" then
		maid2:Add(v58:OnChange({ "AbilityUpgrades", name }, function()
			instance.ImageLabel.Image = getCurrentIcon()

			if object._selectedItem and object._selectedItem.name == name then
				object:Select(object._selectedItem, true)
			end
		end))
	end

	maid2:Add(abilityConfig:GetAttributeChangedSignal("Hidden"):Connect(function()
		instance:SetAttribute("Hidden", abilityConfig:GetAttribute("Hidden") == true)
		state4.Hidden = abilityConfig:GetAttribute("Hidden") == true
		updateVirtualItemOwnership(object, state4)
	end))
	constructCommonBindings(object, state4, instance, maid2)
	local red = instance:FindFirstChild("Red")

	if red then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateAbilityEnabled()
			red.Visible = not v12:IsAbilityAllowed(name)
		end

		updateAbilityEnabled() -- equivalent call inferred; original call site unknown

		if v10.isRankedMatchServer() then
			maid2:Add(task.spawn(function()
				local v59 = v.Client:AwaitReplion("AbilityBanVoting")

				if v59 then
					maid2:Add(v59:OnChange("BannedAbilities", updateAbilityEnabled))
				end
			end))
		end

		maid2:Add(function()
			red.Visible = false
		end)
	end

	maid2:Add(instance.Activated:Connect(function()
		if not v12:IsAbilityAllowed(name) then
			v12:NotifyAbilityBlocked()

			if state4.OwnsItem:Get() then
				return
			end
		end

		object:Select({
			type = "Ability",
			name = name,
			pack = attributes.Pack,
			data = {},
			key = inventoryKey
		})
	end))
end

local function constructCharacterSlot(object, data, instance, maid2)
	local characterConfig = data.CharacterConfig
	local attributes = characterConfig:GetAttributes()
	local name = data.Name
	instance:SetAttribute("Name", name)
	instance:SetAttribute("AlwaysVisible", attributes.AlwaysVisible)
	instance:SetAttribute("Hidden", attributes.Hidden == true)
	instance:SetAttribute("OriginalLayoutOrder", data.OriginalLayoutOrder)
	instance:SetAttribute("NonPurchaseable", attributes.UnavailableReason ~= nil or attributes.Price == nil)
	instance.NameOfAbility.Text = name
	local icon = attributes.Icon

	if icon then
		instance.ImageLabel.Image = icon
		instance.ImageLabel.Visible = true
		instance.ViewportFrame.Visible = false
	else
		local character = characterConfig:FindFirstChild("Character")

		if character then
			instance.ImageLabel.Visible = false
			instance.ViewportFrame.Visible = true
			icons:SetSwordIconAsViewport(instance.ViewportFrame, character:Clone())
		end
	end

	maid2:Add(function()
		if instance.ViewportFrame then
			instance.ViewportFrame:ClearAllChildren()
		end
	end)
	maid2:Add(instance.Activated:Connect(function()
		object:Select({
			type = "Character",
			name = name,
			data = {
				configData = attributes
			}
		})
	end))
end

local function virtualScrollConstructor(p, p2, p3, _: number)
	local v57 = v25.new()

	if p2.Type == "Sword" then
		constructSwordSlot(p, p2, p3, v57)
	elseif p2.Type == "Explosion" then
		constructExplosionSlot(p, p2, p3, v57)
	elseif p2.Type == "Ability" then
		constructAbilitySlot(p, p2, p3, v57)
	elseif p2.Type == "Characters" then
		constructCharacterSlot(p, p2, p3, v57)
	end

	return function()
		v57:Destroy()
	end
end

local function virtualItemMatchesSearch(p)
	if p.Type == "Characters" then
		return true
	end

	local v57 = state and state:Get() or ""

	if #v57 == 0 then
		return true
	end

	local v58 = string.lower(v57)
	local lowerSearchName = p.LowerSearchName
	return lowerSearchName == v58 or string.sub(lowerSearchName, 1, #v58) == v58 or string.find(
		lowerSearchName,
		v58,
		1,
		true
	) ~= nil
end

local function setupInventoryPage(object, childName: string, scrollingFrame)
	local owned = scrollingFrame.Owned
	local unowned = scrollingFrame.Unowned
	local headerTitle = scrollingFrame:FindFirstChild("HeaderTitle")
	local maid2 = v25.new()
	local random = owned:FindFirstChild("!Random") or owned:FindFirstChild("Random")
	local fn

	if childName == "Sword" then
		fn = function(p)
			local parent = swordTemplates:FindFirstChild(p.Sword.Rarity) or swordTemplates.Normal
			prepareSlotTemplate(parent, childName)
			return parent
		end
	elseif childName == "Explosion" then
		fn = function(p)
			local attributes = p.ExplosionConfig:GetAttributes()
			local parent = script.ExplosionTemplates:FindFirstChild(attributes.Rarity) or script.ExplosionTemplates.Normal
			prepareSlotTemplate(parent, childName)
			return parent
		end
	else
		fn = script.AbilityTemplate
		prepareSlotTemplate(fn, childName)
	end

	local function fn2(p, p2)
		if owned.UIGridLayout.SortOrder ~= Enum.SortOrder.LayoutOrder then
			return p.Name_ < p2.Name_
		end

		local layoutOrder = p.LayoutOrder
		local layoutOrder2 = p2.LayoutOrder

		if layoutOrder == layoutOrder2 then
			return p.Name_ < p2.Name_
		end

		return layoutOrder < layoutOrder2
	end

	local v58 = {
		Container = scrollingFrame,
		Padding = 0,
		Layout = {
			{
				Id = "Owned",
				Container = owned,
				Template = fn,
				Constructor = function(p, p2, p3)
					return (virtualScrollConstructor(object, p, p2, p3))
				end,
				Sort = fn2,
				Prefix = random and { random } or {}
			},
			headerTitle and {
				Static = headerTitle
			} or nil,
			{
				Id = "Unowned",
				Container = unowned,
				Template = fn,
				Constructor = function(p, p2, p3)
					return (virtualScrollConstructor(object, p, p2, p3))
				end,
				Sort = fn2
			}
		}
	}
	local layout = {}

	for _, v60 in v58.Layout do
		if v60 then
			table.insert(layout, v60)
		end
	end

	v58.Layout = layout
	local scroll = maid2:Add(v40(v58))

	if headerTitle then
		local visible = headerTitle.Visible
		maid2:Add(function()
			headerTitle.Visible = visible
		end)
	end

	local v61 = {
		Scroll = scroll,
		Type = childName,
		ScrollingFrame = scrollingFrame,
		HeaderTitle = headerTitle,
		RandomButton = random,
		Trove = maid2,
		BatchDepth = 0,
		RefreshQueued = false,
		RecomputeSort = true,
		InvalidateAll = true,
		InvalidatedItems = {}
	}

	local function refreshNow()
		v61.RefreshQueued = false
		local recomputeSort = v61.RecomputeSort
		local invalidateAll = v61.InvalidateAll
		local invalidatedItems = v61.InvalidatedItems
		v61.RecomputeSort = false
		v61.InvalidateAll = false
		v61.InvalidatedItems = {}
		local v62 = {}
		local v63 = {}
		local _virtualItem = object._virtualItems[childName]

		if _virtualItem then
			for _, v64 in _virtualItem do
				if recomputeSort then
					updateVirtualItemSortValues(v64)
				end

				if v64.ForceHide or not virtualItemMatchesSearch(v64) then
					continue
				end

				local v65

				if v64.Section == "Owned" then
					v65 = v62
				else
					v65 = v63
				end

				table.insert(v65, v64)
			end
		end

		scroll.SetItems("Owned", v62)
		scroll.SetItems("Unowned", v63)

		if invalidateAll then
			scroll.Invalidate()
			return
		end

		for k in invalidatedItems do
			scroll.Invalidate(k)
		end
	end

	local function queueRefresh()
		if v61.BatchDepth > 0 or v61.RefreshQueued then
			return
		end

		v61.RefreshQueued = true
		task.defer(refreshNow)
	end

	function v61.MarkDirty(p, flag: boolean?, flag2: boolean?)
		v61.RecomputeSort = v61.RecomputeSort or flag == true

		if flag2 then
			if p then
				v61.InvalidatedItems[p] = true
			else
				v61.InvalidateAll = true
			end
		end

		if not (v61.BatchDepth > 0) then
			if v61.RefreshQueued then
				return
			end

			v61.RefreshQueued = true
			task.defer(refreshNow)
		end
	end

	function v61.BeginBatch()
		v61.BatchDepth += 1
	end

	function v61.EndBatch()
		v61.BatchDepth = math.max(0, v61.BatchDepth - 1)

		if not (v61.BatchDepth > 0) then
			if v61.RefreshQueued then
				return
			end

			v61.RefreshQueued = true
			task.defer(refreshNow)
		end
	end

	if childName == "Characters" then
		v53[childName] = {}
	else
		refreshFavoriteMap(childName)
		v54 = v54 or v.Client:WaitReplion("Data")
		local v62 = { client:GetLegacyInventoryPath(childName), "Favorites" }

		local function favoritesChanged()
			refreshFavoriteMap(childName)
			v61.MarkDirty(nil, true, true)
		end

		maid2:Add(v54:OnChange(v62, favoritesChanged))
		maid2:Add(v54:OnDescendantChange(v62, favoritesChanged))
	end

	local maid3 = v25.new()
	maid2:Add(maid3)
	local count = 0

	local function bindMetricUpdates()
		count += 1
		local v62 = count
		maid3:Clean()
		local v63 = state2:Get()

		if v63 ~= "RAP" and v63 ~= "Exists" then
			return
		end

		task.spawn(function()
			local v64 = v63 == "RAP" and "ItemRAP" or "ClientExistCount"
			local v65 = v.Client:WaitReplion(v64)

			if v62 ~= count then
				return
			end

			maid3:Add(v65:OnChange({ "Items", childName }, function()
				v61.MarkDirty(nil, true, false)
			end))
		end)
	end

	maid2:Add(state:Connect(function()
		v61.MarkDirty(nil, false, false)
	end))
	maid2:Add(state2:Connect(function()
		bindMetricUpdates()
		v61.MarkDirty(nil, true, false)
	end))
	maid2:Add(state3:Connect(function()
		v61.MarkDirty(nil, true, false)
	end))
	bindMetricUpdates()
	v61.MarkDirty(nil, true, true)
	return v61
end

local function registerVirtualItem(p, virtualItem)
	local _virtualItem = p._virtualItems[virtualItem.Type]

	if not _virtualItem then
		_virtualItem = {}
		p._virtualItems[virtualItem.Type] = _virtualItem
	end

	local inventoryKey = virtualItem.InventoryKey or virtualItem.Name
	local v57 = _virtualItem[inventoryKey]
	local v58 = v57 and v57 ~= virtualItem and p._inventoryPages[virtualItem.Type]

	if v58 then
		v58.MarkDirty(v57, false, true)
	end

	_virtualItem[inventoryKey] = virtualItem
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unregisterVirtualItem(p, p2: string, k: string)
	local _virtualItem = p._virtualItems[p2]

	if not _virtualItem then
		return
	end

	local v57 = _virtualItem[k]

	if not v57 then
		return
	end

	_virtualItem[k] = nil
	local _inventoryPage = p._inventoryPages[p2]

	if _inventoryPage then
		_inventoryPage.MarkDirty(v57, false, true)
	end
end

function ShopController:_createSwordSlot(sword, inventoryKey: string?)
	local name = sword.Name
	local originalLayoutOrder = name == "Base Sword" and 0 or v42[sword.Rarity]
	local virtualItem = buildVirtualItem("Sword", name, inventoryKey, {
		Sword = sword,
		Rarity = sword.Rarity,
		OriginalLayoutOrder = originalLayoutOrder,
		Hidden = sword.Hidden == true,
		AlwaysVisible = sword.AlwaysVisible
	})
	registerVirtualItem(self, virtualItem)
	updateVirtualItemOwnership(self, virtualItem)
end

function ShopController:_createExplosionSlot(explosionConfig, inventoryKey: string?)
	local name = explosionConfig.Name
	local attributes = explosionConfig:GetAttributes()
	local rarity = attributes.Rarity
	local virtualItem = buildVirtualItem("Explosion", name, inventoryKey, {
		ExplosionConfig = explosionConfig,
		Rarity = rarity,
		OriginalLayoutOrder = (v42[rarity] or 1) * 10 + (attributes.Order or 0),
		Hidden = attributes.Hidden == true,
		AlwaysVisible = attributes.AlwaysVisible
	})
	registerVirtualItem(self, virtualItem)
	updateVirtualItemOwnership(self, virtualItem)
end

function ShopController._createCharacterSlot(p, characterConfig)
	local name = characterConfig.Name
	local attributes = characterConfig:GetAttributes()
	local virtualItem = buildVirtualItem("Characters", name, nil, {
		CharacterConfig = characterConfig,
		OriginalLayoutOrder = attributes.Order or 1,
		Hidden = attributes.Hidden == true,
		AlwaysVisible = attributes.AlwaysVisible,
		NonPurchaseable = attributes.UnavailableReason ~= nil or attributes.Price == nil
	})
	registerVirtualItem(p, virtualItem)
	updateVirtualItemOwnership(p, virtualItem)
end

function ShopController:_createAbilitySlot(abilityConfig, inventoryKey: string?)
	local name = abilityConfig.Name
	local attributes = abilityConfig:GetAttributes()
	local virtualItem = buildVirtualItem("Ability", name, inventoryKey, {
		AbilityConfig = abilityConfig,
		OriginalLayoutOrder = attributes.Order or 0,
		Hidden = attributes.Hidden == true,
		AlwaysVisible = attributes.AlwaysVisible,
		NonPurchaseable = attributes.UnavailableReason ~= nil or attributes.Price == nil
	})
	registerVirtualItem(self, virtualItem)
	updateVirtualItemOwnership(self, virtualItem)
end

function ShopController:_updateItemStatus(p2, p3, p4)
	local _virtualItem = self._virtualItems[p2]
	local v57 = _virtualItem and _virtualItem[p4 or p3]

	if not v57 then
		return
	end

	updateVirtualItemOwnership(self, v57)
end

local function reflectRandomizerState(p)
	if not p or p == "GamePass" or p == "DevProduct" then
		return
	end

	local v57 = string.format("Settings.Misc.%sRandomizer", p)
	local v58 = v.Client:WaitReplion("Data")
	v58:GetExpect(v57 .. ".Current")
	local expect = v58:GetExpect(v57 .. ".UseFavorites")
	randomizerInfo.UseFavoritesLabel.Star.Image = expect and v45[true].Image or v45[true].HoverImage
	randomizerInfo.UseFavoritesLabel.TextColor3 = expect and color or Color3.fromRGB(255, 255, 255)
	randomizerInfo.UseFavoritesLabel.Text = expect and "Favorites Only: On" or "Favorites Only: Off"
end

function ShopController:Select(selectedItem, p)
	if not (selectedItem and table.find(v47, selectedItem.type)) then
		favorite.Visible = false
		favorite:SetAttribute("Visible", false)
		holder.InfoBG.Delete.Visible = false
	end

	if not p and v3.Dictionary.equals(selectedItem, self._selectedItem) then
		return
	end

	self.itemSelected:Fire(selectedItem)
	local v57 = v.Client:WaitReplion("Data")
	infoBG.SubscriptionRewards.Visible = false
	infoBG.ImageLabel.ViewportFrame.Visible = false

	if #infoBG.ImageLabel.ViewportFrame:GetChildren() > 0 then
		infoBG.ImageLabel.ViewportFrame:ClearAllChildren()
	end

	local configData = selectedItem.configData
	holder.InfoBG.Delete.Visible = false
	equipAccessory.Visible = false
	changeStyle.Visible = false

	if selectedItem.type == "DevProduct" or selectedItem.type == "GamePass" then
		local v58

		if selectedItem.type == "GamePass" then
			v58 = v57:Find("GamePasses", selectedItem.name)
		else
			v58 = false
		end

		buyButton.PriceTag.Price.Visible = false
		buyButton.PriceTag.TextLabel.Visible = true
		buyButton.PriceTag.TextLabel.Text = "Purchase"
		infoBG.Descriptor.Text = v58 and "Already purchased!" or selectedItem.data.description
		infoBG.ImageLabel.ImageColor3 = selectedItem.data.imageColor
		infoBG.ImageLabel.Image = selectedItem.data.image
		infoBG.Namer.Text = selectedItem.data.displayName or selectedItem.name
		buyButton.Visible = not v58
	elseif selectedItem.type == "Subscription" then
		buyButton.PriceTag.Price.Visible = false
		buyButton.PriceTag.TextLabel.Visible = true
		buyButton.PriceTag.TextLabel.Text = "Subscribe"
		local visible = v57:Get({ "Subscriptions", selectedItem.data.SubscriptionInfo.Name, "Active" })
		infoBG.SubscriptionRewards.Visible = visible
		infoBG.Descriptor.Text = visible and "Already subscribed!" or selectedItem.data.Description
		infoBG.ImageLabel.ImageColor3 = selectedItem.data.imageColor
		infoBG.ImageLabel.Image = selectedItem.data.image
		infoBG.Namer.Text = selectedItem.data.DisplayName or selectedItem.name
		buyButton.Visible = not visible
	elseif selectedItem.type == "Ability" then
		local equipped = client:GetEquipped("Ability")
		local v58 = selectedItem.key and client:FindItemsWithKey("Ability", selectedItem.key) or client:FindItems(
			"Ability",
			selectedItem.name
		)
		local item

		if v58[1] then
			item = client:GetItem("Ability", v58[1])
		end

		if equipped then
			if selectedItem.key then
				equipped = table.find(v58, equipped.Id)
			else
				equipped = equipped.Name == selectedItem.name
			end
		end

		local upgrade = item and item.Upgrade or 0
		local attributes = assert(
			ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(selectedItem.name),
			(`Could not find AbilityData for "{selectedItem.name}"`)
		):GetAttributes()
		local v59 = #v58 > 0
		local v60 = not v59 and v46 and not attributes.Hidden and true or v59
		local v61 = nil
		local price = attributes.Price

		if price and upgrade < 2 then
			v61 = price / math.max(1, 2 - upgrade)
		elseif not price and upgrade > 0 and v60 and attributes.MaxUpgradePrice then
			price = attributes.MaxUpgradePrice
			v61 = price / math.max(1, 2 - upgrade)
		end

		local v62 = attributes[`UpgradePrice{upgrade + 1}`] or v61

		if v46 then
			v62 = nil
		end

		finisher.Visible = false
		secretUpgrade2.Visible = false
		buyButton.PriceTag.TextLabel.Visible = true
		buyButton.Visible = true
		infoBG.GiftButton.Visible = false
		upgradeButton.Visible = v60
		killsProgressBar.Visible = false
		infoBG.Namer.Text = attributes.DisplayName or selectedItem.name
		infoBG.Descriptor.Text = attributes.Description or "No description found!"
		local icon = attributes.Icon

		for i = 1, upgrade do
			icon = attributes["Icon" .. i] or attributes.Icon
		end

		infoBG.ImageLabel.Image = icon
		buyButton.PriceTag.TextLabel.Text = equipped and "Equipped" or "Equip"

		for k, v63 in next, { "KillRequirement1", "KillRequirement2" }, nil do
			if not v60 then
				break
			end

			local v64 = v57:Get({ "AbilityUpgrades", selectedItem.name }) or 0

			if not (attributes[v63] and v64 == k - 1) then
				continue
			end

			v62 = attributes.MaxUpgradePrice / math.max(1, 2 - upgrade)
			local v65 = v57:Get("TotalStats.Kills") or 0
			local v66

			if attributes.UseLegacyUpgradeProgression then
				v66 = math.clamp(
					v65 - (v57:Get({ "AbilityUpgradeProgression", selectedItem.name }) or v65),
					0,
					attributes[v63]
				)
			else
				v66 = math.clamp(
					v57:Get({ "NewAbilityUpgradeProgression", selectedItem.name }) or 0,
					0,
					attributes[v63]
				)
			end

			killsProgressBar.Visible = true
			killsProgressBar.Progress.Text = `{v66}/{attributes[v63]} Eliminations`
			killsProgressBar.Fill.Size = UDim2.fromScale(v66 / attributes[v63], 0.9)
		end

		local count = 0
		local flag = false

		for k, childName in pairs({ "Description1", "Description2", "Description3" }) do
			local child = holder.Upgrades:FindFirstChild(childName)

			if not child then
				continue
			end

			local attribute = attributes[childName]

			if attribute then
				count += 1
				local v63 = child
				local v64 = k
				task.delay(0.1, function()
					local v65 = v57:Get({ "AbilityUpgrades", selectedItem.name }) or 0
					v63.OwnedLabel.Visible = v64 <= v65
				end)
				child.UpgradeDesc.Text = attribute
				child.Visible = true
				flag = true
			else
				child.Visible = false
			end
		end

		for i = 1, 3 do
			local child = holder.Upgrades:FindFirstChild("Description" .. i)

			if not child then
				continue
			end

			local size

			if count == 3 then
				size = UDim2.fromScale(0.832, 0.28)
			else
				size = UDim2.fromScale(0.832, 0.44)
			end

			child.Size = size

			if i == 1 then
				local position

				if count == 3 then
					position = UDim2.fromScale(0.122, 0.05)
				else
					position = UDim2.fromScale(0.122, 0.035)
				end

				child.Position = position
			elseif i == 2 then
				local position

				if count == 3 then
					position = UDim2.fromScale(0.1, 0.35)
				else
					position = UDim2.fromScale(0.07, 0.51)
				end

				child.Position = position
			end
		end

		if flag then
			local activatedConnection = infoBG.UpgradesInfoButton.Activated:Connect(function()
				holder.Upgrades.Visible = not holder.Upgrades.Visible

				if holder.Upgrades.Visible == true then
					inviteRewardsHolder.Visible = false
				else
					inviteRewardsHolder.Visible = true
				end
			end)

			function self._selectionMaid.OnUpgradesPressed()
				activatedConnection:Disconnect()
				infoBG.UpgradesInfoButton.Visible = false
				holder.Upgrades.Visible = false
			end

			infoBG.UpgradesInfoButton.Visible = true
		else
			self._selectionMaid.OnUpgradesPressed = nil
		end

		local nonUpgradable = attributes.NonUpgradable
		local customUpgrade = attributes.CustomUpgrade

		if nonUpgradable or not v60 then
			upgradeButton.Upg[`Upg{1}`].Visible = false
			upgradeButton.Upg[`Upg{2}`].Visible = false
			upgradeButton.Upg[`Upg{3}`].Visible = false

			if customUpgrade and v60 and not v46 then
				if attributes.MaxUpgrade <= upgrade then
					upgradeButton.PriceTag.TextLabel.Text = "MAX"
				else
					upgradeButton.PriceTag.TextLabel.Text = "UPGRADE"
				end

				upgradeButton.PriceTag.Price.Visible = false
				selectedItem.data.custom = customUpgrade
			else
				upgradeButton.PriceTag.TextLabel.Text = "CANNOT UPGRADE"
				upgradeButton.PriceTag.Price.Visible = false
			end
		else
			upgradeButton.PriceTag.Price.AmountText.Text = not v62 and "" or v6.commify(v62)
			upgradeButton.PriceTag.Price.Visible = v62 ~= nil
			local maxUpgrade = attributes.MaxUpgrade or 2

			for i = 1, 3 do
				if maxUpgrade == 3 then
					upgradeButton.Upg[`Upg{i}`].Size = UDim2.fromScale(0.3, 1)
				else
					upgradeButton.Upg[`Upg{i}`].Size = UDim2.fromScale(0.475, 1)
				end

				upgradeButton.Upg[`Upg{i}`].Visible = i <= maxUpgrade
				upgradeButton.Upg[`Upg{i}`].Shadow.Enabled = upgrade < i
			end

			if upgrade < maxUpgrade then
				upgradeButton.PriceTag.TextLabel.Text = "UPGRADE"
				upgradeButton.PriceTag.Price.Visible = true
			else
				upgradeButton.PriceTag.TextLabel.Text = "MAX"
				upgradeButton.PriceTag.Price.Visible = false
			end
		end

		if v60 then
			buyButton.PriceTag.Price.Visible = false
		elseif price then
			buyButton.Visible = true
			local amountText = buyButton.PriceTag.Price.AmountText

			if v51 and v14[selectedItem.name] then
				price = v14[selectedItem.name]
			end

			amountText.Text = v6.commify(price)
			buyButton.PriceTag.Price.Visible = true
			buyButton.PriceTag.TextLabel.Visible = false
		elseif attributes.UnavailableReason then
			buyButton.Visible = true
			buyButton.PriceTag.TextLabel.Visible = true
			buyButton.PriceTag.Price.Visible = false
			buyButton.PriceTag.TextLabel.Text = attributes.UnavailableReason
		elseif attributes.Pack then
			buyButton.Visible = true
			buyButton.PriceTag.TextLabel.Visible = true
			buyButton.PriceTag.Price.Visible = false
			buyButton.PriceTag.TextLabel.Text = attributes.PackDescription
		else
			buyButton.Visible = false
		end

		selectedItem.data.unlocked = v60
	elseif selectedItem.type == "Sword" then
		local v58 = self._virtualItems.Sword[selectedItem.key or selectedItem.name]
		local sword = self._inventoryPages.Sword
		local v59

		if v58 and sword then
			v59 = sword.Scroll.GetRenderedSlot(v58)
		end

		local data = selectedItem.data
		assert(data)
		local description = data.Description or "No description found!"
		local equipped = client:GetEquipped("Sword")
		local v60 = selectedItem.key and client:FindItemsWithKey("Sword", selectedItem.key) or client:FindItems(
			"Sword",
			selectedItem.name
		)
		local item

		if v60[1] then
			item = client:GetItem("Sword", v60[1])
		end

		if equipped then
			if selectedItem.key then
				equipped = table.find(v60, equipped.Id)
			else
				equipped = equipped.Name == selectedItem.name
			end
		end

		local visible = #client:FindItems("Sword", selectedItem.name) > 0
		buyButton.Visible = visible
		infoBG.Equips.Visible = true

		if data.HasFinisher then
			finisher.Visible = true

			if item and item.Finisher == true then
				if v57:Get({ "Finishers", "Equipped", selectedItem.name }) then
					finisher.Image = "rbxassetid://15452502387"
					finisher.HoverImage = "rbxassetid://14783051124"
					finisher.ImageColor3 = Color3.new(1, 1, 1)
					finisher.Label.Text = "UNEQUIP"
				else
					finisher.Image = "rbxassetid://15452544682"
					finisher.HoverImage = "rbxassetid://14783051124"
					finisher.ImageColor3 = Color3.new(1, 1, 1)
					finisher.Label.Text = "EQUIP"
				end
			else
				finisher.Image = "rbxassetid://15452544682"
				finisher.HoverImage = "rbxassetid://14783051124"
				finisher.ImageColor3 = Color3.new(0.5, 0.5, 0.5)
				finisher.Label.Text = data.ObtainFinisher or `OBTAIN IN {data.Name:find("Nebula") and "NEBULA" or "SCI FI"} SPINS`
			end
		else
			finisher.Visible = false
		end

		local animationStyle = data.AnimationStyles[localPlayer:GetAttribute("ShowSwordAccessory") and "Accessory" or "Base"]
		equipAccessory.Visible = equipped and data.AccessoryToggleable and (not data.AccessoryUnlockable or item and item.Accessory == true)
		local changeStyle2 = changeStyle

		if equipped then
			if animationStyle == nil then
				equipped = false
			else
				equipped = #animationStyle > 1
			end
		end

		changeStyle2.Visible = equipped

		if changeStyle.Visible then
			local animationStyle2 = localPlayer:GetAttribute("AnimationStyle") or "Default"
			local index = table.find(animationStyle, animationStyle2)
			local v63 = select(2, next(animationStyle, index)) or animationStyle[1]

			if v63 then
				changeStyle.Image = (index or 1) % 2 == 0 and "rbxassetid://15452502387" or "rbxassetid://15452544682"
				changeStyle.HoverImage = "rbxassetid://14783051124"
				changeStyle.Label.Text = `EQUIP {string.upper(v63)} STYLE`
			else
				changeStyle.Visible = false
			end
		end

		if data.AccessoryToggleable then
			local showSwordAccessory = localPlayer:GetAttribute("ShowSwordAccessory") == true
			equipAccessory.Image = showSwordAccessory and "rbxassetid://15452502387" or "rbxassetid://15452544682"
			equipAccessory.HoverImage = "rbxassetid://14783051124"
			equipAccessory.Label.Text = data.Name == "Cherub" and "SWITCH" or showSwordAccessory and "UNEQUIP ACCESSORY" or "EQUIP ACCESSORY"
		else
			equipAccessory.Visible = false
		end

		secretUpgrade2.Visible = data.CanAwaken

		if data.CanAwaken then
			secretUpgrade:SetAttribute("ToAwaken", client:GetInventoryVersion() == "New" and v60[1] or data.Name)
		else
			secretUpgrade:SetAttribute("ToAwaken", nil)
		end

		upgradeButton.Visible = false
		buyButton.PriceTag.Price.Visible = false
		buyButton.PriceTag.TextLabel.Visible = true
		infoBG.ImageLabel.Image = "rbxassetid://0"
		infoBG.Namer.Text = selectedItem.name
		infoBG.Descriptor.Text = description
		buyButton.PriceTag.TextLabel.Text = equipped and "Equipped" or "Equip"

		if not self._selectedItem or self._selectedItem.name ~= selectedItem.name then
			if v59 then
				local clone = (v59.ViewportFrame.Visible and v59.ViewportFrame or v59.IconLabel):Clone()
				clone.Size = UDim2.new(1, 0, 1, 0)
				clone.Parent = infoBG.ImageLabel
				self._selectionMaid.weaponViewport = clone
			else
				local sword2 = v58 and v58.Sword or v18:GetSword(selectedItem.name)

				if sword2 then
					if sword2.Icon then
						local imageLabel = Instance.new("ImageLabel")
						imageLabel.BackgroundTransparency = 1
						imageLabel.Image = sword2.Icon
						imageLabel.Size = UDim2.fromScale(1, 1)
						imageLabel.Parent = infoBG.ImageLabel
						self._selectionMaid.weaponViewport = imageLabel
					else
						local viewportFrame = Instance.new("ViewportFrame")
						viewportFrame.BackgroundTransparency = 1
						viewportFrame.Size = UDim2.fromScale(1, 1)
						viewportFrame.Parent = infoBG.ImageLabel
						icons:SetSwordIconAsViewportByName(viewportFrame, sword2.Name)
						self._selectionMaid.weaponViewport = viewportFrame
					end
				end
			end
		end

		holder.InfoBG.Delete.Visible = visible and selectedItem.key and self:_canDelete(
			selectedItem.type,
			selectedItem.key
		)
	elseif selectedItem.type == "Explosion" then
		local equipped = client:GetEquipped("Explosion")
		local v58 = equipped and equipped.Name == selectedItem.name
		local visible = #client:FindItems("Explosion", selectedItem.name) > 0
		finisher.Visible = false
		secretUpgrade2.Visible = false
		buyButton.PriceTag.TextLabel.Visible = true
		buyButton.Visible = visible
		infoBG.UpgradeButton.Visible = false
		buyButton.PriceTag.Price.Visible = false
		infoBG.ImageLabel.Image = icons:GetExplosionIcon(selectedItem.name)
		local displayName = selectedItem.configData.DisplayName

		if not displayName or #displayName == 0 then
			displayName = selectedItem.name
		end

		infoBG.Namer.Text = displayName
		local description = configData.Description
		local text = (not description or #description == 0) and "After finishing an opponent, the ball will explode into this effect." or description
		infoBG.Descriptor.Text = text
		buyButton.PriceTag.TextLabel.Text = v58 and "Equipped" or "Equip"
		holder.InfoBG.Delete.Visible = visible and selectedItem.key and self:_canDelete(
			selectedItem.type,
			selectedItem.key
		)
	end

	local visible2 = selectedItem.type == "Randomizer"
	infoBG.GiftButton.Visible = selectedItem.type == "DevProduct" or selectedItem.type == "GamePass"
	infoBG.ImageLabel.Visible = not visible2
	infoBG.Namer.Visible = not visible2
	infoBG.Descriptor.Visible = not visible2
	infoBG.ImageLabelz.Visible = not visible2
	local categoryName = selectedItem.categoryName

	if not categoryName then
		if selectedItem.type == "Character" then
			categoryName = false
		else
			categoryName = client:SafeGetLegacyInventoryPath(selectedItem.type)
		end
	end

	local v59

	if categoryName and categoryName ~= "GamePass" and categoryName ~= "DevProduct" then
		v59 = string.format("Settings.Misc.%sRandomizer.Current", categoryName)
	end

	local expect

	if v59 then
		expect = v57:GetExpect(v59)
	else
		expect = false
	end

	if visible2 then
		self._selectedItem = nil
		v27:Close("Inventory")
		v50 = categoryName
		buyButton.Visible = false
		finisher.Visible = false

		if not expect then
			remoteEvent:FireServer(categoryName, true, false)
		end
	else
		if expect then
			remoteEvent:FireServer(categoryName, false, false)
		end

		v50 = nil
		self._selectedItem = selectedItem
		v27:Close("Inventory")

		if table.find(v47, selectedItem.type) then
			local visible = #client:FindItems(selectedItem.type, selectedItem.name) > 0

			if visible then
				local v61 = v57:Get({ client:GetLegacyInventoryPath(selectedItem.type), "Favorites", selectedItem.name }) == true

				for k, v62 in pairs(v45[v61]) do
					favorite[k] = v62
				end
			end

			favorite.Visible = visible
			favorite:SetAttribute("Visible", visible)
		else
			favorite.Visible = false
			favorite:SetAttribute("Visible", false)
		end
	end

	randomizerInfo.Visible = visible2
	reflectRandomizerState(client:SafeGetLegacyInventoryPath(categoryName))
	local v60 = table.find(v48, selectedItem.type) ~= nil
	infoBG.Rap.Visible = v60 and v28:IsEnabled() and v28:ShouldShowRAP(selectedItem.type, selectedItem.name)
	infoBG.Rap.Coins.Amount.Text = "---"
	local key = selectedItem.key or client:ItemToKey(selectedItem.type, {
		Name = selectedItem.name
	})

	if v60 then
		task.spawn(function()
			local text = v8.ValueConvertor:AddCommas(v28:GetRAPAsync(selectedItem.type, key) or 0)

			if text and v3.Dictionary.equals(selectedItem, self._selectedItem) then
				infoBG.Rap.Coins.Amount.Text = text
			end
		end)
	end

	local v61 = v37:Get(selectedItem.type, key)

	if v61 then
		infoBG.ExistCount.Exist.Label.Text = `{v8.ValueConvertor:ShrinkNumber(v61)} Exist{v61 == 1 and "s" or ""}`
	end

	infoBG.ExistCount.Visible = v61 ~= nil
	self._selectionMaid:GiveTask(function()
		self._selectedItem = nil
		v27:Close("Inventory")
	end)
end

function ShopController:_updateInventoryLimit(p)
	local v57 = v22[p]
	local inventoryLimit = holder.InventoryLimit

	if not v57 then
		inventoryLimit.Visible = false
		return
	end

	local v58 = client:Get(p) or {}
	local count = 0

	for _, _ in pairs(v58) do
		count += 1
	end

	local v59 = v57 * 0.8

	if count < v59 then
		inventoryLimit.Visible = false
		return
	end

	inventoryLimit.Text = `{count}/{v57}`
	inventoryLimit.TextColor3 = Color3.fromHSV(0.15 * (1 - v59 / v57), 1, 1)
	inventoryLimit.Visible = true
end

function ShopController:_updateMultiDelete()
	local scrollingFrame = holder.DeleteItems.List.ContentsCanvas.ScrollingFrame

	if self._multiDelete then
		for _, guiObject in scrollingFrame:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local inventoryType = guiObject:GetAttribute("InventoryType")
			local name = guiObject.Name

			if not self._multiDelete[inventoryType] or #(self._multiDelete[inventoryType][name] or {}) <= 0 then
				guiObject:Destroy()
			end
		end

		for k, v57 in self._multiDelete do
			for childName, v58 in v57 do
				local keyToItem = client:KeyToItem(childName)
				local clone = scrollingFrame:FindFirstChild(childName)

				if not clone then
					clone = scrollingFrame.UIListLayout.Template:Clone()
					clone.Name = childName
					clone.Parent = scrollingFrame
					v33:Add(clone, k, keyToItem, childName)
					local v59 = v58
					local v60 = k
					local v61 = childName
					local v62 = keyToItem

					local function removeItem()
						table.remove(v59, 1)

						if #v59 <= 0 then
							self._multiDelete[v60][v61] = nil
							clone:Destroy()
						end

						self:_updateItemStatus(v60, v62.Name, v61)
						self:_updateMultiDelete()
					end

					clone.Button.Activated:Connect(removeItem)
					clone.Button.Item.Activated:Connect(removeItem)
				end

				local v59 = v29[k][keyToItem.Name]
				local displayName = v59.DisplayName or keyToItem.Name
				local v60 = v59.Rarity and v30.SmallerSlotColors[v59.Rarity] or v30.SmallerSlotColors.Default
				clone.Button.Item.Image = v60.Image
				clone.Button.Item.HoverImage = v60.HoverImage
				clone.Button.Item.Vector.Image = v59.Icon or v8.Icons:GetIcon("DEFAULT_MISSING")
				clone.Button.Item.Label.Text = `x{#v58}`
				clone.Button.Label.Text = displayName
			end
		end
	else
		for _, guiObject in scrollingFrame:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end
	end
end

function ShopController:_canDelete(p, p2)
	return v32.IsDeleteable(localPlayer, p, client:KeyToItem(p2))
end

function ShopController:_addToMultiDelete(p, p2)
	local _canDelete, v57 = self:_canDelete(p, p2)

	if _canDelete then
		local v58 = self._multiDelete and self._multiDelete[p]

		if not v58 then
			return
		end

		if not v58[p2] then
			v58[p2] = {}
		end

		local items = client:FindItemsWithKey(p, p2)

		for _, v59 in v58[p2] do
			local index = table.find(items, v59)

			if index then
				table.remove(items, index)
			end
		end

		if #items <= 0 or table.find(v58[p2], items[1]) then
			return
		end

		table.insert(v58[p2], items[1])
		self:_updateItemStatus(p, client:KeyToItem(p2).Name, p2)
		self:_updateMultiDelete()
	elseif v57 then
		v26:SendNotification(v57)
	end
end

function ShopController:_updateMultiDeleteVisbility()
	holder.DeleteItems.Visible = self._multiDelete and self._page and (self._page.Name == "Explosion" or self._page.Name == "Sword")
	holder.InfoBG.Visible = not holder.DeleteItems.Visible
	favorite.Visible = holder.InfoBG.Visible and favorite:GetAttribute("Visible")
end

function ShopController:GoTo(childName: string, flag: boolean?)
	favorite.Visible = false
	favorite:SetAttribute("Visible", false)

	if self._page and self._page.Name == childName and not flag then
		return
	end

	self._selectionMaid:DoCleaning()

	if self._page then
		self._page.Visible = false
		local assert_2 = assert(frameSelectionButtons:FindFirstChild(self._page.Name))
		assert_2.Image = "rbxassetid://14782684812"
	end

	for _, guiObject in infoBG:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	end

	local page = assert(pages:FindFirstChild(childName), (`Could not find "{childName}!"`))
	page.Visible = true
	local assert_3 = assert(frameSelectionButtons:FindFirstChild(childName))
	assert_3.Image = "rbxassetid://14782680596"
	self._page = page
	self:CheckSearchVisibility()

	if shop.Enabled and self._loadInventoryPage then
		self._loadInventoryPage(childName)
	end

	self:_updateInventoryLimit(childName)
	holder.Delete.Visible = childName == "Explosion" or childName == "Sword"
	self:_updateMultiDeleteVisbility()
end

function ShopController:Open()
	if not v16:IsOpen("Shop") then
		v16:Open("Shop")
	end

	if self._page and self._loadInventoryPage then
		self._loadInventoryPage(self._page.Name)
	end
end

function ShopController:Close(p)
	if v16:IsOpen("Shop") then
		v16:Close("Shop", p)
	end
end

function ShopController:Start()
	v.Client:WaitReplion("Data")
	pages.ExplosionSkins.Name = "Explosion"
	frameSelectionButtons.ExplosionSkins.Name = "Explosion"
	pages.Abilities.Name = "Ability"
	frameSelectionButtons.Abilities.Name = "Ability"
	pages.SwordSkins.Name = "Sword"
	frameSelectionButtons.SwordSkins.Name = "Sword"
	pages.Finishers:Destroy()

	for _, childName in { "Sword", "Explosion", "Ability" } do
		local scrollingFrame = pages:FindFirstChild(childName)

		if scrollingFrame and scrollingFrame:IsA("ScrollingFrame") then
			self._inventoryPages[childName] = setupInventoryPage(self, childName, scrollingFrame)
		end
	end

	holder.CloseButton.Activated:Connect(function()
		self:Close()
	end)
	task.delay(1, function()
		local _currency = v15._currency or "Credits"
		local _lastCurrencyChange = 0
		v16:OnGuiOpen("Shop", function()
			v27:Close("Inventory")
			self:CheckSearchVisibility()
			remoteEvent5:FireServer("ShopOpened", {
				inMatch = workspace:GetAttribute("GameActive") == true,
				productIntelligence = localPlayer:GetAttribute("ShopProductIntelligence") == true
			})

			if self._page and self._loadInventoryPage then
				self._loadInventoryPage(self._page.Name)
			end

			if v10.isDungeonsMatchServer() or v10.isDungeonsLobbyServer() then
				_currency = v15._currency

				if _currency ~= "Credits" then
					v15:SetCurrency("Credits")
					_lastCurrencyChange = v15._lastCurrencyChange
				end
			end
		end)
		v16:OnGuiClose("Shop", function()
			if _currency ~= v15._currency and _lastCurrencyChange == v15._lastCurrencyChange then
				v15:SetCurrency(_currency)
				_currency = v15._currency
			end

			self:CheckSearchVisibility()
		end)
		shop:GetPropertyChangedSignal("Enabled"):Connect(function()
			task.defer(function()
				self:CheckSearchVisibility()
			end)
		end)
	end)

	for _, button in frameSelectionButtons:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v57 = button
		button.Activated:Connect(function()
			self:GoTo(v57.Name)
		end)
	end

	local robux = pages.Robux

	for _, button in robux.Items:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local subscriptionInfo = v4[button.Name]

		if subscriptionInfo then
			if subscriptionInfo.Disabled then
				button.Visible = false
			else
				button.Text.Text = subscriptionInfo.DisplayName
				local v58 = button
				local subscriptionInfo2 = subscriptionInfo
				button.Activated:Connect(function()
					self:Select({
						type = "Subscription",
						name = v58.Name,
						data = {
							DisplayName = subscriptionInfo2.DisplayName,
							SubscriptionInfo = subscriptionInfo2,
							Description = v58.Description.Value,
							image = v58.ImageLabel.Image,
							imageColor = v58.ImageLabel.ImageColor3
						}
					})
				end)
			end
		else
			local v58 = v43[button.Name]
			local v59 = v44[button.Name]
			local v60 = {
				productId = v58 or v59,
				displayName = button.VisualName.Value,
				image = button.ImageLabel.Image,
				imageColor = button.ImageLabel.ImageColor3,
				description = button.Description.Value
			}

			if v58 then
				v19(button.Bottomtext, v58, "DevProduct")
			elseif v59 then
				v19(button.Bottomtext, v59, "GamePass")
			end

			local v62 = button
			button.Activated:Connect(function()
				if v58 then
					self:Select({
						type = "DevProduct",
						name = v62.Name,
						data = v60
					})
				elseif v59 then
					self:Select({
						type = "GamePass",
						name = v62.Name,
						data = v60
					})
				end
			end)
		end
	end

	local function createInventory(p, options)
		local v57 = options or {}

		if type(v57) == "table" and not table.find(v57, "Id") then
			table.insert(v57, "Id")
		end

		local _inventoryPage = self._inventoryPages[p]
		local v58 = client:GetInventoryVersion() == "New"

		local function createDynamicSlot(p2, k: string)
			if self._virtualItems[p][k] then
				return
			end

			if p == "Ability" then
				local child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(p2.Name)

				if child then
					self:_createAbilitySlot(child, k)
				end
			elseif p == "Sword" then
				local sword = v18:GetSword(p2.Name)

				if sword then
					self:_createSwordSlot(sword, k)
				end
			else
				local child = p == "Explosion" and ReplicatedStorage2.Misc.DataExplosions:FindFirstChild(p2.Name)

				if child then
					self:_createExplosionSlot(child, k)
				end
			end
		end

		local function rebuildIndexAndSync()
			_inventoryPage.BeginBatch()
			local v59 = {
				ByKey = {},
				ByName = {},
				ItemByKey = {}
			}

			for k, v60 in client:Get(p) or {} do
				local itemToKey = client:ItemToKey(p, v60, v57)

				if not itemToKey then
					continue
				end

				local v61 = v59.ByKey[itemToKey]

				if not v61 then
					v61 = {}
					v59.ByKey[itemToKey] = v61
					v59.ItemByKey[itemToKey] = v60
				end

				table.insert(v61, k)
				local v62 = v59.ByName[v60.Name]

				if not v62 then
					v62 = {}
					v59.ByName[v60.Name] = v62
				end

				table.insert(v62, k)
			end

			v52[p] = v59

			if v58 then
				for k, v60 in v59.ItemByKey do
					createDynamicSlot(v60, k)
				end
			end

			for k, v60 in self._virtualItems[p] do
				if v60.InventoryKey and not (v58 and v59.ByKey[k]) then
					unregisterVirtualItem(self, p, k) -- equivalent call inferred; original call site unknown
				else
					updateVirtualItemOwnership(self, v60)
				end
			end

			if self._selectedItem and self._selectedItem.type == p and self._selectedItem.key and not v59.ByKey[self._selectedItem.key] then
				for k, v60 in v59.ItemByKey do
					if v60.Name ~= self._selectedItem.name then
						continue
					end

					local clone = table.clone(self._selectedItem)
					clone.key = k
					self:Select(clone)
					break
				end
			end

			_inventoryPage.MarkDirty(nil, true, true)
			_inventoryPage.EndBatch()
		end

		rebuildIndexAndSync()
		local v59 = false
		client:OnChange(p, function(_, p2)
			if not v59 then
				v59 = true
				task.defer(function()
					v59 = false
					rebuildIndexAndSync()
				end)
			end

			if p2 == "Insert" or p2 == "Remove" then
				self:_updateInventoryLimit(p)
			end
		end)
	end

	local v57 = {}

	function self._loadInventoryPage(p: string)
		if v57[p] or v10.isRegionalTournamentMatch() then
			return
		end

		local _inventoryPage = self._inventoryPages[p]

		if not _inventoryPage then
			return
		end

		v57[p] = "Loading"
		task.spawn(function()
			_inventoryPage.BeginBatch()
			local v58, v59 = xpcall(function()
				if p == "Sword" then
					createInventory("Sword")

					for _, v60 in v18:GetCollection() do
						self:_createSwordSlot(v60)
					end
				elseif p == "Explosion" then
					createInventory("Explosion")

					for _, child in ReplicatedStorage2.Misc.DataExplosions:GetChildren() do
						if not child:GetAttribute("Hidden") then
							self:_createExplosionSlot(child)
						end
					end
				elseif p == "Ability" then
					createInventory("Ability")

					for _, child in ReplicatedStorage2.Misc.DataAbilities:GetChildren() do
						self:_createAbilitySlot(child)
					end

					ReplicatedStorage2.Misc.DataAbilities.ChildAdded:Connect(function(child)
						task.wait(1)

						if child and child.Parent then
							self:_createAbilitySlot(child)
						end
					end)
				end
			end, debug.traceback)
			_inventoryPage.EndBatch()

			if v58 then
				v57[p] = "Loaded"
				return
			end

			v57[p] = nil
			warn((`[ShopController] Failed to lazily load {p}:\n{v59}`))
		end)
	end

	shop:GetPropertyChangedSignal("Enabled"):Connect(function()
		if shop.Enabled and self._page and self._loadInventoryPage then
			self._loadInventoryPage(self._page.Name)
		end
	end)
	task.spawn(function()
		if v10.isRegionalTournamentMatch() then
			return
		end

		local searchFrame = holder:WaitForChild("SearchFrame")
		searchFrame.SearchBG.SearchInput.ClearTextOnFocus = false
		task.spawn(self.CheckSearchVisibility, self)
		v35:CreateSortOptions(searchFrame.SearchBG.Sort, state2, state3)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function doSearchAction()
			state:Set(searchFrame.SearchBG.SearchInput.Text)
		end

		searchFrame.Search.MouseButton1Click:Connect(doSearchAction)
		searchFrame.SearchBG.SearchInput.FocusLost:Connect(doSearchAction)
		local name = nil
		searchFrame.SearchBG.SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
			if self._page then
				name = self._page.Name
			end

			if not self._selectionMaid.OnSearched then
				function self._selectionMaid.OnSearched()
					state:Set("")
				end
			end

			doSearchAction() -- equivalent call inferred; original call site unknown
		end)
		local v58 = { "Sword", "Explosion" }
		local computed = v34.Computed(function(callback)
			for _, child in pages:GetChildren() do
				if callback((v34.getPropertyState(child, "Visible"))) then
					return child.Name
				end
			end

			return false
		end)
		computed:Connect(function()
			state2:Set("Default")
			state3:Set("Most")
		end)
		v34.setPropertyComputed(searchFrame.SearchBG.Sort, "Visible", function(callback)
			return table.find(v58, callback(computed))
		end)

		for _, v59 in v58 do
			local computed2 = v34.Computed(function(callback)
				local v60 = not state2 and "Default" or callback(state2)

				if v60 == "Default" or v60 == "Alphabetical" then
					return Enum.SortOrder.Name
				end

				return Enum.SortOrder.LayoutOrder
			end)
			v34.setPropertyState(pages[v59].Owned.UIGridLayout, "SortOrder", computed2)
			v34.setPropertyState(pages[v59].Unowned.UIGridLayout, "SortOrder", computed2)
		end
	end)
	self:GoTo("Ability")
	workspace.Alive.ChildAdded:Connect(function(child)
		if child == localPlayer.Character then
			self:Close(true)
		end
	end)
	favorite.Visible = false
	favorite:SetAttribute("Visible", false)
	favorite.Activated:Connect(function()
		local _selectedItem = self._selectedItem

		if not (_selectedItem and table.find(v47, _selectedItem.type)) then
			return
		end

		local name = _selectedItem.name
		local key = _selectedItem.key

		if key then
			name = client:FindItemsWithKey(_selectedItem.type, key)[1] or name
		end

		v2:RemoteEvent("RequestFavoriteItem"):FireServer(_selectedItem.type, name)
	end)
	buyButton.Activated:Connect(function()
		if not self._selectedItem then
			return
		end

		local name = self._selectedItem.name
		local key = self._selectedItem.key
		local v58

		if key then
			v58 = client:FindItemsWithKey(self._selectedItem.type, key)[1] or name
		else
			v58 = name
		end

		if self._selectedItem.type == "GamePass" then
			v23:PromptPurchase(self._selectedItem.data.productId, Enum.InfoType.GamePass)
		elseif self._selectedItem.type == "DevProduct" then
			v23:PromptPurchase(self._selectedItem.data.productId, Enum.InfoType.Product)
		elseif self._selectedItem.type == "Subscription" then
			v16:Open("VIPPlus")
		elseif self._selectedItem.type == "Sword" then
			remoteFunction3:InvokeServer(v58)
		elseif self._selectedItem.type == "Character" then
			if self._selectedItem.data.purchaseable then
				remotes.Store.RequestBuyCharacter:InvokeServer(name)
			else
				remotes.Store.RequestEquipCharacter:InvokeServer(name)
			end
		elseif self._selectedItem.type == "Ability" then
			if self._selectedItem.data.unlocked then
				if v12:IsAbilityAllowed(name) then
					remoteFunction2:InvokeServer(v58)
				else
					v12:NotifyAbilityBlocked()
				end
			elseif not self._selectedItem.pack then
				remoteFunction6:InvokeServer(name)
			elseif self._selectedItem.pack == "BattlepassGacha" then
				v21:OpenView("SpinGacha")
				v21:Open()
			elseif self._selectedItem.pack == "ProgressiveRewards" then
				self:GoTo("Robux")
			else
				v16:Open(self._selectedItem.pack)
			end
		elseif self._selectedItem.type == "Explosion" then
			remoteFunction4:InvokeServer(v58)
		end
	end)
	finisher.Activated:Connect(function()
		if finisher.Label.Text == "OBTAIN IN SELECTION CRATE" then
			v16:Open("BattlepassSelectionCrate")
		elseif finisher.Label.Text == "OBTAIN IN MERCHANT" then
			v16:Open("MerchantFinisher")
		elseif finisher.Label.Text == "OBTAIN IN JACK-O-LANTERN SPINS" then
			v38:Open()
		end

		if self._selectedItem and self._selectedItem.type == "Sword" then
			remoteFunction:InvokeServer(self._selectedItem.name)
		end
	end)
	secretUpgrade2.Activated:Connect(function()
		v16:Open("SecretUpgrade")
	end)
	upgradeButton.Activated:Connect(function()
		if not self._selectedItem then
			return
		end

		if self._selectedItem.type == "Ability" then
			if self._selectedItem.data.custom then
				v16:Open(self._selectedItem.data.custom)
			elseif self._selectedItem.name or self._selectedItem.key then
				local v58

				if self._selectedItem.name then
					v58 = client:FindItems("Ability", self._selectedItem.name)
				else
					v58 = not self._selectedItem.key and {} or client:FindItemsWithKey(
						"Ability",
						self._selectedItem.key
					)
				end

				if #v58 < 0 then
					ReplicatedStorage2.Misc.error:Play()
				else
					remoteFunction5:InvokeServer(v58[1])
				end
			end
		end
	end)
	rapButton.Activated:Connect(function()
		if not (self._selectedItem and table.find(v48, self._selectedItem.type) and v28:IsEnabled() and v28:ShouldShowRAP(
			self._selectedItem.type,
			self._selectedItem.name
		)) then
			return
		end

		local key = self._selectedItem.key or client:ItemToKey(self._selectedItem.type, {
			Name = self._selectedItem.name
		})

		if v27:Render("Inventory", self._selectedItem.type, key) then
			return
		end

		warn("Failed to render RAP chart")
		v26:SendNotification("Failed to load RAP history. Try again later")
		v27:Close("Inventory")
	end)
	equipAccessory.Activated:Connect(function()
		if not self._selectedItem or self._selectedItem.type ~= "Sword" or not self._selectedItem.data.AccessoryToggleable then
			return
		end

		remoteEvent2:FireServer()
	end)
	localPlayer:GetAttributeChangedSignal("ShowSwordAccessory"):Connect(function()
		localPlayer:GetAttribute("ShowSwordAccessory")

		if self._selectedItem and self._selectedItem.type == "Sword" then
			self:Select(self._selectedItem, true)
		end
	end)
	changeStyle.Activated:Connect(function()
		if not self._selectedItem or self._selectedItem.type ~= "Sword" then
			return
		end

		remoteEvent3:FireServer()
	end)
	localPlayer:GetAttributeChangedSignal("AnimationStyle"):Connect(function()
		localPlayer:GetAttribute("AnimationStyle")

		if self._selectedItem and self._selectedItem.type == "Sword" then
			self:Select(self._selectedItem, true)
		end
	end)
	infoBG.GiftButton.Activated:Connect(function()
		if not self._selectedItem then
			return
		end

		v13:SetGift(self._selectedItem.data.displayName)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function checkIfExtraEnabled()
		extra.Visible = v9:GetKey("NewInventoryEnabled") == true and not extraBtns.Visible
	end

	extra.Activated:Connect(function()
		extraBtns.Visible = true
		extra.Visible = false
	end)
	extraBtns.Back.Activated:Connect(function()
		extraBtns.Visible = false
		extra.Visible = true
	end)
	task.defer(function()
		v9:WaitForData()
		checkIfExtraEnabled() -- equivalent call inferred; original call site unknown
		self:CheckSearchVisibility()
	end)
	v9.DataUpdatedEvent:Connect(checkIfExtraEnabled)
	v9.DataUpdatedEvent:Connect(function()
		self:CheckSearchVisibility()
	end)

	local function updateItem(p: string)
		return function(p2, _)
			local name

			if type(p2) == "table" then
				name = p2.Name
			else
				name = p2
			end

			local v58

			if client:GetInventoryVersion() == "New" and type(p2) == "table" then
				v58 = client:ItemToKey(p, p2)
			end

			if self._selectedItem and self._selectedItem.name == name then
				self:Select(self._selectedItem, true)
			end

			self:_updateItemStatus(p, name, v58)

			if v58 then
				self:_updateItemStatus(p, name)
			end
		end
	end

	local function updateSelected(p)
		if self._selectedItem and self._selectedItem.name == p.Name then
			self:Select(self._selectedItem, true)
		end
	end

	local v58 = v.Client:WaitReplion("Data")
	v58:OnDescendantChange("Subscriptions", function()
		if self._selectedItem and self._selectedItem.type == "Subscription" then
			self:Select(self._selectedItem, true)
		end
	end)
	client:OnEquip("Sword", updateSelected)
	client:OnEquip("Ability", updateSelected)
	client:OnEquip("Explosion", updateSelected)
	v58:OnChange("Characters.CurrentlySelected", updateSelected)
	v58:OnDescendantChange("Finishers", function()
		if self._selectedItem then
			self:Select(self._selectedItem, true)
		end
	end)

	for _, v59 in v47 do
		local v60 = v59
		v58:OnDescendantChange({ client:GetLegacyInventoryPath(v59), "Favorites" }, function(list)
			if typeof(list) == "table" and #list >= 3 then
				local _virtualItem = self._virtualItems[v60]

				if _virtualItem then
					for k, v61 in _virtualItem do
						if v61.Name == list[3] and v61.Name ~= k then
							self:_updateItemStatus(v60, list[3], k)
						end
					end
				end

				self:_updateItemStatus(v60, list[3])
			end

			if self._selectedItem then
				self:Select(self._selectedItem, true)
			end
		end)
	end

	local v59 = "Sword"
	client:OnChange("Sword", function(p, _)
		local name

		if type(p) == "table" then
			name = p.Name
		else
			name = p
		end

		local v60

		if client:GetInventoryVersion() == "New" and type(p) == "table" then
			v60 = client:ItemToKey(v59, p)
		end

		if self._selectedItem and self._selectedItem.name == name then
			self:Select(self._selectedItem, true)
		end

		self:_updateItemStatus(v59, name, v60)

		if v60 then
			self:_updateItemStatus(v59, name)
		end
	end)
	local v60 = "Ability"
	client:OnChange("Ability", function(p, _)
		local name

		if type(p) == "table" then
			name = p.Name
		else
			name = p
		end

		local v61

		if client:GetInventoryVersion() == "New" and type(p) == "table" then
			v61 = client:ItemToKey(v60, p)
		end

		if self._selectedItem and self._selectedItem.name == name then
			self:Select(self._selectedItem, true)
		end

		self:_updateItemStatus(v60, name, v61)

		if v61 then
			self:_updateItemStatus(v60, name)
		end
	end)
	local v61 = "Explosion"
	client:OnChange("Explosion", function(p, _)
		local name

		if type(p) == "table" then
			name = p.Name
		else
			name = p
		end

		local v62

		if client:GetInventoryVersion() == "New" and type(p) == "table" then
			v62 = client:ItemToKey(v61, p)
		end

		if self._selectedItem and self._selectedItem.name == name then
			self:Select(self._selectedItem, true)
		end

		self:_updateItemStatus(v61, name, v62)

		if v62 then
			self:_updateItemStatus(v61, name)
		end
	end)
	local v62 = "Characters"

	local function fn(p, _)
		local name

		if type(p) == "table" then
			name = p.Name
		else
			name = p
		end

		local v63

		if client:GetInventoryVersion() == "New" and type(p) == "table" then
			v63 = client:ItemToKey(v62, p)
		end

		if self._selectedItem and self._selectedItem.name == name then
			self:Select(self._selectedItem, true)
		end

		self:_updateItemStatus(v62, name, v63)

		if v63 then
			self:_updateItemStatus(v62, name)
		end
	end

	v58:OnArrayInsert("Characters.Unlocked", function(_: number, p)
		fn(p, nil)
	end)
	v58:OnArrayRemove("Characters.Unlocked", function(_: number, p)
		fn(p, nil)
	end)
	v58:OnDescendantChange("NewAbilityUpgradeProgression", function(list, _)
		if type(list) ~= "table" then
			return
		end

		local v63 = list[2]

		if not self._selectedItem or self._selectedItem.type ~= "Ability" or self._selectedItem.name ~= v63 then
			return
		end

		self:Select(self._selectedItem, true)
	end)

	if v8.FFlag.GetFFlag("AbilityPriceReductionEnabled", true) then
		v51 = true

		for k, _ in pairs(v14) do
			self:_updateItemStatus("Ability", k)
		end
	end

	for _, v63 in v49 do
		local safeGetLegacyInventoryPath = client:SafeGetLegacyInventoryPath(v63)
		local _inventoryPage = self._inventoryPages[v63]
		local randomButton = _inventoryPage and _inventoryPage.RandomButton

		if not randomButton then
			continue
		end

		randomButton.Check.Visible = v58:Get((`Settings.Misc.{safeGetLegacyInventoryPath}Randomizer.Current`))
		local v64 = randomButton
		v58:OnChange(`Settings.Misc.{safeGetLegacyInventoryPath}Randomizer.Current`, function(visible: boolean)
			v64.Check.Visible = visible
		end)
		local categoryName = safeGetLegacyInventoryPath
		randomButton.Activated:Connect(function()
			self:Select({
				type = "Randomizer",
				categoryName = categoryName,
				name = "Random"
			}, true)
			holder.Upgrades.Visible = false
			holder.InfoBG.UpgradeButton.Visible = false
			holder.InfoBG.UpgradesInfoButton.Visible = false
			equipAccessory.Visible = false
			finisher.Visible = false
		end)
		local v66 = v63
		local v67 = randomButton

		local function reflectRandomizerVisibility()
			local v68 = {}

			for k, v69 in pairs(client:Get(v66) or {}) do
				if not v68[v69.Name] then
					v68[v69.Name] = true
				end
			end

			v67.Visible = (v66 ~= "Ability" or not v10.isHuntPrivateServer()) and v3.Dictionary.count(v68) >= 15
		end

		task.spawn(reflectRandomizerVisibility)
		client:OnChange(v63, reflectRandomizerVisibility)
		local v68 = string.format("Settings.Misc.%sRandomizer", safeGetLegacyInventoryPath)
		local categoryName2 = safeGetLegacyInventoryPath

		local function reflect()
			reflectRandomizerState(categoryName2)
		end

		v58:OnChange(v68 .. ".Current", reflect)
		v58:OnChange(v68 .. ".UseFavorites", reflect)
	end

	randomizerInfo.ToggleFavorites.Activated:Connect(function()
		if not v50 then
			return
		end

		local expect = v58:GetExpect((string.format("Settings.Misc.%sRandomizer.UseFavorites", v50)))
		remoteEvent:FireServer(v50, true, not expect)
	end)
	local summerPack = robux.SummerPack
	local uIPageLayout = summerPack.Main.List.UIPageLayout
	local v63 = {}
	local clones = {}
	local v64 = true

	for i = 1, 6 do
		local clone = uIPageLayout.Template:Clone()
		clone.LayoutOrder = i
		clone.Name = i
		clone.Parent = summerPack.Main.List
		clone.Buy.Activated:Connect(function()
			local v66 = v63[clone]

			if not v66 then
				return
			end

			local v67, v68 = v2:Invoke("ClaimProgressiveReward", v66)

			if v67 or not v68 then
				return
			end

			ReplicatedStorage2.Misc.error:Play()
			v26:SendNotification(v68)
		end)
		-- equivalent calls inferred from this helper; original call sites unknown
		local v66 = clone

		local function updateText()
			local targetProdctId = v66:GetAttribute("TargetProdctId")
			local formatted = `<stroke color="rgb(8, 76, 28)" thickness="{v66.Buy.Label.UIStroke.Thickness}">{targetProdctId and "" or ""}<font size="16">{v66.Buy.Label.PriceLabel.Text}</font></stroke>`
			v66.Buy.Label.Text = formatted
		end

		local v67 = clone

		local function updateProduct()
			v67.Buy.Label.PriceLabel:RemoveTag("ProductPriceLabel")
			local targetProdctId = v67:GetAttribute("TargetProdctId")

			if targetProdctId then
				v19(v67.Buy.Label.PriceLabel, targetProdctId, "DevProduct", "%s")
			else
				v67.Buy.Label.PriceLabel.Text = "FREE"
			end

			updateText() -- equivalent call inferred; original call site unknown
		end

		clone.Buy.Label.PriceLabel:GetPropertyChangedSignal("Text"):Connect(updateText)
		clone.Buy.Label.UIStroke:GetPropertyChangedSignal("Thickness"):Connect(updateText)
		clone:GetAttributeChangedSignal("TargetProdctId"):Connect(updateProduct)
		task.spawn(updateText)
		task.spawn(updateProduct)
		clones[i] = clone
	end

	local v65 = nil

	local function updateSlots()
		local thread = coroutine.running()

		if v65 and coroutine.status(v65) == "suspended" and thread ~= v65 then
			v8.Thread.SafeCancel(v65)
		end

		v65 = thread
		local expect = v58:GetExpect("ProgressiveRewards.Claimed")
		local v66 = #expect + 1
		local v67 = v58:Get("ProgressiveRewards.Rewards")

		if not v67 or #v67 == 0 then
			return
		end

		uIPageLayout:JumpToIndex(v66 % 6)
		local currentPage = uIPageLayout.CurrentPage
		local name = currentPage and tonumber(currentPage.Name) or 1
		local v68 = {}
		local v69 = {}

		for i = 1, 6 do
			local v70 = i - 2
			local v71 = (name + v70 - 1) % 6 + 1
			local v72 = math.max(v66 + v70, 1)
			local v73 = clones[v71]
			local v74 = expect[v72]
			local v75 = not v74 and v72 <= v66
			v73.Buy.Image = v75 and "rbxassetid://18453026315" or "rbxassetid://18468467098"
			v73.Buy.HoverImage = v75 and "rbxassetid://18453540357" or "rbxassetid://18468473058"

			if not v74 and v72 <= v66 then
				v64 = false

				if robux.Visible and shop.Enabled and not v64 then
					v8.Sounds:Play("SummerPackPurchase")
					task.delay(0.1, v8.Sounds.Play, v8.Sounds, "SummerPackScroll")
				end
			end

			v63[v73] = v72
			v68[i] = v72
			v69[i] = v73
		end

		task.wait(uIPageLayout.TweenTime)

		if thread ~= v65 then
			return
		end

		for i = 1, 6 do
			local v70 = v68[i]
			local v71 = v69[i]
			local v72 = v67[math.clamp(v70, 1, #v67)]
			local reward = v72 and v24.RewardsList[v72.Type][v72.Index].Reward

			if v72 then
				v71:SetAttribute("TargetProdctId", v24.ProductIds[v72.Type])
				v71.Vector.Image = reward.Icon or ""
				local label = v71.Label
				local text

				if reward.Type == "Ability" then
					text = `{reward.DisplayName}\nPERMANENT`
				else
					text = reward.DisplayName
				end

				label.Text = text
			else
				v71.Vector.Image = ""
				v71.Label.Text = "???"
			end
		end
	end

	v58:OnChange("ProgressiveRewards.Rewards", updateSlots)
	v58:OnChange("ProgressiveRewards.Claimed", updateSlots)
	task.spawn(updateSlots)
	local timer = summerPack.Main.Timer
	local blackFridaySale = robux.BlackFridaySale
	v8.Thread.Every(1, function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v66 = v58:Get("ProgressiveRewards.LastReset")
		timer.Text = not v66 and "" or `{v8.ValueConvertor:FormatTimeHHMMSS(v66 + v24.ResetTime - workspace:GetServerTimeNow())}`
		local instantFFlag = v8.FFlag.GetInstantFFlag("BlackFridaySaleEndTime", 0)
		blackFridaySale.Visible = serverTimeNow < instantFFlag and v8.FFlag.GetInstantFFlag("BlackFridaySaleEnabled") == true
		blackFridaySale.Timer.Text = v8.ValueConvertor:FormatTimeWithDaysFull(instantFFlag - serverTimeNow)
	end)

	local function deactivateMultiDelete()
		if not self._multiDelete then
			return
		end

		local clone = table.clone(self._multiDelete)
		self._multiDelete = nil
		self:_updateMultiDeleteVisbility()
		self:_updateMultiDelete()

		for k, v66 in clone do
			for k2 in v66 do
				self:_updateItemStatus(k, client:KeyToItem(k2).Name, k2)
			end
		end

		if self._selectedItem and self._selectedItem.type == "Sword" then
			self:Select(self._selectedItem, true)
		end
	end

	local function activateMultiDelete()
		if self._multiDelete then
			deactivateMultiDelete()
		end

		self._multiDelete = {
			Sword = {},
			Explosion = {}
		}
		self:_updateMultiDeleteVisbility()
	end

	holder.Delete.Activated:Connect(function()
		if self._multiDelete then
			deactivateMultiDelete()
		else
			activateMultiDelete()
		end
	end)
	holder.DeleteItems.List.Buttons.Cancel.Activated:Connect(function()
		deactivateMultiDelete()
	end)
	holder.DeleteItems.List.Buttons.Delete.Activated:Connect(function()
		if not self._multiDelete then
			return
		end

		local v66 = {}
		local total = 0

		for k, v67 in self._multiDelete do
			v66[k] = {}

			for _, v68 in v67 do
				total += #v68

				for _, v69 in v68 do
					table.insert(v66[k], v69)
				end
			end
		end

		v31:PromptConfirmation({
			PromptType = "Single",
			Description = `Are you sure you want to delete x{total} items? This cannot be undone.`
		}, function(p, p2: string?)
			if p then
				local v67, v68 = v2:Invoke("RequestDelete", v66)

				if not v67 and v68 then
					v26:SendNotification(v68)
				end

				deactivateMultiDelete()
			elseif p2 then
				v26:SendNotification(p2)
			end
		end)
	end)
	holder.InfoBG.Delete.Activated:Connect(function()
		local _selectedItem = self._selectedItem

		if not (_selectedItem and _selectedItem.key) then
			return
		end

		local _canDelete, v66 = self:_canDelete(_selectedItem.type, _selectedItem.key)

		if _canDelete then
			local v67 = v29[_selectedItem.type][_selectedItem.name]
			local displayName = v67 and v67.DisplayName or _selectedItem.name
			local formatted = `x1 {displayName}`
			local promptType

			if #client:FindItemsWithKey(_selectedItem.type, _selectedItem.key) > 1 then
				formatted = displayName
				promptType = "Selector"
			else
				promptType = "Single"
			end

			v31:PromptConfirmation({
				PromptType = promptType,
				Description = `Are you sure you want to delete {formatted}? This cannot be undone.`,
				InventoryType = _selectedItem.type,
				ItemKey = _selectedItem.key
			}, function(p, p2: string?)
				if p then
					if self._selectedItem and self._selectedItem.type == "Sword" then
						self:Select(self._selectedItem, true)
					end
				elseif p2 then
					v26:SendNotification(p2)
				end
			end)
		elseif v66 then
			v26:SendNotification(v66)
		end
	end)
	remoteEvent4.OnClientEvent:Connect(function(value)
		if type(value) ~= "number" or value < 0 then
			return
		end

		ReplicatedStorage2.Misc.error:Play()
		v26:SendNotification("Not enough coins!")
		self:Open()
		ShopController:GoTo("Robux")
		local coinReward = 1e999
		local v66 = nil
		local name = nil

		for k, v68 in v29.DevProduct do
			if not (v68.CoinReward and value <= v68.CoinReward and v68.CoinReward < coinReward) then
				continue
			end

			coinReward = v68.CoinReward
			name = k
			v66 = v68
		end

		if not v66 then
			local coinReward2 = 0

			for k, v68 in v29.DevProduct do
				if not (v68.CoinReward and coinReward2 < v68.CoinReward) then
					continue
				end

				coinReward2 = v68.CoinReward
				name = k
				v66 = v68
			end
		end

		if v66 then
			self:Select({
				type = "DevProduct",
				name = name,
				data = {
					productId = v66.ProductId,
					displayName = v66.DisplayName,
					image = v66.Icon,
					imageColor = Color3.fromRGB(255, 255, 255),
					description = v66.Description
				}
			})
		end
	end)

	if not v58:Get("HasInteractedWithTrading") then
		local connection = nil
		connection = v58:OnChange("HasInteractedWithTrading", function()
			connection:Disconnect()

			for k, _virtualItem in self._virtualItems do
				for k2, v66 in _virtualItem do
					local name = v66.Name

					if name == k2 then
						k2 = nil
					end

					self:_updateItemStatus(k, name, k2)
				end
			end
		end)
	end

	local v66 = RunService:IsStudio() and true

	local function sortShopByProductRank(p: number)
		local v67 = {}

		for _, id in v43 do
			table.insert(v67, {
				Id = id,
				InfoType = Enum.InfoType.Product
			})
		end

		for _, id in v44 do
			table.insert(v67, {
				Id = id,
				InfoType = Enum.InfoType.GamePass
			})
		end

		local success, result = pcall(function()
			return v17:RankProductsAsync(v67)
		end)

		if not success or typeof(result) ~= "table" then
			warn((`MarketplaceService:RankProductsAsync() failed: {result}`))
			return
		end

		if p ~= productRankSortGeneration then
			return
		end

		local v68 = {}

		for k, v69 in result do
			v68[v69.ProductIdentifier.Id] = k
		end

		for childName, v69 in v44 do
			local child = robux.Items:FindFirstChild(childName)

			if child then
				child.LayoutOrder = v68[v69] or 1
			end
		end

		local v69 = "SmallCoins"

		for k, v70 in v43 do
			if (v68[v70] or 1) < (v68[v43[v69]] or 1) then
				v69 = k
			end
		end

		local child = robux.Items:FindFirstChild(v69)

		for childName, _ in v43 do
			local child2 = robux.Items:FindFirstChild(childName)

			if child2 and child2 ~= child then
				child2.LayoutOrder += 100
			end
		end

		child.LayoutOrder = 90
	end

	local layoutOrdersByButton = {}
	local count = 0
	local v67 = false

	local function captureOriginalLayoutOrders()
		for _, button in robux.Items:GetChildren() do
			if button:IsA("GuiButton") then
				layoutOrdersByButton[button] = button.LayoutOrder
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function revertProductRankSorting()
		for k, layoutOrder in layoutOrdersByButton do
			k.LayoutOrder = layoutOrder
		end
	end

	local function setProductRankSorting(flag: boolean)
		if v67 == flag then
			return
		end

		v67 = flag
		count += 1
		local v68 = count

		if flag then
			if next(layoutOrdersByButton) == nil then
				captureOriginalLayoutOrders()
			end

			task.spawn(function()
				sortShopByProductRank(v68)
			end)
		else
			revertProductRankSorting() -- equivalent call inferred; original call site unknown
		end
	end

	local v68 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateProductRankSorting()
		local shopProductIntelligence = localPlayer:GetAttribute("ShopProductIntelligence") == true
		setProductRankSorting(shopProductIntelligence or v68)
	end

	local function runExperiments(object2)
		local v69 = object2:Get({ "Configs", "ShopProductRankSorting" }) == true
		local v70 = object2:Get({ "Configs", "CombinedShopProductRankSorting" }) == true
		v68 = v69 or v70 or v66
		updateProductRankSorting() -- equivalent call inferred; original call site unknown
	end

	local v69 = {}

	local function observeConfigReplion(object2)
		if v69[object2] then
			return
		end

		v69[object2] = true
		runExperiments(object2)
		object2:OnChange({ "Configs", "ShopProductRankSorting" }, function()
			runExperiments(object2)
		end)
		object2:OnChange({ "Configs", "CombinedShopProductRankSorting" }, function()
			runExperiments(object2)
		end)
	end

	task.spawn(function()
		local v70 = v.Client:WaitReplion(`{localPlayer.Name}_Configs`, 60)

		if v70 then
			observeConfigReplion(v70)
		end
	end)
	v.Client:OnReplionAddedWithTag("PlayerConfigs", observeConfigReplion)
	localPlayer:GetAttributeChangedSignal("ShopProductIntelligence"):Connect(updateProductRankSorting)
	setProductRankSorting(localPlayer:GetAttribute("ShopProductIntelligence") == true or v68)
end

return ShopController