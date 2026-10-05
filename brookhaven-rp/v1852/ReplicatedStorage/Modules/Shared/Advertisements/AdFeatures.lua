local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local Houses = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Houses)
local Mansions = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Mansions)
local Motels = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Motels)
local Landmarks = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Landmarks)
local EmotesConfig = require(ReplicatedStorage.Modules.Shared.DB.Emotes.EmotesConfig)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Props = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Props)
local Apartments = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Apartments)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local GamepassIconItem = require(ReplicatedStorage.Modules.Shared.Item.GamepassIconItem)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
local LotConfig = require(ReplicatedStorage.Modules.Shared.DB.Housing.LotConfig)
local PetsConfig = require(ReplicatedStorage.Modules.Shared.DB.Pets.PetsConfig)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
local BakingConfig = require(ReplicatedStorage.Modules.Shared.Housing.Baking.BakingConfig)
local AdFeatures = {}

function concat(...)
	local result = {}

	for _, v in pairs({ ... }) do
		if v.id then
			table.insert(result, v)
		else
			for _, v2 in pairs(v) do
				table.insert(result, v2)
			end
		end
	end

	return result
end

function forThoseWithChild(instance, childName: string?, callback)
	local result = {}

	for _, guiObject in instance:GetChildren() do
		if not (guiObject:IsA("GuiObject") and (childName == nil or guiObject:FindFirstChild(childName))) then
			continue
		end

		local v = callback(guiObject)
		result[v.id] = v
	end

	return result
end

function dict(items, p, callback)
	local result = {}

	for _, item in items do
		if not (p == nil or item[p]) then
			continue
		end

		local v = callback(item)
		result[v.id] = v
	end

	return result
end

function dictConditional(items, callback, callback2)
	local result = {}

	for k, item in items do
		if not (callback == nil or callback(item)) then
			continue
		end

		local v = callback2(item, k)

		if v ~= nil then
			result[v.id] = v
		end
	end

	return result
end

function itemAdFeature(callback)
	return function(p)
		local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
		local item = ItemRegistry.GetItem(p.Item, DisplayItem)

		if item == nil then
			return callback(p)
		end

		return item:GetAdFeature()
	end
end

function itemDirectGamepass(object)
	return function(object2)
		if Object.InstanceOf(object2, GamepassIconItem) then
			local purchasable = object2:GetPurchasable()

			if object == nil and purchasable ~= nil or object ~= nil and object:Equals(purchasable) then
				return not FeatureFlagsConfig.HasFeatureFlag(object2:GetName())
			end
		end

		return false
	end
end

function itemRegistryAds(callback)
	return function(p)
		if not p.Item then
			return callback(p)
		end

		local v = assert(ItemRegistry.GetItem(p.Item, Item), "unknown item " .. p.Item)
		local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)

		if Object.InstanceOf(v, DisplayItem) and v:GetAdFeature() ~= nil then
			return not FeatureFlagsConfig.HasFeatureFlag(v:GetName())
		end

		return false
	end
end

function itemRegistryGamepass(p, callback)
	return function(p2)
		if p2.Item and itemDirectGamepass(p)(assert(ItemRegistry.GetItem(p2.Item, Item), "unknown item " .. p2.Item)) then
			return true
		end

		return callback(p2)
	end
end

function AdFeatures.Houses()
	return dictConditional(Houses.Entries, function(p)
		if p.IsRobuxPass == true then
			return true
		end

		return itemRegistryGamepass(Purchasable.ofGamepass(Gamepasses.PREMIUM), function(p2)
			return p2.IsPremium
		end)(p)
	end, itemAdFeature(function(p)
		return {
			icon = p.Icon,
			category = "HOUSE",
			gamepass = Gamepasses.PREMIUM,
			id = p.Name
		}
	end))
end

function AdFeatures.HasAdReleaseElapsed(p: number?)
	return p == nil or p <= DateTime.now().UnixTimestamp
end

