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
	_id = "Rhinobear",
	DisplayName = "Rhinobear",
	Icon = "rbxassetid://129250605173124",
	Egg = table.freeze({
		DisplayName = "Rhinobear Egg",
		Icon = "rbxassetid://121178065227483",
		ModelName = "Unstable",
		GrowthTime = 60,
		WeightKg = 1,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 1000000000,
	IndexSpeedReward = 0,
	DropWeight = 0,
	VisualOdds = 0,
	ModelWeight = 20000,
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
local animationId2 = "rbxassetid://120649405734325"

if not pcall(function()
	animation.AnimationId = animationId2
end) then
	warn("Animation rbxassetid://120649405734325 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://78295402076410"

if not pcall(function()
	animation2.AnimationId = animationId3
end) then
	warn("Animation rbxassetid://78295402076410 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Eternal
v.BaseModelColor = Color3.fromRGB(234, 203, 144)
v.PossibleModelColors = table.freeze({ table.freeze({ Color3.fromRGB(234, 203, 144), 1 }) })
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 90060394622485
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 104589623511260
})
return (table.freeze(v))