local Option = require(game.ReplicatedStorage.Packages.Option)
local Qualification = require(game.ReplicatedStorage.Economy.EconomyItem.Qualification)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
require(game.ReplicatedStorage.SaleService)
local Qualification2 = {
	Templates = {}
}
Qualification2.Templates.Item = {}

function Qualification2.Templates.Item.new(p: number, p2: string, p3, p4: number?, p5: number?, p6, p7)
	local unwrapped = ItemConfig.match(p):unwrap()
	local new = Qualification.Templates.ItemRange.new
	local storageKey = unwrapped.Index.StorageKey
	local idType = unwrapped.Index.IdType
	local v = Option.from(p4)
	local v2 = Option.from(p5)
	local v3 = Option.from(p6)
	local v4

	if p7 then
		v4 = Option.some(p7)
	else
		v4 = Option.none()
	end

	return (new(p2, storageKey, idType, p3, v, v2, v3, v4))
end

function Qualification2.Templates.Item.doesNotOwnFruitSkin(p: number, p2, p3)
	local unwrapped = ItemConfig.match(p):unwrap()
	assert(unwrapped.Index.IdType == "Skin", (`not a skin: {p}`))
	local new = Qualification.Templates.ItemRange.new
	local storageKey = unwrapped.Index.StorageKey
	local none = Option.none()
	local some = Option.some(0)
	local v4 = Option.from(p2)
	local v5

	if p3 then
		v5 = Option.some(p3)
	else
		v5 = Option.none()
	end

	return (new("RedeemLimit", storageKey, "Skin", "Recipient", none, some, v4, v5))
end

function Qualification2.Templates.Item.doesNotOwnSwordSkin(p: number, p2, p3)
	local unwrapped = ItemConfig.match(p):unwrap()
	assert(unwrapped.Index.IdType == "Skin", (`not a skin: {p}`))
	local new = Qualification.Templates.ItemRange.new
	local storageKey = unwrapped.Index.StorageKey
	local none = Option.none()
	local some = Option.some(0)
	local v4 = Option.from(p2)
	local v5

	if p3 then
		v5 = Option.some(p3)
	else
		v5 = Option.none()
	end

	return (new("RedeemLimit", storageKey, "Skin", "Recipient", none, some, v4, v5))
end

function Qualification2.Templates.Item.doesNotOwnProfileFullArt(p: number, p2, p3)
	local unwrapped = ItemConfig.match(p):unwrap()
	assert(unwrapped.Index.IdType == "ProfileFullArt", (`not a profile-full-art: {p}`))
	local new = Qualification.Templates.ItemRange.new
	local storageKey = unwrapped.Index.StorageKey
	local none = Option.none()
	local some = Option.some(0)
	local v4 = Option.from(p2)
	local v5

	if p3 then
		v5 = Option.some(p3)
	else
		v5 = Option.none()
	end

	return (new("RedeemLimit", storageKey, "ProfileFullArt", "Recipient", none, some, v4, v5))
end

function Qualification2.Templates.Item.doesNotOwnAuraSkin(p: number, p2, p3)
	local unwrapped = ItemConfig.match(p):unwrap()
	assert(unwrapped.Index.IdType == "Skin", (`not an aura skin: {p}`))
	local new = Qualification.Templates.ItemRange.new
	local storageKey = unwrapped.Index.StorageKey
	local none = Option.none()
	local some = Option.some(0)
	local v4 = Option.from(p2)
	local v5

	if p3 then
		v5 = Option.some(p3)
	else
		v5 = Option.none()
	end

	return (new("RedeemLimit", storageKey, "Skin", "Recipient", none, some, v4, v5))
end

function Qualification2.Templates.Item.hasNotLearnedAuraSkill(p, p2)
	local new = Qualification.Templates.Special.new
	local v3 = Option.from(p)
	local v4

	if p2 then
		v4 = Option.some(p2)
	else
		v4 = Option.none()
	end

	return (new("HasNotLearnedAuraSkill", "Recipient", v3, v4))
end

