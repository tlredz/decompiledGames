local Option = require(game.ReplicatedStorage.Packages.Option)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local Settlement = require(game.ReplicatedStorage.Economy.EconomyItem.Product.Settlement)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local v = {
	FRAGMENTS = {
		[2100] = IdMap.Redeemable["2.1K Fragments"],
		[10000] = IdMap.Redeemable["10K Fragments"],
		[4500] = IdMap.Redeemable["4.5K Fragments"],
		[500] = IdMap.Redeemable["500 Fragments"],
		[16000] = IdMap.Redeemable["16K Fragments"]
	},
	MONEY = {
		[135000] = IdMap.Redeemable["135K Money"],
		[10000] = IdMap.Redeemable["10K Money"],
		[20000] = IdMap.Redeemable["20K Money"],
		[810000] = IdMap.Redeemable["810K Money"],
		[1500000] = IdMap.Redeemable["1.5M Money"],
		[300000] = IdMap.Redeemable["300K Money"],
		[30000] = IdMap.Redeemable["30K Money"],
		[1800000] = IdMap.Redeemable["1.8M Money"],
		[50000] = IdMap.Redeemable["50K Money"],
		[150000] = IdMap.Redeemable["150K Money"],
		[600000] = IdMap.Redeemable["600K Money"],
		[900000] = IdMap.Redeemable["900K Money"],
		[500000] = IdMap.Redeemable["500K Money"],
		[305000] = IdMap.Redeemable["305K Money"],
		[60000] = IdMap.Redeemable["60K Money"],
		[405000] = IdMap.Redeemable["405K Money"],
		[3000000] = IdMap.Redeemable["3M Money"]
	},
	SIMULATION_DATA = {
		[200] = IdMap.Redeemable["200 Simulation Data"],
		[1000] = IdMap.Redeemable["1000 Simulation Data"],
		[2700] = IdMap.Redeemable["2700 Simulation Data"],
		[6000] = IdMap.Redeemable["6000 Simulation Data"],
		[10000] = IdMap.Redeemable["10000 Simulation Data"]
	}
}
local Settlement2 = {
	Templates = {}
}
Settlement2.Templates.Item = {}

function Settlement2.Templates.Item.profileFullArt(value, p: number?)
	local v2

	if type(value) == "string" then
		v2 = ItemId.getId(value, "ProfileFullArt"):unwrap()
	else
		v2 = value
	end

	local ItemConfig2 = require(game.ReplicatedStorage.ItemConfig)
	assert(ItemConfig2.match(v2):unwrap().Index.IdType == "ProfileFullArt", (`{value} is not of type ProfileFullArt`))
	return (Settlement.Templates.Item.new(v2, "ProfileFullArt", Option.from(p)))
end

function Settlement2.Templates.Item.physicalMoveset(value)
	if type(value) == "string" then
		value = ItemId.getId(value, "PhysicalMoveset"):unwrap()
	end

	assert(ItemId.getDataFromId(value):unwrap().Type == "PhysicalMoveset", (`itemId {value} is not of type Fruit`))
	return (Settlement.Templates.Item.new(value, "PhysicalMoveset", Option.none()))
end

function Settlement2.Templates.Item.auraSkin(value)
	if type(value) == "string" then
		value = ItemId.getId(value, "Skin"):unwrap()
	end

	assert(ItemId.getDataFromId(value):unwrap().Type == "Skin", (`itemId {value} is not of type Skin`))
	return (Settlement.Templates.Item.new(value, "AuraSkin", Option.none()))
end

function Settlement2.Templates.Item.fruitMutation(value)
	if type(value) == "string" then
		value = ItemId.getId(value, "Mutation"):unwrap()
	end

	assert(ItemId.getDataFromId(value):unwrap().Type == "Mutation", (`itemId {value} is not of type Mutation`))
	return (Settlement.Templates.Item.new(value, "FruitMutation", Option.none()))
end

function Settlement2.Templates.Item.fruitSkin(value)
	local v2

	if type(value) == "string" then
		v2 = ItemId.getId(value, "Skin"):unwrap()
	else
		v2 = value
	end

	assert(ItemId.getDataFromId(v2):unwrap().Type == "Skin", (`itemId {v2} is not of type Skin`))
	local ItemConfig2 = require(game.ReplicatedStorage.ItemConfig)
	assert(ItemConfig2.match(v2):unwrap().Index.IdType == "Skin", (`{value} is not of type FruitSkin`))
	return (Settlement.Templates.Item.new(v2, "FruitSkin", Option.none()))
end

function Settlement2.Templates.Item.swordSkin(value)
	local v2

	if type(value) == "string" then
		v2 = ItemId.getId(value, "Skin"):unwrap()
	else
		v2 = value
	end

	assert(ItemId.getDataFromId(v2):unwrap().Type == "Skin", (`itemId {v2} is not of type Skin`))
	local ItemConfig2 = require(game.ReplicatedStorage.ItemConfig)
	assert(ItemConfig2.match(v2):unwrap().Index.IdType == "Skin", (`{value} is not of type FruitSkin`))
	return (Settlement.Templates.Item.new(v2, "SwordSkin", Option.none()))
end

