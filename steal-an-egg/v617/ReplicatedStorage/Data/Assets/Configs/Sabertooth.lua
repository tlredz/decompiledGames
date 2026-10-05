local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local color = Color3.fromRGB(255, 255, 255)

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
	_id = "Sabertooth",
	DisplayName = "Sabertooth",
	Icon = "rbxassetid://91478668822122",
	Egg = table.freeze({
		DisplayName = "Sabertooth Egg",
		Icon = "rbxassetid://127756525542829",
		ModelName = "Extinction Egg",
		GrowthTime = 10,
		WeightKg = 6,
		HideRarity = true,
		IgnoreSizeGrowthMultiplier = true
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 5000000000,
	IndexSpeedReward = 0,
	DropWeight = 0,
	VisualOdds = 200,
	ModelWeight = 60000,
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
	AlbinosColorFullWhite = true
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://80503938261720"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://80503938261720 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://128003288273375"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://128003288273375 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Divine
v.BaseModelColor = color
v.PossibleModelColors = table.freeze({ table.freeze({ color, 1 }) })
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 72876489375653
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 108848883707065
})
return (table.freeze(v))