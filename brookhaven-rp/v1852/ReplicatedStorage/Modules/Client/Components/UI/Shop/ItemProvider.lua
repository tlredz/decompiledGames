local ItemProvider = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ThemesMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.ThemesMenu)
local EmmitersConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Emmiters.EmmitersConfig)
local FacesConfig = require(ReplicatedStorage.Modules.Shared.DB.AvatarEditor.Faces.FacesConfig)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Houses = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Houses)
local Mansions = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Mansions)
local Apartments = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Apartments)
local Motels = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Motels)
local Props = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Props)
local DatabaseRemoteConfigController = require(ReplicatedStorage.Modules.Client.Databases.DatabaseRemoteConfigController)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
local AirVehiclesConfig = require(ReplicatedStorage.Modules.Shared.DB.Vehicles.AirVehiclesConfig)
local GamepassIconItem = require(ReplicatedStorage.Modules.Shared.Item.GamepassIconItem)
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local RobloxPlusItem = require(ReplicatedStorage.Modules.Shared.Item.Items.RobloxPlusItem)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Purchasable = require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)

local function isFeatureFlagEligible(name: string)
	if FeatureFlagsConfig.HasFeatureFlag(name) then
		return FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(Players.LocalPlayer, name)
	end

	return true
end

local values = {}

local function memoise(callback)
	return function()
		local v = values[callback]

		if v ~= nil then
			return v
		end

		local frozen = table.freeze(callback())
		values[callback] = frozen
		return frozen
	end
end

local function invalidateMemoised()
	table.clear(values)
end

FeatureFlagsConfig.OverrideChanged:Connect(invalidateMemoised)
DatabaseRemoteConfigController.OnLoaded:Connect(invalidateMemoised)

function concat(...)
	local result = {}

	for _, v in pairs({ ... }) do
		if typeof(v) == "table" then
			for _, v2 in pairs(v) do
				table.insert(result, v2)
			end
		else
			table.insert(result, v)
		end
	end

	return result
end

function iconChild(instance)
	return instance:WaitForChild("Icon").Image
end

function forThoseWithChild(instance, childName: string?, callback)
	local result = {}

	for _, guiObject in instance:GetChildren() do
		if not (guiObject:IsA("GuiObject") and (childName == nil or guiObject:FindFirstChild(childName))) then
			continue
		end

		local v = callback(guiObject)

		if v ~= nil then
			table.insert(result, v)
		end
	end

	return result
end

function itemDirectGamepass(p)
	return function(object)
		if Object.InstanceOf(object, GamepassIconItem) and Purchasable.equals(object:GetPurchasable(), p) then
			return isFeatureFlagEligible(object:GetName())
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

function itemId(callback)
	return function(p)
		local item = ItemRegistry.GetItem(p.Item, MenuItem)

		if item == nil then
			return callback(p)
		end

		return item:GetIcon()
	end
end

function idImage(p)
	return "rbxassetid://" .. p.Id
end

function thumbImage(p)
	return "rbxthumb://type=Asset&id=" .. p.Id .. "&w=150&h=150"
end

function dict(items, p, callback)
	local result = {}

	for _, item in items do
		if p == nil or item[p] then
			table.insert(result, callback(item))
		end
	end

	return result
end

function dictConditional(items, callback, callback2)
	local result = {}

	for _, item in items do
		if not (callback == nil or callback(item)) then
			continue
		end

		local v = callback2(item)

		if v ~= nil then
			table.insert(result, v)
		end
	end

	return result
end

local noResetGUIHandler = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler")
local v = {}

v[Gamepasses.LAND_UNLOCKED] = function()
	return {}
end

