local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local v = {
	BlueTrail = table.freeze({
		_id = "BlueTrail",
		Price = 75000,
		ProductId = 3611606747,
		Icon = "rbxassetid://137035834049811",
		Rarity = Rarity.Rarities.Rare,
		SpeedMultiplier = 2.5,
		DisplayInShop = true,
		DisplayName = "Blue Trail"
	}),
	MoonbloomTrail = table.freeze({
		_id = "MoonbloomTrail",
		Price = 5000000000000000,
		ProductId = 3712487399,
		Icon = "rbxassetid://123538285077698",
		Rarity = Rarity.Rarities.Divine,
		SpeedMultiplier = 20,
		SpeedNumberColor = Color3.fromRGB(29, 255, 210),
		DisplayInShop = true,
		DisplayName = "Moonbloom Trail"
	}),
	DivineTrail = table.freeze({
		_id = "DivineTrail",
		Price = 300000000000000,
		ProductId = 3611606791,
		Icon = "rbxassetid://140597836052094",
		Rarity = Rarity.Rarities.Divine,
		SpeedMultiplier = 14,
		DisplayInShop = true,
		DisplayName = "Divine Trail"
	}),
	EternalTrail = table.freeze({
		_id = "EternalTrail",
		Price = 12500000000000,
		ProductId = 3611606787,
		Icon = "rbxassetid://127740746006344",
		Rarity = Rarity.Rarities.Eternal,
		SpeedMultiplier = 10,
		DisplayInShop = true,
		DisplayName = "Eternal Trail"
	}),
	GalaxyTrail = table.freeze({
		_id = "GalaxyTrail",
		Price = 20000000000,
		ProductId = 3611606773,
		Icon = "rbxassetid://86672420342894",
		Rarity = Rarity.Rarities.Cosmic,
		SpeedMultiplier = 5,
		DisplayInShop = true,
		DisplayName = "Galaxy Trail"
	}),
	GoldenTrail = table.freeze({
		_id = "GoldenTrail",
		Price = 30000000,
		ProductId = 3611606764,
		Icon = "rbxassetid://78957355975053",
		Rarity = Rarity.Rarities.Legendary,
		SpeedMultiplier = 3.5,
		DisplayInShop = true,
		DisplayName = "Golden Trail"
	}),
	GreenTrail = table.freeze({
		_id = "GreenTrail",
		Price = 5000,
		ProductId = 3611606739,
		Icon = "rbxassetid://123930672117029",
		Rarity = Rarity.Rarities.Uncommon,
		SpeedMultiplier = 2,
		DisplayInShop = true,
		DisplayName = "Green Trail"
	}),
	GreyTrail = table.freeze({
		_id = "GreyTrail",
		Price = 100,
		ProductId = nil,
		Icon = "rbxassetid://103930213073663",
		Rarity = Rarity.Rarities.Common,
		SpeedMultiplier = 1.5,
		DisplayInShop = true,
		DisplayName = "Grey Trail"
	}),
	PurpleTrail = table.freeze({
		_id = "PurpleTrail",
		Price = 1500000,
		ProductId = 3611606754,
		Icon = "rbxassetid://109475464579632",
		Rarity = Rarity.Rarities.Epic,
		SpeedMultiplier = 3,
		DisplayInShop = true,
		DisplayName = "Purple Trail"
	}),
	RedTrail = table.freeze({
		_id = "RedTrail",
		Price = 750000000,
		ProductId = 3611606768,
		Icon = "rbxassetid://72219596211828",
		Rarity = Rarity.Rarities.Mythic,
		SpeedMultiplier = 4,
		DisplayInShop = true,
		DisplayName = "Red Trail"
	}),
	SecretTrail = table.freeze({
		_id = "SecretTrail",
		Price = 500000000000,
		ProductId = 3611606784,
		Icon = "rbxassetid://124057247070872",
		Rarity = Rarity.Rarities.Secret,
		SpeedMultiplier = 7,
		DisplayInShop = true,
		DisplayName = "Secret Trail"
	})
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local directory = require(ReplicatedStorage2.Shared.Flags.BalanceConfig).Bind("Game.Balance.Trails", v, {
	Price = true,
	SpeedMultiplier = true
}, true, function(items)
	for _, item in items do
		assert(item.SpeedMultiplier > 0)
	end
end)
table.freeze(directory)
return table.freeze({
	Directory = directory,
	TrailNameExists = function(p: string)
		if directory[p] == nil then
			return false, (`Trails name "{p}" does not exist in the Trails directory.`)
		end

		return true
	end
})