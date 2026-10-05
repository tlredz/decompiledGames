local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local AreaEggs = {
	States = {
		Slot = "Slot",
		Carried = "Carried",
		Dropped = "Dropped",
		GuardCarried = "GuardCarried",
		Claimed = "Claimed"
	},
	DropReasons = {
		PlayerRequest = "PlayerRequest",
		GuardHit = "GuardHit",
		PlayerSlap = "PlayerSlap",
		Rewind = "Rewind",
		CharacterRemoving = "CharacterRemoving",
		HumanoidDied = "HumanoidDied",
		PlayerRemoving = "PlayerRemoving",
		External = "External",
		OutOfBounds = "OutOfBounds"
	}
}
local union = t.union(
	t.literal(AreaEggs.States.Slot),
	t.literal(AreaEggs.States.Carried),
	t.literal(AreaEggs.States.Dropped),
	t.literal(AreaEggs.States.GuardCarried),
	t.literal(AreaEggs.States.Claimed)
)
local union2 = t.union(
	t.literal(AreaEggs.DropReasons.PlayerRequest),
	t.literal(AreaEggs.DropReasons.GuardHit),
	t.literal(AreaEggs.DropReasons.PlayerSlap),
	t.literal(AreaEggs.DropReasons.Rewind),
	t.literal(AreaEggs.DropReasons.CharacterRemoving),
	t.literal(AreaEggs.DropReasons.HumanoidDied),
	t.literal(AreaEggs.DropReasons.PlayerRemoving),
	t.literal(AreaEggs.DropReasons.External),
	t.literal(AreaEggs.DropReasons.OutOfBounds)
)
local interface = t.interface({
	Uid = t.string,
	AreaId = t.string,
	NestId = t.string,
	AssetCategory = t.string,
	AssetScale = t.number,
	AssetEyeColor = t.string,
	AssetColorSeed = t.number,
	AssetColorIndex = t.number,
	Mutations = t.array(t.string),
	BaseMutation = t.optional(t.string),
	HasParasite = t.optional(t.boolean),
	NestScale = t.number,
	BottomCFrame = t.CFrame,
	BoundsCFrame = t.CFrame,
	BoundsSize = t.Vector3,
	State = union,
	CarrierUserId = t.optional(t.number),
	DroppedAt = t.optional(t.number),
	Version = t.number
})
AreaEggs.SchemaValidation = {
	AreaEggState = union,
	DropReason = union2,
	AreaEggRecord = interface,
	AreaEggSnapshot = t.interface({
		Records = t.array(interface),
		ServerTime = t.number
	}),
	AreaEggBatchUpdate = t.interface({
		UpdatedRecords = t.array(interface),
		RemovedUids = t.array(t.string),
		ServerTime = t.number
	}),
	AreaEggCarryRequest = t.interface({
		Uid = t.string,
		FirstAreaSlotKey = t.optional(t.string)
	}),
	AreaEggDropRequest = t.interface({
		Reason = t.optional(union2)
	}),
	AreaEggCarryState = t.interface({
		IsCarrying = t.boolean,
		Uid = t.optional(t.string),
		AreaId = t.optional(t.string),
		AssetCategory = t.optional(t.string),
		RunBackWakeDelayRequired = t.optional(t.boolean),
		GuardDisabled = t.optional(t.boolean),
		SpeedMultiplier = t.number
	}),
	AreaEggClaimFeedback = t.interface({
		AssetCategory = t.string,
		DisplayName = t.string,
		Rarity = t.string,
		Color = t.Color3,
		Position = t.Vector3
	})
}
return AreaEggs