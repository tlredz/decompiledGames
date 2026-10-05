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
	_id = "Triceratops",
	DisplayName = "Triceratops",
	Icon = "rbxassetid://127014885618024",
	Egg = table.freeze({
		DisplayName = "Triceratops Egg",
		Icon = "rbxassetid://73329615832715",
		GrowthTime = 480,
		WeightKg = 3,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 1200000,
	IndexSpeedReward = 360000,
	DropWeight = 0.3333333333333333,
	VisualOdds = 13901.327813000002,
	ModelWeight = 3500,
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
local animationId2 = "rbxassetid://87496654880154"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://87496654880154 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://122861021000342"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://122861021000342 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Cosmic
v.BaseModelColor = Color3.new(0.35686275362968445, 0.30588236451148987, 0.2823529541492462)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.35686275362968445, 0.30588236451148987, 0.2823529541492462), 520 }),
	table.freeze({ Color3.new(0.4313725531101227, 0.37254902720451355, 0.2549019753932953), 180 }),
	table.freeze({ Color3.new(0.3333333432674408, 0.4117647111415863, 0.2549019753932953), 130 }),
	table.freeze({ Color3.new(0.5098039507865906, 0.47058823704719543, 0.37254902720451355), 110 }),
	table.freeze({ Color3.new(0.23529411852359772, 0.21568627655506134, 0.19607843458652496), 60 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 117490508431150
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 103866172195808
})
return (table.freeze(v))