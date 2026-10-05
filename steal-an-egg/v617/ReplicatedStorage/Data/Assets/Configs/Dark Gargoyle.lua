local LightDarkPlaceholder = require(script.Parent.Parent.LightDarkPlaceholder)
local clone = table.clone(LightDarkPlaceholder.FromTemplate("Shadow Dragon", {
	_id = "Dark Gargoyle",
	DisplayName = "Gargoyle",
	Rarity = "Secret",
	EarningRate = 225000000,
	IndexSpeedReward = 30000000,
	VisualOdds = 22.935779816513758
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
local animationId2 = "rbxassetid://116878464800621"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://116878464800621 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://72168860461322"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://72168860461322 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
local clone2 = table.clone(clone.Egg)
clone2.Icon = "rbxassetid://119732629571247"
clone2.GrowthTime = 10800
clone.Egg = table.freeze(clone2)
clone.Icon = "rbxassetid://99077940722686"
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 140567909859107
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 89807033480950
})
return table.freeze(clone)