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
	_id = "Shattered Drake",
	DisplayName = "Shattered Drake",
	Icon = "rbxassetid://133460635177491",
	Egg = table.freeze({
		DisplayName = "Shattered Drake Egg",
		Icon = "rbxassetid://124927737636564",
		ModelName = "Crystal Egg",
		GrowthTime = 60,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 800000000,
	IndexSpeedReward = 65000,
	DropWeight = 0,
	VisualOdds = 25000000,
	ModelWeight = 30000,
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
local animationId2 = "rbxassetid://89629859180827"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://89629859180827 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://93157054599286"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://93157054599286 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Eternal
v.BaseModelColor = Color3.fromRGB(0, 0, 0)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.fromRGB(0, 0, 0), 850 }),
	table.freeze({ Color3.fromRGB(187, 107, 198), 90 }),
	table.freeze({ Color3.fromRGB(152, 86, 168), 48 }),
	table.freeze({ Color3.fromRGB(57, 1, 68), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 127063996949067
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 88679077900730
})
return (table.freeze(v))