function AdFeatures.Lots()
	local v = {
		Lot_27 = "rbxassetid://99003567633300",
		Lot_28 = "rbxassetid://79528768436499",
		Lot_29 = "rbxassetid://119436498144399",
		Lot_30 = "rbxassetid://127354118293067",
		Lot_31 = "rbxassetid://99132953138371",
		Lot_32 = "rbxassetid://122037266870411",
		Lot_36 = "rbxassetid://78609128569933",
		Lot_39 = "rbxassetid://140279160656489"
	}
	return dictConditional(LotConfig.GetConfig(), function(p)
		return p.Gamepasses and table.find(p.Gamepasses, Gamepasses.GetName(Gamepasses.LAND_UNLOCKED)) and AdFeatures.HasAdReleaseElapsed(p.AdReleaseTimestamp)
	end, function(_, id)
		return {
			icon = v[id],
			category = "HOUSE",
			gamepass = Gamepasses.LAND_UNLOCKED,
			id = id
		}
	end)
end

function AdFeatures.Pets()
	return dictConditional(PetsConfig.GetConfig(), function(p)
		return typeof(p) == "table" and PetsConfig.GetRequiredGamepass(p) ~= nil and AdFeatures.HasAdReleaseElapsed(p.AdReleaseTimestamp)
	end, function(p)
		return {
			icon = p.Icon,
			category = "PERK",
			gamepass = PetsConfig.GetRequiredGamepass(p),
			id = p.Name
		}
	end)
end

function AdFeatures.Motels()
	return dict(Motels.Entries, "IsVIP", function(p)
		return {
			icon = p.Icon,
			category = "HOUSE",
			gamepass = Gamepasses.VIP,
			id = p.Name
		}
	end)
end

function AdFeatures.Landmarks()
	return dictConditional(Landmarks.Entries, function(p)
		return p.IsRobuxPass == true
	end, itemAdFeature(function(p)
		return {
			icon = p.Icon,
			category = "HOUSE",
			gamepass = Gamepasses.PRISON_LANDMARK,
			id = p.Name
		}
	end))
end

function AdFeatures.Penthouses()
	return dict(Apartments.Entries, "IsPenthouse", function(p)
		return {
			icon = p.Icon,
			category = "HOUSE",
			gamepass = Gamepasses.PENTHOUSE,
			id = p.Name
		}
	end)
end

function AdFeatures.Estates()
	return dictConditional(
		Mansions.Entries,
		itemRegistryGamepass(Purchasable.ofGamepass(Gamepasses.ESTATES_UNLOCKED), function(_)
			return true
		end),
		itemAdFeature(function(p)
			return {
				icon = p.Icon,
				category = "HOUSE",
				gamepass = Gamepasses.ESTATES_UNLOCKED,
				id = p.Name
			}
		end)
	)
end

function AdFeatures.Emotes()
	local result = {}

	for k, icon in {
		Griddy = "rbxassetid://126585529306767",
		Deathdrop = "rbxassetid://120894800956292",
		Duckwalk = "rbxassetid://131241276817540",
		Lean = "rbxassetid://129042354594354",
		Twirl = "rbxassetid://98371975608304",
		["Blow Kiss"] = "rbxassetid://118673865490720",
		Serving = "rbxassetid://76621375283356",
		["67"] = "rbxassetid://127261437671103"
	} do
		for _, v2 in EmotesConfig.GetConfig() do
			if v2.Name == k then
				result[v2.Name] = {
					icon = icon,
					id = "Emote_$" .. v2.Name,
					gamepass = Gamepasses.VIP,
					category = "PERK"
				}
			end
		end
	end

	local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)

	for _, v in ItemRegistry.GetRegistry(ItemRegistry.EMOTES_REGISTRY) do
		if not Object.InstanceOf(v, DisplayItem) then
			continue
		end

		local adFeature = v:GetAdFeature()

		if adFeature then
			result[v:GetName()] = adFeature
		end
	end

	return result
end

function AdFeatures.Vehicles()
	local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
	return dictConditional(ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY), function(_)
		return true
	end, function(object)
		if Object.InstanceOf(object, DisplayItem) then
			return object:GetAdFeature()
		end

		return nil
	end)
end

