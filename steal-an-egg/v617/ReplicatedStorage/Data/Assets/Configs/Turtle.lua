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
	_id = "Turtle",
	DisplayName = "Turtle",
	Icon = "rbxassetid://90736612624734",
	Egg = table.freeze({
		DisplayName = "Turtle Egg",
		Icon = "rbxassetid://132237234794333",
		GrowthTime = 50,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 60,
	IndexSpeedReward = 2750,
	DropWeight = 0.3333333333333333,
	VisualOdds = 349.30572063219404,
	ModelWeight = 100,
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
	RandomIdleSound = nil,
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
local animationId2 = "rbxassetid://79398133579699"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://79398133579699 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://116555747328509"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://116555747328509 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Rare
v.BaseModelColor = Color3.new(0.364705890417099, 0.5254902243614197, 0.239215686917305)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.364705890417099, 0.5254902243614197, 0.239215686917305), 560 }),
	table.freeze({ Color3.new(0.3529411852359772, 0.3137255012989044, 0.1764705926179886), 220 }),
	table.freeze({ Color3.new(0.23529411852359772, 0.37254902720451355, 0.21568627655506134), 120 }),
	table.freeze({ Color3.new(0.5490196347236633, 0.45098039507865906, 0.2549019753932953), 75 }),
	table.freeze({ Color3.new(0.1764705926179886, 0.19607843458652496, 0.13725490868091583), 25 }),
	table.freeze({ Color3.new(1, 1, 1), 15 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 129596767024447
})
return (table.freeze(v))