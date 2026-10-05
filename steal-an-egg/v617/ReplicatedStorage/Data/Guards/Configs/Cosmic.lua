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
			SoundId = "rbxassetid://135419634519147",
			Volume = 5
		},
		{
			Looped = false,
			MaxDistance = 250.48046875,
			PlaybackSpeed = 1,
			SoundId = "rbxassetid://136805444765117",
			Volume = 5
		}
	},
	AnimationBaseWalkSpeed = 28,
	AttackAnimation = AnimationAssets.Get("rbxassetid://73187024208060"),
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
	HitDistance = 4,
	HomeImpulseBoostDistanceXZ = 300,
	IdleAnimation = AnimationAssets.Get("rbxassetid://120083284147768", frozen),
	Rarity = 0,
	SleepAnimation = 0,
	SleepSound = 0,
	WakeSound = 0,
	WalkAnimation = 0,
	WalkSpeed = 200,
	_id = "Cosmic"
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage2.Data.Rarity).Rarities.Eternal
v.SleepAnimation = AnimationAssets.Get("rbxassetid://124788456180750", frozen)
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
v.WalkAnimation = AnimationAssets.Get("rbxassetid://103226370812076", frozen)
return table.freeze(v)