function Qualification2.Templates.Item.doesNotOwnFruitMutation(p: number, p2, p3)
	local unwrapped = ItemConfig.match(p):unwrap()
	assert(unwrapped.Index.IdType == "Mutation", (`not a fruit mutation: {p}`))
	local new = Qualification.Templates.ItemRange.new
	local storageKey = unwrapped.Index.StorageKey
	local none = Option.none()
	local some = Option.some(0)
	local v4 = Option.from(p2)
	local v5

	if p3 then
		v5 = Option.some(p3)
	else
		v5 = Option.none()
	end

	return (new("RedeemLimit", storageKey, "Mutation", "Recipient", none, some, v4, v5))
end

function Qualification2.Templates.Item.hasFruitEquipped(p: string, p2, p3)
	local unwrapped = ItemConfig.match(p, "Moveset"):unwrap()
	local new = Qualification.Templates.EquipState.new
	local storageKey = unwrapped.Index.StorageKey
	local idType = unwrapped.Index.IdType
	local v3 = Option.from(p2)
	local v4

	if p3 then
		v4 = Option.some(p3)
	else
		v4 = Option.none()
	end

	return (new("HasItemEquipped", storageKey, idType, "Recipient", v3, v4))
end

function Qualification2.Templates.Item.ownsPermanentFruit(p: string, p2, p3)
	return Qualification2.Templates.Item.new(
		ItemId.getId(p, "Moveset"):unwrap(),
		"RedeemLimit",
		"Recipient",
		1,
		nil,
		p2,
		p3
	)
end

function Qualification2.Templates.Item.ownsSword(p: string, p2, p3)
	return Qualification2.Templates.Item.new(
		ItemId.getId(p, "Moveset"):unwrap(),
		"RedeemLimit",
		"Recipient",
		1,
		nil,
		p2,
		p3
	)
end

function Qualification2.Templates.Item.notAlreadyRedeemed(p: number, p2, p3)
	return Qualification2.Templates.Item.new(p, "RedeemLimit", "Recipient", nil, 0, p2, p3)
end

function Qualification2.Templates.Item.notAlreadyStored(p: number, p2, p3)
	return Qualification2.Templates.Item.new(p, "StorageLimit", "Recipient", nil, 0, p2, p3)
end

function Qualification2.Templates.Item.maxPurchases(p: number, p2: number, p3, p4)
	return Qualification2.Templates.Item.new(p, "PurchaseLimit", "Recipient", nil, p2, p3, p4)
end

function Qualification2.Templates.Item.maxGiftsSent(p: number, p2: number, p3, p4)
	return Qualification2.Templates.Item.new(p, "GiftLimit", "Recipient", nil, p2, p3, p4)
end

Qualification2.Templates.Special = {}

function Qualification2.Templates.Special.no2xMoney(value, p, p2)
	local new = Qualification.Templates.Special.new
	local v3 = Option.from(p)
	local v4

	if p2 then
		v4 = Option.some(p2)
	else
		v4 = Option.none()
	end

	return (new("HasNoActiveBeliBoost", value or "Recipient", v3, v4))
end

function Qualification2.Templates.Special.noFastBoats(value, p, p2)
	local new = Qualification.Templates.Special.new
	local v3 = Option.from(p)
	local v4

	if p2 then
		v4 = Option.some(p2)
	else
		v4 = Option.none()
	end

	return (new("HasNoActiveBoatSpeedBoost", value or "Recipient", v3, v4))
end

function Qualification2.Templates.Special.no2xBossDrops(value, p, p2)
	local new = Qualification.Templates.Special.new
	local v3 = Option.from(p)
	local v4

	if p2 then
		v4 = Option.some(p2)
	else
		v4 = Option.none()
	end

	return (new("HasNoActiveBossDropsBoost", value or "Recipient", v3, v4))
end

function Qualification2.Templates.Special.noFruitNotifier(value, p, p2)
	local new = Qualification.Templates.Special.new
	local v3 = Option.from(p)
	local v4

	if p2 then
		v4 = Option.some(p2)
	else
		v4 = Option.none()
	end

	return (new("HasNoActiveFruitNotifier", value or "Recipient", v3, v4))
end

function Qualification2.Templates.Special.no2xMastery(value, p, p2)
	local new = Qualification.Templates.Special.new
	local v3 = Option.from(p)
	local v4

	if p2 then
		v4 = Option.some(p2)
	else
		v4 = Option.none()
	end

	return (new("HasNoActiveMasteryBoost", value or "Recipient", v3, v4))
