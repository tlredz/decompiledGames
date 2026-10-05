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
	_id = "Bronto",
	DisplayName = "Bronto",
	Icon = "rbxassetid://97379364436568",
	Egg = table.freeze({
		DisplayName = "Bronto Egg",
		Icon = "rbxassetid://102498197407436",
		GrowthTime = 660,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 1500000,
	IndexSpeedReward = 300000,
	DropWeight = 0.25,
	VisualOdds = 10773529.055,
	ModelWeight = 35000,
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
local animationId2 = "rbxassetid://99676847051723"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://99676847051723 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://93614636566946"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://93614636566946 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Cosmic
v.BaseModelColor = Color3.new(0.4117647111415863, 0.41960784792900085, 0.4745098054409027)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.4117647111415863, 0.41960784792900085, 0.4745098054409027), 440 }),
	table.freeze({ Color3.new(0.4313725531101227, 0.37254902720451355, 0.27450981736183167), 210 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.45098039507865906, 0.29411765933036804), 150 }),
	table.freeze({ Color3.new(0.5686274766921997, 0.5098039507865906, 0.37254902720451355), 120 }),
	table.freeze({ Color3.new(0.2549019753932953, 0.2549019753932953, 0.27450981736183167), 80 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 104739285394756
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 90507633553833
})
return (table.freeze(v))