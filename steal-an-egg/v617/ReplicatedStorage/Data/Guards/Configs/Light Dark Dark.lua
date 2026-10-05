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
		Looped = false,
		MaxDistance = 250,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://121596581308112",
		Volume = 5
	},
	AnimationBaseWalkSpeed = 28,
	AttackAnimation = AnimationAssets.Get("rbxassetid://122794232664512"),
	AttackSound = {
		Looped = false,
		MaxDistance = 150,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://138722127554208",
		Volume = 2
	},
	FlatRadius = 20,
	FootstepSound = {
		Looped = true,
		MaxDistance = 60,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://92275166182207",
		Volume = 1.5
	},
	HitDistance = 7,
	HomeImpulseBoostDistanceXZ = 300,
	IdleAnimation = AnimationAssets.Get("rbxassetid://105908120568207", frozen),
	Rarity = 0,
	SleepAnimation = 0,
	SleepSound = 0,
	WakeSound = 0,
	WalkAnimation = 0,
	WalkSpeed = 244.8,
	_id = "Light Dark Dark"
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage2.Data.Rarity).Rarities.LightDark
v.SleepAnimation = AnimationAssets.Get("rbxassetid://102075859346895", frozen)
v.SleepSound = {
	Looped = false,
	MaxDistance = 40,
	PlaybackSpeed = 1,
	SoundId = "rbxassetid://129416806869914",
	Volume = 0.800000011920929
}
v.WakeSound = {
	Looped = false,
	MaxDistance = 250,
	PlaybackSpeed = 1.0700000524520874,
	SoundId = "rbxassetid://96595477884583",
	Volume = 0.30000001192092896
}
v.WalkAnimation = AnimationAssets.Get("rbxassetid://134098549938118", frozen)
return table.freeze(v)