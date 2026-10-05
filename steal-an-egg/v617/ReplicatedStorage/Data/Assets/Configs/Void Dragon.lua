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
	_id = "Void Dragon",
	DisplayName = "Void Dragon",
	Icon = "rbxassetid://140262099495529",
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
	EarningRate = 120000000,
	IndexSpeedReward = 40000,
	DropWeight = 0,
	VisualOdds = 5000,
	ModelWeight = 12000,
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
local animationId2 = "rbxassetid://137162488295849"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://137162488295849 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://115568355078468"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://115568355078468 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Eternal
v.BaseModelColor = Color3.new(0.19607843458652496, 0.1568627506494522, 0.27450981736183167)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.19607843458652496, 0.1568627506494522, 0.27450981736183167), 700 }),
	table.freeze({ Color3.new(0.35686275362968445, 0.239215686917305, 0.4588235318660736), 180 }),
	table.freeze({ Color3.new(0.5490196347236633, 0.35686275362968445, 0.6235294342041016), 108 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 0.97,
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