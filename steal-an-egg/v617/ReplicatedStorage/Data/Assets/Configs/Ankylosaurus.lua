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
	_id = "Ankylosaurus",
	DisplayName = "Ankylosaurus",
	Icon = "rbxassetid://71901208958017",
	Egg = table.freeze({
		DisplayName = "Ankylosaurus Egg",
		Icon = "rbxassetid://103179713771844",
		GrowthTime = 300,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 120000,
	IndexSpeedReward = 330000,
	DropWeight = 0.5,
	VisualOdds = 7778.721339,
	ModelWeight = 2500,
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
local animationId2 = "rbxassetid://71910623791893"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://71910623791893 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://115768568703296"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://115768568703296 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Mythic
v.BaseModelColor = Color3.new(0.3843137323856354, 0.3450980484485626, 0.364705890417099)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.3843137323856354, 0.3450980484485626, 0.364705890417099), 450 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.3137255012989044, 0.23529411852359772), 210 }),
	table.freeze({ Color3.new(0.3137255012989044, 0.37254902720451355, 0.2549019753932953), 150 }),
	table.freeze({ Color3.new(0.5098039507865906, 0.45098039507865906, 0.3529411852359772), 120 }),
	table.freeze({ Color3.new(0.21568627655506134, 0.21568627655506134, 0.21568627655506134), 70 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 129507085485558
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 73050793707525
})
return (table.freeze(v))