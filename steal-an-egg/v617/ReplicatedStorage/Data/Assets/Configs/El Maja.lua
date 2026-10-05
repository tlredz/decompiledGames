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
	_id = "El Maja",
	DisplayName = "El Maja",
	Icon = "rbxassetid://77518688092604",
	Egg = table.freeze({
		DisplayName = "El Maja Egg",
		Icon = "rbxassetid://123897639279253",
		GrowthTime = 19800,
		WeightKg = 6,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 130000000,
	IndexSpeedReward = 180000,
	DropWeight = 0.125,
	VisualOdds = 66391535236.3381,
	ModelWeight = 90000,
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
	GenderLocked = "Male",
	AlbinosColorFullWhite = nil
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://132181117287223"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://132181117287223 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://75800532076044"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://75800532076044 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Eternal
v.BaseModelColor = Color3.new(0, 0.6000000238418579, 1)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0, 0.6000000238418579, 1), 900 }),
	table.freeze({ Color3.new(0, 0.1764705926179886, 0.37254902720451355), 100 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 115062059439564
})
return (table.freeze(v))