local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)

local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")

	if not pcall(function()
		animation.AnimationId = animationId
	end) then
		warn((`Animation {animationId} is not shared with this experience`))
	end

	return animation
end

local v = {
	_id = "Octophant",
	DisplayName = "Octophant",
	Icon = "rbxassetid://72515463861381",
	Egg = table.freeze({
		DisplayName = "Octophant Egg",
		Icon = "rbxassetid://121178065227483",
		ModelName = "Unstable",
		GrowthTime = 60,
		WeightKg = 1,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 4000000000,
	IndexSpeedReward = 0,
	DropWeight = 0,
	VisualOdds = 0,
	ModelWeight = 30000,
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
local animationId2 = "rbxassetid://102896021926478"

if not pcall(function()
	animation.AnimationId = animationId2
end) then
	warn("Animation rbxassetid://102896021926478 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://104990424155215"

if not pcall(function()
	animation2.AnimationId = animationId3
end) then
	warn("Animation rbxassetid://104990424155215 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Divine
v.BaseModelColor = Color3.fromRGB(227, 174, 248)
v.PossibleModelColors = table.freeze({ table.freeze({ Color3.fromRGB(227, 174, 248), 1 }) })
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 78592116085367
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 78730149034163
})
return (table.freeze(v))