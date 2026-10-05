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
	_id = "Catfish",
	DisplayName = "Catfish",
	Icon = "rbxassetid://137813424891388",
	Egg = table.freeze({
		DisplayName = "Catfish Egg",
		Icon = "rbxassetid://120156933101223",
		GrowthTime = 30,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 12,
	IndexSpeedReward = 2500,
	DropWeight = 0.5,
	VisualOdds = 262.769001,
	ModelWeight = 35,
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
	AlbinosColorFullWhite = nil
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://77531242643307"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://77531242643307 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://97654952506163"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://97654952506163 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Uncommon
v.BaseModelColor = Color3.new(0.01568627543747425, 0.686274528503418, 0.9254902005195618)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.01568627543747425, 0.686274528503418, 0.9254902005195618), 470 }),
	table.freeze({ Color3.new(0.25882354378700256, 0.2705882489681244, 0.250980406999588), 230 }),
	table.freeze({ Color3.new(0.2549019753932953, 0.23529411852359772, 0.19607843458652496), 150 }),
	table.freeze({ Color3.new(0.45490196347236633, 1, 0.5921568870544434), 100 }),
	table.freeze({ Color3.new(0.13725490868091583, 0.13725490868091583, 0.13725490868091583), 50 }),
	table.freeze({ Color3.new(1, 1, 1), 15 })
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 131342808703780
})
return (table.freeze(v))