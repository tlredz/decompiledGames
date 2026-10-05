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
		MaxDistance = 250.48046875,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://74748426849681",
		Volume = 5
	},
	AnimationBaseWalkSpeed = 28,
	AttackAnimation = AnimationAssets.Get("rbxassetid://112112045391587"),
	AttackSound = {
		Looped = false,
		MaxDistance = 150,
		PlaybackSpeed = 1.0700000524520874,
		SoundId = "rbxassetid://103435959847699",
		Volume = 2
	},
	FlatRadius = 20,
	FootstepSound = {
		Looped = true,
		MaxDistance = 60,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://85892053481113",
		Volume = 1.5
	},
	HitDistance = 7,
	HomeImpulseBoostDistanceXZ = 300,
	IdleAnimation = AnimationAssets.Get("rbxassetid://108535480817318", frozen),
	Rarity = 0,
	SleepAnimation = 0,
	SleepSound = 0,
	WakeSound = 0,
	WalkAnimation = 0,
	WalkSpeed = 222,
	_id = "Cherry Blossom"
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage2.Data.Rarity).Rarities.Divine
v.SleepAnimation = AnimationAssets.Get("rbxassetid://109844193123113", frozen)
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
v.WalkAnimation = AnimationAssets.Get("rbxassetid://75608548920054", frozen)
return table.freeze(v)