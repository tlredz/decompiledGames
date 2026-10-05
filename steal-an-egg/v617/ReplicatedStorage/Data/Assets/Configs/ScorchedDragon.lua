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
	_id = "ScorchedDragon",
	DisplayName = "Scorched Dragon",
	Icon = "rbxassetid://71785777924134",
	Egg = table.freeze({
		DisplayName = "Dragon's Egg",
		Icon = "rbxassetid://114970669202722",
		GrowthTime = 10800,
		WeightKg = 40,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = true
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 35000000,
	IndexSpeedReward = 150000,
	DropWeight = 0,
	VisualOdds = 1000,
	ModelWeight = 120000,
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
	DontRoll = true,
	CannotFuse = nil,
	GenderLocked = nil,
	AlbinosColorFullWhite = nil
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://85591916692734"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://85591916692734 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://95766204290612"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://95766204290612 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Secret
v.BaseModelColor = Color3.new(0.3529411852359772, 0.2980392277240753, 0.25882354378700256)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.3529411852359772, 0.2980392277240753, 0.25882354378700256), 700 }),
	table.freeze({ Color3.new(0.20000000298023224, 0.18039216101169586, 0.16862745583057404), 180 }),
	table.freeze({ Color3.new(0.6666666865348816, 0.3333333432674408, 0.13725490868091583), 108 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 140401695659406
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 30,
		Volume = 1.5
	}),
	SoundId = 99984406249141
})
return (table.freeze(v))