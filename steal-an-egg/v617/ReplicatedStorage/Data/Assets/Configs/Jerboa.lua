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
	_id = "Jerboa",
	DisplayName = "Jerboa",
	Icon = "rbxassetid://139650837807677",
	Egg = table.freeze({
		DisplayName = "Jerboa Egg",
		Icon = "rbxassetid://116318646770786",
		GrowthTime = 20,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 6,
	IndexSpeedReward = 7200,
	DropWeight = 0.1,
	VisualOdds = 4275.209942,
	ModelWeight = 2,
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
local animationId2 = "rbxassetid://119512588879927"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://119512588879927 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://110008586319221"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://110008586319221 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Common
v.BaseModelColor = Color3.new(0.8274509906768799, 0.7450980544090271, 0.5882353186607361)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.8392156958580017, 0.729411780834198, 0.5568627715110779), 760 }),
	table.freeze({ Color3.new(0.7254902124404907, 0.5882353186607361, 0.37254902720451355), 145 }),
	table.freeze({ Color3.new(0.9215686321258545, 0.843137264251709, 0.686274528503418), 70 }),
	table.freeze({ Color3.new(0.8588235378265381, 0.6352941393852234, 0.4117647111415863), 25 }),
	table.freeze({ Color3.new(1, 1, 1), 15 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 100593786623130
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 133440437999035
})
return (table.freeze(v))