local function fn()
	return concat(
		"rbxassetid://100959256729360",
		"rbxassetid://139496375095588",
		"rbxassetid://76731593209797",
		"rbxassetid://101553452808997",
		"rbxassetid://76001977186770",
		"rbxassetid://18458871100",
		"rbxassetid://126585529306767",
		"rbxassetid://120894800956292",
		"rbxassetid://131241276817540",
		"rbxassetid://76621375283356",
		"rbxassetid://98371975608304",
		"rbxassetid://118673865490720",
		"rbxassetid://129042354594354",
		"rbxassetid://127261437671103",
		dictConditional(
			ItemRegistry.GetRegistry(ItemRegistry.EMOTES_REGISTRY),
			itemDirectGamepass(Purchasable.ofGamepass(Gamepasses.VIP)),
			function(object)
				return object:GetIcon()
			end
		),
		dictConditional(AirVehiclesConfig.GetConfig(), function(p)
			return p.PassRequired == "VIP"
		end, function(p)
			return "rbxassetid://" .. p.Icon
		end),
		dictConditional(
			ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
			itemDirectGamepass(Purchasable.ofGamepass(Gamepasses.VIP)),
			function(object)
				return object:GetIcon()
			end
		),
		dict(Motels.Entries, "IsVIP", function(p)
			return p.Icon
		end),
		"rbxassetid://133569784195609",
		"rbxassetid://82694778975202",
		dictConditional(Props.Entries, itemRegistryGamepass(Purchasable.ofGamepass(Gamepasses.VIP), function(p)
			return p.PropVIP and not p.IsCategory
		end), itemId(idImage)),
		dictConditional(
			ToolsConfig.GetConfig(),
			itemRegistryGamepass(Purchasable.ofGamepass(Gamepasses.VIP), function(_)
				return false
			end),
			itemId(idImage)
		),
		dict(EmmitersConfig.getConfig(), "EmmitersVIP", thumbImage)
	)
end

v[Gamepasses.VIP] = function()
	local v2 = values[fn]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn())
	values[fn] = frozen
	return frozen
end

local function fn2()
	return concat(
		dictConditional(Houses.Entries, itemRegistryGamepass(Purchasable.ofGamepass(Gamepasses.PREMIUM), function(p)
			local name = p.Name

			if not FeatureFlagsConfig.HasFeatureFlag(name) or FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
				Players.LocalPlayer,
				name
			) then
				return p.IsPremium
			end

			return false
		end), itemId(function(p)
			return p.Icon
		end)),
		dictConditional(AirVehiclesConfig.GetConfig(), function(p)
			return p.PassRequired == "PREMIUM"
		end, function(p)
			return "rbxassetid://" .. p.Icon
		end),
		dictConditional(
			ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
			itemDirectGamepass(Purchasable.ofGamepass(Gamepasses.PREMIUM)),
			function(object)
				return object:GetIcon()
			end
		),
		"rbxassetid://92977762957132",
		"rbxassetid://140310268016968",
		forThoseWithChild(
			noResetGUIHandler:WaitForChild("CharacterKidMenu"):WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollingFrameKid"),
			"Silver",
			iconChild
		)
	)
end

v[Gamepasses.PREMIUM] = function()
	local v2 = values[fn2]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn2())
	values[fn2] = frozen
	return frozen
end

local function fn3()
	return dict(Mansions.Entries, "Icon", function(p)
		return p.Icon
	end)
end

v[Gamepasses.ESTATES_UNLOCKED] = function()
	local v2 = values[fn3]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn3())
	values[fn3] = frozen
	return frozen
end

local function fn4()
	return dictConditional(
		ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
		itemDirectGamepass(Purchasable.ofGamepass(Gamepasses.VEHICLE_PACK)),
		function(object)
			return object:GetIcon()
		end
	)
end

v[Gamepasses.VEHICLE_PACK] = function()
	local v2 = values[fn4]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn4())
	values[fn4] = frozen
	return frozen
end

v[Gamepasses.VEHICLE_UPGRADE] = function()
	return { "rbxassetid://88739129268462", "rbxassetid://119126470594853" }
end

v[Gamepasses.VEHICLE_BOOST] = function()
	return { "rbxassetid://137895797019860" }
end

v[Gamepasses.VEHICLE_CUSTOMIZATION] = function()
	return {
		"rbxassetid://103468099703025",
		"rbxassetid://125064974876925",
		"rbxassetid://112213789255953",
		"rbxassetid://74858259229702",
		"rbxassetid://91324894339401",
		"rbxassetid://121275945400909",
		"rbxassetid://122747722576710",
		"rbxassetid://127104078794185",
		"rbxassetid://18960814905",
		"rbxassetid://18960840101",
		"rbxassetid://79703372821891",
		"rbxassetid://18961798522",
		"rbxassetid://18960285599",
		"rbxassetid://18960648032",
		"rbxassetid://81764797602193",
		"rbxassetid://85627548804523",
		"rbxassetid://76794199896693",
		"rbxassetid://18961959904",
		"rbxassetid://18961957514",
		"rbxassetid://18960464228",
		"rbxassetid://18960370909",
		"rbxassetid://18960349051",
		"rbxassetid://18960491426",
		"rbxassetid://18960221506",
		"rbxassetid://18960193045",
		"rbxassetid://18960138794",
		"rbxassetid://18960400519",
		"rbxassetid://18960617838",
		"rbxassetid://130561808145174",
		"rbxassetid://99457814398953",
		"rbxassetid://18960876123",
		"rbxassetid://108870527383890",
		"rbxassetid://18950943949",
		"rbxassetid://18962032077",
		"rbxassetid://18960735963",
		"rbxassetid://18960739783",
		"rbxassetid://18961935268"
	}
