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
	_id = "Swordfish",
	DisplayName = "Swordfish",
	Icon = "rbxassetid://103426699196063",
	Egg = table.freeze({
		DisplayName = "Swordfish Egg",
		Icon = "rbxassetid://108314641239947",
		GrowthTime = 120,
		WeightKg = 6,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 1100,
	IndexSpeedReward = 81000,
	DropWeight = 0.5,
	VisualOdds = 4910446705.478001,
	ModelWeight = 250,
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
local animationId2 = "rbxassetid://79570633151364"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://79570633151364 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://103930506176496"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://103930506176496 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Epic
v.BaseModelColor = Color3.new(0.22745098173618317, 0.2980392277240753, 0.38823530077934265)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.22745098173618317, 0.2980392277240753, 0.38823530077934265), 650 }),
	table.freeze({ Color3.new(0.4313725531101227, 0.572549045085907, 0.7098039388656616), 170 }),
	table.freeze({ Color3.new(0.13725490868091583, 0.21568627655506134, 0.3333333432674408), 120 }),
	table.freeze({ Color3.new(0.09803921729326248, 0.13725490868091583, 0.21568627655506134), 15 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 96287155757786
})
return (table.freeze(v))