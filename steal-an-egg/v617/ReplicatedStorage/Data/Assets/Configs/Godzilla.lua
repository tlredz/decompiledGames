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
	_id = "Godzilla",
	DisplayName = "Nightflame",
	Icon = "rbxassetid://102979882140882",
	Egg = table.freeze({
		DisplayName = "Nightflame Egg",
		Icon = "rbxassetid://134762388111337",
		GrowthTime = 57600,
		WeightKg = 4,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 3000000000,
	IndexSpeedReward = 6870240,
	DropWeight = 0,
	VisualOdds = 168336000000000,
	ModelWeight = 160000,
	Animations = 0,
	WalkAnimationReferenceSpeed = nil,
	Rarity = 0,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	BaseModelColor = 0,
	PossibleModelColors = 0,
	PlaceSound = nil,
	WalkSound = nil,
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
local animationId2 = "rbxassetid://105030323854881"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://105030323854881 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://78608369871297"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://78608369871297 is not shared with this experience")
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
return (table.freeze(v))