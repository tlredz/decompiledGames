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
	_id = "Frog",
	DisplayName = "Frog",
	Icon = "rbxassetid://114669220150056",
	Egg = table.freeze({
		DisplayName = "Frog Egg",
		Icon = "rbxassetid://103297453814736",
		GrowthTime = 15,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 3,
	IndexSpeedReward = 2000,
	DropWeight = 0.2,
	VisualOdds = 159.607838,
	ModelWeight = 3,
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
local animationId2 = "rbxassetid://117840973653687"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://117840973653687 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://90603625106827"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://90603625106827 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Common
v.BaseModelColor = Color3.new(0.29411765933036804, 0.5921568870544434, 0.29411765933036804)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.29411765933036804, 0.5921568870544434, 0.29411765933036804), 620 }),
	table.freeze({ Color3.new(0.4117647111415863, 0.5098039507865906, 0.21568627655506134), 170 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.3137255012989044, 0.1764705926179886), 95 }),
	table.freeze({ Color3.new(0.886274516582489, 0.13725490868091583, 1), 65 }),
	table.freeze({ Color3.new(0.21568627655506134, 0.47058823704719543, 0.47058823704719543), 35 }),
	table.freeze({ Color3.new(0.1568627506494522, 0.1764705926179886, 0.13725490868091583), 15 }),
	table.freeze({ Color3.new(1, 1, 1), 15 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 2.1
	}),
	SoundId = 137308803652619
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 105312001208106
})
return (table.freeze(v))