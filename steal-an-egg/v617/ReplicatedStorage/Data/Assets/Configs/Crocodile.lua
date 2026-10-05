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
	_id = "Crocodile",
	DisplayName = "Crocodile",
	Icon = "rbxassetid://122868974506056",
	Egg = table.freeze({
		DisplayName = "Crocodile Egg",
		Icon = "rbxassetid://122378249879058",
		GrowthTime = 60,
		WeightKg = 3,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 420,
	IndexSpeedReward = 9000,
	DropWeight = 0.5,
	VisualOdds = 215470.581098,
	ModelWeight = 400,
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
local animationId2 = "rbxassetid://90280232778597"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://90280232778597 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://127622983417455"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://127622983417455 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Epic
v.BaseModelColor = Color3.new(0.3607843220233917, 0.40784314274787903, 0.23529411852359772)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.3607843220233917, 0.40784314274787903, 0.23529411852359772), 560 }),
	table.freeze({ Color3.new(0.21568627655506134, 0.29411765933036804, 0.1764705926179886), 210 }),
	table.freeze({ Color3.new(0.3529411852359772, 0.3137255012989044, 0.21568627655506134), 130 }),
	table.freeze({ Color3.new(0.13725490868091583, 0.1764705926179886, 0.125490203499794), 25 }),
	table.freeze({ Color3.new(1, 1, 1), 2 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 82231882756292
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 77086186021615
})
return (table.freeze(v))