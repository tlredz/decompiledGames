local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)

local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")

	local function setAnimationId()
		animation.AnimationId = animationId
	end

	if not pcall(setAnimationId) then
		warn((`Animation {animationId} is not shared with this experience`))
	end

	return animation
end

local v = {
	_id = "Depths Manta Ray",
	DisplayName = "Luminous Spirit Manta",
	Icon = "rbxassetid://98909828891785",
	Egg = table.freeze({
		DisplayName = "Luminous Spirit Manta Egg",
		Icon = "rbxassetid://103020287697704",
		ModelName = "Depths Reroll Egg",
		GrowthTime = 10,
		WeightKg = 6,
		HideRarity = true,
		IgnoreSizeGrowthMultiplier = true
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 500000000,
	IndexSpeedReward = 0,
	DropWeight = 0,
	VisualOdds = 412.5,
	ModelWeight = 450,
	Animations = 0,
	WalkAnimationReferenceSpeed = nil,
	Rarity = 0,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	BaseModelColor = 0,
	PossibleModelColors = 0,
	PlaceSound = nil,
	WalkSound = 0,
	RandomIdleSound = 0,
	LuckyBlockDropTable = nil,
	LuckyBlockDropTableType = nil,
	LuckyBlockLevelRange = nil,
	LuckyBlockOpenDuration = nil,
	DontRoll = true,
	CannotFuse = nil,
	GenderLocked = nil,
	AlbinosColorFullWhite = true
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://105989677028261"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://105989677028261 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://101971494384327"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://101971494384327 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Secret
v.BaseModelColor = Color3.fromRGB(75, 40, 135)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.fromRGB(75, 40, 135), 80 }),
	table.freeze({ Color3.fromRGB(86, 54, 120), 19 }),
	table.freeze({ Color3.fromRGB(255, 255, 255), 1 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 129118606287387
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 112060333280301
})
return (table.freeze(v))