function AdFeatures.Themes()
	local ThemesMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.ThemesMenu)
	return forThoseWithChild(ThemesMenu:GetAll()[1].Instance, "ThemePass", function(instance)
		return {
			icon = instance:WaitForChild("Icon").Image,
			category = "THEME",
			gamepass = Gamepasses.THEME_PASS,
			id = "ThemePass" .. instance.Name
		}
	end)
end

function AdFeatures.Props()
	return dictConditional(Props.Entries, itemRegistryAds(function(data)
		return data.PropVIP and not (data.IsCategory or data.RequirementBehaviorData)
	end), itemAdFeature(function(p)
		return {
			icon = "rbxassetid://" .. p.Id,
			category = "PROP",
			gamepass = Gamepasses.VIP,
			id = "Prop_" .. p.Name
		}
	end))
end

function AdFeatures.Tools()
	return dictConditional(ToolsConfig.GetConfig(), itemRegistryAds(function(_)
		return false
	end), function(data)
		local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
		local item = ItemRegistry.GetItem(data.Item, DisplayItem)

		if item == nil then
			return nil
		end

		local adFeature = item:GetAdFeature()

		if adFeature == nil then
			return nil
		end

		local icon = data.Icon

		if icon == nil or icon == "" then
			icon = adFeature.icon
		end

		if icon == nil or icon == "" then
			icon = BakingConfig.GetIconForToolName(data.Name)
		end

		adFeature.icon = icon
		return adFeature
	end)
end

function AdFeatures.IsOwned(p)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)

	if p.id == "CarEffects" then
		return UnlockableController.IsFeatureUnlocked("CarEffects", Gamepasses.VEHICLE_CUSTOMIZATION) or GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM)
	end

	if p.id == "ChangeCarColor" then
		return UnlockableController.IsFeatureUnlocked("ChangeCarColor", Gamepasses.VEHICLE_UPGRADE) or GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) or GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) or GamepassController.IsOwnedLegacy(Gamepasses.VEHICLE_UPGRADE)
	end

	return UnlockableController.IsFeatureUnlocked(p.id) or AdFeatures.IsProductOwned(p)
end

function AdFeatures.GetPurchasable(p)
	if p.gamepass ~= nil then
		return Purchasable.ofGamepass(p.gamepass)
	end

	local v = assert(p.devProduct, "ad feature has neither a gamepass nor a dev product")
	return Purchasable.ofDevProduct(v)
end

function AdFeatures.IsProductOwned(p)
	if p.gamepass ~= nil then
		local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
		return GamepassController.IsOwned(p.gamepass)
	end

	if p.devProduct == nil then
		return false
	end

	local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
	return DevProductController.IsOwned(p.devProduct)
end

