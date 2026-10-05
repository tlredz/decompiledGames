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
	_id = "Spider",
	DisplayName = "Spider",
	Icon = "rbxassetid://132010793204072",
	Egg = table.freeze({
		DisplayName = "Spider Egg",
		Icon = "rbxassetid://85241307147394",
		GrowthTime = 270,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 22000,
	IndexSpeedReward = 12600,
	DropWeight = 0.16666666666666666,
	VisualOdds = 861882.324392,
	ModelWeight = 120,
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
local animationId2 = "rbxassetid://117459506499807"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://117459506499807 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://71117255441251"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://71117255441251 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Mythic
v.BaseModelColor = Color3.new(0.21568627655506134, 0.21960784494876862, 0.24313725531101227)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.21568627655506134, 0.21960784494876862, 0.24313725531101227), 520 }),
	table.freeze({ Color3.new(0.1764705926179886, 0.13725490868091583, 0.11764705926179886), 180 }),
	table.freeze({ Color3.new(0.3333333432674408, 0.27450981736183167, 0.1764705926179886), 130 }),
	table.freeze({ Color3.new(0.13725490868091583, 0.1764705926179886, 0.13725490868091583), 100 }),
	table.freeze({ Color3.new(0.5098039507865906, 0.37254902720451355, 0.1764705926179886), 50 }),
	table.freeze({ Color3.new(0.09803921729326248, 0.09803921729326248, 0.09803921729326248), 20 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 131115341364194
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 134280584978628
})
return (table.freeze(v))