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
	_id = "Depths Terra Snapper",
	DisplayName = "Luminous Terra Snapper",
	Icon = "rbxassetid://136624351055651",
	Egg = table.freeze({
		DisplayName = "Luminous Terra Snapper Egg",
		Icon = "rbxassetid://103020287697704",
		ModelName = "Depths Reroll Egg",
		GrowthTime = 10,
		WeightKg = 6,
		HideRarity = true,
		IgnoreSizeGrowthMultiplier = true
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 2500000000,
	IndexSpeedReward = 0,
	DropWeight = 0,
	VisualOdds = 1523.076923,
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
	WalkSound = nil,
	RandomIdleSound = nil,
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
local animationId2 = "rbxassetid://111704086981326"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://111704086981326 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://119158427903872"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://119158427903872 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Eternal
v.BaseModelColor = Color3.fromRGB(63, 76, 172)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.fromRGB(63, 76, 172), 80 }),
	table.freeze({ Color3.fromRGB(85, 80, 143), 19 }),
	table.freeze({ Color3.fromRGB(255, 255, 255), 1 })
})
return (table.freeze(v))