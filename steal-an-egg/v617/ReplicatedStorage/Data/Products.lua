local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local GameplayBalance = require(ReplicatedStorage.Shared.Flags.GameplayBalance)
local eggProducts = GameplayBalance.EggProducts
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local GeneratedProducts = require(script.Internal.GeneratedProducts)
local LimitedEgg = require(ReplicatedStorage.Data.LimitedEgg)
local MarketplaceValidator = require(script.Internal.MarketplaceValidator)
require(script.Internal.ProductTypes)
local Sakura = require(ReplicatedStorage.Data.Sakura)
local t = require(ReplicatedStorage.Packages.t)
local BillboardReward = require(script.Builders.BillboardReward)
local TreadmillAdEggBoost = require(script.Builders.TreadmillAdEggBoost)
local CashPack = require(script.Builders.CashPack)
local EggSkipGrowth = require(script.Builders.EggSkipGrowth)
local LimitedEgg2 = require(script.Builders.LimitedEgg)
local Money = require(script.Builders.Money)
local RiftRefresh = require(script.Builders.RiftRefresh)
local SamplePack = require(script.Builders.SamplePack)
local SamplePacks = require(ReplicatedStorage.Data.SamplePacks)
local ServerLuck = require(script.Builders.ServerLuck)
local ServerLuckExtension = require(script.Builders.ServerLuckExtension)
local SpeedBoost = require(script.Builders.SpeedBoost)
local SpeedPower = require(script.Builders.SpeedPower)
local TemporarySpeedBoost = require(script.Builders.TemporarySpeedBoost)
local directory = {}
local v2 = {}

local function enlist(p)
	local name = p.Name
	t.strict(t.string)(name)
	t.strict(t.number)(p.ProductId)

	if directory[name] ~= nil then
		error((`product "{name}" is listed twice`))
	end

	local v3 = v2[p.ProductId]

	if v3 ~= nil then
		error((`"{name}" reuses ProductId {p.ProductId} of "{v3.Name}"`))
	end

	directory[name] = p
	v2[p.ProductId] = p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requirePlayer(p)
	t.strict(t.instanceIsA("Player"))(p)
end

local function clientProfileLoaded()
	local Save = require(ReplicatedStorage.Shared.Save)

	if Save.Await() == nil then
		return false, "Data not loaded"
	end

	return true
end

local function creditWhenLoaded(p, _, _: string?)
	local Database = require(ServerScriptService.Library.Database)

	if Database.IsPlayerLoaded(p) then
		return "Credit"
	end

	return "Retry"
end

local function retiredDnaProduct(p: string, productId: number)
	local function refuse()
		return false, "DNA stealing is no longer available."
	end

	return {
		Name = p,
		ProductId = productId,
		DisplayName = p,
		Desc = "DNA stealing is no longer available.",
		Silent = true,
		Precheck = refuse,
		Authorize = refuse,
		Grant = refuse
	}
end

local function growAllEggsProduct(name: string)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function eggs()
		local Eggs = require(ServerScriptService.Controllers.Eggs)
		return Eggs
	end

	return {
		Name = name,
		DisplayName = "Grow All Eggs",
		Desc = "Finish growing all placed eggs.",
		ProductId = 3611613592,
		HoldWhilePending = true,
		Silent = true,
		Grant = function(p2)
			requirePlayer(p2) -- equivalent call inferred; original call site unknown
			return (eggs()).PurchaseGrowAll(p2)
		end,
		Precheck = function()
			local EggState = require(ReplicatedStorage.Client.EggState)
			return EggState.MayBuyGrowAll()
		end,
		Authorize = function(p2)
			requirePlayer(p2) -- equivalent call inferred; original call site unknown
			return (eggs()).CanPurchaseGrowAll(p2)
		end,
		ResolveFailedReceipt = creditWhenLoaded
	}
end

