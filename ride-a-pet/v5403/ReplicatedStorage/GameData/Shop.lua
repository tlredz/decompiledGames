local gameServices = game.ReplicatedStorage.GameServices
local General = require(gameServices:WaitForChild("General"))
local gameData = game.ReplicatedStorage.GameData
local Foods = require(gameData:WaitForChild("Foods"))
local Shop = {}
local assets = game.ReplicatedStorage.Assets
Shop.Gears = {
	["Advanced Radar"] = {
		Price = 50,
		Rarity = "Rare",
		StockChance = 100,
		MinStock = 2,
		MaxStock = 5,
		Source = "Radars",
		ProductKey = "AdvancedRadar",
		ImageId = "rbxassetid://97565116461010"
	},
	["Jewel Radar"] = {
		Price = 3000,
		Rarity = "Epic",
		StockChance = 100,
		MinStock = 1,
		MaxStock = 4,
		Source = "Radars",
		ProductKey = "CrystalRadar",
		ImageId = "rbxassetid://125865340765975"
	},
	["Royal Radar"] = {
		Price = 20000,
		Rarity = "Legendary",
		StockChance = 100,
		MinStock = 1,
		MaxStock = 3,
		Source = "Radars",
		ProductKey = "RoyalRadar",
		ImageId = "rbxassetid://128885631050594"
	},
	["Magic Radar"] = {
		Price = 300000,
		Rarity = "Mythic",
		StockChance = 100,
		MinStock = 1,
		MaxStock = 2,
		Source = "Radars",
		ProductKey = "MagicRadar",
		ImageId = "rbxassetid://112080839084490"
	},
	["Angelic Radar"] = {
		Price = 7000000,
		Rarity = "Divine",
		StockChance = 40,
		MinStock = 1,
		MaxStock = 1,
		Source = "Radars",
		ProductKey = "AngelicRadar",
		ImageId = "rbxassetid://116940131274481"
	},
	["Eternal Radar"] = {
		Price = 30000000,
		Rarity = "Ethereal",
		StockChance = 5,
		MinStock = 1,
		MaxStock = 1,
		Source = "Radars",
		ProductKey = "EternalRadar",
		ImageId = "rbxassetid://77943097275767"
	},
	["Basic Lantern"] = {
		Price = 500,
		Rarity = "Rare",
		StockChance = 80,
		MinStock = 1,
		MaxStock = 5,
		Source = "Lanterns",
		ProductKey = "BasicLantern",
		ImageId = "rbxassetid://71180225010705"
	},
	["Cool Lantern"] = {
		Price = 5000,
		Rarity = "Epic",
		StockChance = 50,
		MinStock = 1,
		MaxStock = 3,
		Source = "Lanterns",
		ProductKey = "CoolLantern",
		ImageId = "rbxassetid://81282164041861"
	},
	["Royal Lantern"] = {
		Price = 30000,
		Rarity = "Legendary",
		StockChance = 15,
		MinStock = 1,
		MaxStock = 2,
		Source = "Lanterns",
		ProductKey = "RoyalLantern",
		ImageId = "rbxassetid://135589431517431"
	},
	["Magic Lantern"] = {
		Price = 600000,
		Rarity = "Mythic",
		StockChance = 10,
		MinStock = 1,
		MaxStock = 1,
		Source = "Lanterns",
		ProductKey = "MagicLantern",
		ImageId = "rbxassetid://87728771181105"
	},
	["Eternal Lantern"] = {
		Price = 30000000,
		Rarity = "Ethereal",
		StockChance = 1,
		MinStock = 1,
		MaxStock = 1,
		Source = "Lanterns",
		ProductKey = "EternalLantern",
		ImageId = "rbxassetid://136751354338811"
	},
	NameTag = {
		Price = 200000000,
		Rarity = "Ethereal",
		StockChance = 2,
		MinStock = 1,
		MaxStock = 1,
		Source = "MiscGears",
		ProductKey = "NameTag",
		DisplayName = "Name Tag",
		ImageId = "rbxassetid://100112781575491"
	}
}
Shop.Food = {
	Grass = {
		StockChance = 100,
		MinStock = 5,
		MaxStock = 15,
		Source = "Foods",
		ProductKey = "Grass",
		ImageId = "rbxassetid://79219529092402"
	},
	Bone = {
		StockChance = 75,
		MinStock = 2,
		MaxStock = 6,
		Source = "Foods",
		ProductKey = "Bone",
		ImageId = "rbxassetid://134268104055181"
	},
	Meat = {
		StockChance = 45,
		MinStock = 1,
		MaxStock = 4,
		Source = "Foods",
		ProductKey = "Meat",
		ImageId = "rbxassetid://79514346385181"
	},
	["Magic Apple"] = {
		StockChance = 6,
		MinStock = 1,
		MaxStock = 2,
		Source = "Foods",
		ProductKey = "MagicApple",
		ImageId = "rbxassetid://70504097307837"
	},
	Dragonfruit = {
		StockChance = 2.5,
		MinStock = 1,
		MaxStock = 1,
		Source = "Foods",
		ProductKey = "DragonFruit",
		ImageId = "rbxassetid://75458127545746"
	}
}

for k, v in Shop.Food do
	local food = Foods[k]

	if food then
		v.Price = food.Cost
		v.Rarity = food.Rarity
	else
		warn(string.format("Shop: no GameData.Foods entry for %q", k))
		v.Price = v.Price or 0
		v.Rarity = v.Rarity or "Common"
	end
end

Shop.Categories = {
	Gears = Shop.Gears,
	Food = Shop.Food
}
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local success, result = pcall(require2, ReplicatedStorage:WaitForChild("GameSettings"))

if success and result and result.NOSHOWLANTERNSONSHOP == true then
	for k, gear in pairs(Shop.Gears) do
		if gear.Source == "Lanterns" then
			Shop.Gears[k] = nil
		end
	end
end

Shop.SourceOrder = {
	Radars = 1,
	Lanterns = 2,
	MiscGears = 3,
	Foods = 1
}
Shop.DisplayNames = {
	Gears = "Gear",
	Food = "Food"
}

function Shop.GetDisplayName(p: string)
	return Shop.DisplayNames[p] or p
end

function Shop.GetItem(p: string, p2: string)
	local category = Shop.Categories[p]
	return category and category[p2] or nil
end

function Shop.GetProductId(p: string, p2: string, p3: number)
	local item = Shop.GetItem(p, p2)

	if item and item.ProductKey then
		local Monetization = require(gameData:WaitForChild("Monetization"))
		return Monetization[string.format("x%d%s", p3, item.ProductKey)]
	else
		return nil
	end
end

function Shop.GiveProduct(_, p, p2: string, childName: string, flag: boolean?, value: number?)
	local PlayerDataHandler = require(game.ServerScriptService.Data.PlayerDataService.PlayerDataHandler)
	local item = Shop.GetItem(p2, childName)
	local source

	if item then
		source = item.Source or p2
	else
		source = p2
	end

	local child = assets:FindFirstChild(source)

	if not child then
		warn(string.format("Shop: no asset folder %q for %s/%s", source, p2, childName))
		return
	end

	local child2 = child:FindFirstChild(childName)

	if not child2 then
		warn(string.format("Shop: no asset %q in %s", childName, source))
		return
	end

	local count = General:GiveItem(p, child2, value or 1)

	if not flag then
		PlayerDataHandler:Set(p, { "Inventory", childName }, {
			Count = count
		})
	end

	return count
end

return Shop