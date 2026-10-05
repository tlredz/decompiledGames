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
	_id = "Tiger",
	DisplayName = "Tiger",
	Icon = "rbxassetid://140159309028586",
	Egg = table.freeze({
		DisplayName = "Tiger Egg",
		Icon = "rbxassetid://134641680880560",
		GrowthTime = 360,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 28000,
	IndexSpeedReward = 14400,
	DropWeight = 0.14285714285714285,
	VisualOdds = 1150976.057531318,
	ModelWeight = 260,
	Animations = 0,
	WalkAnimationReferenceSpeed = 10,
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
local animationId2 = "rbxassetid://114561164594465"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://114561164594465 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://71271079410070"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://71271079410070 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Mythic
v.BaseModelColor = Color3.new(1, 0.5333333611488342, 0.20000000298023224)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(1, 0.5333333611488342, 0.20000000298023224), 820 }),
	table.freeze({ Color3.new(0.9333333373069763, 0.8980392217636108, 0.8039215803146362), 120 }),
	table.freeze({ Color3.new(0.8313725590705872, 0.6627451181411743, 0.27843138575553894), 40 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 80252515692802
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 88142592932537
})
return (table.freeze(v))