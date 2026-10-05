local LightDarkPlaceholder = require(script.Parent.Parent.LightDarkPlaceholder)
local clone = table.clone(LightDarkPlaceholder.FromTemplate("Swan", {
	_id = "Dove",
	DisplayName = "Light Dove",
	Rarity = "Legendary",
	EarningRate = 225000,
	IndexSpeedReward = 3000000,
	VisualOdds = 2.6659557451346307
}))
clone.ModelWeight = 45000

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
local animationId2 = "rbxassetid://87026407917685"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://87026407917685 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://88155121013841"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://88155121013841 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
clone.Icon = "rbxassetid://71242072766450"
local clone2 = table.clone(clone.Egg)
clone2.Icon = "rbxassetid://104459545767438"
clone2.GrowthTime = 300
clone.Egg = table.freeze(clone2)
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 128632172954714
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 118323451396721
})
return table.freeze(clone)