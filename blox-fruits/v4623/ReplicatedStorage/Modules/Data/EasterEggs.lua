require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
require(game.ReplicatedStorage.Economy.ItemId)
local RunService = game:GetService("RunService")
local GlobalUtil

if RunService:IsServer() then
	GlobalUtil = require(game.ServerStorage.GlobalUtil)
else
	GlobalUtil = nil
end

local v = {
	["Eggcited Egg"] = {
		Rarity = "Common",
		Id = 1
	},
	["Thirsty Egg"] = {
		Rarity = "Common",
		Id = 2
	},
	["Rocket Egg"] = {
		Rarity = "Common",
		Id = 3
	},
	["Shockwave Egg"] = {
		Rarity = "Common",
		Id = 4
	},
	["Fishy Egg"] = {
		Rarity = "Common",
		Id = 5
	},
	["Wooden Egg"] = {
		Rarity = "Common",
		Id = 6
	},
	["Eggspensive Egg"] = {
		Rarity = "Uncommon",
		Id = 7
	},
	["Treasured Egg"] = {
		Rarity = "Uncommon",
		Id = 8
	},
	["Duelists Egg"] = {
		Rarity = "Uncommon",
		Id = 9
	},
	["Mended Egg"] = {
		Rarity = "Rare",
		Id = 10
	},
	["Kawaii Egg"] = {
		Rarity = "Rare",
		Id = 11
	},
	["Falling Sky Egg"] = {
		Rarity = "Rare",
		Id = 12
	},
	["Eggsploration Egg"] = {
		Rarity = "Rare",
		Id = 13
	},
	["Friendly Neighborhood Egg"] = {
		Rarity = "Rare",
		Id = 14
	},
	["Firefly Egg"] = {
		Rarity = "Legendary",
		Id = 15
	},
	["Pirate Egg"] = {
		Rarity = "Legendary",
		Id = 16
	},
	["Molten Egg"] = {
		Rarity = "Legendary",
		Id = 17
	},
	["Boss Hunt Egg"] = {
		Rarity = "Legendary",
		Id = 18
	},
	["Gacha Egg"] = {
		Rarity = "Legendary",
		Id = 19
	},
	["Full Moon Egg"] = {
		Rarity = "Mythical",
		Id = 20
	},
	["Night Hunter Egg"] = {
		Rarity = "Mythical",
		Id = 21
	},
	["Sealed Showdown Egg"] = {
		Rarity = "Mythical",
		Id = 22
	},
	["Golden Egg"] = {
		Rarity = "Mythical",
		Id = 23
	},
	["Celestial Egg"] = {
		Rarity = "Mythical",
		Id = 24
	}
}
local v2 = {}
local count = 0

for k, v3 in pairs(v) do
	assert(v2[v3.Id] == nil)
	count += 1
	v2[v3.Id] = k
end

-- equivalent calls inferred from this helper; original call sites unknown
local function awardMoney(p, quantity: number)
	local v3 = assert(GlobalUtil.tryGetSession(p))
	v3.wrap.addBeli(quantity)
	v3.wrap.doStatUpdate()
end

