local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationAssets = require(ReplicatedStorage.Shared.Utils.AnimationAssets)
require(script.Parent.Parent.Types)
local frozen = table.freeze({
	DropWeight = 1,
	Looped = true,
	Play = { 0.15 },
	Stop = { 0.5 }
})
local v = {
	AfterWakeSound = {
		{
			Looped = false,
			MaxDistance = 250.48046875,
			PlaybackSpeed = 1,
			SoundId = "rbxassetid://110971572672011",
			Volume = 5
		},
		{
			Looped = false,
			MaxDistance = 250.48046875,
			PlaybackSpeed = 1,
			SoundId = "rbxassetid://71105135143267",
			Volume = 5
		}
	},
	AnimationBaseWalkSpeed = 14,
	AttackAnimation = AnimationAssets.Get("rbxassetid://137152617410120"),
	AttackSound = {
		Looped = false,
		MaxDistance = 150,
		PlaybackSpeed = 1.0700000524520874,
		SoundId = "rbxassetid://127853591688222",
		Volume = 2
	},
	FlatRadius = 20,
	FootstepSound = {
		Looped = true,
		MaxDistance = 60,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://95492669493151",
		Volume = 1.5
	},
	HitDistance = 3,
	HomeImpulseBoostDistanceXZ = 160,
	IdleAnimation = AnimationAssets.Get("rbxassetid://129822945034773", frozen),
	Rarity = 0,
	SleepAnimation = 0,
	SleepSound = 0,
	WakeSound = 0,
	WalkAnimation = 0,
	WalkSpeed = 82,
	_id = "Jungle"
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage2.Data.Rarity).Rarities.Epic
v.SleepAnimation = AnimationAssets.Get("rbxassetid://80254440617270", frozen)
v.SleepSound = {
	Looped = false,
	MaxDistance = 40,
	PlaybackSpeed = 1,
	SoundId = "rbxassetid://129416806869914",
	Volume = 0.800000011920929
}
v.WakeSound = {
	Looped = false,
	MaxDistance = 250.48046875,
	PlaybackSpeed = 1.0700000524520874,
	SoundId = "rbxassetid://96595477884583",
	Volume = 0.30000001192092896
}
v.WalkAnimation = AnimationAssets.Get("rbxassetid://102697421744284", frozen)
return table.freeze(v)