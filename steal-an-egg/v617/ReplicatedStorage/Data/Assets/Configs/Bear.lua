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
	_id = "Bear",
	DisplayName = "Bear",
	Icon = "rbxassetid://99309954423391",
	Egg = table.freeze({
		DisplayName = "Bear Egg",
		Icon = "rbxassetid://75135783493246",
		GrowthTime = 120,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 240,
	IndexSpeedReward = 820,
	DropWeight = 0.3333333333333333,
	VisualOdds = 56.702784,
	ModelWeight = 220,
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
local animationId2 = "rbxassetid://117105848139359"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://117105848139359 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://112971811958973"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://112971811958973 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Epic
v.BaseModelColor = Color3.new(0.32549020648002625, 0.23529411852359772, 0.125490203499794)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.32549020648002625, 0.23529411852359772, 0.125490203499794), 640 }),
	table.freeze({ Color3.new(0.1764705926179886, 0.14901961386203766, 0.125490203499794), 180 }),
	table.freeze({ Color3.new(0.364705890417099, 0.26274511218070984, 0.1725490242242813), 120 }),
	table.freeze({ Color3.new(0.8235294222831726, 0.7450980544090271, 0.5882353186607361), 45 }),
	table.freeze({ Color3.new(0.9215686321258545, 0.9019607901573181, 0.843137264251709), 15 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 84881266793081
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 88584063816692
})
return (table.freeze(v))