local ReplicatedStorage = game:GetService("ReplicatedStorage")
local eggs = require(ReplicatedStorage.Shared.Flags.GameplayBalance).Eggs
local HttpService = game:GetService("HttpService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local AdminBoosts = require(ReplicatedStorage2.Shared.Util.AdminBoosts)
local Areas = require(ReplicatedStorage2.Data.Areas)
local AreaEggCycle = require(ReplicatedStorage2.Shared.Util.AreaEggCycle)
local Assets = require(ReplicatedStorage2.Data.Assets)
require(ReplicatedStorage2.Shared.Util.AssetGender)
local AssetItems = require(ReplicatedStorage2.Shared.Util.AssetItems)
local AssetLottery = require(ReplicatedStorage2.Shared.Util.AssetLottery)
local AssetPalette = require(ReplicatedStorage2.Shared.Util.AssetPalette)
require(ReplicatedStorage2.Shared.Types.AssetItem)
local Numbers = require(ReplicatedStorage2.Shared.Utils.Numbers)
local addCommas = Numbers.AddCommas
local Eggs = require(ReplicatedStorage2.Shared.Types.Eggs)
local EggSkins = require(ReplicatedStorage2.Data.EggSkins)
local Mutations = require(ReplicatedStorage2.Shared.Modules.Mutations)
local Assets2 = require(ReplicatedStorage2.Data.Assets)
local personalities = Assets2.Personalities
local t = require(ReplicatedStorage2.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local intersection2 = t.intersection(t.numberMin(0), t.numberMaxExclusive(1e999))
local intersection3 = t.intersection(t.integer, t.numberMin(0))
local strict = t.strict(t.boolean)
local strict2 = t.strict(intersection)
local strict3 = t.strict(t.optional(intersection2))
local strict4 = t.strict(t.optional(intersection3))
local strict5 = t.strict(intersection2)
local strict6 = t.strict(t.string)
local strict7 = t.strict(intersection3)
local strict8 = t.strict(t.optional(t.callback))
local strict9 = t.strict(t.optional(t.number))
local strict10 = t.strict(t.number)
local strict11 = t.strict(t.table)
local EggRecords = {
	ScaleHardCap = eggs.SCALE_HARD_CAP
}
local BalanceConfig = require(ReplicatedStorage2.Shared.Flags.BalanceConfig)
BalanceConfig.Changed:Connect(function()
	EggRecords.ScaleHardCap = eggs.SCALE_HARD_CAP
end)
local random = Random.new()
local v = {}

local function reloadGrowthBoosts()
	local temporaryGrowthBoosts = workspace:GetAttribute("TemporaryGrowthBoosts")

	if type(temporaryGrowthBoosts) ~= "string" or temporaryGrowthBoosts == "" then
		return
	end

	xpcall(function()
		v = HttpService:JSONDecode(temporaryGrowthBoosts)
	end, function()
		v = {}
	end)
end

workspace:GetAttributeChangedSignal("TemporaryGrowthBoosts"):Connect(reloadGrowthBoosts)
task.spawn(reloadGrowthBoosts)

-- equivalent calls inferred from this helper; original call sites unknown
local function bandBias(p, callback)
	local v2 = not callback and 1 or callback(p.min, p.max)
	strict2(v2)
	assert(v2 > 0, "A scale band bias has to be a positive multiplier")
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function growthCurve(assetScale: number)
	if assetScale <= eggs.FLAT_GROWTH_MAX_SCALE then
		return 1
	end

	if assetScale <= eggs.STEEP_GROWTH_MAX_SCALE then
		return (assetScale / eggs.FLAT_GROWTH_MAX_SCALE) ^ eggs.STEEP_GROWTH_POWER
	end

	return (math.min(
		eggs.TAIL_GROWTH_COEFFICIENT * (assetScale / eggs.STEEP_GROWTH_MAX_SCALE) ^ eggs.TAIL_GROWTH_POWER,
		eggs.TAIL_GROWTH_CAP
	))
end

local function boostedSecondsFor(instance)
	local joinTick

	if instance then
		joinTick = instance:GetAttribute("JoinTick")
	end

	if type(joinTick) ~= "number" then
		return 0
	end

	local total = 0

	for _, v2 in v do
		local v3 = math.max(v2.StartedAt, joinTick)
		total += math.floor((math.min(workspace:GetServerTimeNow(), v2.EndsAt) - v3) * v2.Multiplier)
	end

	return total
end

-- equivalent calls inferred from this helper; original call sites unknown
local function eggConfig(p: string)
	local v2 = Assets.Directory[p]
	assert(v2 ~= nil, (`Asset catalog carries no entry named {p}`))
	return v2
end

local function adminScaleBias()
	local multiplier = AdminBoosts.ReadMultiplier(AdminBoosts.EGG_SIZE)

	if multiplier <= 1 then
		return nil
	end

	return function(p: number, p2: number)
		if eggs.ADMIN_GROWS_BANDS_FROM <= p then
			return multiplier
		end

		if p2 <= eggs.ADMIN_SHRINKS_BANDS_UNTIL then
			return 1 / multiplier
		end

		return 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requireSchema(p)
	assert(Eggs.SchemaValidation.SavedEgg(p), "Saved egg failed its schema check")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function copyTiming(data)
	return {
		LocalCFrame = nil,
		PlacedAt = data.PlacedAt,
		ReadyAt = data.ReadyAt,
		GrowthDuration = data.GrowthDuration,
		GrowthCreditSeconds = data.GrowthCreditSeconds,
		NightGrowthPeriodIndex = data.NightGrowthPeriodIndex,
		NightGrowthCreditSeconds = data.NightGrowthCreditSeconds
	}
end

local function copyIdentity(data)
	local v2 = {
		AssetCategory = data.AssetCategory,
		AssetScale = data.AssetScale,
		AssetEyeColor = data.AssetEyeColor,
		AssetColorSeed = data.AssetColorSeed,
		AssetColorIndex = data.AssetColorIndex,
		AssetGender = data.AssetGender,
		AssetPersonality = data.AssetPersonality,
		BaseMutation = data.BaseMutation,
		Mutations = 0,
		IsStolenDNA = 0,
		CreatorTemporary = 0,
		HasParasite = 0,
		ParasiteRemovedForHatch = 0,
		MechaRerollDone = 0,
		PurchaseId = 0,
		EggSkin = 0,
		Placement = nil
	}
	local mutations

	if data.Mutations then
		mutations = table.clone(data.Mutations)
	end

	v2.Mutations = mutations
	v2.IsStolenDNA = data.IsStolenDNA
	v2.CreatorTemporary = data.CreatorTemporary
	v2.HasParasite = data.HasParasite
	v2.ParasiteRemovedForHatch = data.ParasiteRemovedForHatch
	v2.MechaRerollDone = data.MechaRerollDone
	v2.PurchaseId = data.PurchaseId
	v2.EggSkin = data.EggSkin
	return v2
end

local function slotOf(p)
	return p.Placement
end

local function cframeToComponents(cframe: CFrame)
	return { cframe:GetComponents() }
end

local function componentsToCFrame(list)
	return CFrame.new(table.unpack(list, 1, 12))
end

function EggRecords.DrawAssetScale(p, callback)
	strict11(eggs.SCALE_BANDS)
	strict9(eggs.SCALE_HARD_CAP)
	strict9(eggs.SCALE_DOUBLING_ODDS)
	strict8(callback)
	local v2 = p or Random.new()
	local total = 0

	for _, v3 in ipairs(eggs.SCALE_BANDS) do
		strict10(v3.min)
		strict10(v3.max)
		strict10(v3.weight)
		assert(v3.max >= v3.min, "A scale band cannot end below where it starts")
		assert(v3.weight > 0, "A scale band needs a weight above zero to be reachable")
		total += v3.weight * bandBias(v3, callback)
	end

	assert(total > 0, "No scale band is reachable: the weights total zero")
	local v3 = eggs.SCALE_BANDS[1]
	local v4 = v2:NextNumber() * total
	local total2 = 0

	for _, v6 in ipairs(eggs.SCALE_BANDS) do
		total2 += v6.weight * bandBias(v6, callback)

		if not (v4 <= total2) then
			continue
		end

		v3 = v6
		break
	end

	local v6 = v3.min + v2:NextNumber() * (v3.max - v3.min)

	while v6 * 2 <= eggs.SCALE_HARD_CAP and v2:NextNumber() <= eggs.SCALE_DOUBLING_ODDS do
		v6 *= 2
	end

	return v6
end

function EggRecords.EggModelName(p: string, p2, p3: string?, p4: string?)
	strict6(p)
	local v2 = EggSkins.Get(p4)

	if v2 ~= nil then
		return v2.ModelName
	end

	local modelName = (eggConfig(p)).Egg.ModelName

	if modelName == nil then
		return Mutations.EggModelName(p2, p3) or p
	end

	return modelName
end

function EggRecords.EggModelTemplate(p: string, p2, p3: string?, p4: string?)
	local eggModelName = EggRecords.EggModelName(p, p2, p3, p4)
	local model = ReplicatedStorage2.Assets.Models.Eggs:FindFirstChild(eggModelName)
	assert(
		model ~= nil,
		(`Egg model "{eggModelName}" for asset {p} is missing from ReplicatedStorage.Assets.Models.Eggs`)
	)
	assert(model:IsA("Model"), (`Egg model "{eggModelName}" must be a Model`))
	return model
end

function EggRecords.Normalize(data)
	local settleFields = AssetPalette.SettleFields(
		data.AssetCategory,
		data.AssetEyeColor,
		data.AssetColorSeed,
		data.AssetColorIndex
	)
	local clone = table.clone(data)
	clone.AssetEyeColor = settleFields.EyeColor
	clone.AssetColorSeed = settleFields.ColorSeed
	clone.AssetColorIndex = settleFields.ColorIndex
	return clone
end

function EggRecords.EncodePlacement(data)
	return {
		PlacedAt = data.PlacedAt,
		ReadyAt = data.ReadyAt,
		GrowthDuration = data.GrowthDuration,
		GrowthCreditSeconds = data.GrowthCreditSeconds,
		NightGrowthPeriodIndex = data.NightGrowthPeriodIndex,
		NightGrowthCreditSeconds = data.NightGrowthCreditSeconds,
		LocalCFrame = { data.LocalCFrame:GetComponents() }
	}
end

function EggRecords.DecodePlacement(data)
	local v2 = copyTiming(data) -- equivalent call inferred; original call site unknown
	local localCFrame = data.LocalCFrame
	v2.LocalCFrame = CFrame.new(table.unpack(localCFrame, 1, 12))
	return v2
end

function EggRecords.Encode(p)
	local normalized = EggRecords.Normalize(p)
	local v2 = copyIdentity(normalized)
	local placement = normalized.Placement
	local placement2

	if placement then
		placement2 = EggRecords.EncodePlacement(placement)
	end

	v2.Placement = placement2
	return v2
end

function EggRecords.Decode(p)
	local v2 = copyIdentity(p)
	local placement = p.Placement
	local placement2

	if placement then
		placement2 = EggRecords.DecodePlacement(placement)
	end

	v2.Placement = placement2
	return EggRecords.Normalize(v2)
end

function EggRecords.GrowthSpeedMultiplier(flag: boolean)
	strict(flag)

	if flag then
		return 1 + eggs.X2_GROWTH_BONUS
	end

	return 1
end

function EggRecords.GrowthDuration(data)
	requireSchema(data) -- equivalent call inferred; original call site unknown
	local v2 = assert(data.Placement, "Growth duration is only defined for a placed egg")

	if v2.GrowthDuration ~= nil then
		return v2.GrowthDuration
	end

	strict2(data.AssetScale)
	assert(data.AssetScale > 0, "Growth duration needs a positive asset scale")
	local egg = (eggConfig(data.AssetCategory)).Egg

	if egg.IgnoreSizeGrowthMultiplier then
		return egg.GrowthTime
	end

	local growthTime = egg.GrowthTime
	local v3 = growthCurve(data.AssetScale) -- equivalent call inferred; original call site unknown
	return growthTime * v3
end

function EggRecords.GrowthCredit(p)
	local placement = p.Placement
	local selected = placement == nil and 0 or placement.GrowthCreditSeconds or 0
	strict5(selected)
	return selected
end

function EggRecords.GrowthAlpha(p, p2: number, p3: number, value: number?, p4)
	strict2(p2)
	strict2(p3)
	strict3(value)
	assert(p3 > 0, "The growth speed multiplier has to be above zero")
	local placement = p.Placement

	if placement == nil then
		return 0
	end

	if placement.ReadyAt ~= nil then
		return 1
	end

	local growthDuration = EggRecords.GrowthDuration(p)

	if growthDuration <= 0 then
		return 1
	end

	local v2 = EggRecords.GrowthCredit(p) + (value or 0) + boostedSecondsFor(p4)
	return (math.clamp(((p2 - placement.PlacedAt) * p3 + v2) / growthDuration, 0, 1))
end

function EggRecords.GrowthSecondsRemaining(p, p2: number, p3: number, value: number?, p4)
	strict2(p2)
	strict2(p3)
	strict3(value)
	assert(p3 > 0, "The growth speed multiplier has to be above zero")
	local v2 = assert(p.Placement, "Remaining growth is only defined for a placed egg")

	if v2.ReadyAt ~= nil then
		return 0
	end

	local v3 = EggRecords.GrowthCredit(p) + (value or 0) + boostedSecondsFor(p4)
	local v4 = (p2 - v2.PlacedAt) * p3
	return (math.max(0, EggRecords.GrowthDuration(p) - v4 - v3))
end

function EggRecords.WallSecondsRemaining(p, p2: number, p3: number, p4: number?)
	local growthSecondsRemaining = EggRecords.GrowthSecondsRemaining(p, p2, p3, p4)

	if growthSecondsRemaining <= 0 then
		return 0
	end

	return growthSecondsRemaining / p3
end

function EggRecords.IsGrown(p, p2: number, p3: number, p4: number?, p5)
	return EggRecords.GrowthAlpha(p, p2, p3, p4, p5) >= 1
end

function EggRecords.CommittedNightCredit(p, p2: number)
	strict7(p2)
	local placement = p.Placement

	if placement == nil then
		return 0
	end

	strict4(placement.NightGrowthPeriodIndex)
	local selected = placement.NightGrowthPeriodIndex ~= p2 and 0 or placement.NightGrowthCreditSeconds or 0
	strict5(selected)
	return selected
end

function EggRecords.NightCreditAt(p, p2: number, p3: number, p4: number, p5: number)
	strict2(p2)
	strict2(p3)
	strict2(p4)
	strict7(p5)
	assert(p3 > 0, "The growth speed multiplier has to be above zero")
	local placement = p.Placement

	if placement == nil or placement.ReadyAt ~= nil or p4 < placement.PlacedAt then
		return 0
	end

	local committedNightCredit = EggRecords.CommittedNightCredit(p, p5)
	local v2 = EggRecords.GrowthSecondsRemaining(p, p4, p3) + committedNightCredit
	return (math.max(0, math.min(AreaEggCycle.NightGrowthCreditAt(p2, p4), v2) - committedNightCredit))
end

function EggRecords.CurrentNightCredit(p, p2: number, p3: number)
	if not AreaEggCycle.IsNightPhase(p2) then
		return 0
	end

	local nightStartTime = AreaEggCycle.NightStartTime(p2)
	local v2 = nightStartTime + AreaEggCycle.NightLengthSeconds()
	local periodIndexAt = AreaEggCycle.PeriodIndexAt(v2)
	return EggRecords.NightCreditAt(p, p2, p3, nightStartTime, periodIndexAt)
end

function EggRecords.ServerGrowthBoostMultiplier()
	local total = 0

	for _, v2 in v do
		total += v2.Multiplier
	end

	return total
end

function EggRecords.ServerGrowthBoostEndsAt()
	local v2 = 0

	for _, v3 in v do
		v2 = math.max(v2, v3.EndsAt)
	end

	return v2
end

function EggRecords.NewEgg(assetCategory: string, p2)
	strict6(assetCategory)
	local v2 = p2 or random
	local mutations = AssetLottery.DrawMutations(nil, nil, v2, AdminBoosts.ReadMultiplier(AdminBoosts.MUTATION_LUCK))
	local v4 = AssetPalette.DrawFields(assetCategory, v2)
	local drawAssetScale = EggRecords.DrawAssetScale
	local multiplier = AdminBoosts.ReadMultiplier(AdminBoosts.EGG_SIZE)
	local v5 = {
		AssetCategory = assetCategory,
		AssetScale = drawAssetScale(v2, not (multiplier <= 1) and function(p3: number, p4: number)
			if eggs.ADMIN_GROWS_BANDS_FROM <= p3 then
				return multiplier
			end

			if p4 <= eggs.ADMIN_SHRINKS_BANDS_UNTIL then
				return 1 / multiplier
			end

			return 1
		end or nil),
		AssetEyeColor = v4.EyeColor,
		AssetColorSeed = v4.ColorSeed,
		AssetColorIndex = v4.ColorIndex,
		Mutations = mutations,
		BaseMutation = mutations[1]
	}
	local savedEgg, v6 = Eggs.SchemaValidation.SavedEgg(v5)
	assert(savedEgg, v6)
	return v5
end

function EggRecords.ToAssetItemData(data)
	requireSchema(data) -- equivalent call inferred; original call site unknown
	local v2 = {
		Category = data.AssetCategory,
		Scale = data.AssetScale,
		EyeColor = data.AssetEyeColor,
		ColorSeed = data.AssetColorSeed,
		ColorIndex = data.AssetColorIndex,
		Mutations = data.Mutations or {},
		BaseMutation = data.BaseMutation,
		Gender = data.AssetGender,
		Personality = data.AssetPersonality,
		IsStolenDNA = data.IsStolenDNA,
		CreatorTemporary = data.CreatorTemporary
	}
	return (personalities.CreateNewItemData(v2))
end

function EggRecords.SellPrice(p)
	requireSchema(p) -- equivalent call inferred; original call site unknown
	local clone = table.clone(EggRecords.ToAssetItemData(p))
	clone.Mutations = {}
	clone.BaseMutation = nil
	return AssetItems.SalePrice(clone) * eggs.SELL_PRICE_SHARE
end

function EggRecords.WeightKgForScale(category: string, scale: number)
	strict6(category)
	strict2(scale)
	return AssetItems.WeightKg({
		Category = category,
		Scale = scale,
		Mutations = {}
	})
end

function EggRecords.WeightKg(p)
	requireSchema(p) -- equivalent call inferred; original call site unknown
	return EggRecords.WeightKgForScale(p.AssetCategory, p.AssetScale)
end

function EggRecords.WeightLabel(p)
	return (`{addCommas(EggRecords.WeightKg(p))}Kg`)
end

function EggRecords.EggIcon(data)
	local v2 = EggSkins.Get(data.EggSkin)

	if v2 ~= nil then
		return v2.Icon
	end

	local icon = Mutations.EggIcon(data.Mutations, data.BaseMutation)

	if not icon then
		icon = (eggConfig(data.AssetCategory)).Egg.Icon
	end

	return icon
end

function EggRecords.DisplayName(data)
	requireSchema(data) -- equivalent call inferred; original call site unknown
	local v2 = EggSkins.Get(data.EggSkin)

	if v2 ~= nil then
		return v2.DisplayName
	end

	local eggDisplayName = Mutations.EggDisplayName(data.Mutations, data.BaseMutation)

	if eggDisplayName then
		return eggDisplayName
	end

	local _id = (eggConfig(data.AssetCategory)).Rarity._id

	for _, v3 in pairs(Areas.Directory) do
		for _, v4 in ipairs(v3.DropTable) do
			local v5 = v4[1]

			if v5 == data.AssetCategory or v5 == _id then
				return (`{v3.DisplayName} Egg`)
			end
		end
	end

	return "Egg"
end

function EggRecords.DisplayNameWithWeight(p)
	return (`{EggRecords.DisplayName(p)} ({EggRecords.WeightLabel(p)})`)
end

return EggRecords