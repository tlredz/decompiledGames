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
	_id = "Burrowing Owl",
	DisplayName = "Burrowing Owl",
	Icon = "rbxassetid://123516361239872",
	Egg = table.freeze({
		DisplayName = "Burrowing Owl Egg",
		Icon = "rbxassetid://122807946218302",
		GrowthTime = 40,
		WeightKg = 1,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 35,
	IndexSpeedReward = 560,
	DropWeight = 0.2,
	VisualOdds = 6.484806179286864,
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
local animationId2 = "rbxassetid://89419902709935"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://89419902709935 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://137489865198011"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://137489865198011 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Rare
v.BaseModelColor = Color3.new(0.3450980484485626, 0.2980392277240753, 0.2078431397676468)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.3450980484485626, 0.2980392277240753, 0.2078431397676468), 720 }),
	table.freeze({ Color3.new(0.4901960790157318, 0.4117647111415863, 0.27450981736183167), 170 }),
	table.freeze({ Color3.new(0.2549019753932953, 0.22745098173618317, 0.1764705926179886), 75 }),
	table.freeze({ Color3.new(0.47058823704719543, 0.4117647111415863, 0.29019609093666077), 35 }),
	table.freeze({ Color3.new(1, 1, 1), 15 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 99892403203037
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 87403836085353
})
return (table.freeze(v))