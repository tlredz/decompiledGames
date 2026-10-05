local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Types.AssetItem)
require(ReplicatedStorage.Data.Assets)
local t = require(ReplicatedStorage.Packages.t)
local interface = t.interface({
	LocalCFrame = t.CFrame,
	PlacedAt = t.number,
	GrowthDuration = t.optional(t.number),
	GrowthCreditSeconds = t.optional(t.number),
	NightGrowthPeriodIndex = t.optional(t.number),
	NightGrowthCreditSeconds = t.optional(t.number),
	ReadyAt = t.optional(t.number)
})
local interface2 = t.interface({
	LocalCFrame = t.array(t.number),
	PlacedAt = t.number,
	GrowthDuration = t.optional(t.number),
	GrowthCreditSeconds = t.optional(t.number),
	NightGrowthPeriodIndex = t.optional(t.number),
	NightGrowthCreditSeconds = t.optional(t.number),
	ReadyAt = t.optional(t.number)
})
local interface3 = t.interface({
	AssetCategory = t.string,
	AssetScale = t.number,
	AssetEyeColor = t.string,
	AssetColorSeed = t.number,
	AssetColorIndex = t.number,
	Mutations = t.optional(t.array(t.string)),
	BaseMutation = t.optional(t.string),
	AssetGender = t.optional(t.union(t.literal("Male"), t.literal("Female"))),
	AssetPersonality = t.optional(t.string),
	IsStolenDNA = t.optional(t.boolean),
	CreatorTemporary = t.optional(t.boolean),
	HasParasite = t.optional(t.boolean),
	ParasiteRemovedForHatch = t.optional(t.boolean),
	MechaRerollDone = t.optional(t.boolean),
	PurchaseId = t.optional(t.string),
	EggSkin = t.optional(t.string),
	Placement = t.optional(interface)
})
local interface4 = t.interface({
	AssetCategory = t.string,
	AssetScale = t.number,
	AssetEyeColor = t.string,
	AssetColorSeed = t.number,
	AssetColorIndex = t.number,
	Mutations = t.optional(t.array(t.string)),
	BaseMutation = t.optional(t.string),
	AssetGender = t.optional(t.union(t.literal("Male"), t.literal("Female"))),
	AssetPersonality = t.optional(t.string),
	IsStolenDNA = t.optional(t.boolean),
	CreatorTemporary = t.optional(t.boolean),
	HasParasite = t.optional(t.boolean),
	ParasiteRemovedForHatch = t.optional(t.boolean),
	MechaRerollDone = t.optional(t.boolean),
	PurchaseId = t.optional(t.string),
	EggSkin = t.optional(t.string),
	Placement = t.optional(interface2)
})
local interface5 = t.interface({
	AssetCategory = t.string,
	AssetScale = t.number,
	AssetEyeColor = t.string,
	AssetColorSeed = t.number,
	AssetColorIndex = t.number,
	Mutations = t.optional(t.array(t.string)),
	BaseMutation = t.optional(t.string),
	AssetGender = t.optional(t.union(t.literal("Male"), t.literal("Female"))),
	AssetPersonality = t.optional(t.string),
	IsStolenDNA = t.optional(t.boolean),
	CreatorTemporary = t.optional(t.boolean),
	HasParasite = t.optional(t.boolean),
	ParasiteRemovedForHatch = t.optional(t.boolean),
	MechaRerollDone = t.optional(t.boolean),
	PurchaseId = t.optional(t.string),
	EggSkin = t.optional(t.string),
	Placement = t.optional(interface),
	GrowthSpeedMultiplier = t.number
})
return {
	MAX_INVENTORY = 115,
	HATCH_RESULT_MECHA_UPGRADED = "MechaUpgraded",
	SchemaValidation = {
		EggPlacement = interface,
		EggInventory = t.map(t.string, interface4),
		PlaceEggRequest = t.interface({
			Uid = t.string,
			LocalCFrame = t.CFrame
		}),
		RuntimeEggOwnerClear = t.interface({
			OwnerUserId = t.number
		}),
		RuntimeEggOwnerUpdate = t.interface({
			OwnerUserId = t.number,
			Records = t.map(t.string, interface5)
		}),
		RuntimeEggSnapshot = t.array(t.interface({
			OwnerUserId = t.number,
			Records = t.map(t.string, interface5)
		})),
		RuntimeEggRecord = interface5,
		SavedEgg = interface3,
		SerializedEggPlacement = interface2,
		SerializedSavedEgg = interface4
	}
}