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
	_id = "Mecha Scrambler",
	DisplayName = "Mecha Scrambler",
	Icon = "rbxassetid://92101779058721",
	Egg = table.freeze({
		DisplayName = "Mecha Scrambler Egg",
		Icon = "rbxassetid://121178065227483",
		GrowthTime = 60,
		WeightKg = 1,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 7500000000,
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
	WalkSound = nil,
	RandomIdleSound = nil,
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
local animationId2 = "rbxassetid://120484795823977"

if not pcall(function()
	animation.AnimationId = animationId2
end) then
	warn("Animation rbxassetid://120484795823977 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://107270328959157"

if not pcall(function()
	animation2.AnimationId = animationId3
end) then
	warn("Animation rbxassetid://107270328959157 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Divine
v.BaseModelColor = Color3.fromRGB(81, 226, 36)
v.PossibleModelColors = table.freeze({ table.freeze({ Color3.fromRGB(81, 226, 36), 1 }) })
return (table.freeze(v))