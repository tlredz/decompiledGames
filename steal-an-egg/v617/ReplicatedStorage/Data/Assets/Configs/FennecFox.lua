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
	_id = "FennecFox",
	DisplayName = "Fennec",
	Icon = "rbxassetid://130204625520606",
	Egg = table.freeze({
		DisplayName = "Fennec Egg",
		Icon = "rbxassetid://104249034532190",
		GrowthTime = 30,
		WeightKg = 2,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 18,
	IndexSpeedReward = 8100,
	DropWeight = 0.5,
	VisualOdds = 7778.721339,
	ModelWeight = 8,
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
local animationId2 = "rbxassetid://97698541539837"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://97698541539837 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://87942495505255"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://87942495505255 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Uncommon
v.BaseModelColor = Color3.new(0.8392156958580017, 0.729411780834198, 0.5568627715110779)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.8392156958580017, 0.729411780834198, 0.5568627715110779), 780 }),
	table.freeze({ Color3.new(0.9215686321258545, 0.843137264251709, 0.686274528503418), 130 }),
	table.freeze({ Color3.new(0.7058823704719543, 0.529411792755127, 0.3137255012989044), 70 }),
	table.freeze({ Color3.new(1, 0.7333333492279053, 0.501960813999176), 20 }),
	table.freeze({ Color3.new(1, 1, 1), 15 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 100755799211418
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 139113514652602
})
return (table.freeze(v))