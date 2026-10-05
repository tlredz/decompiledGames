local LightDarkPlaceholder = require(script.Parent.Parent.LightDarkPlaceholder)
local clone = table.clone(LightDarkPlaceholder.FromTemplate("Demon Imp", {
	_id = "Flame Sprite",
	DisplayName = "Flame Sprite",
	Rarity = "Legendary",
	EarningRate = 225000,
	IndexSpeedReward = 3000000,
	VisualOdds = 2.6659557451346307
}))

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

local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://102483784314308"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://102483784314308 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://98424320124914"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://98424320124914 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
clone.Icon = "rbxassetid://84084008364875"
local clone2 = table.clone(clone.Egg)
clone2.Icon = "rbxassetid://120917483549782"
clone2.GrowthTime = 300
clone.Egg = table.freeze(clone2)
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 95027260926731
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 77020164781939
})
return table.freeze(clone)