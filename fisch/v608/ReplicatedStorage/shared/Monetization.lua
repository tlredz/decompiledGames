local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("HttpService")
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local modules = shared.modules
local Net = require(packages.Net)
local RewardInfo = require(shared.RewardInfo)
local Signal = require(packages.Signal)
require(packages.PromiseTypes)
local Promise = require(packages.Promise)
local Bundles = require(modules.Bundles)
local vessels = require(modules.vessels)
local Factions = require(modules.Factions)
local SalesBooth = require(ReplicatedStorage.shared.modules.SalesBooth)
local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local OfficialCommerceProducts = require(ReplicatedStorage.shared.modules.OfficialCommerceProducts)
require(script.Types)
local Monetization = {
	BuyProduct = Net:RemoteEvent("Monetization/BuyProduct"),
	DEV_PLACE = game.GameId == 6756890519 or game.GameId == 7431162737,
	BuyFromServer = RunService:IsServer() and Signal.new(),
	productInfoCache = {
		gamepasses = {},
		products = {}
	},
	gamepasses = {
		SellAnywhere = {
			GamepassId = 901839344,
			Description = "Sell your fish from anywhere in Fisch!",
			Color = Color3.fromRGB(255, 106, 106),
			Priority = 1
		},
		BobberPack = {
			GamepassId = 927437431,
			Description = "10 Cosmetic Bobbers & Bobber Enthusiast Title!",
			Color = Color3.fromRGB(140, 101, 255),
			Priority = 2
		},
		["837360470"] = {
			GamepassId = 837360470,
			Description = "Increases XP gain by 2x",
			Color = Color3.fromRGB(131, 185, 255),
			Priority = 3
		},
		AppraisersLuck = {
			GamepassId = 837341519,
			Description = "Increased Appraiser Luck & costs 25% less to appraise!",
			Color = Color3.fromRGB(144, 255, 148),
			Priority = 4
		},
		Supporter = {
			GamepassId = 837478377,
			Description = "Supporter Title, Halo, /e rain Emote & +1000 Credits!",
			Color = Color3.fromRGB(255, 233, 120),
			Priority = 5
		},
		EmotePack = {
			GamepassId = 847012516,
			Description = "11+ Emotes & Dances",
			Color = Color3.fromRGB(229, 135, 255),
			Priority = 6
		},
		Radio = {
			GamepassId = 948629114,
			AssetId = 76708475214091,
			DisplayName = "Boombox & Party Boat",
			Description = "Get a Boombox and a DJ Enabled Party Boat",
			Icon = "rbxassetid://76960252099952",
			Color = Color3.fromRGB(170, 85, 255),
			Priority = 7
		},
		SpawnBoatsAnywhere = {
			GamepassId = 986687236,
			Description = "Be able to spawn boats anywhere in the ocean!",
			Color = Color3.fromRGB(88, 233, 255),
			Priority = 8
		},
		AppraiseAnywhere = {
			GamepassId = 986882975,
			Description = "Appraise an item anywhere",
			Color = Color3.fromRGB(111, 255, 195),
			Priority = 8
		},
		EnchantAnywhere = {
			GamepassId = 1359918468,
			Description = "Enchant rods anywhere",
			Color = Color3.fromRGB(98, 153, 255),
			Priority = 9
		},
		DiscoveryPass = {
			GamepassId = 1142100573,
			Hide = true,
			Description = "Walmart gamepass",
			Color = Color3.fromRGB(111, 255, 195),
			Priority = 9
		}
	},
	products = {
		TestProduct = {
			ProductId = 3253355283
		},
		GamepassesGifts = {
			SellAnywhere = {
				ProductId = 2653139351,
				Gamepass = 901839344
			},
			BobberPack = {
				ProductId = 2653139607,
				Gamepass = 927437431
			},
			DoubleXP = {
				ProductId = 2653139013,
				Gamepass = 837360470
			},
			AppraisersLuck = {
				ProductId = 2653029225,
				Gamepass = 837341519
			},
			Supporter = {
				ProductId = 2653079522,
				Gamepass = 837478377
			},
			EmotePack = {
				ProductId = 2653139236,
				Gamepass = 847012516
			},
			AppraiseAnywhere = {
				ProductId = 2669993179,
				Gamepass = 986882975
			},
			EnchantAnywhere = {
				ProductId = 3351840567,
				Gamepass = 1359918468
			},
			SpawnBoatsAnywhere = {
				ProductId = 2669991547,
				Gamepass = 986687236
			}
		},
		AquariumSlot = {
			ProductId = 3301643355
		},
		VideoAds = {
			ProductId = 3303181747
		},
		PersonalAquariumSlot = {
			{
				ProductId = 3525046322
			},
			{
				ProductId = 3525046324
			},
			{
				ProductId = 3525046330
			},
			{
				ProductId = 3525046323
			},
			{
				ProductId = 3525046331
			},
			{
				ProductId = 3525046327
			},
			{
				ProductId = 3525046325
			},
			{
				ProductId = 3525046329
			},
			{
				ProductId = 3525072900
			},
			{
				ProductId = 3525046326
			}
		},
		Credits = {
			["500_Credits"] = {
				Credits = 500,
				ProductId = 2661085733
			},
			["500_CreditsGift"] = {
				Credits = 500,
				ProductId = 2661246253
			},
			["2500_Credits"] = {
				Credits = 2500,
				ProductId = 2661085915
			},
			["2500_CreditsGift"] = {
				Credits = 2500,
				ProductId = 2661246373
			},
			["5000_Credits"] = {
				Credits = 5000,
				ProductId = 2661086238
			},
			["5000_CreditsGift"] = {
				Credits = 5000,
				ProductId = 2661246403
			},
			["10000_Credits"] = {
				Credits = 10000,
				ProductId = 2661086358
			},
			["10000_CreditsGift"] = {
				Credits = 10000,
				ProductId = 2661246443
			},
			["25000_Credits"] = {
				Credits = 25000,
				ProductId = 2661086566
			},
			["25000_CreditsGift"] = {
				Credits = 25000,
				ProductId = 2661246501
			},
			["25000_CreditsFirstTimeOffer"] = {
				Credits = 25000,
				ProductId = 2661607668,
				FirstTimeTag = "FirstTimeOffer/2661086566"
			}
		},
		LimitedBobbers = {
			Enabled = true,
			TimeRange = NumberRange.new(
				DateTime.fromUniversalTime(2026, 9, 18).UnixTimestamp,
				DateTime.fromUniversalTime(2026, 9, 26).UnixTimestamp
			),
			Bobbers = {
				Chiwari = {
					ProductId = 3713556836
				},
				Nanatama = {
					ProductId = 3713556838
				},
				Uwa = {
					ProductId = 3713556839
				},
				Bundle = {
					ProductId = 3713556841,
					PurchaseCoins = 5000000
				}
			},
			BundlePurchaseCoins = 5000000
		},
		Eggs = {
			OneEgg = {
				ProductId = 3231935650,
				Amount = 1
			},
			TenEggs = {
				ProductId = 3231936535,
				Amount = 10
			}
		},
		AFK = {
			["1Hour"] = {
				ProductId = 3243442865
			},
			["3Hours"] = {
				ProductId = 3243443085
			},
			["10Hours"] = {
				ProductId = 3243443442
			}
		},
		Luck = {
			["2xLuck"] = {
				ProductId = 2651156738,
				SetLuckAt = 2,
				Price = 99
			},
			["4xLuck"] = {
				ProductId = 2651157043,
				SetLuckAt = 4,
				RequiredBoost = 2,
				Price = 199,
				Discount = 399,
				Previous = "2xLuck",
				Extensions = {
					["15Min"] = 2658213093,
					["30Min"] = 2658213211
				}
			},
			["8xLuck"] = {
				ProductId = 2651157275,
				SetLuckAt = 8,
				RequiredBoost = 4,
				Price = 399,
				Previous = "4xLuck",
				Discount = 799,
				Extensions = {
					["15Min"] = 2658213306,
					["30Min"] = 2658213423
				}
			}
		},
		Others = {
			StarterPack = {
				ProductId = 2657335337,
				Enabled = true,
				MaxLevel = 10,
				DisplayIn = 600,
				Timer = 600,
				Rewards = {
					RewardInfo.Rod("Fischer's Rod"),
					RewardInfo.Boat("Coral Cruiser Boat"),
					RewardInfo.Item("Fish Radar")
				}
			},
			RefreshDailyShop = {
				ProductId = 3339126667
			},
			RefreshFurnitureShop = {
				ProductId = 3604327857
			},
			RefreshKaitosShop = {
				ProductId = 3710910820
			},
			SkipChallenge = {
				ProductId = 3289987675
			},
			RefreshReputationQuests = {
				["Red Marlins"] = Factions["Red Marlins"].RefreshProductId,
				["Midas' Mates"] = Factions["Midas' Mates"].RefreshProductId,
				Ghosts = Factions.Ghosts.RefreshProductId
			},
			SalesBooths = {},
			AdventCalendar = {
				NextDay = 3469182307,
				PreviousDay = 3469182309,
				["5Days"] = 3469182311,
				AllDays = 3469182310
			}
		},
		DateReward = {
			PreviousDay = {
				ProductId = 2668497927
			},
			DaySkip = {
				ProductId = 2669804295
			},
			["5DaySkip"] = {
				ProductId = 2669804736
			},
			SkipAll = {
				ProductId = 2669805001
			}
		},
		Baits = {
			Buy5 = {
				ProductId = 3232726029
			},
			Buy25 = {
				ProductId = 3232726189
			}
		},
		Bundles = {
			FeaturedBundle = "Fish Bowl Bundle",
			bundles = {}
		},
		Vessels = {
			FeaturedBoat = "Orange Unicycle",
			vessels = {}
		},
		PotionsSkips = {
			["Luck Potion Tier 1 - Skip"] = {
				ProductId = 3286522717
			},
			["Luck Potion Tier 2 - Skip"] = {
				ProductId = 3286522720
			},
			["Luck Potion Tier 3 - Skip"] = {
				ProductId = 3286522721
			},
			["Lure Speed Potion Tier 1 - Skip"] = {
				ProductId = 3286522978
			},
			["Lure Speed Potion Tier 2 - Skip"] = {
				ProductId = 3286522977
			},
			["Lure Speed Potion Tier 3 - Skip"] = {
				ProductId = 3286522976
			},
			["Glitched Potion Tier 1 - Skip"] = {
				ProductId = 3286523108
			},
			["All Season Potion Tier 1 - Skip"] = {
				ProductId = 3286523211
			}
		},
		Jukebox = {
			ProductId = 3478370321,
			Duration = 1200,
			Price = 49
		},
		FischmasExpress = {
			["1Token"] = {
				ProductId = 3487679424,
				Tokens = 1
			},
			["5Tokens"] = {
				ProductId = 3487679566,
				Tokens = 5
			},
			["10Tokens"] = {
				ProductId = 3487679681,
				Tokens = 10
			}
		},
		SkinCrates = {},
		RodSkins = {},
		Commerce = {},
		CompanionSkins = {}
	},
	GetItemInTableById = function(self, items, p)
		for k, item in pairs(items) do
			if typeof(item) == "table" then
				if item.ProductId and item.ProductId == p or item.GamepassId and item.GamepassId == p then
					return k, item
				end

				local itemInTableById, v = self:GetItemInTableById(item, p)

				if itemInTableById then
					return itemInTableById, v
				end
			elseif item == p then
				return k, {
					ProductId = item
				}
			end
		end

		return nil
	end,
	GetProductDataById = function(self, p, p2)
		if not p then
			return
		end

		if p2 then
			return self:GetItemInTableById(self.gamepasses, p)
		end

		return self:GetItemInTableById(self.products, p)
	end,
	GetProductInfo = function(self, p, p2)
		if not p then
			warn((`Product id not entered! - {p}`))
			return
		end

		local productDataById, v = self:GetProductDataById(p, p2)

		if not (productDataById and v) then
			warn((`Product data not found! - {p}`))
			return
		end

		local v2

		if p2 then
			v2 = self.productInfoCache.gamepasses[productDataById]
		else
			v2 = self.productInfoCache.products[productDataById]
		end

		local assetId = v.AssetId or p2 and v.GamepassId or v.ProductId
		local asset = v.AssetId and Enum.InfoType.Asset or Enum.InfoType[p2 and "GamePass" or "Product"]

		if v2 then
			return v2
		end

		local success, result = pcall(function()
			return MarketplaceService:GetProductInfo(assetId, asset)
		end)

		if not result then
			local count = 0

			repeat
				task.wait(5)
				local _, result2 = pcall(function()
					return MarketplaceService:GetProductInfo(assetId, asset)
				end)
				count += 1
			until result2 ~= nil or count > 5
		end

		if success and result then
			if p2 then
				self.productInfoCache.gamepasses[productDataById] = result
			else
				self.productInfoCache.products[productDataById] = result
			end

			return result
		end

		return v2
	end,
	GetRobuxPrice = function(self, p, p2, _)
		if not p then
			warn((`Product id not entered! - {p}`))
			return
		end

		local _, v = self:GetProductDataById(p, p2)
		local productInfo = self:GetProductInfo(p, p2)

		if v and productInfo and not v.IgnorePriceDebug and self.DEV_PLACE then
			productInfo = self:GetProductInfo(3253355283)
		end

		return productInfo and productInfo.PriceInRobux
	end,
	GetPriceLevelAsync = function(_, instance)
		return Promise.new(function(callback, callback2)
			if instance then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function grabCachedPriceLevel()
					return instance:GetAttribute("PriceLevel")
				end

				if not RunService:IsServer() then
					callback(grabCachedPriceLevel())
					return
				end

				local v = grabCachedPriceLevel() -- equivalent call inferred; original call site unknown

				if v then
					callback(v)
				else
					callback(MarketplaceService:GetUsersPriceLevelsAsync({ instance.UserId })[1].PriceLevel or nil)
				end
			elseif callback2 then
				callback2("[Monetization.GetPriceLevelAsync]: No player was passed into promise!")
			end
		end)
	end
}

