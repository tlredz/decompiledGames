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
			SoundId = "rbxassetid://76753017038067",
			Volume = 5
		},
		{
			Looped = false,
			MaxDistance = 250.48046875,
			PlaybackSpeed = 1,
			SoundId = "rbxassetid://122381958459272",
			Volume = 5
		}
	},
	AnimationBaseWalkSpeed = 35,
	AttackAnimation = AnimationAssets.Get("rbxassetid://86276843966778"),
	AttackSound = {
		Looped = false,
		MaxDistance = 150,
		PlaybackSpeed = 1.0700000524520874,
		SoundId = "rbxassetid://70850087419426",
		Volume = 2
	},
	EggPickupDistance = 18,
	FlatRadius = 20,
	FootstepSound = {
		Looped = true,
		MaxDistance = 60,
		PlaybackSpeed = 1,
		SoundId = "rbxassetid://103736662890224",
		Volume = 1.5
	},
	HitDistance = 5,
	HomeImpulseBoostDistanceXZ = 220,
	IdleAnimation = AnimationAssets.Get("rbxassetid://128670391346328", frozen),
	Rarity = 0,
	SleepAnimation = 0,
	SleepSound = 0,
	WakeSound = 0,
	WalkAnimation = 0,
	WalkSpeed = 113,
	_id = "Volcano"
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
v.Rarity = require(ReplicatedStorage2.Data.Rarity).Rarities.Mythic
v.SleepAnimation = AnimationAssets.Get("rbxassetid://106118773587652", frozen)
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
v.WalkAnimation = AnimationAssets.Get("rbxassetid://102298982391360", frozen)
return table.freeze(v)