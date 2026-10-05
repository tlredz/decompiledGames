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
	_id = "Finned Thresher",
	DisplayName = "Shark",
	Icon = "rbxassetid://125497863961128",
	Egg = table.freeze({
		DisplayName = "Shark Egg",
		Icon = "rbxassetid://71615245424079",
		GrowthTime = 240,
		WeightKg = 6,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 15000,
	IndexSpeedReward = 90000,
	DropWeight = 0,
	VisualOdds = 9500000000,
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
	WalkSound = nil,
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
local animationId2 = "rbxassetid://127775181505316"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://127775181505316 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://76392180822636"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://76392180822636 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Legendary
v.BaseModelColor = Color3.new(0, 0.27843138575553894, 0.4274509847164154)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0, 0.27843138575553894, 0.4274509847164154), 610 }),
	table.freeze({ Color3.new(0.1764705926179886, 0.29411765933036804, 0.3529411852359772), 190 }),
	table.freeze({ Color3.new(0.0784313753247261, 0.1764705926179886, 0.27450981736183167), 70 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 71821986721113
})
return (table.freeze(v))