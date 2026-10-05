local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)

local function toggle(p: string, flag: boolean)
	return FastFlags.Replicated(p, Asserts.Boolean, flag)
end

local function bounded(p: string, p2: number, p3: number, p4: number)
	return FastFlags.Replicated(p, Asserts.Range(p2, p3), p4)
end

local function nonNegative(p: string, p2: number)
	return FastFlags.Replicated(p, Asserts.FiniteNonNegative, p2)
end

local function wholeNumber(p: string, p2: number)
	return FastFlags.Replicated(p, Asserts.IntegerNonNegative, p2)
end

local v = {
	StorefrontOpen = FastFlags.Replicated("Game.Storefront.Open", Asserts.Boolean, true),
	OneTimeRepeatGuard = FastFlags.Replicated("Game.Storefront.OneTimeRepeatGuard", Asserts.Boolean, true),
	ClientSidePrompts = FastFlags.Replicated("Game.Storefront.ClientSidePrompts", Asserts.Boolean, false),
	SoundEffects = FastFlags.Replicated("Game.Audio.SoundEffects", Asserts.Boolean, true),
	WorldOverlaysHidden = FastFlags.Replicated("Game.World.OverlaysHidden", Asserts.Boolean, false),
	ForbiddenIslandEnabled = FastFlags.Replicated("Game.ForbiddenIsland.Enabled", Asserts.Boolean, true),
	GreatBloomEnabled = FastFlags.Replicated("Game.GreatBloom.Enabled", Asserts.Boolean, false),
	FriendBoostCap = FastFlags.Replicated("Game.FriendBoost.Cap", Asserts.IntegerNonNegative, 4),
	FriendBoostPercentPerFriend = FastFlags.Replicated(
		"Game.FriendBoost.PercentPerFriend",
		Asserts.FiniteNonNegative,
		10
	),
	PetUpdateSchedulingEnabled = FastFlags.Replicated("ClientPerformance.Pets.SchedulingEnabled", Asserts.Boolean, true),
	DistantPetUpdateDistance = FastFlags.Replicated(
		"ClientPerformance.Pets.DistantUpdateDistance",
		Asserts.Range(128, 4096),
		300
	),
	DistantPetUpdateInterval = FastFlags.Replicated(
		"ClientPerformance.Pets.DistantUpdateInterval",
		Asserts.Range(0, 0.25),
		0.1
	),
	HiddenPetUpdateInterval = FastFlags.Replicated(
		"ClientPerformance.Pets.HiddenUpdateInterval",
		Asserts.Range(0, 0.25),
		0.1
	)
}
return table.freeze(v)