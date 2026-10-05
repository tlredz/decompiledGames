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
	_id = "Pterodactyl",
	DisplayName = "Pterodactyl",
	Icon = "rbxassetid://92643140066500",
	Egg = table.freeze({
		DisplayName = "Pterodactyl Egg",
		Icon = "rbxassetid://88209726148785",
		GrowthTime = 180,
		WeightKg = 3,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 22000,
	IndexSpeedReward = 270000,
	DropWeight = 0.5,
	VisualOdds = 215470.581098,
	ModelWeight = 180,
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
local animationId2 = "rbxassetid://139638551129821"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://139638551129821 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://92715712978388"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://92715712978388 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Legendary
v.BaseModelColor = Color3.new(0.33725491166114807, 0.3137255012989044, 0.30588236451148987)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.33725491166114807, 0.3137255012989044, 0.30588236451148987), 520 }),
	table.freeze({ Color3.new(0.47058823704719543, 0.37254902720451355, 0.2549019753932953), 180 }),
	table.freeze({ Color3.new(0.5882353186607361, 0.5098039507865906, 0.37254902720451355), 130 }),
	table.freeze({ Color3.new(0.21568627655506134, 0.21568627655506134, 0.23529411852359772), 100 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.4117647111415863, 0.45098039507865906), 70 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 137006206175690
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 106521441079177
})
return (table.freeze(v))