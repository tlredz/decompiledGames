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
			SoundId = "rbxassetid://109513647043767",
			Volume = 5
		},
		{
			Looped = false,
			MaxDistance = 250.48046875,
			PlaybackSpeed = 1,
			SoundId = "rbxassetid://112789890097920",
			Volume = 5
		}
	},
	AnimationBaseWalkSpeed = 17,
	AttackAnimation = AnimationAssets.Get("rbxassetid://138307614547337"),
	AttackSound = {
		Looped = false,
		MaxDistance = 150,
		PlaybackSpeed = 1.0700000524520874,
		SoundId = "rbxassetid://100308696101952",
		Volume = 2
	},
	EggPickupDistance = 18,
	FlatRadius = 20,
	FootstepSound = {
		Looped = false,
		MaxDistance = 74.38033294677734,
		PlaybackSpeed = 1.0700000524520874,
		SoundId = "rbxassetid://89709728610870",
		Volume = 1.5
	},
	HitDistance = 5,
	HomeImpulseBoostDistanceXZ = 250,
	IdleAnimation = AnimationAssets.Get("rbxassetid://102403705437382", frozen),
	Rarity = 0,
	SleepAnimation = 0,
	SleepSound = 0,
	WakeSound = 0,
	WalkAnimation = 0,
	WalkSpeed = 130,
	_id = "Abyss Ocean"
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage2.Data.Rarity).Rarities.Cosmic
v.SleepAnimation = AnimationAssets.Get("rbxassetid://79122874973512", frozen)
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
v.WalkAnimation = AnimationAssets.Get("rbxassetid://128961185865478", frozen)
return table.freeze(v)