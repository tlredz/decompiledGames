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
	_id = "Gorilla",
	DisplayName = "Gorilla",
	Icon = "rbxassetid://117411686345819",
	Egg = table.freeze({
		DisplayName = "Gorilla Egg",
		Icon = "rbxassetid://83787014176548",
		GrowthTime = 120,
		WeightKg = 3,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 4800,
	IndexSpeedReward = 9900,
	DropWeight = 0.3333333333333333,
	VisualOdds = 294259.18734308693,
	ModelWeight = 190,
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
local animationId2 = "rbxassetid://74956622750880"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://74956622750880 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://97501167000723"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://97501167000723 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Legendary
v.BaseModelColor = Color3.new(0.15294118225574493, 0.15294118225574493, 0.15294118225574493)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.15294118225574493, 0.15294118225574493, 0.15294118225574493), 720 }),
	table.freeze({ Color3.new(0.2549019753932953, 0.2549019753932953, 0.2549019753932953), 180 }),
	table.freeze({ Color3.new(0.4117647111415863, 0.4117647111415863, 0.3921568691730499), 80 }),
	table.freeze({ Color3.new(0.09803921729326248, 0.09803921729326248, 0.09803921729326248), 20 }),
	table.freeze({ Color3.new(0.929411768913269, 0.9176470637321472, 0.9176470637321472), 2 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 138687597486095
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 131453269610048
})
return (table.freeze(v))