local function earningsBoostProduct(name: string)
	local PlayerEarningsBoost = require(ReplicatedStorage.Shared.Util.PlayerEarningsBoost)
	local configuredMultiplier = PlayerEarningsBoost.GetConfiguredMultiplier()
	local v3 = PlayerEarningsBoost.DURATION_SECONDS / 60

	-- equivalent calls inferred from this helper; original call sites unknown
	local function boostService()
		return require(ServerScriptService.Controllers.EarningsBoostService)
	end

	return {
		Name = name,
		DisplayName = `x{configuredMultiplier} Earnings ({v3}m)`,
		Desc = `Your pets earn {configuredMultiplier}x cash for {v3} minutes.`,
		ProductId = 3709963353,
		HoldWhilePending = true,
		Grant = function(p2)
			requirePlayer(p2) -- equivalent call inferred; original call site unknown
			local v4 = boostService() -- equivalent call inferred; original call site unknown
			return v4.Activate(p2)
		end,
		Precheck = clientProfileLoaded,
		Authorize = function(p2)
			requirePlayer(p2) -- equivalent call inferred; original call site unknown
			local v4 = boostService() -- equivalent call inferred; original call site unknown
			return v4.CanActivate(p2)
		end,
		ResolveFailedReceipt = creditWhenLoaded
	}
end

local function sakuraLuckBoostProduct(name: string, productId: number, k: number)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function bloomActive()
		return GameFlags.GreatBloomEnabled:Get() == true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sakuraService()
		return require(ServerScriptService.Controllers.SakuraService)
	end

	return {
		Name = name,
		DisplayName = `Sakura Luck Boost {k}`,
		Desc = `{Sakura.GetLuckMultiplier(k)}x Great Bloom odds for the egg inside the incubator ({k}/{Sakura.Incubator.MaxLuckBoosts}).`,
		ProductId = productId,
		HoldWhilePending = true,
		Grant = function(p3)
			requirePlayer(p3) -- equivalent call inferred; original call site unknown
			local v3 = sakuraService() -- equivalent call inferred; original call site unknown
			return v3.ActivateLuckBoost(p3, k)
		end,
		Precheck = function()
			if GameFlags.GreatBloomEnabled:Get() ~= true then
				return false, "The Great Bloom has ended"
			end

			local Save = require(ReplicatedStorage.Shared.Save)
			local v3 = Save.Await()

			if v3 == nil then
				return false, "Data not loaded"
			end

			return Sakura.CanBuyLuckBoost(v3.Sakura, k)
		end,
		Authorize = function(p3)
			requirePlayer(p3) -- equivalent call inferred; original call site unknown

			if GameFlags.GreatBloomEnabled:Get() ~= true then
				return false, "The Great Bloom has ended"
			end

			local v3 = sakuraService() -- equivalent call inferred; original call site unknown
			return v3.CanActivateLuckBoost(p3, k)
		end,
		ResolveFailedReceipt = function(p3, _, value: string?)
			if bloomActive() then
				local Database = require(ServerScriptService.Library.Database)

				if Database.IsPlayerLoaded(p3) then
					return "Credit"
				end

				return "Retry"
			else
				local Analytics = require(ServerScriptService.UserGenerated.Analytics)
				Analytics:LogPlayerEvent(p3, "PlayerRetiredProductReceipt", {
					ProductId = productId,
					Reason = value or "Unknown"
				})
				return "Satisfied"
			end
		end
	}
end

enlist(growAllEggsProduct("EggGrowAll"))
enlist(earningsBoostProduct("EarningsBoost2x"))
enlist(RiftRefresh("RiftRefresh", 3710888247))

for k, offer in SamplePacks.Offers do
	enlist(SamplePack(`SamplePack{k}`, offer.ProductId))
end

for k, v3 in {
	{
		ProductId = 3611606887,
		Minutes = 15
	},
	{
		ProductId = 3611606895,
		Minutes = 30
	},
	{
		ProductId = 3611606898,
		Minutes = 60
	},
	{
		ProductId = 3611606901,
		Minutes = 120
	},
	{
		ProductId = 3611606906,
		Minutes = 180
	},
	{
		ProductId = 3611606912,
		Minutes = 240
	},
	{
		ProductId = 3611606918,
		Minutes = 360
	},
	{
		ProductId = 3611606926,
		Minutes = 480
	},
	{
		ProductId = 3611606930,
		Minutes = 600
	},
	{
		ProductId = 3611606938,
		Minutes = 720
	}
} do
	enlist(EggSkipGrowth(`Instant Hatch ({k})`, v3.ProductId, v3.Minutes * 60))
