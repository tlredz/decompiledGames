local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local t = require(ReplicatedStorage.Packages.t)
local strictInterface = t.strictInterface({
	OwnerUserId = t.number,
	UID = t.string,
	ItemData = AssetItem.AssetItemData,
	MoneyPerSecond = t.number,
	Seed = t.number,
	IsFirstPlacement = t.optional(t.boolean)
})
local mapped = t.map(t.string, strictInterface)
local strictInterface2 = t.strictInterface({
	OwnerUserId = t.number,
	Records = mapped
})
return {
	SchemaValidation = {
		RuntimeAssetRecord = strictInterface,
		RuntimeAssetRecords = mapped,
		RuntimeAssetOwnerUpdate = strictInterface2,
		RuntimeAssetOwnerClear = t.strictInterface({
			OwnerUserId = t.number
		}),
		RuntimeAssetSnapshot = t.array(strictInterface2)
	}
}