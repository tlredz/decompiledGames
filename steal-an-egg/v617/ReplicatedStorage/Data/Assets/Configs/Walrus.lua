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
	_id = "Walrus",
	DisplayName = "Walrus",
	Icon = "rbxassetid://129141571024477",
	Egg = table.freeze({
		DisplayName = "Walrus Egg",
		Icon = "rbxassetid://91972491841412",
		GrowthTime = 60,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 600,
	IndexSpeedReward = 14400,
	DropWeight = 0.5,
	VisualOdds = 4788235.136,
	ModelWeight = 200,
	Animations = 0,
	WalkSound = 0,
	WalkAnimationReferenceSpeed = nil,
	Rarity = 0,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	BaseModelColor = 0,
	PossibleModelColors = 0,
	PlaceSound = nil,
	RandomIdleSound = nil,
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
local animationId2 = "rbxassetid://98973083016392"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://98973083016392 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://106288976924750"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://106288976924750 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 81119519724182
})
v.Rarity = Rarity.Rarities.Epic
v.BaseModelColor = Color3.new(0.46666666865348816, 0.4431372582912445, 0.41960784792900085)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.46666666865348816, 0.4431372582912445, 0.41960784792900085), 620 }),
	table.freeze({ Color3.new(0.4117647111415863, 0.3333333432674408, 0.27450981736183167), 180 }),
	table.freeze({ Color3.new(0.6470588445663452, 0.5490196347236633, 0.47058823704719543), 140 }),
	table.freeze({ Color3.new(0.7450980544090271, 0.6470588445663452, 0.5686274766921997), 45 }),
	table.freeze({ Color3.new(0.27450981736183167, 0.23529411852359772, 0.21568627655506134), 15 }),
	table.freeze({ Color3.new(0.27843138575553894, 0.3686274588108063, 0.615686297416687), 7 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 110863031812081
})
return (table.freeze(v))