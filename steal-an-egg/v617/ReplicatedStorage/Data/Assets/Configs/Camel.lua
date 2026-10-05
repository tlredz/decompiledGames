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
	_id = "Camel",
	DisplayName = "Camel",
	Icon = "rbxassetid://108762713931799",
	Egg = table.freeze({
		DisplayName = "Camel Egg",
		Icon = "rbxassetid://115488818954741",
		GrowthTime = 45,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 75,
	IndexSpeedReward = 9000,
	DropWeight = 0.5,
	VisualOdds = 7778.721339,
	ModelWeight = 700,
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
local animationId2 = "rbxassetid://132038053239618"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://132038053239618 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://88361956334028"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://88361956334028 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Rare
v.BaseModelColor = Color3.new(0.6901960968971252, 0.5333333611488342, 0.3529411852359772)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.7372549176216125, 0.6078431606292725, 0.364705890417099), 680 }),
	table.freeze({ Color3.new(0.5882353186607361, 0.4117647111415863, 0.23529411852359772), 180 }),
	table.freeze({ Color3.new(0.8627451062202454, 0.7647058963775635, 0.5490196347236633), 105 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.2549019753932953, 0.1568627506494522), 35 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 107100680371623
})
return (table.freeze(v))