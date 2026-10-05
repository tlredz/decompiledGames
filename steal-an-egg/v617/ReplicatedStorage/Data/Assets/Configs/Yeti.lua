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
	_id = "Yeti",
	DisplayName = "Yeti",
	Icon = "rbxassetid://112918798684335",
	Egg = table.freeze({
		DisplayName = "Yeti Egg",
		Icon = "rbxassetid://109969559601816",
		GrowthTime = 6300,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 5000000,
	IndexSpeedReward = 25600,
	DropWeight = 0.14285714285714285,
	VisualOdds = 39176469.291,
	ModelWeight = 1500,
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
	GenderLocked = "Male",
	AlbinosColorFullWhite = nil
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://82636665685816"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://82636665685816 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://121460485550564"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://121460485550564 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Secret
v.BaseModelColor = Color3.new(0.6392157077789307, 0.6352941393852234, 0.6470588445663452)
v.PossibleModelColors = table.freeze({})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 105915818610159
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 94576444449255
})
return (table.freeze(v))