local function awardFragments(p, quantity: number)
	assert(GlobalUtil.tryGetSession(p)).wrap.addFragments(quantity, {
		callback = function(data)
			local RobloxAnalytics = require(game.ServerScriptService.Services.RobloxAnalytics)
			RobloxAnalytics.Fragments.Source:General({
				player = data.player,
				name = "WorldDrop",
				amount = data.total,
				endingBalance = data.endingBalance
			})
		end
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function awardMaterial(p, name: string, quantity: number)
	assert(GlobalUtil.tryGetSession(p)).wrap.awardEtcItem(name, quantity)
end

return table.freeze({
	List = table.freeze(v),
	Total = count,
	Rewards = table.freeze({
		{
			StorageName = "1",
			Milestone = 1,
			Callback = function(p, p2)
				awardMaterial(p, p2.Name, p2.Quantity) -- equivalent call inferred; original call site unknown
			end,
			Seas = {
				{
					Quantity = 100,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 100,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 100,
					Name = "Candy Egg",
					Type = "Material"
				}
			}
		},
		{
			StorageName = "5",
			Milestone = 3,
			Callback = function(p, p2)
				awardMoney(p, p2.Quantity) -- equivalent call inferred; original call site unknown
			end,
			Seas = {
				{
					Quantity = 10000,
					Name = "10K Money",
					Type = "Redeemable"
				},
				{
					Quantity = 30000,
					Name = "30K Money",
					Type = "Redeemable"
				},
				{
					Quantity = 30000,
					Name = "30K Money",
					Type = "Redeemable"
				}
			}
		},
		{
			StorageName = "10",
			Milestone = 5,
			Callback = function(p, p2)
				awardMaterial(p, p2.Name, p2.Quantity) -- equivalent call inferred; original call site unknown
			end,
			Seas = {
				{
					Quantity = 200,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 200,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 200,
					Name = "Candy Egg",
					Type = "Material"
				}
			}
		},
		{
			StorageName = "15",
			Milestone = 7,
			Callback = function(p, p2)
				if not p2.Name:match("Money") then
					awardFragments(p, p2.Quantity)
					return
				end

				awardMoney(p, p2.Quantity) -- equivalent call inferred; original call site unknown
			end,
			Seas = {
				{
					Quantity = 50000,
					Name = "50K Money",
					Type = "Redeemable"
				},
				{
					Quantity = 500,
					Name = "500 Fragments",
					Type = "Redeemable"
				},
				{
					Quantity = 500,
					Name = "500 Fragments",
					Type = "Redeemable"
				}
			}
		},
		{
			StorageName = "20",
			Milestone = 10,
			Callback = function(p, p2)
				awardMaterial(p, p2.Name, p2.Quantity) -- equivalent call inferred; original call site unknown
			end,
			Seas = {
				{
					Quantity = 400,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 400,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 400,
					Name = "Candy Egg",
					Type = "Material"
				}
			}
		},
		{
			StorageName = "25",
			Milestone = 13,
			Callback = function(p, p2)
				if not p2.Name:match("Money") then
					awardFragments(p, p2.Quantity)
					return
				end

				awardMoney(p, p2.Quantity) -- equivalent call inferred; original call site unknown
			end,
			Seas = {
				{
					Quantity = 135000,
					Name = "135K Money",
					Type = "Redeemable"
				},
				{
					Quantity = 2100,
					Name = "2.1K Fragments",
					Type = "Redeemable"
				},
				{
					Quantity = 2100,
					Name = "2.1K Fragments",
					Type = "Redeemable"
				}
			}
		},
		{
			StorageName = "30",
			Milestone = 15,
			Callback = function(p, p2)
				awardMaterial(p, p2.Name, p2.Quantity) -- equivalent call inferred; original call site unknown
			end,
			Seas = {
				{
					Quantity = 600,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 600,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 600,
					Name = "Candy Egg",
					Type = "Material"
				}
			}
		},
		{
			StorageName = "35",
			Milestone = 17,
			Callback = function(p, p2)
				awardMaterial(p, p2.Name, p2.Quantity) -- equivalent call inferred; original call site unknown
			end,
			Seas = {
				{
					Quantity = 1000,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 1000,
					Name = "Candy Egg",
					Type = "Material"
				},
				{
					Quantity = 1000,
					Name = "Candy Egg",
					Type = "Material"
				}
			}
		},
		{
			StorageName = "40",
			Milestone = 22,
			Callback = function(p, p2)
				local GlobalUtil2 = require(game.ServerStorage.GlobalUtil)
				local v4 = assert(GlobalUtil2.tryGetSession(p))
				v4.Data.StoredFruits[p2.Name] = (v4.Data.StoredFruits[p2.Name] or 0) + p2.Quantity
				local Global = require(game.ReplicatedStorage.Global)
				Global.getWrappedPlayer(p).replicateItem(p2.Name, "stored")
			end,
			Seas = {
				{
					Quantity = 1,
					Name = "RareEasterGift26",
					Type = "Redeemable"
				},
				{
					Quantity = 1,
					Name = "RareEasterGift26",
					Type = "Redeemable"
				},
				{
					Quantity = 1,
					Name = "RareEasterGift26",
					Type = "Redeemable"
				}
			}
		},
		{
			StorageName = "45",
			Milestone = 23,
			Callback = function(p, p2)
				local GlobalUtil2 = require(game.ServerStorage.GlobalUtil)
				local v4 = assert(GlobalUtil2.tryGetSession(p))
				v4.Data.StoredFruits[p2.Name] = (v4.Data.StoredFruits[p2.Name] or 0) + p2.Quantity
				local Global = require(game.ReplicatedStorage.Global)
				Global.getWrappedPlayer(p).replicateItem(p2.Name, "stored")
			end,
			Seas = {
				{
					Quantity = 1,
					Name = "RareEasterGift26",
					Type = "Redeemable"
				},
				{
					Quantity = 1,
					Name = "RareEasterGift26",
					Type = "Redeemable"
				},
				{
					Quantity = 1,
					Name = "RareEasterGift26",
					Type = "Redeemable"
				}
			}
		},
		{
			StorageName = "50",
			Milestone = 24,
			Callback = function(p, p2)
				local GlobalUtil2 = require(game.ServerStorage.GlobalUtil)
				local v4 = assert(GlobalUtil2.tryGetSession(p))
				v4.Data.StoredFruits[p2.Name] = (v4.Data.StoredFruits[p2.Name] or 0) + p2.Quantity
				local Global = require(game.ReplicatedStorage.Global)
				Global.getWrappedPlayer(p).replicateItem(p2.Name, "stored")
			end,
			Seas = {
				{
					Quantity = 1,
					Name = "LegendaryEasterGift26",
					Type = "Redeemable"
				},
				{
					Quantity = 1,
					Name = "LegendaryEasterGift26",
					Type = "Redeemable"
				},
				{
					Quantity = 1,
					Name = "LegendaryEasterGift26",
					Type = "Redeemable"
				}
			}
		}
	}),
	GetFromId = function(p: number)
		local v4 = v2[p]
		return v[v4], v4
	end
})