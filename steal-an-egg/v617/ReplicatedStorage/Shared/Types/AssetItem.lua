local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Parent.Parent.Data.Assets)
local t = require(ReplicatedStorage.Packages.t)
local union = t.union(t.literal("Male"), t.literal("Female"))
local AssetItem = {
	AssetItemData = t.interface({
		Category = t.string,
		Mutations = t.array(t.string),
		BaseMutation = t.optional(t.string),
		Scale = t.number,
		Gender = t.optional(union),
		EyeColor = t.optional(t.string),
		ColorSeed = t.optional(t.number),
		ColorIndex = t.optional(t.number),
		IsFavorite = t.optional(t.boolean),
		GeneratedMoney = t.optional(t.number),
		LastTick = t.optional(t.number),
		PendingEggName = t.optional(t.string),
		Claimed = t.optional(t.boolean),
		LuckyBlockUnlockTimestamp = t.optional(t.number),
		LuckyBlockUnlockDuration = t.optional(t.number),
		LuckyBlockInstantUnlock = t.optional(t.boolean),
		InFuse = t.optional(t.boolean),
		SpecialLuckyBlockColumn = t.optional(t.number),
		SpecialLuckyBlockCapturedAt = t.optional(t.number),
		Personality = t.optional(t.string),
		HasBeenFirstPlaced = t.optional(t.boolean),
		IsStolenDNA = t.optional(t.boolean),
		CreatorTemporary = t.optional(t.boolean)
	})
}
AssetItem.AssetItemDataArray = t.array(AssetItem.AssetItemData)
AssetItem.SerializedAssetItemData = t.interface({
	Category = t.string,
	Mutations = t.array(t.string),
	BaseMutation = t.optional(t.string),
	Scale = t.number,
	Gender = t.optional(union),
	EyeColor = t.optional(t.string),
	ColorSeed = t.optional(t.number),
	ColorIndex = t.optional(t.number),
	IsFavorite = t.optional(t.boolean),
	GeneratedMoney = t.optional(t.number),
	LastTick = t.optional(t.number),
	PendingEggName = t.optional(t.string),
	Claimed = t.optional(t.boolean),
	LuckyBlockUnlockTimestamp = t.optional(t.number),
	LuckyBlockUnlockDuration = t.optional(t.number),
	LuckyBlockInstantUnlock = t.optional(t.boolean),
	InFuse = t.optional(t.boolean),
	SpecialLuckyBlockColumn = t.optional(t.number),
	SpecialLuckyBlockCapturedAt = t.optional(t.number),
	Personality = t.optional(t.string),
	HasBeenFirstPlaced = t.optional(t.boolean),
	IsStolenDNA = t.optional(t.boolean),
	CreatorTemporary = t.optional(t.boolean)
})
return AssetItem