end

function Qualification2.Templates.Special.noPermanentDragonDiscount(value, p, p2)
	local new = Qualification.Templates.Special.new
	local v3 = Option.from(p)
	local v4

	if p2 then
		v4 = Option.some(p2)
	else
		v4 = Option.none()
	end

	return (new("HasNoPermanentDragonDiscount", value or "Recipient", v3, v4))
end

function Qualification2.Templates.Special.noTradeableDragonToken(value, p, p2)
	local new = Qualification.Templates.Special.new
	local v3 = Option.from(p)
	local v4

	if p2 then
		v4 = Option.some(p2)
	else
		v4 = Option.none()
	end

	return (new("HasNoTradeableDragonToken", value or "Recipient", v3, v4))
end

function Qualification2.Templates.hasReachedSea(p: string, p2, p3)
	local v = p == "Sea1" and 1 or p == "Sea2" and 2 or 3
	local new = Qualification.Templates.ValueRange.new
	local some = Option.some(v)
	local none = Option.none()
	local v4 = Option.from(p2)
	local v5

	if p3 then
		v5 = Option.some(p3)
	else
		v5 = Option.none()
	end

	return (new("SeaLevelLimit", "Both", some, none, v4, v5))
end

function Qualification2.Templates.canBoostMastery(p, p2, p3)
	local new = Qualification.Templates.MasteryBoostable.new
	local v2 = Option.from(p2)
	local v3

	if p3 then
		v3 = Option.some(p3)
	else
		v3 = Option.none()
	end

	return (new(p, "Recipient", v2, v3))
end

function Qualification2.Templates.hasReachedLevel(p: number, p2, p3)
	local new = Qualification.Templates.ValueRange.new
	local some = Option.some(p)
	local none = Option.none()
	local v3 = Option.from(p2)
	local v4

	if p3 then
		v4 = Option.some(p3)
	else
		v4 = Option.none()
	end

	return (new("LevelLimit", "Both", some, none, v3, v4))
end

function Qualification2.Templates.hasFruitStorageAvailable(p: string, p2, p3: number, p4, p5)
	local new = Qualification.Templates.ItemRange.new
	local some = Option.some(p3)
	local none = Option.none()
	local v3 = Option.from(p4)
	local v4

	if p5 then
		v4 = Option.some(p5)
	else
		v4 = Option.none()
	end

	return (new("AvailableFruitStorage", p, p2, "Recipient", some, none, v3, v4))
end

function Qualification2.Templates.hasLessMoneyThan(p: number, p2, p3)
	local new = Qualification.Templates.ValueRange.new
	local none = Option.none()
	local some = Option.some(p)
	local v3 = Option.from(p2)
	local v4

	if p3 then
		v4 = Option.some(p3)
	else
		v4 = Option.none()
	end

	return (new("BeliLimit", "Recipient", none, some, v3, v4))
end

function Qualification2.Templates.hasLessFragmentsThan(p: number, p2, p3)
	local new = Qualification.Templates.ValueRange.new
	local none = Option.none()
	local some = Option.some(p)
	local v3 = Option.from(p2)
	local v4

	if p3 then
		v4 = Option.some(p3)
	else
		v4 = Option.none()
	end

	return (new("FragmentsLimit", "Recipient", none, some, v3, v4))
end

function Qualification2.Templates.minRobuxSpent(p: number, p2, p3)
	local new = Qualification.Templates.ValueRange.new
	local some = Option.some(p)
	local none = Option.none()
	local v3 = Option.from(p2)
	local v4

	if p3 then
		v4 = Option.some(p3)
	else
		v4 = Option.none()
	end

	return (new("RobuxSpentLimit", "Both", some, none, v3, v4))
end

function Qualification2.Templates.saleIsActive(p, p2, p3)
	local new = Qualification.Templates.SaleIsActive.new
	local v = Option.from(p2)
	local v2

	if p3 then
		v2 = Option.some(p3)
	else
		v2 = Option.none()
	end

	return (new(p, v, v2))
end

return Qualification2