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
	_id = "Ascended Vermilion Phoenix",
	DisplayName = "Phoenix",
	Icon = "rbxassetid://118067990008425",
	Egg = table.freeze({
		DisplayName = "Phoenix Egg",
		Icon = "rbxassetid://108172622989366",
		GrowthTime = 16200,
		WeightKg = 5,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 85000000,
	IndexSpeedReward = 48000,
	DropWeight = 0.1111111111111111,
	VisualOdds = 1077352905.49,
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
local animationId2 = "rbxassetid://85057156715276"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://85057156715276 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://104273848115084"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://104273848115084 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Eternal
v.BaseModelColor = Color3.new(0.6392157077789307, 0.33725491166114807, 0.16470588743686676)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.6392157077789307, 0.33725491166114807, 0.16470588743686676), 440 }),
	table.freeze({ Color3.new(1, 0.48235294222831726, 0.18431372940540314), 210 }),
	table.freeze({ Color3.new(0.5098039507865906, 0.2549019753932953, 0.10588235408067703), 150 }),
	table.freeze({ Color3.new(0.7176470756530762, 0.30588236451148987, 0.07058823853731155), 120 }),
	table.freeze({ Color3.new(1, 0, 0), 80 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 74222673189312
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 78009543684733
})
return (table.freeze(v))