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
	_id = "Duckling",
	DisplayName = "Duckling",
	Icon = "rbxassetid://81116137079823",
	Egg = table.freeze({
		DisplayName = "Duckling Egg",
		Icon = "rbxassetid://120651022174989",
		GrowthTime = 20,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 4,
	IndexSpeedReward = 2250,
	DropWeight = 0,
	VisualOdds = 190,
	ModelWeight = 3,
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
local animationId2 = "rbxassetid://118496144381000"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://118496144381000 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://121924503798489"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://121924503798489 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Common
v.BaseModelColor = Color3.new(0.5098039507865906, 0.4941176474094391, 0.32156863808631897)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.5098039507865906, 0.4941176474094391, 0.32156863808631897), 360 }),
	table.freeze({ Color3.new(1, 0.7921568751335144, 0.47843137383461), 480 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.29411765933036804, 0.1764705926179886), 80 }),
	table.freeze({ Color3.new(0.9607843160629272, 0.9215686321258545, 0.7058823704719543), 60 }),
	table.freeze({ Color3.new(0.23529411852359772, 0.21568627655506134, 0.1764705926179886), 20 }),
	table.freeze({ Color3.new(1, 1, 1), 20 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.9
	}),
	SoundId = 108170229428604
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 99745906196706
})
return (table.freeze(v))