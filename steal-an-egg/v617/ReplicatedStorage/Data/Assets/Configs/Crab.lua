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
	_id = "Crab",
	DisplayName = "Crustacia",
	Icon = "rbxassetid://76352927219607",
	Egg = table.freeze({
		DisplayName = "Crustacia Egg",
		Icon = "rbxassetid://126728057663017",
		GrowthTime = 360,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 130000,
	IndexSpeedReward = 2748096,
	DropWeight = 0,
	VisualOdds = 135000000000,
	ModelWeight = 1000,
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
local animationId2 = "rbxassetid://117215283003119"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://117215283003119 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://126728107034943"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://126728107034943 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Legendary
v.BaseModelColor = Color3.new(1, 0.8980392217636108, 0.8980392217636108)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(1, 0.8980392217636108, 0.8980392217636108), 850 }),
	table.freeze({ Color3.new(1, 0.7843137383460999, 0.8627451062202454), 90 }),
	table.freeze({ Color3.new(0.8823529481887817, 0.8823529481887817, 0.9215686321258545), 48 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
return (table.freeze(v))