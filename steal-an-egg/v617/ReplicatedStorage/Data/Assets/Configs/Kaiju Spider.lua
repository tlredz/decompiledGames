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
	_id = "Kaiju Spider",
	DisplayName = "Spideron",
	Icon = "rbxassetid://139501051458007",
	Egg = table.freeze({
		DisplayName = "Spideron Egg",
		Icon = "rbxassetid://82570250248776",
		GrowthTime = 240,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 95000,
	IndexSpeedReward = 3778632,
	DropWeight = 0,
	VisualOdds = 1724000000000,
	ModelWeight = 600,
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
local animationId2 = "rbxassetid://110222166625963"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://110222166625963 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://77112176991013"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://77112176991013 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Legendary
v.BaseModelColor = Color3.new(0.8156862854957581, 0.7921568751335144, 0.7215686440467834)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.8156862854957581, 0.7921568751335144, 0.7215686440467834), 850 }),
	table.freeze({ Color3.new(0.6666666865348816, 0.529411792755127, 0.37254902720451355), 90 }),
	table.freeze({ Color3.new(0.47058823704719543, 0.47058823704719543, 0.4901960790157318), 48 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
return (table.freeze(v))