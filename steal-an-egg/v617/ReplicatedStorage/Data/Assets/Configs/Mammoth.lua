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
	_id = "Mammoth",
	DisplayName = "Mammoth",
	Icon = "rbxassetid://127045436214447",
	Egg = table.freeze({
		DisplayName = "Mammoth Egg",
		Icon = "rbxassetid://99020285854980",
		GrowthTime = 300,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 42000,
	IndexSpeedReward = 19200,
	DropWeight = 0,
	VisualOdds = 12000000,
	ModelWeight = 2000,
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
local animationId2 = "rbxassetid://96559517682950"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://96559517682950 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://71037817684116"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://71037817684116 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Mythic
v.BaseModelColor = Color3.new(0.20392157137393951, 0.13333334028720856, 0.09019608050584793)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.20392157137393951, 0.13333334028720856, 0.09019608050584793), 620 }),
	table.freeze({ Color3.new(0.3529411852359772, 0.23529411852359772, 0.13725490868091583), 210 }),
	table.freeze({ Color3.new(0.529411792755127, 0.37254902720451355, 0.21568627655506134), 120 }),
	table.freeze({ Color3.new(0.7450980544090271, 0.6470588445663452, 0.4901960790157318), 40 }),
	table.freeze({ Color3.new(0.10980392247438431, 0.09803921729326248, 0.08627451211214066), 10 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 87980387017956
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 98423116392516
})
return (table.freeze(v))