AdFeatures.HORSE_FEATURES = {
	icon = "rbxassetid://129851018609249",
	id = "HorseFeatures",
	gamepass = Gamepasses.HORSE_UNLOCKED,
	category = "PERK"
}
AdFeatures.VEHICLE_SPEED_UPGRADE = {
	icon = "rbxassetid://119126470594853",
	id = "CarSpeed",
	gamepass = Gamepasses.VEHICLE_UPGRADE,
	category = "PERK"
}
AdFeatures.VEHICLE_SPEED_MAX = {
	icon = "rbxassetid://74850247569401",
	id = "CarSpeed200",
	gamepass = Gamepasses.VEHICLE_SPEED_UNLOCKED,
	category = "PERK"
}
AdFeatures.VEHICLE_BOOST = {
	icon = "rbxassetid://137895797019860",
	id = "CarBoost",
	gamepass = Gamepasses.VEHICLE_BOOST,
	category = "PERK"
}
AdFeatures.VIP_HOUSE_COOLDOWN = {
	icon = "rbxassetid://139496375095588",
	id = "VIP_HOUSE_COOLDOWN",
	gamepass = Gamepasses.VIP,
	category = "PERK"
}
AdFeatures.VIP_JOB = {
	icon = "rbxassetid://5084437490",
	id = "VIP_JOB",
	gamepass = Gamepasses.VIP,
	category = "PERK"
}
AdFeatures.VIP_HOUSE_SIGN_EFFECT = {
	icon = "rbxassetid://139496375095588",
	id = "VIP_HOUSE_SIGN_EFFECT",
	gamepass = Gamepasses.VIP,
	category = "PERK"
}
AdFeatures.DISASTER_PASS = {
	icon = "rbxassetid://129011374501269",
	id = "Feature_DISASTER_PASS",
	gamepass = Gamepasses.DISASTER_PASS,
	category = "PERK"
}
AdFeatures.HOUSE_MUSIC = {
	icon = "rbxassetid://113599232709088",
	id = "HouseMusic",
	gamepass = Gamepasses.MUSIC_UNLOCKED,
	category = "PERK"
}
AdFeatures.CAR_MUSIC = {
	icon = "rbxassetid://123757228405223",
	id = "CarMusic",
	gamepass = Gamepasses.MUSIC_UNLOCKED,
	category = "PERK"
}
AdFeatures.PROP_MUSIC = {
	icon = "rbxassetid://113077324050977",
	id = "PropMusic",
	gamepass = Gamepasses.MUSIC_UNLOCKED,
	category = "PERK"
}
AdFeatures.TOOL_MUSIC = {
	icon = "rbxassetid://113077324050977",
	id = "ToolMusic",
	gamepass = Gamepasses.MUSIC_UNLOCKED,
	category = "PERK"
}
AdFeatures.CAR_COLOUR = {
	icon = "rbxassetid://139193464809192",
	id = "ChangeCarColor",
	gamepass = Gamepasses.VEHICLE_CUSTOMIZATION,
	category = "PERK"
}
AdFeatures.CAR_EFFECTS = {
	icon = "rbxassetid://95305822075886",
	id = "CarEffects",
	gamepass = Gamepasses.VEHICLE_CUSTOMIZATION,
	category = "PERK"
}
AdFeatures.AIR_VEHICLES = {
	icon = "rbxassetid://92977762957132",
	id = "AIR_VEHICLES",
	gamepass = Gamepasses.PREMIUM,
	category = "PERK"
}
AdFeatures.CHINOOK = {
	icon = "rbxassetid://117282238452885",
	id = "CHINOOK",
	gamepass = Gamepasses.VIP,
	category = "PERK"
}
AdFeatures.HOT_AIR_BALLOON = {
	icon = "rbxassetid://82220539053559",
	id = "HOT_AIR_BALLOON",
	gamepass = Gamepasses.VIP,
	category = "PERK"
}

function AdFeatures.All()
	local values = TableUtil.Values(AdFeatures.Vehicles())
	table.sort(values, function(a, b)
		local name = AdFeatures.GetPurchasable(a):GetName()
		local name2 = AdFeatures.GetPurchasable(b):GetName()

		if name == name2 then
			return a.id > b.id
		end

		return name2 < name
	end)
	return concat(
		AdFeatures.VEHICLE_SPEED_MAX,
		AdFeatures.VEHICLE_BOOST,
		AdFeatures.CAR_EFFECTS,
		AdFeatures.CAR_COLOUR,
		AdFeatures.CAR_MUSIC,
		AdFeatures.VIP_HOUSE_COOLDOWN,
		AdFeatures.DISASTER_PASS,
		AdFeatures.HOUSE_MUSIC,
		AdFeatures.PROP_MUSIC,
		AdFeatures.TOOL_MUSIC,
		AdFeatures.HORSE_FEATURES,
		AdFeatures.Pets(),
		AdFeatures.AIR_VEHICLES,
		AdFeatures.CHINOOK,
		AdFeatures.HOT_AIR_BALLOON,
		AdFeatures.Emotes(),
		AdFeatures.Lots(),
		AdFeatures.Houses(),
		AdFeatures.Estates(),
		AdFeatures.Penthouses(),
		AdFeatures.Motels(),
		AdFeatures.Landmarks(),
		values,
		AdFeatures.Props(),
		AdFeatures.Themes(),
		AdFeatures.Tools()
	)
end

return AdFeatures