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
	_id = "DeathstalkerScorpion",
	DisplayName = "Scorpion",
	Icon = "rbxassetid://95410883489917",
	Egg = table.freeze({
		DisplayName = "Scorpion Egg",
		Icon = "rbxassetid://94810083404486",
		GrowthTime = 300,
		WeightKg = 3,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 18500,
	IndexSpeedReward = 14400,
	DropWeight = 0.2,
	VisualOdds = 35911.763516,
	ModelWeight = 75,
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
local animationId2 = "rbxassetid://85777917853482"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://85777917853482 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://73290619201848"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://73290619201848 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Mythic
v.BaseModelColor = Color3.new(0.8352941274642944, 0.6313725709915161, 0.364705890417099)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.9176470637321472, 0.6941176652908325, 0.4000000059604645), 520 }),
	table.freeze({ Color3.new(0.686274528503418, 0.47058823704719543, 0.2549019753932953), 220 }),
	table.freeze({ Color3.new(0.7490196228027344, 0.5137255191802979, 0.35686275362968445), 150 }),
	table.freeze({ Color3.new(0.8627451062202454, 0.8039215803146362, 0.5882353186607361), 30 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 98032095284026
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 82428421778817
})
return (table.freeze(v))