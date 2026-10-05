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
		SoundId = "rbxassetid://79235768556063",
		Volume = 5
	},
	AnimationBaseWalkSpeed = 28,
	AttackAnimation = AnimationAssets.Get("rbxassetid://79728098291967"),
	AttackSound = {
		Looped = false,
		MaxDistance = 150,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://95162478809038",
		Volume = 2
	},
	FlatRadius = 20,
	FootstepSound = {
		Looped = true,
		MaxDistance = 60,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://133144236442120",
		Volume = 1.5
	},
	HitDistance = 7,
	HomeImpulseBoostDistanceXZ = 300,
	IdleAnimation = AnimationAssets.Get("rbxassetid://98979439516885", frozen),
	Rarity = 0,
	SleepAnimation = 0,
	SleepSound = 0,
	WakeSound = 0,
	WalkAnimation = 0,
	WalkSpeed = 244.8,
	_id = "Light Dark Mixed"
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage2.Data.Rarity).Rarities.LightDark
v.SleepAnimation = AnimationAssets.Get("rbxassetid://107441624128628", frozen)
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
v.WalkAnimation = AnimationAssets.Get("rbxassetid://126775867049371", frozen)
return table.freeze(v)