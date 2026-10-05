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
	_id = "Mire Fox",
	DisplayName = "Fox",
	Icon = "rbxassetid://96639152572865",
	Egg = table.freeze({
		DisplayName = "Fox Egg",
		Icon = "rbxassetid://122218902574805",
		GrowthTime = 90,
		WeightKg = 1,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 180,
	IndexSpeedReward = 720,
	DropWeight = 0.14285714285714285,
	VisualOdds = 10.773529,
	ModelWeight = 28,
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
local animationId2 = "rbxassetid://115440197758670"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://115440197758670 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://107607987905386"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://107607987905386 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Epic
v.BaseModelColor = Color3.new(1, 0.2823529541492462, 0)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(1, 0.2823529541492462, 0), 760 }),
	table.freeze({ Color3.new(0.48627451062202454, 0.3137255012989044, 0.18431372940540314), 120 }),
	table.freeze({ Color3.new(0.9215686321258545, 0.8235294222831726, 0.6470588445663452), 70 }),
	table.freeze({ Color3.new(0.1764705926179886, 0.16470588743686676, 0.14901961386203766), 35 }),
	table.freeze({ Color3.new(0.9607843160629272, 0.9607843160629272, 0.9215686321258545), 15 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 124821449139609
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 140069693056979
})
return (table.freeze(v))