end

for _, v3 in {
	{
		Config = LimitedEgg.Luminous,
		Name = "Limited Egg",
		Count = 1,
		ProductId = 3712476038
	},
	{
		Config = LimitedEgg.Luminous,
		Name = "Limited Egg x3",
		Count = 3,
		ProductId = 3712476039
	},
	{
		Config = LimitedEgg.Luminous,
		Name = "Limited Egg x10",
		Count = 10,
		ProductId = 3712476044
	},
	{
		Config = LimitedEgg.Luminous,
		Name = "Limited Egg x50",
		Count = 50,
		ProductId = 3712476050
	},
	{
		Config = LimitedEgg.Extinction,
		Name = "Extinction Egg",
		Count = 1,
		ProductId = 3714749344
	},
	{
		Config = LimitedEgg.Extinction,
		Name = "Extinction Egg x3",
		Count = 3,
		ProductId = 3714749375
	},
	{
		Config = LimitedEgg.Extinction,
		Name = "Extinction Egg x10",
		Count = 10,
		ProductId = 3714749397
	},
	{
		Config = LimitedEgg.Extinction,
		Name = "Extinction Egg x50",
		Count = 50,
		ProductId = 3714749414
	}
} do
	enlist(LimitedEgg2(v3.Name, v3.ProductId, v3.Count, v3.Config))
end

for _, v3 in {
	{
		Amount = 24000,
		ProductId = 3611606487
	},
	{
		Amount = 200000,
		ProductId = 3611606470
	},
	{
		Amount = 800000,
		ProductId = 3611606501
	},
	{
		Amount = 4000000,
		ProductId = 3611606493
	},
	{
		Amount = 8000000,
		ProductId = 3611606507
	}
} do
	enlist(Money(`Money_{v3.Amount}`, v3.ProductId))
end

for _, offer in CashPacks.Offers do
	enlist(CashPack(offer.Name, offer.ProductId))
end

for k, v3 in { 3709207454, 3709207509, 3709207563 } do
	enlist(sakuraLuckBoostProduct(`SakuraLuckBoost{k}`, v3, k))
end

for _, v3 in {
	{
		Multiplier = 2,
		ProductId = 3604958187
	},
	{
		Multiplier = 4,
		ProductId = 3604958083
	},
	{
		Multiplier = 8,
		ProductId = 3604957992
	}
} do
	enlist(ServerLuck(`ServerLuck_X{v3.Multiplier}`, v3.ProductId, v3.Multiplier))
end

for _, v3 in {
	{
		Minutes = 15,
		ProductId = 3604958348
	},
	{
		Minutes = 30,
		ProductId = 3604958272
	}
} do
	enlist(ServerLuckExtension(`ServerLuck_Extend{v3.Minutes}`, v3.ProductId, v3.Minutes))
end

for k, v3 in {
	3611606570,
	3611606611,
	3611606618,
	3611606628,
	3611606636,
	3611606645,
	3611606648,
	3611606653,
	3611606661,
	3611606588,
	3611606597,
	3611606604
} do
	enlist(SpeedBoost(`SpeedBoostTier{k}`, v3, k, 2 ^ k))
end

for _, v3 in {
	{
		Amount = 150000,
		ProductId = 3611606545
	},
	{
		Amount = 1000000,
		ProductId = 3611606516
	},
	{
		Amount = 10000000,
		ProductId = 3611606528
	},
	{
		Amount = 50000000,
		ProductId = 3611606552
	},
	{
		Amount = 500000000,
		ProductId = 3611606562
	},
	{
		Amount = 1000000000,
		ProductId = 3611606539
	}
} do
	enlist(SpeedPower(`SpeedPower_{v3.Amount}`, v3.ProductId))
end

