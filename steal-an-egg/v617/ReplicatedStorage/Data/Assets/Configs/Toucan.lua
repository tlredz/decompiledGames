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
	_id = "Toucan",
	DisplayName = "Toucan",
	Icon = "rbxassetid://125683101618417",
	Egg = table.freeze({
		DisplayName = "Toucan Egg",
		Icon = "rbxassetid://133240723882442",
		GrowthTime = 40,
		WeightKg = 3,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 110,
	IndexSpeedReward = 8100,
	DropWeight = 0.5,
	VisualOdds = 215470.581098,
	ModelWeight = 5,
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
local animationId2 = "rbxassetid://103568539384204"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://103568539384204 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://93317338815787"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://93317338815787 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Rare
v.BaseModelColor = Color3.new(0.0313725508749485, 0.0313725508749485, 0.03529411926865578)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.0313725508749485, 0.0313725508749485, 0.03529411926865578), 760 }),
	table.freeze({ Color3.new(0.1764705926179886, 0.1764705926179886, 0.16470588743686676), 120 }),
	table.freeze({ Color3.new(0.9607843160629272, 0.9215686321258545, 0.8039215803146362), 80 }),
	table.freeze({ Color3.new(0.29411765933036804, 0.21568627655506134, 0.13725490868091583), 40 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 115370318218911
})
return (table.freeze(v))