function Monetization.GetGamepassFromGiftId(_, p)
	for _, gamepass in Monetization.gamepasses do
		if gamepass.GamepassId == p then
			return gamepass
		end
	end

	return nil
end

function Monetization.GetProductGiftFromGamepass(_, p)
	for _, gamepassesGift in Monetization.products.GamepassesGifts do
		if gamepassesGift.Gamepass == p then
			return gamepassesGift
		end
	end

	return nil
end

function Monetization.GetFeaturedVesselData(p)
	local featuredBoat = p.products.Vessels.FeaturedBoat
	local vessel = p.products.Vessels.vessels[p.products.Vessels.FeaturedBoat]

	if featuredBoat and vessel then
		return featuredBoat, vessel
	end

	local count = 0

	repeat
		task.wait(5)
		featuredBoat = p.products.Vessels.FeaturedBoat
		vessel = p.products.Vessels.vessels[p.products.Vessels.FeaturedBoat]
		count += 1
	until featuredBoat and vessel or count > 5

	return featuredBoat, vessel
end

for k, bundle in pairs(Bundles) do
	if bundle.ProductId then
		Monetization.products.Bundles.bundles[k] = {
			ProductId = bundle.ProductId
		}
	end
end

for k, item in pairs(SalesBooth.Items) do
	if item.ProductId then
		Monetization.products.Others.SalesBooths[k] = item.ProductId
	end
end

for _, moduleScript in modules.SkinCrates:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	if module and module.ProductId and module.CrateName then
		Monetization.products.SkinCrates[module.CrateName] = {
			ProductId = module.ProductId
		}
	end
end

for _, moduleScript in modules.RodSkins:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	for k, v in module, nil, nil do
		if v.DevProduct then
			Monetization.products.RodSkins[k] = {
				ProductId = v.DevProduct
			}
		end
	end
end

for k, v in pairs(vessels.library) do
	if v.ProductId then
		Monetization.products.Vessels.vessels[k] = {
			ProductId = v.ProductId
		}
	end
end

for k, officialCommerceProduct in OfficialCommerceProducts do
	Monetization.products.Commerce[k] = officialCommerceProduct
end

for k, skin in skins.Skins do
	if skin.ProductId then
		Monetization.products.CompanionSkins[k] = {
			ProductId = skin.ProductId
		}
	end
end

return Monetization