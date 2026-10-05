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
	_id = "Kraken",
	DisplayName = "Kraken",
	Icon = "rbxassetid://136429320011912",
	Egg = table.freeze({
		DisplayName = "Kraken Egg",
		Icon = "rbxassetid://114986552390612",
		GrowthTime = 8100,
		WeightKg = 6,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 15000000,
	IndexSpeedReward = 144000,
	DropWeight = 0.14285714285714285,
	VisualOdds = 40284267734.10782,
	ModelWeight = 18000,
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
local animationId2 = "rbxassetid://77550298467205"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://77550298467205 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://125902579005259"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://125902579005259 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Secret
v.BaseModelColor = Color3.new(0.7686274647712708, 0.1568627506494522, 0.10980392247438431)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.7686274647712708, 0.1568627506494522, 0.10980392247438431), 460 }),
	table.freeze({ Color3.new(0.47058823704719543, 0.21568627655506134, 0.3333333432674408), 190 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.23529411852359772, 0.1764705926179886), 140 }),
	table.freeze({ Color3.new(0.7254902124404907, 0.4313725531101227, 0.27450981736183167), 110 }),
	table.freeze({ Color3.new(0.21568627655506134, 0.1764705926179886, 0.23529411852359772), 70 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 91640952661817
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 99264926798032
})
return (table.freeze(v))