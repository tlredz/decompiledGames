local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local store = ReplicatedStorage.Assets.Data.Store
local Data = require(modules.Data)
local Network = require(modules.Network)
local ShopUtil = require(modules.ShopUtil)
local Items = require(store.Items)
local Skins = require(store.Skins)
local Emotes = require(store.Emotes)
local Titles = require(store.Titles)
local Decoration = require(store.Decoration)
local Bundles = require(store.Bundles)
local localPlayer = Players.LocalPlayer

local function commaValue(p: number)
	return (string.format("%0.0f", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBundleByName(name: string)
	for _, bundle in Bundles do
		if bundle.Name == name then
			return bundle
		end
	end

	return nil
end

local FeaturedItemsUtility = {
	Handlers = {}
}
FeaturedItemsUtility.Handlers = {
	Item = {
		Resolve = function(_, p)
			local item = Items[p.Name]

			if not item then
				return nil
			end

			local price = item.Price or 0
			return {
				Display = item.Display or p.Name,
				Icon = item.Icon,
				RoundIcon = item.RoundIcon,
				Price = price,
				Description = item.Description or "A shop item.",
				Owned = ShopUtil:HasItem(p.Name),
				Equipped = Data.Inventory.Items[p.Name] ~= nil and Data.Inventory.Items[p.Name].Equipped == true
			}
		end,
		Purchase = function(_, p)
			Network:fire("Purchase", p.Name)
		end,
		Toggle = function(_, p)
			Network:fire("Equip", p.Name)
		end
	},
	Emote = {
		Resolve = function(_, p)
			local emote = Emotes[p.Name]

			if not emote then
				return nil
			end

			local price = emote.Price or 0
			local v = Data.Emotes:Get(p.Name)
			return {
				Display = emote.Display or p.Name,
				Price = price,
				Description = emote.Description or "An emote.",
				Owned = v ~= nil,
				Equipped = v ~= nil and v.Slot ~= nil,
				AnimationId = tostring(emote.AnimationId)
			}
		end,
		Purchase = function(_, p)
			Network:fire("PurchaseEmote", p.Name)
		end
	},
	Decoration = {
		Resolve = function(_, p)
			if not p.DecoGroup then
				return nil
			end

			local v = Decoration[p.DecoGroup]
			local v2

			if v then
				v2 = v[p.Name]
			end

			if not v2 then
				return nil
			end

			local price = v2.Price or 0
			local v3 = Data.Decoration:Get(p.Name)
			return {
				Display = v2.Display or p.Name,
				Icon = v2.Image,
				Price = price,
				Description = v2.Description or `A {p.DecoGroup} decoration.`,
				Owned = v3 ~= nil,
				Equipped = v3 ~= nil and v3.Equipped == true
			}
		end,
		Purchase = function(_, p)
			Network:fire("BuyDeco", p.Name)
		end,
		Toggle = function(_, p)
			Network:fire("SetDeco", p.Name)
		end
	},
	Title = {
		Resolve = function(_, p)
			local title = Titles[p.Name]

			if not title then
				return nil
			end

			local price = title.Price or 0
			local description = title.Description

			if not description or description == "" then
				description = `"{title.Display or p.Name}" Title`
			end

			return {
				Display = title.Display or p.Name,
				Price = price,
				Description = description,
				Owned = Data.Titles:Get(p.Name) ~= nil,
				Equipped = localPlayer:GetAttribute("Title") == title.Display
			}
		end,
		Purchase = function(_, p)
			Network:fire("BuyTitle", p.Name)
		end,
		Toggle = function(_, p)
			Network:fire("SetActiveTitle", p.Name)
		end
	},
	Skin = {
		Resolve = function(_, p)
			local skin = Skins[p.Name]

			if not skin then
				return nil
			end

			local price = skin.Price or 0
			local v = Data.Skins:Get(p.Name)
			return {
				Display = skin.Display or p.Name,
				Icon = skin.Icon,
				Price = price,
				Description = `{skin.Display or p.Name} Skin`,
				Owned = v ~= nil,
				Equipped = v ~= nil and v.Equipped == true
			}
		end,
		Purchase = function(_, p)
			Network:fire("BuySkin", p.Name)
		end,
		Toggle = function(_, p)
			Network:fire("EquipSkin", p.Name)
		end
	},
	Bundle = {
		Resolve = function(_, p)
			local bundleByName = getBundleByName(p.Name) -- equivalent call inferred; original call site unknown

			if not bundleByName then
				return nil
			end

			local price = tonumber(bundleByName.Price)
			return {
				Display = bundleByName.Display or bundleByName.Name,
				Icon = bundleByName.Icon,
				Price = 0,
				PriceText = not price and " ..." or ` {string.format("%0.0f", price):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")}`,
				Pending = not bundleByName.Ready,
				Description = bundleByName.Description or "A bundle.",
				Owned = localPlayer:GetAttribute((`P{bundleByName.ProductId}`)) == true,
				Equipped = false
			}
		end,
		Purchase = function(_, p)
			local showBundle = _G.ShowBundle

			if showBundle then
				showBundle(p.Name)
			end
		end
	}
}
return FeaturedItemsUtility