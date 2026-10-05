local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local ActiveAssets = {
	LuckyBlockRewardDescriptor = t.interface({
		Category = t.string,
		Mutations = t.array(t.string),
		BaseMutation = t.optional(t.string),
		Scale = t.number
	})
}
ActiveAssets.LuckyBlockOpenAnimationPayload = t.interface({
	ownerUserId = t.number,
	uid = t.string,
	blockCategory = t.string,
	reward = ActiveAssets.LuckyBlockRewardDescriptor,
	dropTable = t.array(t.array(t.union(t.string, t.number))),
	pivot = t.CFrame,
	rollDuration = t.optional(t.number),
	skipRoll = t.optional(t.boolean)
})
ActiveAssets.SpecialLuckyBlockCaptureAnimationPayload = t.interface({
	ownerUserId = t.number,
	spawnId = t.string,
	category = t.string,
	mutations = t.array(t.string),
	baseMutation = t.optional(t.string),
	scale = t.number,
	pivot = t.CFrame,
	cagePivot = t.optional(t.CFrame),
	cageScale = t.optional(t.number)
})
ActiveAssets.SpecialLuckyBlockReadySignalPayload = t.interface({
	initialLoadComplete = t.boolean,
	screenReady = t.boolean,
	isReady = t.boolean,
	roundState = t.optional(t.string),
	spectating = t.optional(t.boolean),
	resultsOverlayOpen = t.optional(t.boolean),
	lobbyTutorialVisualState = t.optional(t.string)
})
return ActiveAssets