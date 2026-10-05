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
	_id = "Whale Shark",
	DisplayName = "Whale Shark",
	Icon = "rbxassetid://133745688279874",
	Egg = table.freeze({
		DisplayName = "Whale Shark Egg",
		Icon = "rbxassetid://93013491848495",
		GrowthTime = 600,
		WeightKg = 6,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 700000,
	IndexSpeedReward = 108000,
	DropWeight = 0.25,
	VisualOdds = 14504941186.087273,
	ModelWeight = 2000,
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
local animationId2 = "rbxassetid://96079428169602"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://96079428169602 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://94460509562960"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://94460509562960 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Cosmic
v.BaseModelColor = Color3.new(0, 0.125490203499794, 0.3764705955982208)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0, 0.125490203499794, 0.3764705955982208), 680 }),
	table.freeze({ Color3.new(0.09803921729326248, 0.16862745583057404, 0.21176470816135406), 160 }),
	table.freeze({ Color3.new(0.14509804546833038, 0.16862745583057404, 0.1764705926179886), 110 }),
	table.freeze({ Color3.new(0.14901961386203766, 0.16078431904315948, 0.16078431904315948), 35 }),
	table.freeze({ Color3.new(0.09803921729326248, 0.13725490868091583, 0.1764705926179886), 15 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 76545999037742
})
return (table.freeze(v))