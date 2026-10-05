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
	_id = "Ember Dragon",
	DisplayName = "Ember Dragon",
	Icon = "rbxassetid://135400297612664",
	Egg = table.freeze({
		DisplayName = "Dragon Egg",
		Icon = "rbxassetid://124581147164560",
		GrowthTime = 60,
		WeightKg = 5,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 600000000,
	IndexSpeedReward = 80000,
	DropWeight = 0,
	VisualOdds = 50000,
	ModelWeight = 14000,
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
	AlbinosColorFullWhite = nil
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://134684952794789"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://134684952794789 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://110166896149574"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://110166896149574 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Secret
v.BaseModelColor = Color3.new(0.3803921639919281, 0.2823529541492462, 0.23529411852359772)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.3803921639919281, 0.2823529541492462, 0.23529411852359772), 700 }),
	table.freeze({ Color3.new(0.5607843399047852, 0.30980393290519714, 0.16470588743686676), 180 }),
	table.freeze({ Color3.new(0.27450981736183167, 0.1882352977991104, 0.14901961386203766), 108 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 0.9,
		Volume = 1.5
	}),
	SoundId = 95640392463828
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 30,
		Volume = 1.5
	}),
	SoundId = 99984406249141
})
return (table.freeze(v))