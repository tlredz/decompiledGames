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
	_id = "Swan",
	DisplayName = "Swan",
	Icon = "rbxassetid://125076114591417",
	Egg = table.freeze({
		DisplayName = "Swan Egg",
		Icon = "rbxassetid://125884067432601",
		GrowthTime = 120,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 320,
	IndexSpeedReward = 3500,
	DropWeight = 0.2,
	VisualOdds = 670.5118643718583,
	ModelWeight = 22,
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
	DontRoll = nil,
	CannotFuse = nil,
	GenderLocked = nil,
	AlbinosColorFullWhite = nil
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://113947385873952"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://113947385873952 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://136832792656489"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://136832792656489 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Epic
v.BaseModelColor = Color3.new(0.7921568751335144, 0.7960784435272217, 0.8196078538894653)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.7921568751335144, 0.7960784435272217, 0.8196078538894653), 200 }),
	table.freeze({ Color3.new(0.9607843160629272, 0.9607843160629272, 0.9333333373069763), 710 }),
	table.freeze({ Color3.new(0.21568627655506134, 0.21568627655506134, 0.21568627655506134), 70 }),
	table.freeze({ Color3.new(0.7450980544090271, 0.686274528503418, 0.6078431606292725), 20 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 99672949453572
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 109415901740965
})
return (table.freeze(v))