for _, v3 in {
	{
		Rarity = "Common",
		ProductId = 3611606824
	},
	{
		Rarity = "Uncommon",
		ProductId = 3611606832
	},
	{
		Rarity = "Rare",
		ProductId = 3611606840
	},
	{
		Rarity = "Epic",
		ProductId = 3611606843
	},
	{
		Rarity = "Legendary",
		ProductId = 3611606849
	},
	{
		Rarity = "Mythic",
		ProductId = 3611606854
	},
	{
		Rarity = "Cosmic",
		ProductId = 3611606859
	},
	{
		Rarity = "Secret",
		ProductId = 3611606864
	},
	{
		Rarity = "Eternal",
		ProductId = 3611606875
	},
	{
		Rarity = "Divine",
		ProductId = 3611606880
	}
} do
	enlist(retiredDnaProduct(`Steal{v3.Rarity}`, v3.ProductId))
end

for _, v3 in {
	{
		Label = "10Minutes",
		Seconds = 600,
		ProductId = 3608561503
	},
	{
		Label = "30Minutes",
		Seconds = 1800,
		ProductId = 3608561464
	},
	{
		Label = "1Hour",
		Seconds = 3600,
		ProductId = 3608561433
	}
} do
	enlist(TemporarySpeedBoost(`TemporarySpeedBoost_{v3.Label}`, v3.ProductId, v3.Seconds))
end

for _, v3 in {
	{
		Variant = "Alt1",
		Control = 3711307995,
		Double = 3711308134,
		Quadruple = 3711308259
	},
	{
		Variant = "Alt2",
		Control = 3711039542,
		Double = 3711036110,
		Quadruple = 3711036196
	},
	{
		Variant = "Default",
		Control = 3711313393,
		Double = 3711313465,
		Quadruple = 3711313519
	}
} do
	for k, v4 in {
		Control = v3.Control,
		["2x"] = v3.Double,
		["4x"] = v3.Quadruple
	} do
		enlist(BillboardReward(`RVBillboard_{v3.Variant}_{k}`, v4))
	end
end

for _, v3 in {
	{
		Name = "TreadmillAdEggBoost",
		ProductId = 3714369091
	},
	{
		Name = "TreadmillAdEggBoost_DEV",
		ProductId = 3714368905
	},
	{
		Name = "TreadmillAdEggBoost_DEV2",
		ProductId = 3590880144
	}
} do
	enlist(TreadmillAdEggBoost(v3.Name, v3.ProductId))
end

for _, record in GeneratedProducts.Records do
	enlist(record)
end

if Constants.IS_STUDIO then
	local v3 = {}

	for k in directory do
		table.insert(v3, k)
	end

	table.sort(v3)
	task.spawn(function()
		for _, v4 in v3 do
			MarketplaceValidator.Validate(v4, directory[v4])
		end
	end)
end

table.freeze(directory)
table.freeze(v2)

local function ladder(fn)
	local v3 = {}

	for _, v4 in directory do
		if fn(v4) ~= nil then
			table.insert(v3, v4)
		end
	end

	table.sort(v3, function(a, b)
		return fn(a) < fn(b)
	end)
	return table.freeze(v3)
end

local v3 = ladder(function(p)
	return p.EggSkipGrowthMaxRemainingSeconds
end)
local v4 = ladder(function(p)
	return p.SpeedPowerReward
end)
local Products = {}
Products.Directory = directory
Products.TreadmillSpeedEquivalentOffers = GeneratedProducts.TreadmillSpeedEquivalentOffers

function Products.FromProductId(p: number)
	return v2[p]
end

function Products.ProductNameExists(p: string)
	if rawget(directory, p) == nil then
		return false, (`no product is registered under "{p}"`)
	end

	return true
end

function Products.GetEggSkipGrowthProduct(p: number)
	assert(p >= 0, "remaining seconds cannot be negative")

	if p <= eggProducts.MIN_SKIP_SECONDS then
		return nil
	end

	for _, v5 in v3 do
		if p <= v5.EggSkipGrowthMaxRemainingSeconds then
			return v5
		end
	end

	return assert(v3[#v3], "no egg skip-growth product is registered")
end

function Products.SmallestSufficientSpeedPowerProduct(p: number)
	t.strict(t.numberPositive)(p)

	for _, v5 in v4 do
		if p <= v5.SpeedPowerReward then
			return v5
		end
	end

	return (assert(v4[#v4], "no speed-power product is registered"))
end

return Products