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
	_id = "Raccoon",
	DisplayName = "Raccoon",
	Icon = "rbxassetid://108876887480947",
	Egg = table.freeze({
		DisplayName = "Raccoon Egg",
		Icon = "rbxassetid://125284294936901",
		GrowthTime = 50,
		WeightKg = 1,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 45,
	IndexSpeedReward = 620,
	DropWeight = 0.16666666666666666,
	VisualOdds = 8.44701453885662,
	ModelWeight = 19,
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
	GenderLocked = nil,
	AlbinosColorFullWhite = nil
}
local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://110452042491667"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://110452042491667 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://134919972715929"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://134919972715929 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Rare
v.BaseModelColor = Color3.new(0.35686275362968445, 0.364705890417099, 0.4117647111415863)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.35686275362968445, 0.364705890417099, 0.4117647111415863), 760 }),
	table.freeze({ Color3.new(0.2549019753932953, 0.2549019753932953, 0.27450981736183167), 140 }),
	table.freeze({ Color3.new(0.5098039507865906, 0.4901960790157318, 0.45098039507865906), 70 }),
	table.freeze({ Color3.new(0.25882354378700256, 0.250980406999588, 0.250980406999588), 30 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 83241021513756
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 125958086678055
})
return (table.freeze(v))