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
	_id = "Mosasaurus",
	DisplayName = "Mosasaurus",
	Icon = "rbxassetid://124293259998827",
	Egg = table.freeze({
		DisplayName = "Mosasaurus Egg",
		Icon = "rbxassetid://110731551346220",
		GrowthTime = 21600,
		WeightKg = 6,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 180000000,
	IndexSpeedReward = 600000,
	DropWeight = 0.55,
	VisualOdds = 2773109151.841,
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
	WalkSound = nil,
	RandomIdleSound = 0,
	LuckyBlockDropTable = nil,
	LuckyBlockDropTableType = nil,
	LuckyBlockLevelRange = nil,
	LuckyBlockOpenDuration = nil,
	DontRoll = nil,
	CannotFuse = nil,
	GenderLocked = nil,
	AlbinosColorFullWhite = true
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://130987511514994"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://130987511514994 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://92570452388491"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://92570452388491 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Eternal
v.BaseModelColor = Color3.new(0.32156863808631897, 0.3686274588108063, 0.4941176474094391)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.32156863808631897, 0.3686274588108063, 0.4941176474094391), 540 }),
	table.freeze({ Color3.new(0.1764705926179886, 0.29411765933036804, 0.37254902720451355), 190 }),
	table.freeze({ Color3.new(0.23529411852359772, 0.3333333432674408, 0.29411765933036804), 120 }),
	table.freeze({ Color3.new(0.1568627506494522, 0.1764705926179886, 0.19607843458652496), 100 }),
	table.freeze({ Color3.new(0.4588235318660736, 0.4000000059604645, 0.21176470816135406), 120 }),
	table.freeze({ Color3.new(0.529411792755127, 0.5490196347236633, 0.529411792755127), 50 }),
	table.freeze({ Color3.new(1, 0, 0), 10 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 110377151729054
})
return (table.freeze(v))