end

v[Gamepasses.VEHICLE_SPEED_UNLOCKED] = function()
	return {
		"rbxassetid://74850247569401",
		"rbxassetid://120878910373409",
		"rbxassetid://97008178176394",
		"rbxassetid://104965443396499",
		"rbxassetid://75956902533796"
	}
end

v[Gamepasses.MUSIC_UNLOCKED] = function()
	return { "rbxassetid://138321289086920", "rbxassetid://74462652160109", "rbxassetid://113077324050977" }
end

local function fn5()
	return dict(Apartments.Entries, "IsPenthouse", function(p)
		return p.Icon
	end)
end

v[Gamepasses.PENTHOUSE] = function()
	local v2 = values[fn5]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn5())
	values[fn5] = frozen
	return frozen
end

local function fn6()
	return forThoseWithChild(ThemesMenu:GetAll()[1].Instance, "ThemePass", iconChild)
end

v[Gamepasses.THEME_PASS] = function()
	local v2 = values[fn6]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn6())
	values[fn6] = frozen
	return frozen
end

local function fn7()
	return dictConditional(
		ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
		itemDirectGamepass(Purchasable.ofGamepass(Gamepasses.BOAT_PACK)),
		function(object)
			return object:GetIcon()
		end
	)
end

v[Gamepasses.BOAT_PACK] = function()
	local v2 = values[fn7]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn7())
	values[fn7] = frozen
	return frozen
end

local function fn8()
	return dict(FacesConfig.getConfig(), "FacePass", thumbImage)
end

v[Gamepasses.FACES_UNLOCKED] = function()
	local v2 = values[fn8]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn8())
	values[fn8] = frozen
	return frozen
end

local function fn9()
	return concat(
		dictConditional(
			ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
			itemDirectGamepass(Purchasable.ofGamepass(Gamepasses.HORSE_UNLOCKED)),
			function(object)
				return object:GetIcon()
			end
		),
		"http://www.roblox.com/asset/?id=5452054609",
		"http://www.roblox.com/asset/?id=5452056985",
		"http://www.roblox.com/asset/?id=5452058066",
		"http://www.roblox.com/asset/?id=5452053206"
	)
end

v[Gamepasses.HORSE_UNLOCKED] = function()
	local v2 = values[fn9]

	if v2 ~= nil then
		return v2
	end

	local frozen = table.freeze(fn9())
	values[fn9] = frozen
	return frozen
end

v[Gamepasses.DISASTER_PASS] = function()
	return {
		"rbxassetid://107819235032307",
		"rbxassetid://115437775829092",
		"rbxassetid://124660716830146",
		"rbxassetid://121268470628745",
		"rbxassetid://96446558912810",
		"rbxassetid://133532719257070",
		"rbxassetid://90830353101693",
		"rbxassetid://106034275314484",
		"rbxassetid://136481971252275",
		"rbxassetid://118581817590340",
		"rbxassetid://117091071030121",
		"rbxassetid://133673577215705",
		"rbxassetid://130474044584681"
	}
end

v[Gamepasses.ON_DEMAND_FIRE] = function()
	return { "rbxassetid://120550119274307" }
end

v[Gamepasses.HOUSE_AND_MOTORCYCLE] = function()
	return concat(dictConditional(Houses.Entries, function(p)
		return p.Item ~= nil and ItemRegistry.GetItem(p.Item, RobloxPlusItem) ~= nil
	end, itemId(function(p)
		return p.Icon
	end)), dictConditional(ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY), function(p)
		return Object.InstanceOf(p, RobloxPlusItem)
	end, function(object)
		return object:GetIcon()
	end))
end

local v2 = {
	[DevProducts.CHRISTMAS_2025_BUNDLE] = function()
		return concat(
			dictConditional(
				Houses.Entries,
				itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.CHRISTMAS_2025_BUNDLE), function(_)
					return false
				end),
				itemId(function(p)
					return p.Icon
				end)
			),
			dictConditional(
				itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.CHRISTMAS_2025_BUNDLE), function(_)
					return false
				end),
				itemId(function(p)
					return "rbxassetid://" .. p.Icon
				end)
			)
		)
	end,
	[DevProducts.PREMIUM_1] = v[Gamepasses.PREMIUM],
	[DevProducts.PREMIUM_2] = v[Gamepasses.PREMIUM],
	[DevProducts.PREMIUM_3] = v[Gamepasses.PREMIUM],
	[DevProducts.PREMIUM_4] = v[Gamepasses.PREMIUM]
}