function Settlement2.Templates.Item.scroll(value, p: number)
	if type(value) == "string" then
		value = ItemId.getId(value, "Scroll"):unwrap()
	end

	assert(ItemId.getDataFromId(value):unwrap().Type == "Scroll", (`itemId {value} is not of type Scroll`))
	return (Settlement.Templates.Item.new(value, "EtcItems", Option.some(p)))
end

function Settlement2.Templates.Item.mutatedFruit(value, p: number?)
	if type(value) == "string" then
		value = ItemId.getId(value, "PhysicalMoveset"):unwrap()
	end

	assert(
		ItemId.getDataFromId(value):unwrap().Type == "PhysicalMoveset",
		(`itemId {value} is not of type MutatedFruit`)
	)
	return (Settlement.Templates.Item.new(value, "MutatedFruit", Option.from(p)))
end

function Settlement2.Templates.Item.skinnedFruit(value)
	if type(value) == "string" then
		value = ItemId.getId(value, "PhysicalMoveset"):unwrap()
	end

	assert(
		ItemId.getDataFromId(value):unwrap().Type == "PhysicalMoveset",
		(`itemId {value} is not of type SkinnedFruit`)
	)
	return (Settlement.Templates.Item.new(value, "SkinnedFruit", Option.none()))
end

function Settlement2.Templates.Item.permanentFruit(value, p: number?)
	if type(value) == "string" then
		value = ItemId.getId(value, "Moveset"):unwrap()
	end

	assert(ItemId.getDataFromId(value):unwrap().Type == "Moveset", (`itemId {value} is not of type Moveset`))
	return (Settlement.Templates.Item.new(value, "PermanentFruit", Option.from(p)))
end

function Settlement2.Templates.Item.sword(value, p: number?)
	if type(value) == "string" then
		value = ItemId.getId(value, "Moveset"):unwrap()
	end

	assert(ItemId.getDataFromId(value):unwrap().Type == "Moveset", (`itemId {value} is not of type Moveset`))
	return (Settlement.Templates.Item.new(value, "Sword", Option.from(p)))
end

function Settlement2.Templates.Item.box(value)
	local v2

	if type(value) == "string" then
		v2 = ItemId.getId(value, "Redeemable"):unwrap()
	else
		v2 = value
	end

	assert(ItemConfig.match(v2):unwrap().Index.IdType == "Redeemable", (`{value} is not of type Redeemable`))
	return (Settlement.Templates.Box.new(v2))
end

Settlement2.Templates.Special = {}

function Settlement2.Templates.Special.plus1FruitStorage()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["+1 Fruit Storage"]))
end

function Settlement2.Templates.Special.fruitNotifier()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["Fruit Notifier"]))
end

function Settlement2.Templates.Special.respawnBosses()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["Respawn Bosses"]))
end

function Settlement2.Templates.Special.refundPoints()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["Refund Points"]))
end

function Settlement2.Templates.Special.changeRace()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["Change Race"]))
end

function Settlement2.Templates.Special.moneyBoost()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["2x Money"]))
end

function Settlement2.Templates.Special.bossBoost()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["2x Boss Drops"]))
end

function Settlement2.Templates.Special.masteryBoost()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["2x Mastery"]))
end

function Settlement2.Templates.Special.fastBoats()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["Fast Boats"]))
end

function Settlement2.Templates.Special.tradableDragonToken()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["Dragon Token (Tradable)"]))
end

function Settlement2.Templates.Special.discountedPermanentDragon()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["Discounted Permanent Dragon"]))
end

function Settlement2.Templates.Special.permanentDarkBlade()
	return (Settlement.Templates.SpecialProduct.new(IdMap.Redeemable["Dark Blade"]))
end

function Settlement2.Templates.Special.holiday2025Box(p: string)
	return (Settlement.Templates.Box.new(IdMap.Redeemable[`x{p} Premium Holiday 2025 Box`]))
end

function Settlement2.Templates.Special.new(p: number)
	return Settlement.Templates.SpecialProduct.new(p)
end

Settlement2.Templates.Currency = {}

function Settlement2.Templates.Currency.money(p: number)
	return (Settlement.Templates.Currency.new(p, 0, Option.some(v.MONEY[p])))
end

function Settlement2.Templates.Currency.fragments(p: number)
	return (Settlement.Templates.Currency.new(0, p, Option.some(v.FRAGMENTS[p])))
end

function Settlement2.Templates.Currency.simulationData(p: number)
	assert(v.SIMULATION_DATA[p], (`invalid itemId for sim-data amount {p}`))
	return (Settlement.Templates.Item.new(IdMap.Material["Simulation Data"], "EtcItems", Option.some(p)))
end

function Settlement2.Templates.expBoost(p: number)
	return (Settlement.Templates.ExpBoost.new(p))
end

function Settlement2.Templates.masteryBoost(p: string, p2: number)
	return (Settlement.Templates.MasteryBoost.new(p, p2))
end

function Settlement2.Templates.economyItem(value, flag: boolean)
	if type(value) == "string" then
		value = ItemId.getId(value, "Redeemable"):unwrap()
	end

	assert(ItemConfig.match(value):unwrap().Index.IdType == "Redeemable", (`itemId {value} is not of type Redeemable`))
	return (Settlement.Templates.EconomyItem.new(value, flag))
end

return Settlement2