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
	_id = "Baby Aurora Dragon",
	DisplayName = "Baby Aurora Dragon",
	Icon = "rbxassetid://93373306453881",
	Egg = table.freeze({
		DisplayName = "Dragon Egg",
		Icon = "rbxassetid://124581147164560",
		GrowthTime = 60,
		WeightKg = 5,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 5000000,
	IndexSpeedReward = 10000,
	DropWeight = 0,
	VisualOdds = 100,
	ModelWeight = 8000,
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
	DontRoll = true,
	CannotFuse = nil,
	GenderLocked = nil,
	AlbinosColorFullWhite = nil
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://94341479254631"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://94341479254631 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://133547081058201"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://133547081058201 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Legendary
v.BaseModelColor = Color3.new(0.9137254953384399, 0.8549019694328308, 0.8549019694328308)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.9137254953384399, 0.8549019694328308, 0.8549019694328308), 700 }),
	table.freeze({ Color3.new(0.5882353186607361, 0.615686297416687, 0.8588235378265381), 180 }),
	table.freeze({ Color3.new(1, 0.48235294222831726, 0.4901960790157318), 108 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1.12,
		Volume = 1.5
	}),
	SoundId = 95640392463828
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 30,
		Volume = 1.5
	}),
	SoundId = 99984406249141
})
return (table.freeze(v))