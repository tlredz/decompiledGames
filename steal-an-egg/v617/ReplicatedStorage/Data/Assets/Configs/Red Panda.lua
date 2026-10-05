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
	_id = "Red Panda",
	DisplayName = "Red Panda",
	Icon = "rbxassetid://87532519318091",
	Egg = table.freeze({
		DisplayName = "Red Panda Egg",
		Icon = "rbxassetid://119131393871771",
		GrowthTime = 480,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 450000,
	IndexSpeedReward = 3435120,
	DropWeight = 0,
	VisualOdds = 2500000000000,
	ModelWeight = 25,
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
	RandomIdleSound = nil,
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
local animationId2 = "rbxassetid://98137834403940"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://98137834403940 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://102540312255963"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://102540312255963 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Mythic
v.BaseModelColor = Color3.new(0.8392156958580017, 0.3843137323856354, 0.14901961386203766)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.8392156958580017, 0.3843137323856354, 0.14901961386203766), 850 }),
	table.freeze({ Color3.new(0.6274510025978088, 0.27450981736183167, 0.11764705926179886), 90 }),
	table.freeze({ Color3.new(0.8823529481887817, 0.5882353186607361, 0.3137255012989044), 48 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 80776140827842
})
return (table.freeze(v))