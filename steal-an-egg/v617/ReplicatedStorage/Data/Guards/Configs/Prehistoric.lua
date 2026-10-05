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
		SoundId = "rbxassetid://75664314250862",
		Volume = 5
	},
	AnimationBaseWalkSpeed = 30,
	AttackAnimation = AnimationAssets.Get("rbxassetid://72819921043071"),
	AttackSound = {
		Looped = false,
		MaxDistance = 300,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://95116072506206",
		Volume = 4
	},
	EggPickupDistance = 18,
	FlatRadius = 20,
	FootstepSound = {
		Looped = true,
		MaxDistance = 60,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://86392397661742",
		Volume = 1.5
	},
	HitDistance = 7,
	HomeImpulseBoostDistanceXZ = 275,
	IdleAnimation = AnimationAssets.Get("rbxassetid://85804925095766", frozen),
	Rarity = 0,
	SleepAnimation = 0,
	SleepSound = 0,
	WakeSound = 0,
	WalkAnimation = 0,
	WalkSpeed = 152,
	_id = "Prehistoric"
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage2.Data.Rarity).Rarities.Secret
v.SleepAnimation = AnimationAssets.Get("rbxassetid://133422374459463", frozen)
v.SleepSound = {
	Looped = false,
	MaxDistance = 107.4382553100586,
	PlaybackSpeed = 1,
	SoundId = "rbxassetid://129416806869914",
	Volume = 0
}
v.WakeSound = {
	Looped = false,
	MaxDistance = 250.48046875,
	PlaybackSpeed = 1.0700000524520874,
	SoundId = "rbxassetid://96595477884583",
	Volume = 0.30000001192092896
}
v.WalkAnimation = AnimationAssets.Get("rbxassetid://117274313338090", frozen)
return table.freeze(v)