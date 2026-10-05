local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
return {
	MutationSpec = t.strictInterface({
		Id = t.string,
		Label = t.string,
		Tint = t.Color3,
		EarningsScalar = t.numberMin(1),
		RollWeight = t.numberMin(0),
		IconAssetId = t.optional(t.number),
		EggModelName = t.optional(t.string),
		EggDisplayName = t.optional(t.string),
		EggIcon = t.optional(t.string),
		Apply = t.callback,
		Clear = t.callback
	})
}