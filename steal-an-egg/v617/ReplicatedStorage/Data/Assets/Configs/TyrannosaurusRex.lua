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
	_id = "TyrannosaurusRex",
	DisplayName = "TRex",
	Icon = "rbxassetid://123124934383954",
	Egg = table.freeze({
		DisplayName = "TRex Egg",
		Icon = "rbxassetid://124390268104324",
		GrowthTime = 9000,
		WeightKg = 5,
		HideRarity = nil,
		IgnoreSizeGrowthMultiplier = nil
	}),
	WhiteImage = nil,
	MutationIcons = nil,
	EarningRate = 25000000,
	IndexSpeedReward = 420000,
	DropWeight = 0.3333333333333333,
	VisualOdds = 134669113.186,
	ModelWeight = 7500,
	Animations = 0,
	WalkAnimationReferenceSpeed = 16,
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
local animationId2 = "rbxassetid://85804925095766"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://85804925095766 is not shared with this experience")
end

local v2 = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://117274313338090"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://117274313338090 is not shared with this experience")
end

v2.Walk = animation2
v.Animations = table.freeze(v2)
v.Rarity = Rarity.Rarities.Secret
v.BaseModelColor = Color3.new(0.4470588266849518, 0.47843137383461, 0.25882354378700256)
v.PossibleModelColors = table.freeze({
	table.freeze({ Color3.new(0.4470588266849518, 0.47843137383461, 0.25882354378700256), 470 }),
	table.freeze({ Color3.new(0.37254902720451355, 0.29411765933036804, 0.1764705926179886), 210 }),
	table.freeze({ Color3.new(0.27450981736183167, 0.37254902720451355, 0.21568627655506134), 140 }),
	table.freeze({ Color3.new(0.5686274766921997, 0.47058823704719543, 0.27450981736183167), 100 }),
	table.freeze({ Color3.new(0.4431372582912445, 0.40392157435417175, 0.33725491166114807), 60 }),
	table.freeze({ Color3.new(0.16862745583057404, 0.25882354378700256, 0.35686275362968445), 60 }),
	table.freeze({ Color3.new(0.6274510025978088, 0.27450981736183167, 0.1764705926179886), 20 }),
	table.freeze({ Color3.new(1, 1, 1), 10 })
})
v.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 114165406336338
})
v.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 81004933444699
})
return (table.freeze(v))