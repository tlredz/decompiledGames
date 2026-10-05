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
	_id = "Dream Axolotl",
	DisplayName = "Axolotl",
	Icon = "rbxassetid://129890708705568",
	Egg = table.freeze({
		DisplayName = "Axolotl Egg",
		Icon = "rbxassetid://82740814910149",
		GrowthTime = 300,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 2800,
	IndexSpeedReward = 4000,
	DropWeight = 0.16666666666666666,
	VisualOdds = 954.119769692145,
	ModelWeight = 28,
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
local animationId2 = "rbxassetid://82684368997608"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://82684368997608 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://102359721577452"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://102359721577452 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Legendary
v.BaseModelColor = Color3.new(0.20000000298023224, 0.3450980484485626, 0.5098039507865906)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.20000000298023224, 0.3450980484485626, 0.5098039507865906), 430 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.27450981736183167, 0.21568627655506134), 230 }),
	table.freeze({ Color3.new(0.9215686321258545, 0.8235294222831726, 0.47058823704719543), 150 }),
	table.freeze({ Color3.new(0.9607843160629272, 0.9607843160629272, 0.9019607901573181), 110 }),
	table.freeze({ Color3.new(0.1764705926179886, 0.1764705926179886, 0.1764705926179886), 60 }),
	table.freeze({ Color3.new(0.6274510025978088, 0.5098039507865906, 0.4117647111415863), 20 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 106266887076783
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 87233046266422
})
return (table.freeze(v))