local function fn10()
	return concat(
		dictConditional(
			Houses.Entries,
			itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.EASTER_2026_SPRING_HOUSE), function(_)
				return false
			end),
			itemId(function(p)
				return p.Icon
			end)
		),
		dictConditional(
			ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
			itemDirectGamepass(Purchasable.ofDevProduct(DevProducts.EASTER_2026_SPRING_HOUSE)),
			function(object)
				return object:GetIcon()
			end
		),
		dictConditional(
			Props.Entries,
			itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.EASTER_2026_SPRING_HOUSE), function(_)
				return false
			end),
			itemId(idImage)
		)
	)
end

v2[DevProducts.EASTER_2026_SPRING_HOUSE] = function()
	local v3 = values[fn10]

	if v3 ~= nil then
		return v3
	end

	local frozen = table.freeze(fn10())
	values[fn10] = frozen
	return frozen
end

local function fn11()
	return concat(
		dictConditional(
			Houses.Entries,
			itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.SUMMER_2026_HOUSE), function(_)
				return false
			end),
			itemId(function(p)
				return p.Icon
			end)
		),
		dictConditional(
			ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
			itemDirectGamepass(Purchasable.ofDevProduct(DevProducts.SUMMER_2026_HOUSE)),
			function(object)
				return object:GetIcon()
			end
		),
		v[Gamepasses.PREMIUM]()
	)
end

v2[DevProducts.SUMMER_2026_PREMIUM_BUNDLE] = function()
	local v3 = values[fn11]

	if v3 ~= nil then
		return v3
	end

	local frozen = table.freeze(fn11())
	values[fn11] = frozen
	return frozen
end

local function fn12()
	return concat(
		dictConditional(
			Houses.Entries,
			itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.SUMMER_2026_HOUSE), function(_)
				return false
			end),
			itemId(function(p)
				return p.Icon
			end)
		),
		dictConditional(
			ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
			itemDirectGamepass(Purchasable.ofDevProduct(DevProducts.SUMMER_2026_HOUSE)),
			function(object)
				return object:GetIcon()
			end
		)
	)
end

v2[DevProducts.SUMMER_2026_HOUSE] = function()
	local v3 = values[fn12]

	if v3 ~= nil then
		return v3
	end

	local frozen = table.freeze(fn12())
	values[fn12] = frozen
	return frozen
end

local function fn13()
	return concat(
		dictConditional(
			Houses.Entries,
			itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.MILITARY_ROLEPLAY_BUNDLE), function(_)
				return false
			end),
			itemId(function(p)
				return p.Icon
			end)
		),
		dictConditional(
			ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY),
			itemDirectGamepass(Purchasable.ofDevProduct(DevProducts.MILITARY_ROLEPLAY_BUNDLE)),
			function(object)
				return object:GetIcon()
			end
		),
		dictConditional(
			ToolsConfig.GetConfig(),
			itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.MILITARY_ROLEPLAY_BUNDLE), function(_)
				return false
			end),
			itemId(idImage)
		),
		dictConditional(
			Props.Entries,
			itemRegistryGamepass(Purchasable.ofDevProduct(DevProducts.MILITARY_ROLEPLAY_BUNDLE), function(_)
				return false
			end),
			itemId(idImage)
		)
	)
end

v2[DevProducts.MILITARY_ROLEPLAY_BUNDLE] = function()
	local v3 = values[fn13]

	if v3 ~= nil then
		return v3
	end

	local frozen = table.freeze(fn13())
	values[fn13] = frozen
	return frozen
end

local v3 = {}

function ItemProvider.GetItemsCountable(p)
	local v4 = v3[p]

	if v4 == nil then
		return {}
	end

	return v4()
end

function ItemProvider.GetItemsPurchasable(object)
	local gamepass = object:ToGamepass()

	if gamepass == nil then
		local devProduct = object:ToDevProduct()

		if devProduct == nil then
			error("illegal state")
			return
		end

		local v4 = v2[devProduct]

		if v4 == nil then
			return {}
		end

		return v4()
	else
		local v4 = v[gamepass]

		if v4 == nil then
			return {}
		end

		return v4()
	end
end

return ItemProvider