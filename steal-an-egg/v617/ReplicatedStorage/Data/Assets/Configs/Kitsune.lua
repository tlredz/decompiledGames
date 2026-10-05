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
	_id = "Kitsune",
	DisplayName = "Kitsune",
	Icon = "rbxassetid://107842067813602",
	Egg = table.freeze({
		DisplayName = "Kitsune Egg",
		Icon = "rbxassetid://136779412524244",
		GrowthTime = 50400,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 1800000000,
	IndexSpeedReward = 6870240,
	DropWeight = 0,
	VisualOdds = 168336000000000,
	ModelWeight = 260,
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
local animationId2 = "rbxassetid://120302895222735"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://120302895222735 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://128388967340982"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://128388967340982 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Divine
v.BaseModelColor = Color3.new(0.8705882430076599, 0.8274509906768799, 0.6549019813537598)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.8705882430076599, 0.8274509906768799, 0.6549019813537598), 850 }),
	table.freeze({ Color3.new(0.9215686321258545, 0.7843137383460999, 0.5490196347236633), 90 }),
	table.freeze({ Color3.new(0.7450980544090271, 0.7450980544090271, 0.7843137383460999), 48 }),
	table.freeze({ Color3.new(1, 1, 1), 12 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 130410188254836
})
return (table.freeze(v))